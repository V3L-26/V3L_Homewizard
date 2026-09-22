# Changelog - app/index.html

Volledige changelog staat ook in de app zelf (pagina "Versie"). Dit is een
overzicht op hoofdlijnen van wat er in dit project is gewijzigd.

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
