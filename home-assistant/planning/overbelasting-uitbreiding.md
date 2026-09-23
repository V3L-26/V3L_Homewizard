# Plan: uitbreiding overbelastingsbeveiliging (fase 1/2/3)

Status: in voorbereiding, wacht op aanschaf hardware. Laatst bijgewerkt na
analyse van de groepenkast-indeling en fase-belasting (september 2026).

## Aanleiding

De bestaande airco-overbelastingsautomatisering (zie
`home-assistant/automations/airco-uit-bij-overbelasting-fase3.yaml` en
`airco-weer-aan-na-overbelasting-fase3.yaml`) bleek, na analyse van de
groepenkast, maar een deel van het overbelastingsrisico af te dekken.
Belangrijkste bevindingen:

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
   gamecomputer) en zet 'm bij de rustigste groep.
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
   marge.
   - **Nog te beslissen:** wordt deze nieuwe drempel/duur overal
     doorgevoerd (de vaste 5250 W in `app/index.html`, de algemene
     overbelastingsmelding/fault_log-automatisering, én deze nieuwe
     ingreep-automatisering), of alleen voor de nieuwe
     ingreep-automatisering, met de rest op 5250 W?
   - **Nog te beslissen:** exacte duur (voorstel 15 seconden, user gaf
     "iets langer" zonder exact getal).
5. **Architectuur nieuwe automatisering(en):** in plaats van per apparaat
   een aparte automatisering (zoals nu bij de airco met twee bestanden),
   voorstel om **één automatisering per fase** te bouwen die bij
   overbelasting een vaste prioriteitsvolgorde afwerkt (bijv. eerst airco,
   dan droger/wasmachine, als laatste de keukenapparaten - de apparaten
   met de minste hinder eerst). Nog niet uitgewerkt/gebouwd.

## Openstaande vragen bij hervatten van dit onderwerp

- Exacte nieuwe drempelwaarde en duur (zie boven).
- Scope van de drempel-aanpassing (overal, of alleen nieuwe
  automatisering).
- Welke HomeWizard-stekkermodellen zijn aangeschaft (vermogenscapaciteit
  checken, met name t.o.v. 1.000-2.300 W per apparaat)?
- Is de airco al verplaatst naar fase 1 door de elektricien?
- Bevestigen van de prioriteitsvolgorde voor de per-fase
  cascade-automatisering (welk apparaat gaat als eerste/laatste uit).
- Voor de wasmachine: deurvergrendeling blijft actief zonder stroom
  (thermisch element, ontgrendelt na ~5-10 min of automatisch bij
  stroomherstel) - geen schade te verwachten bij kortdurende
  onderbreking, wel kans op vochtige/ruikende was bij langere
  onderbreking. Design van de automatisering moet dus zorgen dat de
  stroom zo snel mogelijk weer hersteld wordt zodra het weer veilig is
  (zelfde patroon als de bestaande hervat-automatisering bij de airco).

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

- `home-assistant/automations/airco-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/airco-weer-aan-na-overbelasting-fase3.yaml`
- Bekende beperking Daikin-cloud (vertraging, dagquotum ~200 aanroepen):
  gedocumenteerd in bovenstaande automatiseringen. Geldt niet voor de
  HomeWizard-stekkers (lokaal, geen quotum).
