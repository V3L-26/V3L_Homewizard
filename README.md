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
  zelfde patroon; de uitschakel-actie zelf is inmiddels bevestigd te
  werken, zie het incident hieronder)
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

**Incident (25 september 2026): verkeerde trigger-sensor.** Christians
airco schakelde onterecht uit bij een totaal huisverbruik van 5699 W,
terwijl fase 3 op dat moment maar ~4000 W trok. Onderzoek (Home
Assistant-trace + `minute_log` in Supabase) wees uit dat de trigger van
alle drie de live automatiseringen in Home Assistant per ongeluk stond
ingesteld op `sensor.p1_meter_vermogen` (het totale vermogen over alle
fasen samen) in plaats van op `sensor.p1_meter_vermogen_fase_3` -
waarschijnlijk ontstaan doordat de drie automatiseringen ooit van elkaar
zijn gedupliceerd zonder de trigger-entiteit opnieuw te controleren. Bij
een drempel van 5200 W is dat een groot verschil: 5200 W op één fase is
een reëel overbelastingsrisico, maar 5200 W totaal over drie fasen is
gewoon normaal huishoudelijk gebruik. De repo-bestanden documenteerden
altijd al de juiste sensor (`sensor.p1_meter_vermogen_fase_3`); dit was
puur een afwijking in de live HA-configuratie, en is daar gecorrigeerd.
Les voor volgende keer: bij het dupliceren van een automatisering altijd
de trigger-entiteit expliciet controleren, niet aannemen dat die
correct meekopieert.

**Nachtblokkade airco's (geen airco tussen 23:00 en 06:00):** losstaand
van de overbelastingsbeveiliging - expliciete wens dat er 's nachts nooit
airco aanstaat, afdwingbaar zonder dat gebruikers met toegang tot de
gedeelde V3L-app dit zelf kunnen uitschakelen. Bewust in Home Assistant
gebouwd in plaats van de planningsfunctie in de Daikin Onecta-app of de
V3L-app zelf. Bestaat uit twee lagen, elk weer als drie losse
automatiseringen (één per unit):

1. Om 23:00 zet een vaste automatisering per unit de airco uit:
   `airco-woonkamer-uit-om-23-00.yaml`, `airco-christian-uit-om-23-00.yaml`,
   `airco-jason-uit-om-23-00.yaml`.
2. Tussen 23:00 en 06:00 controleert een tweede automatisering per unit
   elke 2 minuten (`time_pattern`) of de airco (opnieuw) handmatig is
   aangezet, en zet 'm dan weer uit: `airco-woonkamer-geblokkeerd-nacht.yaml`,
   `airco-christian-geblokkeerd-nacht.yaml`,
   `airco-jason-geblokkeerd-nacht.yaml`. Deze checkt eerst goedkoop (zonder
   Daikin-aanroep) de al bekende status in Home Assistant, en spreekt het
   Daikin-quotum pas aan wanneer de airco daadwerkelijk aanstaat.

De eerste versie van laag 2 gebruikte een state-trigger op de
climate-entiteit; die bleek op elke attribuutwijziging te vuren (ook een
kale temperatuurupdate), niet alleen op een echte aan/uit-wisseling, wat
tot verwarrende/valse trace-resultaten leidde. Vervangen door het huidige
polling-ontwerp. Beide lagen gebruiken hetzelfde refresh +
wait_template-patroon als de overbelastingsautomatiseringen. Getest in de
nacht van 24 op 25 september 2026: woonkamer en Jason vingen een
handmatige aan-actie succesvol af; Christian had die nacht geen aan-moment
om te testen.

Onderzocht en niet haalbaar gebleken: "Econo mode" van een Daikin-unit
vastzetten zodat gebruikers die zelf niet kunnen uitzetten. Econo mode is
niet beschikbaar via Home Assistant, niet via de Daikin Onecta-cloud-API
(bevestigd via een issue in de daikin_onecta-integratie op GitHub), en de
Daikin EKRHH Modbus-hub biedt voor Air2Air-units (split-airco's) alleen
Smart Grid-/vermogenslimietregisters, geen Econo-regeling - en vereist
zelf ook nog internet/Onecta-verbinding. Daikin ondersteunt bovendien geen
meerdere accounts met verschillende rechten per unit (bevestigd via de
officiële Daikin-FAQ), dus er is geen manier om te beperken wat een
gebruiker van het gedeelde Onecta-account kan wijzigen.

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
- Na het herstellen van het trigger-sensor-incident (zie hierboven) zijn de
  drie overbelastings-automatiseringen nog niet opnieuw end-to-end getest
  met de juiste sensor (`sensor.p1_meter_vermogen_fase_3`).
- De nachtblokkade-polling (elke 2 minuten, 23:00-06:00) is pas één nacht
  getest; bij problemen eerst de Traces in Home Assistant bekijken (elke
  poll levert een trace op, ook als er niets te doen was - alleen een
  daadwerkelijke uitschakeling werkt "laatst uitgevoerd" bij in het
  automatiseringsoverzicht).
- De trigger van automatisering "P1-meter naar Supabase pushen" is niet
  herbevestigd in dit project (zie
  `home-assistant/automations/p1-meter-naar-supabase-pushen.yaml`).
- `field_locks`, `email_settings` en `photo_meta` zijn in het schema
  gedocumenteerd maar hun huidige gebruik in de app is niet opnieuw
  doorgelicht.
- Er is geen geautomatiseerde build/CI voor de APK; het bouwproces hierboven
  is nog handwerk.
