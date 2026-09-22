# V3L EnergyControl / V3L HomeWizard

Eigen Android-app (Capacitor/WebView) voor een HomeWizard P1-meter, met
Supabase als backend en Home Assistant als bron voor tarieven, kosten,
storingslogboek en overbelastingswaarschuwingen. Oorspronkelijk een
gerepackte versie van de V3L EnergyControl-app (`nl.v3l.homewizardclient`)
met automatische login toegevoegd; sindsdien flink uitgebreid.

## Structuur

- `app/` - de webinhoud van de APK (`index.html`), met de changelog van de
  huidige versie
- `supabase/` - het databaseschema (tabellen, RLS-policies, functies) en de
  Edge Function `send-alert-email`, als documentatie-/herstelkopie van wat
  in het Supabase-project staat
- `home-assistant/` - een leesbare kopie van het `rest_command`-blok uit
  `configuration.yaml` en de automatiseringen die met Supabase praten

Home Assistant en Supabase zelf blijven de bron van waarheid voor de
live-configuratie. Dit is geen deploy-pipeline: wijzigingen maak je in
Home Assistant/Supabase, en je werkt de bestanden hier handmatig bij zodat
er een leesbare, doorzoekbare kopie van bestaat.

## Hoe de onderdelen samenhangen

**De app** (`app/index.html`) praat rechtstreeks met de P1-meter als hij op
hetzelfde netwerk zit, en valt anders terug op Supabase
(`latest_status`/`get_daily_totals`/`daily_cost`). Tarieven zijn
alleen-lezen in de app; de vaste overbelastingsdrempel staat op 5250 W.
Sinds versie 3.67 doet de app zelf geen overbelastingsmail of
storingslogboek meer - dat is uitsluitend Home Assistant, om dubbele
meldingen te voorkomen.

**Home Assistant** leest de P1-meter (HomeWizard-integratie) en:
- pusht de live meterstand elke seconde naar `latest_status`
- pusht elke minuut een momentopname naar `minute_log`
- werkt elke minuut de dagkosten in `daily_cost` bij (functie
  `ha_update_daily_cost`)
- zet de tarieven (helpers `input_number.stroomprijs`/`gasprijs`) door naar
  `app_settings`
- maakt elke nacht om 00:00:05 de daily_cost-rij van de nieuwe dag aan
- mailt bij een fase boven 5250 W, en logt storingstellers in `fault_log`

Alle Home Assistant → Supabase-verzoeken loggen in met hetzelfde vaste
dashboardaccount (`supabase_login`) en gebruiken het teruggekregen token als
Bearer-header.

**Supabase** (project `sdkzzjrtmtzfvjrgpqbm`, "V3L HomeWizard") is de
gedeelde database. RLS staat overal aan; de rol `authenticated` (het vaste
dashboardaccount) mag lezen/schrijven, `anon` niets. De Edge Function
`send-alert-email` verstuurt de waarschuwingsmails via EmailJS, met de
EmailJS-sleutels als server-side secrets.

## Een nieuwe APK bouwen

Er is geen geautomatiseerd buildscript in deze repository; de APK is tot nu
toe telkens handmatig gerepackt:

1. Pas `app/index.html` aan en verhoog `APP_VERSION`/`APP_UPDATED`.
2. Pak een eerdere, werkende APK uit (zip), vervang
   `assets/public/index.html`, en verwijder de oude
   handtekeningbestanden (`META-INF/*.SF`, `*.RSA`/`*.DSA`/`*.EC`,
   `MANIFEST.MF`).
3. Zip de APK opnieuw met dezelfde compressiemethoden.
4. Zipalign en onderteken met `uber-apk-signer`
   (https://github.com/patrickfav/uber-apk-signer), met een debug-keystore
   zodat de handtekening gelijk blijft aan eerdere builds - anders moet de
   vorige versie eerst van het toestel verwijderd worden voor installatie.

## Bekende openstaande punten

- De trigger van automatisering "P1-meter naar Supabase pushen" is niet
  herbevestigd in dit project (zie
  `home-assistant/automations/p1-meter-naar-supabase-pushen.yaml`).
- `field_locks`, `email_settings` en `photo_meta` zijn in het schema
  gedocumenteerd maar hun huidige gebruik in de app is niet opnieuw
  doorgelicht.
- Er is geen geautomatiseerde build/CI voor de APK; het bouwproces hierboven
  is nog handwerk.
