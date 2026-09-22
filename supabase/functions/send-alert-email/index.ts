import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// V3L HomeWizard - stuurt e-mailalerts (overbelasting / Supabase-opslaglimiet)
// via EmailJS. De EmailJS-gegevens (Service ID, Template ID, Public Key, en de
// Private Key voor "strict mode"/server-naar-server-verzoeken) staan hier als
// server-side secrets (Supabase Edge Function secrets) en worden NOOIT naar de
// browser gestuurd - alleen het dashboard-e-mailadres en de meetwaarden gaan
// over en weer.
//
// Sinds het dashboard een echte inlog heeft (Supabase Auth), staat verify_jwt
// aan: Supabase controleert zelf het meegestuurde Authorization: Bearer-token
// (het sessie-token van de ingelogde gebruiker) voordat deze functie wordt
// aangeroepen. De handmatige apikey-check hieronder blijft als extra laag.
//
// Vereiste secrets (instellen via Supabase-dashboard: Edge Functions ->
// send-alert-email -> Secrets, of via de Supabase CLI):
//   EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, EMAILJS_PUBLIC_KEY, EMAILJS_PRIVATE_KEY          (overbelasting)
//   STORAGE_EMAILJS_SERVICE_ID, STORAGE_EMAILJS_TEMPLATE_ID, STORAGE_EMAILJS_PUBLIC_KEY, STORAGE_EMAILJS_PRIVATE_KEY (opslaglimiet)
// EMAILJS_PRIVATE_KEY/STORAGE_EMAILJS_PRIVATE_KEY zijn alleen verplicht als het
// EmailJS-account "strict mode" gebruikt (Account -> Security). Zonder strict
// mode werkt de functie ook zonder deze secrets.
//
// Na een geslaagde verzending wordt er een regel weggeschreven in de tabel
// public.email_send_log, zodat het dashboard kan tonen hoeveel verzendingen
// er deze maand nog over zijn t.o.v. de EmailJS-maandlimiet. Dit gebruikt de
// automatisch beschikbare service-role-sleutel (SUPABASE_SERVICE_ROLE_KEY),
// die nooit naar de browser gaat en RLS omzeilt.
//
// De eerder toegevoegde ntfy.sh-pushmelding is weer verwijderd: het gratis
// publieke ntfy.sh-topic bleek een gedeelde dagelijkse verzendlimiet te
// hebben die door het testen al bereikt was (HTTP 429 "daily message quota
// reached"), en dat maakt zo'n gratis gedeelde dienst sowieso ongeschikt als
// betrouwbaar kanaal voor een tijdkritische waarschuwing. Alleen e-mail dus.
//
// Wordt sinds Home Assistant-automatisering "Overbelasting melding" (zie
// ../../../home-assistant/automations/overbelasting-melding.yaml) ook
// rechtstreeks door Home Assistant aangeroepen, met dezelfde payload-vorm
// als de app gebruikt.

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

// Lichte extra controle i.p.v. echte geheimhouding (die sleutel is bewust
// openbaar): voorkomt dat de functie volledig los van het project aangeroepen
// wordt. De echte toegangscontrole is nu verify_jwt (zie boven).
const EXPECTED_API_KEY = Deno.env.get('DASHBOARD_API_KEY') ?? '';

// Automatisch beschikbaar binnen elke Supabase Edge Function - geen aparte
// secret-configuratie nodig voor het wegschrijven van de verzendteller.
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS_HEADERS }
  });
}

async function logSend(kind: string) {
  if (!SUPABASE_URL || !SERVICE_ROLE_KEY) return;
  try {
    await fetch(SUPABASE_URL + '/rest/v1/email_send_log', {
      method: 'POST',
      headers: {
        'apikey': SERVICE_ROLE_KEY,
        'Authorization': 'Bearer ' + SERVICE_ROLE_KEY,
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
      },
      body: JSON.stringify({ kind })
    });
  } catch {
    // Het bijhouden van de teller mag de e-mailverzending zelf nooit blokkeren.
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }
  if (req.method !== 'POST') {
    return json({ error: 'Methode niet toegestaan' }, 405);
  }

  const providedKey = req.headers.get('apikey') || '';
  if (EXPECTED_API_KEY && providedKey !== EXPECTED_API_KEY) {
    return json({ error: 'Ongeldige of ontbrekende apikey-header' }, 401);
  }

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Ongeldige JSON' }, 400);
  }

  const kind = body.kind === 'storage' ? 'storage' : 'overload';
  const to_email = typeof body.to_email === 'string' ? body.to_email.trim() : '';
  const phase = typeof body.phase === 'string' ? body.phase : '';
  const watt = body.watt;
  const threshold = body.threshold;
  const time = typeof body.time === 'string' ? body.time : '';

  if (!to_email || !phase || watt === undefined || threshold === undefined || !time) {
    return json({ error: 'Ontbrekende velden (to_email, phase, watt, threshold, time zijn verplicht)' }, 400);
  }

  const serviceId = kind === 'storage' ? Deno.env.get('STORAGE_EMAILJS_SERVICE_ID') : Deno.env.get('EMAILJS_SERVICE_ID');
  const templateId = kind === 'storage' ? Deno.env.get('STORAGE_EMAILJS_TEMPLATE_ID') : Deno.env.get('EMAILJS_TEMPLATE_ID');
  const publicKey = kind === 'storage' ? Deno.env.get('STORAGE_EMAILJS_PUBLIC_KEY') : Deno.env.get('EMAILJS_PUBLIC_KEY');
  const privateKey = kind === 'storage' ? Deno.env.get('STORAGE_EMAILJS_PRIVATE_KEY') : Deno.env.get('EMAILJS_PRIVATE_KEY');

  if (!serviceId || !templateId || !publicKey) {
    return json({ error: 'E-mailinstellingen zijn nog niet geconfigureerd op de server (Supabase Edge Function secrets ontbreken).' }, 500);
  }

  try {
    const payload: Record<string, unknown> = {
      service_id: serviceId,
      template_id: templateId,
      user_id: publicKey,
      template_params: { to_email, phase, watt, threshold, time }
    };
    if (privateKey) {
      payload.accessToken = privateKey;
    }
    const res = await fetch('https://api.emailjs.com/api/v1.0/email/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) {
      const detail = await res.text().catch(() => '');
      return json({ error: 'EmailJS-fout: HTTP ' + res.status + (detail ? ' - ' + detail : '') }, 502);
    }
    await logSend(kind);
    return json({ ok: true });
  } catch (err) {
    return json({ error: String(err) }, 500);
  }
});
