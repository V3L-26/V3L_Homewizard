#!/usr/bin/env python3
"""
V3L HomeWizard - achtergrond-poller voor de P1-meter.

Waarom dit script bestaat:
Het dashboard (index.html) logt verbruiks-/storingsdata alleen zolang de
pagina open staat in een browser. Zodra je de browser/tab sluit (of een
telefoon/tablet zet de tab op de achtergrond), stopt het loggen - de
HomeWizard P1-meter zelf bewaart geen geschiedenis die je achteraf kunt
ophalen (bevestigd via de officiele HomeWizard API-documentatie).

Dit script lost dat op door VOLLEDIG LOS van de browser te draaien: het
leest zelf de lokale P1-API uit en schrijft dezelfde soort regels weg naar
dezelfde Supabase-tabellen die het dashboard ook gebruikt (minute_log en
fault_log). Zolang dit script ergens op een altijd-aan apparaat in hetzelfde
thuisnetwerk als de P1-meter draait (bijv. een Raspberry Pi of een pc die
nooit uit gaat), blijft het logboek compleet - ongeacht of het dashboard
zelf ergens open staat.

------------------------------------------------------------------------
EENMALIGE SETUP (interactief, in een terminal):
    python3 p1-poller.py
  Het script vraagt dan om je dashboard-inlog (e-mailadres/wachtwoord) en
  slaat daarna alleen een ververs-token (refresh token) lokaal op in
  poller_state.json - niet je wachtwoord zelf. Vanaf dat moment kan het
  script zelfstandig (dus ook niet-interactief, bijv. als achtergronddienst)
  nieuwe sessietokens ophalen zonder dat je opnieuw hoeft in te loggen.

DAARNA CONTINU LATEN DRAAIEN:
  Zie de instructies onderaan dit bestand (of README.md ernaast) voor het
  instellen als achtergronddienst op Raspberry Pi (systemd) of Windows
  (Taakplanner).
------------------------------------------------------------------------

Vereist: Python 3.8+ en het pakket "requests"
    python3 -m pip install requests
"""

import getpass
import json
import os
import sys
import time
from datetime import datetime, timezone

try:
    import requests
except ImportError:
    print("Het pakket 'requests' ontbreekt. Installeer het met:")
    print("    python3 -m pip install requests")
    sys.exit(1)

# ============================================================================
# Instellingen - pas aan naar jouw situatie, of zet als omgevingsvariabelen
# ============================================================================
P1_IP = os.environ.get("P1_IP", "192.168.178.161")
SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://sdkzzjrtmtzfvjrgpqbm.supabase.co")
SUPABASE_ANON_KEY = os.environ.get(
    "SUPABASE_ANON_KEY", "sb_publishable_voz3n3LyggJR6maHgsER9Q_7oNJW39W"
)
POLL_INTERVAL_SEC = int(os.environ.get("POLL_INTERVAL_SEC", "10"))

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
STATE_FILE = os.path.join(SCRIPT_DIR, "poller_state.json")

MINUTE_LOG_URL = SUPABASE_URL + "/rest/v1/minute_log"
FAULT_LOG_URL = SUPABASE_URL + "/rest/v1/fault_log"


# ============================================================================
# Lokale status (ververs-token + laatst bekende storingstellers) - zodat een
# herstart van dit script niet steeds opnieuw hoeft in te loggen en geen
# storingen dubbel/mist telt.
# ============================================================================
def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, OSError):
            pass
    return {}


def save_state(state):
    try:
        with open(STATE_FILE, "w", encoding="utf-8") as f:
            json.dump(state, f)
        try:
            os.chmod(STATE_FILE, 0o600)  # bevat een gevoelig token: alleen voor de eigenaar leesbaar
        except OSError:
            pass  # niet elk platform (bijv. Windows) ondersteunt chmod hetzelfde, negeren
    except OSError as e:
        print(f"Waarschuwing: kon status niet opslaan ({e})")


# ============================================================================
# Supabase Auth - zelfde endpoints als het dashboard gebruikt
# ============================================================================
def auth_request(path, body):
    res = requests.post(
        SUPABASE_URL + path,
        json=body,
        headers={"apikey": SUPABASE_ANON_KEY, "Content-Type": "application/json"},
        timeout=15,
    )
    data = {}
    try:
        data = res.json()
    except ValueError:
        pass
    if not res.ok:
        msg = data.get("error_description") or data.get("msg") or data.get("error") or f"HTTP {res.status_code}"
        raise RuntimeError(msg)
    return data


def sign_in(email, password):
    return auth_request("/auth/v1/token?grant_type=password", {"email": email, "password": password})


def refresh_session(refresh_token):
    return auth_request("/auth/v1/token?grant_type=refresh_token", {"refresh_token": refresh_token})


class Session:
    """Houdt het huidige toegangstoken bij en ververst het zelf zodra nodig."""

    def __init__(self):
        self.access_token = None
        self.refresh_token = None
        self.expires_at = 0  # unix-timestamp

    def ensure_valid(self):
        if self.access_token and time.time() < self.expires_at - 60:
            return  # nog minstens een minuut geldig

        state = load_state()
        if not self.refresh_token:
            self.refresh_token = state.get("refresh_token")

        if self.refresh_token:
            try:
                data = refresh_session(self.refresh_token)
                self._apply(data)
                return
            except Exception as e:
                print(f"Kon sessie niet verversen ({e}), opnieuw inloggen vereist.")
                self.refresh_token = None

        # Geen (geldig) ververs-token beschikbaar: alleen mogelijk als er een
        # terminal is om interactief in te loggen (eenmalige setup-stap).
        if not sys.stdin.isatty():
            raise RuntimeError(
                "Geen geldige sessie en geen terminal beschikbaar om in te loggen. "
                "Draai dit script eenmaal handmatig (python3 p1-poller.py) om in te loggen, "
                "en start daarna pas de achtergronddienst."
            )

        print("Log in met hetzelfde e-mailadres/wachtwoord als het V3L HomeWizard-dashboard.")
        email = input("E-mailadres: ").strip()
        password = getpass.getpass("Wachtwoord: ")
        data = sign_in(email, password)
        self._apply(data)
        print("Ingelogd. Vanaf nu logt dit script zelfstandig verder zonder opnieuw te hoeven inloggen.")

    def _apply(self, data):
        self.access_token = data["access_token"]
        self.refresh_token = data["refresh_token"]
        self.expires_at = time.time() + data.get("expires_in", 3600)
        state = load_state()
        state["refresh_token"] = self.refresh_token
        save_state(state)

    def headers(self):
        return {
            "apikey": SUPABASE_ANON_KEY,
            "Authorization": "Bearer " + self.access_token,
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        }


# ============================================================================
# P1-meter uitlezen
# ============================================================================
def poll_meter():
    url = P1_IP
    if not url.startswith("http://") and not url.startswith("https://"):
        url = "http://" + url
    url = url.rstrip("/") + "/api/v1/data"
    res = requests.get(url, timeout=10)
    res.raise_for_status()
    return res.json()


def total_import_kwh(d):
    if "total_power_import_kwh" in d:
        return d["total_power_import_kwh"]
    return sum(d.get(f"total_power_import_t{n}_kwh", 0) or 0 for n in (1, 2, 3, 4))


FAULT_COUNTER_FIELDS = {
    "any": "any_power_fail_count",
    "long": "long_power_fail_count",
    "sag1": "voltage_sag_l1_count",
    "sag2": "voltage_sag_l2_count",
    "sag3": "voltage_sag_l3_count",
    "swell1": "voltage_swell_l1_count",
    "swell2": "voltage_swell_l2_count",
    "swell3": "voltage_swell_l3_count",
}


# ============================================================================
# Wegschrijven naar Supabase (zelfde tabellen/kolommen als het dashboard)
# ============================================================================
def push_minute_log(session, minute_start, avgs):
    session.ensure_valid()
    body = {
        "log_time": minute_start.astimezone(timezone.utc).isoformat(),
        "total": avgs.get("total"),
        "l1": avgs.get("l1"),
        "l2": avgs.get("l2"),
        "l3": avgs.get("l3"),
    }
    res = requests.post(MINUTE_LOG_URL, json=body, headers=session.headers(), timeout=15)
    if not res.ok:
        print(f"Kon minuutregel niet wegschrijven: HTTP {res.status_code} - {res.text[:200]}")
    else:
        print(f"[{minute_start:%Y-%m-%d %H:%M}] verbruikslog: totaal={avgs.get('total')} W")


def push_fault_event(session, event_time, fault_type, count):
    session.ensure_valid()
    body = {
        "event_time": event_time.astimezone(timezone.utc).isoformat(),
        "type": fault_type,
        "count": count,
    }
    res = requests.post(FAULT_LOG_URL, json=body, headers=session.headers(), timeout=15)
    if not res.ok:
        print(f"Kon storingsregel niet wegschrijven: HTTP {res.status_code} - {res.text[:200]}")
    else:
        print(f"[{event_time:%Y-%m-%d %H:%M:%S}] storingslog: {fault_type} (+{count})")


# ============================================================================
# Hoofdlus
# ============================================================================
def main():
    print(f"V3L HomeWizard-poller gestart. P1-meter: {P1_IP}, interval: {POLL_INTERVAL_SEC}s")
    session = Session()
    session.ensure_valid()

    state = load_state()
    prev_fault_counts = state.get("prev_fault_counts")  # None bij allereerste run ooit

    minute_key = None
    accum = {"total": [], "l1": [], "l2": [], "l3": []}
    minute_start = None

    while True:
        try:
            d = poll_meter()
            now = datetime.now().astimezone()

            # --- Storingstellers: alleen vergelijken als we al een vorige meting hebben,
            # anders zou een script-herstart een valse uitslag geven. ---
            counts = {key: d.get(field) for key, field in FAULT_COUNTER_FIELDS.items()}
            if prev_fault_counts:
                for key, cur in counts.items():
                    prev = prev_fault_counts.get(key)
                    if cur is not None and prev is not None and cur > prev:
                        push_fault_event(session, now, key, cur - prev)
            prev_fault_counts = counts
            state["prev_fault_counts"] = prev_fault_counts
            save_state(state)

            # --- Verbruik per minuut middelen, zelfde aanpak als het dashboard ---
            key = now.strftime("%Y-%m-%d %H:%M")
            if minute_key is None:
                minute_key = key
                minute_start = now
            if key != minute_key:
                avgs = {
                    k: (sum(v) / len(v) if v else None) for k, v in accum.items()
                }
                push_minute_log(session, minute_start, avgs)
                accum = {"total": [], "l1": [], "l2": [], "l3": []}
                minute_key = key
                minute_start = now

            accum["total"].append(d.get("active_power_w"))
            accum["l1"].append(d.get("active_power_l1_w"))
            accum["l2"].append(d.get("active_power_l2_w"))
            accum["l3"].append(d.get("active_power_l3_w"))
            accum = {k: [x for x in v if x is not None] for k, v in accum.items()}

        except requests.RequestException as e:
            print(f"Kon de P1-meter niet bereiken ({e}), volgende poging over {POLL_INTERVAL_SEC}s.")
        except Exception as e:
            print(f"Onverwachte fout: {e}")

        time.sleep(POLL_INTERVAL_SEC)


if __name__ == "__main__":
    main()
