# Plan: uitbreiding overbelastingsbeveiliging (fase 1/2/3)

Status: HomeWizard-stekkers zijn aangeschaft en geïnstalleerd, en de
bijbehorende load-balancing automatiseringen voor fase 1/2/3 staan sinds
eind september 2026 in Home Assistant (zie "Gerelateerd" onderaan) - nog
niet in de praktijk getest. De airco is nog niet verplaatst naar fase 1.
Laatst bijgewerkt na installatie van de stekkers en bouw van de
automatiseringen (27 september 2026).

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

## Genomen besluiten

1. **Airco verplaatsen van fase 3 naar fase 1** (elektricien nodig, want
   de airco hangt aan een vaste werkschakelaar, niet aan een stopcontact).
   Haalt de airco weg bij zijn drukste "buren" (oven, droger,
   gamecomputer) en zet 'm bij de rustigste groep. **Nog niet
   uitgevoerd** - enige nog openstaande stap uit dit plan.
2. **HomeWizard-stekkers aangeschaft en geïnstalleerd voor:** Magnetron
   (`switch.keuken_magnetron`), Airfryer (`switch.energy_socket`),
   Koffiezetapparaat (`switch.keuken_koffiezetapparaat`), Wasmachine
   (`switch.hal_wasmachine`), Vaatwasser (`switch.keuken_vaatwasser`) en
   Droger (`switch.hal_droger`). Zes stopcontact-apparaten, dus geen
   elektricien nodig geweest voor de stekkers zelf.
3. **Alle bovenstaande apparaten krijgen automatische uitschakeling** bij
   een overbelasting - expliciete keuze van de gebruiker: liever
   incidenteel ongemak (koffie/magnetron/airfryer/wasmachine onderbroken)
   dan een doorslaande zekering. Geldt dus ook voor de kortdurende
   keukenapparaten én voor de wasmachine, niet alleen voor de langdurige
   apparaten. Gebouwd in `fase1-cascade-afschakelen-bij-overbelasting.yaml`,
   `fase2-vaatwasser-afschakelen-bij-overbelasting.yaml` en
   `fase3-droger-afschakelen-bij-overbelasting.yaml`.
4. **Overbelastingsdrempel voor deze nieuwe automatiseringen: 5200 W,
   geen aanhoudingsduur** - dezelfde drempel als de bestaande
   airco-overbelastingsautomatiseringen, in plaats van het eerder
   overwogen 5300-5500 W / ~15 seconden. Simpeler en consistent over alle
   overbelastingsautomatiseringen heen.
   - **Nog steeds niet doorgevoerd op:** de vaste 5250 W in
     `app/index.html` en de algemene overbelastingsmelding/
     fault_log-automatisering - die blijven op hun eigen, iets hogere
     drempel. Bewust niet aangepakt in deze uitbreiding; puur de
     shutdown-automatiseringen gebruiken nu allemaal 5200 W.
5. **Architectuur: cascade voor fase 1, los apparaat voor fase 2 en
   fase 3.** Voor de airco's (drie units) is gekozen voor drie volledig
   losse automatiseringen per unit, vanwege de trage/onbetrouwbare
   Daikin-cloud. Voor de nieuwe HomeWizard-stekkers speelt dat niet (lokaal,
   geen cloud-vertraging), dus daar is de architectuur puur bepaald door
   hoeveel sheddable apparaten een fase heeft: fase 1 heeft er vier
   (Magnetron, Airfryer, Koffiezetapparaat, Wasmachine) en gebruikt daarom
   één cascaderende automatisering die stap voor stap uitschakelt (van
   minst naar meest ingrijpend) en na elke stap opnieuw checkt of de fase
   alweer onder de drempel is. Fase 2 (alleen Vaatwasser) en fase 3
   (alleen Droger) hebben maar één sheddable apparaat, dus daar is een
   simpele losse automatisering per apparaat voldoende.
6. **Herstel: handmatig voor de airco's, automatisch voor de nieuwe
   stekkers.** Voor de airco's blijft herstel handmatig (zie de aparte
   afweging daar). Voor de zes nieuwe HomeWizard-stekkers is gekozen voor
   **automatisch herstel**: zodra de betreffende fase 5 minuten onder
   4000 W blijft, gaat het apparaat automatisch weer aan - bijgehouden per
   apparaat via een input_boolean-helper
   (`input_boolean.<apparaat>_uit_door_overbelasting`), zodat herstel
   nooit iets aanzet dat de gebruiker zelf om een andere reden uit had
   gelaten. Dit geldt ook voor de wasmachine: het deurvergrendelingsrisico
   (zie tabel/vraag hieronder) werd niet zwaar genoeg geacht om
   automatisch herstel voor de wasmachine uit te sluiten.

## Openstaande vragen bij hervatten van dit onderwerp

- Is de airco al verplaatst naar fase 1 door de elektricien? (Nog niet -
  enige nog openstaande punt uit de besluitenlijst hierboven.)
- De zes nieuwe fase 1/2/3-automatiseringen zijn ingeschakeld maar nog
  niet in de praktijk getest (geen echte overbelasting meegemaakt sinds
  installatie) - bij een eerste keer testen de Traces in Home Assistant
  controleren, net als bij de airco-automatiseringen.
- De Oven (fase 3, 3.650 W) en de Sunshower (fase 2, 2.050 W) hebben geen
  smart plug en blijven dus oncontroleerbaar voor load balancing - dat
  blijft een gat in de dekking, met name op fase 3 waar de Oven de
  zwaarste onvoorspelbare last is.
- Christian- en Jason-airco-automatiseringen individueel testen (volgen
  hetzelfde patroon als de geteste woonkamer-versie, maar device_id-
  toewijzing is nog niet apart bevestigd voor die twee) - losstaand van
  deze uitbreiding, maar nog steeds open.

## Apparaatoverzicht (uit groepenkast + gebruiker aangeleverd)

| Apparaat | Fase (huidig) | Vermogen | Aansluiting | Duur/aard |
|---|---|---|---|---|
| Magnetron | 1 | 2.100 W | HomeWizard-stekker (`switch.keuken_magnetron`) | kortdurend |
| Koffiezetapparaat | 1 | 1.500 W | HomeWizard-stekker (`switch.keuken_koffiezetapparaat`) | kortdurend |
| Airfryer | 1 | 1.700 W | HomeWizard-stekker (`switch.energy_socket`) | kortdurend |
| Wasmachine | 1 | onbekend | HomeWizard-stekker (`switch.hal_wasmachine`) | lang/cyclisch |
| Inductiekookplaat | 1 + 2 | 7.400 W (totaal, L3 niet gebruikt) | vast | tijdens koken |
| Vaatwasser | 2 | 2.300 W | HomeWizard-stekker (`switch.keuken_vaatwasser`) | lang cyclus |
| Sunshower | 2 | 2.050 W | WCD (vast), geen smart plug | kortdurend |
| Gamecomputer | 2 en 3 | tot 800 W (elk) | WCD | continu (avond) |
| Droger (warmtepomp) | 3 | 1.000 W | HomeWizard-stekker (`switch.hal_droger`) | lang/cyclisch |
| Oven | 3 | 3.650 W | WCD (vast), geen smart plug | lang/cyclisch |
| Airco (3MXF52A9 multi-split) | 3 (→ voorstel: 1, nog niet uitgevoerd) | ~1,3-1,8 kW nominaal (2.400 W aansluitvermogen) | werkschakelaar (vast, 1P+N) | continu |

Groepen 1, 3 (deels), 5, 6, 10, 12 (algemene verlichting/stopcontacten)
hebben geen bekend individueel vermogen - niet meegenomen in bovenstaande
berekeningen.

## Gerelateerd

- `home-assistant/automations/airco-woonkamer-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/airco-christian-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/airco-jason-uit-bij-overbelasting-fase3.yaml`
- `home-assistant/automations/fase1-cascade-afschakelen-bij-overbelasting.yaml`
- `home-assistant/automations/fase1-herstel-na-overbelasting.yaml`
- `home-assistant/automations/fase2-vaatwasser-afschakelen-bij-overbelasting.yaml`
- `home-assistant/automations/fase2-vaatwasser-herstel-na-overbelasting.yaml`
- `home-assistant/automations/fase3-droger-afschakelen-bij-overbelasting.yaml`
- `home-assistant/automations/fase3-droger-herstel-na-overbelasting.yaml`
- Bekende beperking Daikin-cloud (status kan verouderd zijn tot een
  refresh is uitgevoerd): opgelost binnen de airco-automatiseringen met
  een refresh-knop-druk + wait_template vóór het uit-commando. Geldt niet
  voor de HomeWizard-stekkers - die zijn lokaal, geen cloud-afhankelijkheid.
