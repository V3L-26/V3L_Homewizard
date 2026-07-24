# P1-poller opzetten

Los script (`p1-poller.py`) dat je verbruikslog compleet houdt, ook als het dashboard nergens open staat. Draai het op een apparaat dat altijd aan staat en in hetzelfde netwerk zit als de P1-meter (Raspberry Pi, NAS, oude pc).

## 1. Eenmalig testen

```
python3 -m pip install requests
python3 p1-poller.py
```

Vul je dashboard e-mail/wachtwoord in. Daarna slaat het script alleen een refresh-token op in `poller_state.json` (niet je wachtwoord). Laat het een paar minuten draaien en controleer in het dashboard of er nieuwe regels in het verbruikslog verschijnen. Stop met Ctrl+C.

Staat de P1-meter op een ander IP dan `192.168.178.161`? Zet dat vooraf:

```
export P1_IP=192.168.1.50
```

## 2. Altijd laten draaien — Raspberry Pi / Linux (systemd)

Maak `/etc/systemd/system/p1-poller.service`:

```
[Unit]
Description=V3L P1 poller
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/python3 /home/pi/p1-poller/p1-poller.py
WorkingDirectory=/home/pi/p1-poller
Restart=always
RestartSec=10
User=pi

[Install]
WantedBy=multi-user.target
```

Dan:

```
sudo systemctl daemon-reload
sudo systemctl enable --now p1-poller
journalctl -u p1-poller -f   # logs live volgen
```

Let op: run stap 1 (interactief inloggen) éérst handmatig, zodat `poller_state.json` al een geldig refresh-token bevat voordat de service voor het eerst start — de service zelf kan niet interactief om een wachtwoord vragen.

## 3. Altijd laten draaien — Windows (Taakplanner)

1. Doe stap 1 eenmalig in een gewone terminal (Command Prompt/PowerShell) zodat `poller_state.json` een refresh-token heeft.
2. Open **Taakplanner** → **Basistaak maken**.
3. Trigger: **Bij het opstarten van de computer**.
4. Actie: **Programma starten** → `python.exe`, argumenten: `p1-poller.py`, beginmap: de map met het script.
5. In de taakeigenschappen: vink **"Voer de taak uit ongeacht of de gebruiker is aangemeld"** aan, zodat hij ook zonder ingelogde sessie blijft draaien.

## Werking in het kort

- Elke 10 seconden wordt de P1-meter uitgelezen.
- Per minuut wordt het gemiddelde vermogen weggeschreven naar `minute_log` (zelfde tabel/kolommen als het dashboard).
- Stijgingen in de storingstellers (spanningsdips, -pieken, stroomstoringen) worden weggeschreven naar `fault_log`.
- Bij een herstart van het script wordt de laatste storingsstand lokaal onthouden (`poller_state.json`), zodat er geen valse storingsmelding ontstaat.
- Sessietoken wordt automatisch ververst; alleen bij een verlopen/ongeldig refresh-token moet je opnieuw handmatig inloggen (stap 1).
