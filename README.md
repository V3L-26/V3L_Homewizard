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

**Overbelastingsbeveiliging airco's (fase 3):** drie onafhankelijke
automatiseringen - één per Daikin-airco - zetten hun eigen unit uit zodra
`sensor.p1_meter_vermogen_fase_3` boven 5200 W komt:
- `airco-woonkamer-uit-bij-overbelasting-fase3.yaml` (getest en werkend)
- `airco-christian-uit-bij-overbelasting-fase3.yaml` (slaapkamer Christian,
  zelfde patroon, nog niet los getest)
- `airco-jason-uit-bij-overbelasting-fase3.yaml` (slaapkamer Jason, zelfde
  patroon, nog niet los getest)

Elke automatisering drukt eerst op de refresh-knop van zijn eigen
Daikin-unit en wacht (met een timeout van 30 seconden als vangnet) tot de
status daadwerkelijk ververst is, voordat het uit-commando
(`climate.set_hvac_mode`, `hvac_mode: 'off'`) wordt verstuurd - nodig
omdat de Daikin Onecta-cloudintegratie het commando anders op verouderde
gegevens lijkt te baseren. Door elke airco zijn eigen automatisering te
geven (in plaats van één gecombineerde), houdt een trage of al-uitstaande
unit de andere twee niet op.

Er is geen automatisch herstel meer na afloop van de overbelasting; de
airco's worden handmatig weer aangezet zodra dat weer veilig is. De
eerdere hervat-automatisering en de helper
`input_text.airco_overload_uitgezet` zijn hiermee vervallen. Alle drie de
automatiseringen sturen een pushmelding via `notify.samsung_s23`.

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

- Uitbreiding van de overbelastingsbeveiliging naar meer apparaten
  (droger, wasmachine, magnetron, airfryer, koffiezetapparaat) en het
  verplaatsen van de airco naar fase 1 staat in de planningsfase - zie
  `home-assistant/planning/overbelasting-uitbreiding.md` voor de volledige
  analyse, gemaakte keuzes en openstaande vragen.
- De Christian- en Jason-automatiseringen volgen hetzelfde patroon als de
  geteste woonkamer-versie, maar zijn zelf nog niet individueel getest.
- De trigger van automatisering "P1-meter naar Supabase pushen" is niet
  herbevestigd in dit project (zie
  `home-assistant/automations/p1-meter-naar-supabase-pushen.yaml`).
- `field_locks`, `email_settings` en `photo_meta` zijn in het schema
  gedocumenteerd maar hun huidige gebruik in de app is niet opnieuw
  doorgelicht.
- Er is geen geautomatiseerde build/CI voor de APK; het bouwproces hierboven
  is nog handwerk.
