# Versielogboek - V3L HomeWizard

Overzicht van de wijzigingen per versie (cache-versie zoals gebruikt in `sw.js`, `CACHE_NAME`). Nieuwste bovenaan.

## 3.16
- Architectuur uitgebreid met een aparte serverversie (server.html) die lokaal bij de P1-meter draait en de volledige actuele meterstand naar Supabase (latest_status) schrijft. De clientversie (dit bestand/index.html) valt nu automatisch terug op die Supabase-data wanneer de meter niet rechtstreeks bereikbaar is (bijv. onderweg); het IP-adres van de meter ligt in de client vast en is daar niet meer wijzigbaar.

## 3.15
- Dag-met-hoogste-verbruik-tegel schaalt nu netjes mee op mobiel: de datum breekt niet meer af naar 2 regels en de fase-opsplitsing (L1/L2/L3) blijft compact naast elkaar staan in plaats van onder elkaar te vallen. Ook de labelopmaak van de fasegetallen hersteld.

## 3.14
- Tegels op de Log-pagina hernoemd: "Versielogboek" wordt "Versie", "Storingslog" wordt "Storingen".

## 3.13
- Dag met hoogste verbruik toont de getallen nu in Wh in plaats van kWh.

## 3.12
- Bij de dag met het hoogste verbruik wordt nu ook de opsplitsing per fase (L1/L2/L3 in kWh) getoond.

## 3.11
- Verbruik-pagina toont nu bovenaan de dag met het hoogste totale stroomverbruik (kWh), berekend uit de verbruikslog.

## 3.10
- Bug gefixt: het wegschrijven van nieuwe verbruiks-/storingslogregels ververste het sessietoken niet, waardoor dit na verloop van tijd stil bleef mislukken (401) en de log niet meer aangroeide - terwijl eerdere data gewoon veilig in Supabase bleef staan. Schrijven ververst het token nu net als lezen al deed.

## 3.9
- Batterijbesparing: als het scherm uit gaat of de app op de achtergrond komt, wordt er nog maar 1x per minuut gepolld in plaats van op de ingestelde snelheid. Bij terugkomst wordt direct weer een verse meting opgehaald.

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
- RLS aangescherpt op alle tabellen (`app_settings`, `email_settings`, `fault_log`, `minute_log`, `field_locks`, `email_send_log`): de publieke/anon-sleutel (zichtbaar in de paginabroncode) is niet meer genoeg om te lezen of te schrijven, dat vereist nu een geldig ingelogd sessie-token (rol `authenticated`). Ook `get_storage_stats()` is niet meer publiek aanroepbaar.
- Edge Function `send-alert-email` draait nu met `verify_jwt: true`; het dashboard stuurt het sessie-token mee bij het versturen van alerts/testmails.
- Let op: bij het aanmaken van een account is e-mailbevestiging vereist (standaard Supabase-instelling) - na het aanmaken moet de bevestigingsmail worden geopend voordat inloggen lukt.

## v58
- Bugfix: `.field-row` gebruikte flexbox met `flex:1` (= `flex-basis:0%`) voor de input/select, wat op sommige mobiele browsers (met name bij `<select>`) niet betrouwbaar de volledige breedte innam - met als gevolg een te smal veld en een hangslotje dat niet recht onder de andere stond. Vervangen door CSS Grid (`grid-template-columns:1fr auto`), wat hier stabieler in is.

## v57
- Bugfix mobiele weergave: de instellingentegel toonde grote lege witruimtes na de veld "Ververssnelheid" en "Overbelastingsgrens" - de vaste `flex-basis` (150px/190px, bedoeld als breedte in de desktop-rijweergave) werd op mobiel als hoogte geïnterpreteerd doordat de container daar `flex-direction:column` gebruikt. Nu overschreven met `flex:1 1 auto` op mobiel.

## v56
- LastPass- en 1Password-icoon op de tekst-/e-mailvelden onderdrukt via `data-lpignore="true"` / `data-1p-ignore="true"` (het witte vakje met stipjes bleek het LastPass-icoon, dat alleen online verschijnt omdat de extensie dan de kluis kan raadplegen).

## v55
- Autofill uitgezet (`autocomplete="off"` + autocorrect/autocapitalize/spellcheck uit) op de tekst- en e-mailvelden (IP-adres, database-URL's/sleutels voor Storingslog/Verbruikslog, e-mailadres-velden), zodat mobiele browsers geen eigen invul-/autofill-knop meer tonen naast het hangslotje.

## v54
- Groene/oranje/rode kleurblokjes rechtsonder in de fase-tegels (L1/L2/L3) verwijderd.
- Mobiele weergave geoptimaliseerd: grotere raakvlakken voor knoppen en hangslotjes, betere lettergroottes op smalle schermen (extra breakpoint <380px), header/instellingen/tegels schikken netter op telefoonformaat.

## v53
- Mixed-content-fix: nieuwe `.htaccess` in de dashboardmap dwingt gewoon http af (i.p.v. de site-brede https), omdat de HomeWizard P1-meter lokaal alleen http spreekt en een https-pagina die oproep anders blokkeert. Het veld "IP-adres / hostnaam P1 meter" accepteert nu ook een volledige `http://` of `https://` URL; vul je daar later een beveiligd adres in (reverse-proxy/tunnel), dan wordt dat gebruikt zonder verdere aanpassingen.

## v52
- Voorbereid voor publicatie op 3lcomputers.nl/V3LHomeWizard: `sw.js` en `manifest.webmanifest` verwijzen nu naar `index.html` in plaats van `p1-dashboard.html`, zodat de map direct als startpagina werkt op het domein/de submap. `p1-dashboard.html` moet bij het uploaden hernoemd worden naar `index.html`.

## v51
- Nieuw: bovenaan de tegel "E-mailalerts" toont "Verzendlimiet EmailJS-account" hoeveel alerts er deze kalendermaand al zijn verzonden (beide onderdelen samen) en hoeveel er nog over zijn t.o.v. een instelbare maandelijkse limiet (standaard 200 - de gratis EmailJS-limiet). Nieuwe Supabase-tabel `email_send_log` registreert elke geslaagde verzending server-side (via de Edge Function, met de service-role-sleutel); het dashboard leest alleen het aantal uit. Kleurt oranje bij minder dan 10% marge, rood zodra de limiet is bereikt.

## v50
- De uitleg bij "Overbelasting" en "Supabase-opslaglimiet" is ingekort: de zin over de beveiligde server-functie/Edge Function is verwijderd.

## Database (Supabase, geen dashboard-versiewijziging)
- Automatische logopschoning ingebouwd: `fault_log` en `minute_log` bevatten voortaan maximaal 1 maand aan data. Een `pg_cron`-taak (`cleanup_old_logs`) draait elke nacht om 03:30 en verwijdert regels ouder dan 30 dagen via de functie `public.cleanup_old_logs()`. Dit voorkomt dat de Supabase-opslaglimiet op termijn alsnog wordt overschreden.

## v49
- Bugfix: door de vorige update (v48) stonden de Supabase-constantes (`APP_SETTINGS_URL` e.a.) na de code die ze al gebruikte, waardoor bij het opstarten een `ReferenceError` optrad. Hierdoor stopte de hele scriptuitvoering en deed geen enkele knop in het dashboard meer iets (testmail-knoppen, Verbinden, Instellingen opslaan, etc.). De constantes staan nu vóór het herstellen van de opgeslagen instellingen, zodat dit niet meer misgaat.

## v48
- EmailJS Service ID/Template ID/Public Key staan niet meer in het dashboard, localStorage of Supabase-tabellen: ze zijn verplaatst naar een nieuwe Supabase Edge Function (`send-alert-email`) als server-side secrets. Het dashboard stuurt nu alleen nog het e-mailadres en de meetwaarden naar deze functie; de EmailJS-koppeling zelf is nooit meer zichtbaar in de browser.
- Beide e-mailalert-onderdelen (Overbelasting en Supabase-opslaglimiet) tonen nu alleen nog het veld "Naar e-mailadres"; de bijbehorende uitleg is aangepast.
- Let op: de EmailJS-gegevens moeten na deze update handmatig als secrets in Supabase worden ingesteld (Project Settings -> Edge Functions -> send-alert-email -> Secrets): `EMAILJS_SERVICE_ID`, `EMAILJS_TEMPLATE_ID`, `EMAILJS_PUBLIC_KEY` voor Overbelasting, en `STORAGE_EMAILJS_SERVICE_ID`, `STORAGE_EMAILJS_TEMPLATE_ID`, `STORAGE_EMAILJS_PUBLIC_KEY` voor de opslaglimiet-waarschuwing.

## v47
- De resterende dashboard-instellingen worden nu ook naar Supabase geschreven (nieuwe tabel `app_settings`): IP-adres, ververssnelheid, overbelastingsgrens, elektriciteits- en gasprijzen, en de eigen-database URL/sleutel-waarden voor Storingslog en Verbruikslog. Het dashboard ziet er hiermee op elke pc/browser hetzelfde uit; localStorage blijft als snelle/offline fallback bestaan.

## v46
- Alle e-mailalert-instellingen (beide onderdelen: Overbelasting en Supabase-opslaglimiet - inschakelvinkje, Service ID, Template ID, Public Key, e-mailadres en de testmail-status) worden nu ook naar Supabase geschreven (nieuwe tabel `email_settings`), net als eerder al gebeurde met de vergrendelstatus. localStorage blijft als snelle/offline fallback bestaan; Supabase is leidend bij het opstarten.

## v45
- "E-mailalert inschakelen" kan nu pas aangevinkt worden nadat alle velden zijn ingevuld én er een succesvolle testmail is verstuurd (geldt voor zowel "Overbelasting" als "Supabase-opslaglimiet"). Wijzig je daarna een van de velden, dan is een nieuwe geslaagde testmail nodig voordat je 'm weer kunt inschakelen. Al werkende, eerder ingeschakelde configuraties blijven gewoon actief.

## v44
- Groene rand onder de titel "Meterstanden" verwijderd, zodat deze tegel dezelfde opmaak heeft als de Storingslog-tegel (geen lijn onder de titel).
- Tegeltitel "E-mailalert bij overbelasting" hernoemd naar "E-mailalerts", en opgesplitst in twee aparte onderdelen: "Overbelasting" (bestaande instellingen, ongewijzigd) en "Supabase-opslaglimiet" (nieuw, met eigen EmailJS Service ID/Template ID/Public Key/e-mailadres, inclusief hangslot-vergrendeling en een eigen testmail-knop). Zo kan voor de opslaglimiet-waarschuwing een aparte EmailJS-template gebruikt worden.

## v43
- Dezelfde gele hangslot-vergrendeling toegevoegd aan de 4 EmailJS-velden (Service ID, Template ID, Public Key, Naar e-mailadres) bij "E-mailalert bij overbelasting". Vergrendelstatus wordt, net als bij de andere velden, ook meegesynchroniseerd naar Supabase.

## v42
- Losse titel "Storingen" in de Stroomstoringen-tegel verwijderd (was dubbelop met "Stroomstoringen").
- Alle titels (Meterstanden, Systeeminformatie, en de titels van de uitklapbare tegels: E-mailalert, Tarieven & kosten, Storingslog, Verbruikslog, Versielogboek) naar dezelfde opmaak gebracht als de titel van de "Totaal vermogen"-tegel (kleur en lettergrootte). De fase-tegels (L1/L2/L3) zijn hierbij niet aangepast.

## v41
- Alle titels (los boven een tegel, en die van de uitklapbare tegels) naar dezelfde opmaak gebracht: het streepje voor de titel is overal verwijderd.
- "Meterstanden", "Systeeminformatie" en "Storingen" staan nu als titel in de tegel zelf, in plaats van als losse tekst erboven.

## v40
- Supabase-limietwaarschuwing stuurt nu ook een e-mail, via dezelfde EmailJS-instellingen (service/template/sleutel/ontvanger) als de overbelastingsalert. Verstuurt één mail zodra de 80%-grens wordt bereikt, en pas weer een nieuwe zodra het gebruik daarna weer onder die grens is gezakt en opnieuw stijgt.
- "Storingen"-tegel verplaatst naar direct onder de "Totaal vermogen"-tegel (stond eerder onderaan, na Meterstanden/Systeeminformatie).

## v39
- Betrouwbaardere aanlevering aan Supabase: als een storings- of verbruiksregel niet direct verstuurd kan worden (bijv. tijdelijk geen verbinding), wordt deze lokaal in een wachtrij bewaard en automatisch opnieuw geprobeerd (bij opstarten, elke 2 minuten, en zodra de browser weer online komt). Zo komt elke regel uiteindelijk in de database terecht.
- Waarschuwing toegevoegd die verschijnt zodra het Supabase-gebruik (gratis limiet van 500 MB) richting de 80% gaat, met het huidige gebruik in MB en percentage.

## v38
- "Stroomstoringen" en de dips/pieken per fase samengevoegd tot één tegel (was nog 2 losse tegels), met een dunne scheidingslijn ertussen. Positie van teksten en cijfers ongewijzigd.

## v37
- "Fase X (LX)"-labels boven de dips/pieken-tegel gecentreerd (stonden links uitgelijnd).

## v36
- Bevestigd dat dips/pieken per fase al meegenomen werden in de Storingslog (geen wijziging nodig, was al aanwezig sinds v23).
- De drie losse fase-tegels (dips/pieken) samengevoegd tot één tegel; tekst en cijfers staan qua positie ongewijzigd (zelfde 3-koloms indeling, alleen niet meer als losse tegels).

## v35
- Dit versielogboek is nu ook zichtbaar in het dashboard zelf, als uitklapbaar paneel onderaan (boven de footer).

## v34
- CSV-exportknop toegevoegd aan de Storingslog (naast Verbruikslog, die deze al had).

## v33
- Vergrendelstatus (hangslot) van alle velden (IP, interval, grens, en de database-instellingen) wordt nu ook opgeslagen in Supabase (nieuwe tabel `field_locks`), zodat dit niet meer alleen van de browser afhankelijk is. localStorage blijft als snelle/offline fallback.

## v32
- Tekst "lokaal in deze browser" verwijderd uit de teller-teksten bij Storingslog en Verbruikslog.
- Dezelfde gele hangslot-vergrendeling als bovenin (IP/interval/grens) toegevoegd aan de API-endpoint-URL en API-sleutel velden in beide database-instellingenpanelen.

## v31
- Uitlegtekst onder "Eigen database"-instellingen verwijderd uit beide log-tegels (Storingslog en Verbruikslog).

## v30
- Titel "Logboek (per minuut)" hernoemd naar "Verbruikslog" (NL/EN/DE).

## v29
- De losse koptekst boven de tegel ("Storingslog" / "Logboek (per minuut)") verwijderd, omdat de tegel zelf (via het uitklapbare paneel) die titel al toont.

## v28
- Titel van het uitklapbare "eigen database"-paneel binnen de Storingslog- en Logboek-tegel vervangen: toont nu de tegelnaam zelf ("Storingslog" / "Logboek (per minuut)") in plaats van "Eigen database (optioneel)".

## v27
- Database-koppeling omgezet naar Supabase: Supabase-project en de tabellen `fault_log` en `minute_log` aangemaakt (met RLS-policies voor lezen/schrijven).
- Dashboard praat nu rechtstreeks met de Supabase REST-API (PostgREST) via de headers `apikey` / `Authorization: Bearer ...` in plaats van het eigen PHP-endpoint.
- API-endpoint-URL en API-sleutel staan vooraf ingevuld voor het gekoppelde Supabase-project.

## v26
- De twee losse "eigen database"-instellingentegels samengevoegd met de bijbehorende log-tegel: de database-instellingen staan nu als uitklapbaar onderdeel bovenin dezelfde tegel als de Storingslog / het Logboek, in plaats van als aparte tegel ernaast.

## v25
- Optionele koppeling met een eigen database toegevoegd voor het Logboek (per minuut): elke minuutregel kan ook naar een zelf gehost REST-endpoint (PHP + MySQL) gestuurd worden.
- Bijbehorende `minute-log-schema.sql` en `minute-log-api.php` bestanden opgeleverd.

## v24
- Optionele koppeling met een eigen database toegevoegd voor de Storingslog: elke gelogde storing kan ook naar een zelf gehost REST-endpoint (PHP + MySQL, bijv. bij mijndomein) gestuurd worden, met een instellingenpaneel voor API-URL en API-sleutel.
- Bijbehorende `fault-log-schema.sql` en `fault-log-api.php` bestanden opgeleverd.

## v23
- Nieuwe sectie "Storingslog" toegevoegd: logt tijdstip, type en aantal zodra een storingsteller (stroomstoring, langdurige stroomstoring, dip of piek per fase) omhoog gaat tijdens het pollen. Blijft lokaal bewaard (max. 500 regels) en overleeft een herlaad.
- Toegelicht dat de duur van een storing niet gelogd kan worden, omdat de HomeWizard-API die informatie niet levert.

## v22
- Kleurblokje bij de fase-tegels verkleind naar 2 x 1 cm.

## v21
- Kleurblokje bij de fase-tegels start nu standaard groen (naald op 0 / geen data) in plaats van grijs; wordt pas oranje of rood zodra het vermogen daadwerkelijk in die zone komt.

## v20
- Kleurblokje bij de fase-tegels verkleind naar 3 x 1 cm.

## v19
- Nieuw kleurblokje (3 x 1,5 cm) rechtsonder in elke fase-tegel (L1/L2/L3) toegevoegd: toont live in welke gauge-zone (groen/oranje/rood) de wijzer op dat moment staat.

## v18
- Subtitel aangepast van "Live inzicht in je stroomverbruik per fase" naar "Live inzicht in je stroomverbruik".

## v17
- Gauge-schaal uitgebreid met een vaste groene zone van 0 tot 4,5 kW, gevolgd door de bestaande oranje (4,5-5k) en rode (5k+) zones.

## v16
- Groene rand toegevoegd onder de titel "Meterstanden".

## v15
- Fase-tegel krijgt bij overschrijding van de overbelastingsgrens nu een dikkere (3px), knipperende rode rand in plaats van een volledig rode/pulserende achtergrond.

## v14
- De rode/pulserende achtergrondkleuring van de fase-tegels (L1/L2/L3) bij overschrijding van de overbelastingsgrens verwijderd, inclusief opschonen van de bijbehorende CSS.

## v1 t/m v13 (eerdere ontwikkeling)
Ruwweg in chronologische volgorde:
- Eerste opzet van het dashboard: header, instellingen (IP-adres, ververssnelheid, overbelastingsgrens), analoge gauges per fase, meterstanden-tabel, logboek per minuut, e-mailalert bij overbelasting (via EmailJS), i18n (NL/EN/DE), PWA-ondersteuning (manifest + service worker).
- Ververssnelheid en overbelastingsgrens omgezet van invoervelden naar pulldown-menu's met eigen pijl-icoon.
- Hangslot-vergrendeling toegevoegd op IP-adres, ververssnelheid en overbelastingsgrens (los per veld vergrendelbaar, geel hangslotje dat open/dicht zwaait).
- Statuspil naast de taalvlaggen in de header verwijderd.
- Storingstegels (dips/pieken) in dezelfde stijl en grootte gebracht als de andere tegels; "Stroomstoringen"-tegel eveneens gelijkgetrokken.
- Bug verholpen waarbij scrollen in het logboek de waarden over de koptekst liet schuiven (transparante koptekst-achtergrond).
- Footer aangepast: HomeWizard-API-uitleg vervangen door een V3L-copyrightregel met dynamisch jaartal ("Alle rechten voorbehouden").
- Titel/naam overal gewijzigd van "P1 Meter Dashboard" naar "V3L HomeWizard", inclusief het V3L-logo bovenaan (i.p.v. het bliksenschichtje).
- Foutmelding bij verbindingsproblemen omgezet naar een uitklapbare tegel (alleen de titelregel zichtbaar, rest pas bij uitklappen).
- Gauge-gevarenzones gefixt: rode zone startte te vroeg (linecap-bug), vaste oranje waarschuwingszone (4,5k-5k) en dieper rode gevarenzone (5k+) toegevoegd, losgekoppeld van de instelbare overbelastingsgrens, en een overgebleven grijs randje na de rode zone verholpen.
- Gasverbruik (tijdstip) en Systeeminformatie (meter-model, DSMR-versie, unieke IDs) toegevoegd op basis van de HomeWizard API-velden.
- Configureerbare elektriciteits- en gasprijzen toegevoegd, met berekende kosten (elektriciteit, gas, totaal) en verwijdering van de native invoerspinners op de prijsvelden.
- Tegel-layout herzien: volle-breedte "Totaal vermogen"-tegel met daaronder een 2-koloms rij met "Kosten elektriciteit" en "Kosten gas" naast elkaar.
