# Changelog - app/index.html

Volledige changelog staat ook in de app zelf (pagina "Versie"). Dit is een
overzicht op hoofdlijnen van wat er in dit project is gewijzigd.

## 3.70
De overbelastingsgrens en de tarieven (stroom/gas) zijn nu instelbaar in de
app zelf, in plaats van vast ingesteld in Home Assistant. Een wijziging
wordt via `app_settings` in Supabase gedeeld; Home Assistant haalt de
waarden nu op (nieuwe automatisering
`home-assistant/automations/instellingen-uit-supabase.yaml`) in plaats van
ze te versturen - de oude `prijzen-naar-supabase.yaml` is daarmee vervallen.

Vereist een nieuwe HA-helper `input_number.p1_overload_w` (min 4000, max
5750, step 50, eenheid W) - zie de opmerkingen bovenaan de nieuwe
automatisering voor de precieze stappen. De 7 overbelastings-
automatiseringen (mail + airco's + fase1/2/3) zijn aangepast om deze helper
te lezen in plaats van de vaste waarde 5000.

## 3.69
Overbelastingsgrens verlaagd van 5250 W naar 5000 W per fase, gelijk aan de
nieuwe drempel in Home Assistant (meer marge tot de 5750 W hoofdzekering,
vooral met de 5-seconden-ontdendering die beide systemen nu gebruiken). De
waarde in Supabase (`app_settings`, key `p1_overload_w`) is in dezelfde
beweging bijgewerkt.

## 3.68
Nieuw: "Overbelastingsmeldingen" op de Storingen-pagina, een alleen-lezen
overzicht van elke automatische overbelastingsactie die Home Assistant
uitvoert (mailmelding of een apparaat uitschakelen), met fase, exact
wattage en tijdstip. Haalt de gegevens op uit de nieuwe Supabase-tabel
`overload_event_log` (zie `home-assistant/configuration.yaml`,
rest_command `supabase_log_overload_event`).

Ook nieuw app-icoon (lampje), voor de launcher en het adaptive-icon-laagje
op alle schermdichtheden.

Daarnaast: de eerdere commit op deze bestandsnaam bleek een onvolledige,
halverwege afgebroken push van `app/index.html` (1230 van de 5541 regels) -
nog niet via de API hersteld (bestandsgrootte-beperking); het werkende
bestand wordt rechtstreeks als APK/HTML gedeeld, zie de chat.

## 3.67
Overbelasting-e-mails en het loggen van storingen gebeuren niet meer door de
app zelf, ook niet bij een rechtstreekse P1-verbinding. Dat doet nu volledig
Home Assistant (zie `home-assistant/automations/overbelasting-melding.yaml`
en `storingen-naar-supabase.yaml`), zodat er geen dubbele mails of dubbele
regels in het storingenlogboek meer ontstaan.

## 3.66
Kostenberekening robuuster: een meting zonder gas- of exportstand (zoals de
gegevens die Home Assistant via Supabase doorgeeft) overschrijft de al
opgeslagen stand van vandaag niet meer met "leeg". De dagrij wordt telkens
opnieuw opgehaald, zodat een handmatig gecorrigeerde beginstand direct wordt
overgenomen.

## 3.65
Tarieven voor stroom en gas zijn alleen-lezen in de app: ze komen vanuit
Home Assistant (helpers Stroomprijs/Gasprijs) via Supabase binnen en worden
hier alleen getoond en gebruikt voor de kostenberekening.

## 3.6x (eerder in dit project)
- Overbelastingsdrempel vast op 5250 W, slotje weggehaald.
- Kostenberekening (dagelijkse elektra-/gaskosten) ook in de clientversie
  toegevoegd, naar het voorbeeld van de oude serverversie.
- Automatische login met het vaste dashboardaccount toegevoegd (het
  startpunt van dit project: reverse engineering van de originele APK).
