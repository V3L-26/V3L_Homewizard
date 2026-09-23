# Plan: uitbreiding overbelastingsbeveiliging (fase 1/2/3)

Status: in voorbereiding, wacht op aanschaf hardware. Laatst bijgewerkt na
analyse van de groepenkast-indeling en fase-belasting, en na herbouw van de
airco-uitzetautomatiseringen (september 2026).

## Aanleiding

De airco-overbelastingsautomatisering voor fase 3 (drie losse
automatiseringen, zie `home-assistant/automations/airco-woonkamer-uit-bij-overbelasting-fase3.yaml`,
`airco-christian-uit-bij-overbelasting-fase3.yaml` en
`airco-jason-uit-bij-overbelasting-fase3.yaml`) dekt, na analyse van de
groepenkast, maar een deel van het overbelastingsrisico af. Belangrijkste
bevindingen:

- Fase 3 (L3) heeft de zwaarste realistische risicocombinatie: airco
  (continu, tot 2.400 W volgens aansluitvermogen) + oven (3.650 W,
  cyclisch/lang) + droger (1.000 W, cyclisch/lang) + gamecomputer (tot
  800 W, continu 's avonds). Droger + oven + gamecomputer alleen al komt
  op ~5.450 W, dus ook zonder de airco kan fase 3 over de drempel gaan.
- Fase 2 (L2) heeft een vergelijkbaar cluster: vaatwasser (2.300 W) +
  sunshower (2.050 W) + de helft van de inductiekookplaat (schatting
  ~3.700 W, want de kookplaat hangt op L1+L2, L3 niet gebruikt) +
  gamecomputer (800 W). Sunshower is kortdurend, dus het reële
  overlap-risico is hier iets lager dan op fase 3.
- Fase 1 (L1) heeft alleen kortdurende apparaten (koffiezetter, airfryer,
  magnetron) plus de andere helft van de inductiekookplaat en de
  wasmachine. Minst risicovolle fase voor langdurige overlap.
- Complete apparaatlijst met vermogens: zie tabel onderaan.

## Genomen/voorgenomen besluiten

1. **Airco verplaatsen van fase 3 naar fase 1** (elektricien nodig, want
   de airco hangt aan een vaste werkschakelaar, niet aan een stopcontact).
   Haalt de airco weg bij zijn drukste "buren" (oven, droger,
   gamecomputer) en zet 'm bij de rustigste groep. Nog niet uitgevoerd.
2. **HomeWizard-stekkers aanschaffen voor:** droger, wasmachine,
   magnetron, airfryer, koffiezetapparaat. Deze zijn (in tegenstelling tot
   de airco) allemaal stopcontact-apparaten, dus geen elektricien nodig
   voor de stekkers zelf.
3. **Alle bovenstaande apparaten krijgen automatische uitschakeling** bij
   een aanhoudende overbelasting - expliciete keuze van de gebruiker:
   liever incidenteel ongemak (koffie/magnetron/airfryer onderbroken) dan
   een doorslaande zekering. Dit geldt dus ook voor de kortdurende
   keukenapparaten, niet alleen voor de langdurige apparaten
   (aanvankelijk was het idee om de keukenapparaten alleen te monitoren
   zonder automatische ingreep, maar dat is bijgesteld).
4. **Overbelastingsdrempel en -duur worden aangepast:** van 5250 W / 5
   seconden naar (voorstel, nog te bevestigen) **5300-5500 W / ~15
   seconden**. Doel: korte, onschuldige piekmomenten (bijv. het opstarten
   van een apparaat) negeren, maar nog steeds tijdig ingrijpen bij een
   echte aanhoudende overbelasting. Let op: magnetron + airfryer +
   koffiezetter samen komt op ~5.300 W - bij een drempel van precies 5300
   W ligt dat op de grens, dus mogelijk is 5400-5500 W een veiligere
   marge. De huidige airco-automatiseringen gebruiken inmiddels al 5200 W
   zonder aanhoudingsduur (`for:`) - nog niet afgestemd met dit voorstel.
   - **Nog te beslissen:** wordt deze nieuwe drempel/duur overal
     doorgevoerd (de vaste 5250 W in `app/index.html`, de algemene
     overbelastingsmelding/fault_log-automatisering, én de
     airco-automatiseringen), of blijft elke automatisering zijn eigen
     drempel houden?
   - **Nog te beslissen:** exacte duur (voorstel 15 seconden, user gaf
     "iets langer" zonder exact getal).
5. **Architectuur airco-automatiseringen: per unit, niet per fase.** In
   plaats van één gecombineerde automatisering voor alle drie de airco's,
   of één cascade-automatisering per fase, is gekozen voor drie volledig
   losse automatiseringen (één per airco-unit). Reden: een trage of
   al-uitstaande Daikin-unit houdt zo de andere twee niet op, en elke
   automatisering blijft eenvoudig, met dezelfde trigger. Voor de nog te
   bouwen droger/wasmachine/keukenapparaten-automatiseringen moet dit
   opnieuw afgewogen worden - dat zijn andere merken/integraties (lokale
   HomeWizard-stekkers, geen cloud-vertraging), dus de reden om per unit
   te splitsen (trage cloud) speelt daar mogelijk niet.
6. **Herstel na overbelasting is handmatig, niet automatisch.** Eerdere
   opzet zette airco's automatisch terug naar hun vorige hvac-modus via
   een helper (`input_text.airco_overload_uitgezet`) zodra fase 3 vijf
   minuten onder 4000 W bleef. Dat is losgelaten: de gebruiker zet de
   airco's zelf weer aan wanneer dat weer veilig is. Geldt vooralsnog
   alleen voor de airco's - voor de droger/wasmachine (met
   deurvergrendeling, zie onder) moet nog worden afgewogen of handmatig
   herstel daar ook volstaat, of dat automatisch herstel daar wel
   gewenst is.

## Openstaande vragen bij hervatten van dit onderwerp

- Exacte nieuwe drempelwaarde en duur (zie boven), en afstemming met de
  5200 W die de airco-automatiseringen nu al gebruiken.
- Scope van de drempel-aanpassing (overal, of per automatisering eigen
  drempel).
- Welke HomeWizard-stekkermodellen zijn aangeschaft (vermogenscapaciteit
  checken, met name t.o.v. 1.000-2.300 W per apparaat)?
- Is de airco al verplaatst naar fase 1 door de elektricien?
- Voor de nieuwe apparaten: per apparaat een losse automatisering (zoals
  nu bij de airco's), of alsnog een gedeelde/cascade-opzet per fase?
- Voor de wasmachine: deurvergrendeling blijft actief zonder stroom
  (thermisch element, ontgrendelt na ~5-10 min of automatisch bij
  stroomherstel) - geen schade te verwachten bij kortdurende
  onderbreking, wel kans op vochtige/ruikende was bij langere
  onderbreking. Aangezien herstel bij de airco's nu handmatig is, moet
  bepaald worden of dat voor de wasmachine ook volstaat, of dat daar
  automatisch herstel (zoals oorspronkelijk bij de airco's) alsnog
  gewenst is vanwege dit risico.
- Christian- en Jason-airco-automatiseringen individueel testen (volgen
  hetzelfde patroon als de geteste woonkamer-versie, maar device_id-
  toewijzing is nog niet apart bevestigd voor die twee).

## Apparaatoverzicht (uit groepenkast + gebruiker aangeleverd)

| Apparaat | Fase (huidig) | Vermogen | Aansluiting | Duur/aard |
|---|---|---|---|---|
| Magnetron | 1 | 2.100 W | WCD (stekker) | kortdurend |
| Koffiezetapparaat | 1 | 1.500 W | WCD (dubbel) | kortdurend |
| Airfryer | 1 | 1.700 W | WCD (dubbel) | kortdurend |
| Wasmachine | 1 | onbekend | WCD | lang/cyclisch |
| Inductiekookplaat | 1 + 2 | 7.400 W (totaal, L3 niet gebruikt) | vast | tijdens koken |
| Vaatwasser | 2 | 2.300 W | WCD (stekker) | lang cyclus |
| Sunshower | 2 | 2.050 W | WCD (vast) | kortdurend |
| Gamecomputer | 2 en 3 | tot 800 W (elk) | WCD | continu (avond) |
| Droger (warmtepomp) | 3 | 1.000 W | WCD (stekker) | lang/cyclisch |
| Oven | 3 | 3.650 W | WCD (stekker) | lang/cyclisch |
| Airco (3MXF52A9 multi-split) | 3 (→ voorstel: 1) | ~1,3-1,8 kW nominaal (2.400 W aansluitvermogen) | werkschakelaar (vast, 1P+N) | continu |

Groepen 1, 3 (deels), 5, 6, 10, 12 (algemene verlichting/stopcontacten)
hebben geen bekend individueel vermogen - niet meegenomen in bovenstaande
berekeningen.

## Gerelateerd

- `home-assistant/automations/airco-woonkamer-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/airco-christian-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/airco-jason-uit-bij-overbelasting-fase3.yaml`
- Bekende beperking Daikin-cloud (status kan verouderd zijn tot een
  refresh is uitgevoerd): opgelost binnen bovenstaande automatiseringen
  met een refresh-knop-druk + wait_template vóór het uit-commando.
  Geldt niet voor de (nog te installeren) HomeWizard-stekkers - die zijn
  lokaal, geen cloud-afhankelijkheid.
