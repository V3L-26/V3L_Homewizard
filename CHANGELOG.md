# Versielogboek - V3L HomeWizard

Overzicht van de wijzigingen per versie (cache-versie zoals gebruikt in `sw.js`, `CACHE_NAME`). Nieuwste bovenaan.

## 3.8
- Fase-meter-popup op mobiel opent nu met een zoom-animatie (van klein naar groot) en zoomt weer terug bij het sluiten.

## 3.7
- Uitlogknop staat nu naast de taalvlaggetjes in de header, ook op mobiel (stond eerst eronder).

## 3.6
- Volgorde en indeling van de tabbladen aangepast: Home, Verbruik (nieuw, met de verbruikslog), Meterstanden, Storingen, Instellingen, Log.
- Meldingen-tabblad opgeheven: e-mailalerts en de opslaglimiet-waarschuwing staan nu bij Instellingen.
- Systeeminformatie is niet langer een eigen tabblad, maar staat nu ook bij Instellingen.

## 3.5
- Meterstanden en Systeeminformatie zijn nu allebei een eigen pagina in de navigatiebalk, los van Instellingen.
- Meldingen-pagina: de e-mailalerts-tegel is niet meer uitklapbaar, alle onderdelen staan meteen zichtbaar.
- Instellingen-pagina: IP-adres, ververssnelheid en overbelastingsgrens staan nu onder elkaar in plaats van naast elkaar.

## 3.4
- Pauzeknop verwijderd (had geen functie meer).
- Dashboard opgesplitst in aparte pagina's: Home (fase-meters + totaal vermogen), Instellingen (IP/ververssnelheid/overbelastingsgrens, meterstanden, systeeminformatie), Storingen (stroomstoringen-tegel), Meldingen (e-mailalerts, opslaglimiet-waarschuwing) en Log (storingslog, verbruikslog, versielogboek) - met een navigatiebalk met iconen bovenaan, werkt op zowel computer als mobiel. Home laadt altijd als eerste.

## 3.3
- Wachtwoordveld op het inlogscherm hersteld naar bolletjes-weergave (was tijdelijk platte tekst, waardoor de browser het wachtwoord niet meer automatisch invulde). Het e-mailveld blijft wel zonder voorbeeldtekst.

## 3.2
- Inlogscherm: geen voorbeeldtekst meer in het e-mailveld ("jij@voorbeeld.nl") en het wachtwoordveld toont nu gewoon leesbare tekst in plaats van bolletjes.

## 3.1
- De versie-/update-regel in de footer heeft nu dezelfde opmaak (lettergrootte, kleur, doorzichtigheid) als de copyrightregel erboven.

## 3.0
- Nieuwe versienummering vanaf hier: x.y (bijv. 3.0, 3.1 ... 3.9, dan 4.0, 4.1, ...). De oudere v1-v75-nummers hieronder blijven staan als historisch overzicht.
- Bij de versie-informatie in de footer staat nu ook het tijdstip (uu:mm:ss) van de laatste update, naast de datum.

## v75
- Onder de copyrightregel in de footer staat nu de huidige app-versie en de datum van de laatste update (vertaald voor nl/en/de).

## v74
- Sluitkruisje op de fase-meter-popup verwijderd - naast de tegel klikken/tikken sluit de popup al.

## v73
- Tik op een fase-tegel (L1/L2/L3) op een mobiel/tablet om deze vergroot als popup te bekijken (schaalt automatisch mee met de schermgrootte). Alleen actief op touch-apparaten (`pointer: coarse`) - op een computer met muis blijft dit uit.

## v72
- Fase-tegels (L1/L2/L3) blijven op elk schermformaat naast elkaar staan (3 kolommen) in plaats van onder elkaar op smalle telefoons - padding, labels, cijfers en meters krimpen automatisch mee met de schermbreedte zodat alle drie altijd op 1 scherm passen.

## v71
- Het cijfer in de tegel "Totaal vermogen" staat nu gecentreerd in de tegel.

## v70
- Tegel "Totaal vermogen" verlaagd (minder verticale padding, kleiner cijfer) - zelfde breedte als voorheen, alleen minder hoog.

## v69
- De tegel "Kosten" en het paneel "Tarieven" zijn volledig verwijderd (niet alleen verborgen): de lokale P1-API levert geen prijs-/tariefgegevens, waardoor een betrouwbare kostenberekening met de beschikbare data niet goed mogelijk was (geen apart terugleveringstarief, geen periode-afbakening). Meterstanden (import/export/gas/water) blijven gewoon zichtbaar.

## v68
- De tegels "Kosten elektriciteit" en "Kosten gas" zijn samengevoegd tot één uitklapbare tegel "Kosten" op dezelfde plek in de layout: ingeklapt toont deze het totaal, opengeklapt de uitsplitsing elektriciteit/gas.
- De tegel "Tarieven" (titel ingekort van "Tarieven & kosten" naar "Tarieven") is verplaatst naar direct onder de nieuwe Kosten-tegel, vóór E-mailalerts.

## v67
- Titels ingekort: "Verzendlimiet EmailJS-account" → "Verzendlimiet", "Supabase-opslaglimiet" → "Opslaglimiet".

## v66
- Bugfix: het vinkje "E-mailalert inschakelen" (Overbelasting en Supabase-opslaglimiet) werd alleen weggeschreven via de knop "Instellingen opslaan", niet bij het vinkje zelf. Klikte je alleen het vinkje aan of uit zonder daarna op Opslaan te drukken, dan stond het na een pagina-ververing altijd weer uit - ook al leek het aangevinkt tijdens die sessie. Het vinkje slaat zijn status nu direct op bij elke wijziging.

## v65
- Zelfde bugfix als v63 (verlopen sessietoken → stille 401), nu ook toegepast op: vergrendelstatus (field_locks), e-mailalert-instellingen (email_settings), overige dashboard-instellingen incl. IP/interval/overbelastingsgrens/tarieven (app_settings), de EmailJS-verzendteller, en de Supabase-opslaglimiet-check/testmail. Al deze oproepen verversen nu eerst het sessietoken vóór ze data ophalen of wegschrijven. Hiervoor kon het lijken alsof e-mailadressen en hangslot-vergrendelingen "gereset" waren na verloop van tijd, terwijl de laatst opgeslagen waarde nooit succesvol in Supabase was weggeschreven (de mislukte poging bleef alleen lokaal in die ene browser staan).

## v64
- Automatisch uitloggen na 15 minuten zonder muis-/toetsenbord-/aanraakactiviteit (elke interactie zet de klok weer op 0), zodat een vergeten open tabblad niet onbeperkt ingelogd blijft.

## v63
- Bugfix: het inlog-sessietoken (Supabase Auth) verloopt standaard na een tijd. Als dat gebeurde vóórdat de Storingslog/Verbruikslog werden geladen, mislukte die oproep stil op de achtergrond (401) en leek de data "verdwenen" - terwijl deze gewoon nog in de database stond (bevestigd via directe controle: de data van gisteravond stond nog gewoon in `minute_log`). Beide logs verversen nu eerst het sessietoken vóór het laden, proberen het automatisch opnieuw zodra een verlopen sessie op de achtergrond ververst is, en tonen voortaan een zichtbare foutmelding i.p.v. stil te falen.

## v62
- Bugfix: `autocomplete="off"` wordt door Chrome's ingebouwde wachtwoordmanager bewust genegeerd voor inlogvelden (bekend, opzettelijk browsergedrag sinds 2014). De e-mail-/wachtwoordvelden op het inlogscherm staan nu bij het laden op `readonly` en worden pas bewerkbaar bij focus (`onfocus`) - hierdoor vult Chrome ze niet meer automatisch.

## v61
- E-mailadres/wachtwoord op het inlogscherm blijven niet meer hangen: `autocomplete="off"` + lpignore/1p-ignore-attributen, en de velden worden bovendien bij elke paginalading expliciet geleegd via JS, ongeacht wat de browser zelf zou willen invullen.

## v60
- Het "Account aanmaken"-formulier en de bijbehorende link zijn uit het inlogscherm verwijderd - alleen inloggen is nu mogelijk vanaf de pagina. Bevestigd dat registratie ook server-side dicht staat (`disable_signup: true` in Supabase Auth), dus ook rechtstreeks via de API kan niemand meer een account aanmaken.

## v59
- Echte inlog toegevoegd via Supabase Auth. Het dashboard toont nu een inlog-/aanmaakscherm en blijft verborgen tot er succesvol is ingelogd. Een nieuw account vereist een wachtwoord van minimaal 12 tekens met ten minste 1 cijfer en 1 vreemd teken (client-side gevalideerd via een live checklist).
- RLS aangescherpt op alle tabellen (`app_settings`, `email_settings`, `fault_log`, `minute_log`, `field_locks`, `email_send_log`): de publieke/anon-sleutel (zichtbaar in de paginabroncode) is niet meer genoeg om te leze