-- V3L EnergyControl / V3L HomeWizard
-- Supabase-schema (project sdkzzjrtmtzfvjrgpqbm, "V3L HomeWizard")
--
-- Dit bestand is een documentatie-/herstelkopie van het schema zoals het op
-- 22-09-2026 in Supabase staat. Het is niet automatisch gekoppeld aan het
-- project: wijzig het schema via de Supabase-tools/dashboard en werk dit
-- bestand daarna handmatig bij (of via een migratie-tool als dat later
-- wordt ingericht).
--
-- Alle tabellen staan in het schema "public" en hebben Row Level Security
-- aan staan met policies voor de rol "authenticated". De app en Home
-- Assistant loggen beide in met hetzelfde vaste account
-- (arjan@familievandriel.nl) via /auth/v1/token?grant_type=password en
-- praten daarna met deze tabellen via PostgREST.

-- ============================================================
-- latest_status - live meterstand (1 rij, wordt overschreven)
-- ============================================================
create table if not exists public.latest_status (
  id boolean primary key default true,
  active_power_w double precision,
  active_power_l1_w double precision,
  active_power_l2_w double precision,
  active_power_l3_w double precision,
  active_voltage_l1_v double precision,
  active_voltage_l2_v double precision,
  active_voltage_l3_v double precision,
  active_voltage_v double precision,
  active_current_l1_a double precision,
  active_current_l2_a double precision,
  active_current_l3_a double precision,
  active_current_a double precision,
  total_power_import_kwh double precision,
  total_power_export_kwh double precision,
  total_gas_m3 double precision,
  gas_timestamp text,
  water_m3 double precision,
  meter_model text,
  smr_version integer,
  unique_id text,
  unique_id_gas text,
  any_power_fail_count integer,
  long_power_fail_count integer,
  voltage_sag_l1_count integer,
  voltage_sag_l2_count integer,
  voltage_sag_l3_count integer,
  voltage_swell_l1_count integer,
  voltage_swell_l2_count integer,
  voltage_swell_l3_count integer,
  updated_at timestamptz not null default now(),
  constraint latest_status_single_row check (id = true)
);

alter table public.latest_status enable row level security;
create policy "authenticated can select latest_status" on public.latest_status for select to authenticated using (true);
create policy "authenticated can insert latest_status" on public.latest_status for insert to authenticated with check (true);
create policy "authenticated can update latest_status" on public.latest_status for update to authenticated using (true) with check (true);

-- ============================================================
-- minute_log - historie, 1 rij per minuut (vermogens in watt)
-- ============================================================
create table if not exists public.minute_log (
  id bigint generated always as identity primary key,
  log_time timestamptz not null,
  total double precision,
  l1 double precision,
  l2 double precision,
  l3 double precision,
  created_at timestamptz not null default now()
);

alter table public.minute_log enable row level security;
create policy "authenticated can select minute_log" on public.minute_log for select to authenticated using (true);
create policy "authenticated can insert minute_log" on public.minute_log for insert to authenticated with check (true);
-- Bewust geen update-policy: minute_log is append-only.

-- ============================================================
-- fault_log - loggen van storingstellers (stijgingen)
-- type: 'any' | 'long' | 'sag1'..'sag3' | 'swell1'..'swell3'
-- ============================================================
create table if not exists public.fault_log (
  id bigint generated always as identity primary key,
  event_time timestamptz not null,
  type text not null,
  count integer not null,
  created_at timestamptz not null default now()
);

alter table public.fault_log enable row level security;
create policy "authenticated can select fault_log" on public.fault_log for select to authenticated using (true);
create policy "authenticated can insert fault_log" on public.fault_log for insert to authenticated with check (true);

-- ============================================================
-- daily_cost - dagtotalen en berekende kosten, 1 rij per dag
-- ============================================================
create table if not exists public.daily_cost (
  log_date date primary key,
  import_kwh_start double precision,
  export_kwh_start double precision,
  gas_m3_start double precision,
  import_kwh_now double precision,
  export_kwh_now double precision,
  gas_m3_now double precision,
  elec_cost double precision,
  gas_cost double precision,
  total_cost double precision,
  updated_at timestamptz not null default now()
);

alter table public.daily_cost enable row level security;
create policy "authenticated can select daily_cost" on public.daily_cost for select to authenticated using (true);
create policy "authenticated can insert daily_cost" on public.daily_cost for insert to authenticated with check (true);
create policy "authenticated can update daily_cost" on public.daily_cost for update to authenticated using (true) with check (true);

-- ============================================================
-- app_settings - gedeelde instellingen (o.a. tarieven, drempel)
-- Wordt zowel door de app als door Home Assistant gebruikt;
-- de tarieven (p1_elec_price/p1_gas_price) worden sinds app 3.65
-- alleen nog vanuit Home Assistant geschreven, de app leest ze
-- read-only.
-- ============================================================
create table if not exists public.app_settings (
  field_id text primary key,
  value text,
  updated_at timestamptz default now()
);

alter table public.app_settings enable row level security;
create policy "authenticated can select app_settings" on public.app_settings for select to authenticated using (true);
create policy "authenticated can insert app_settings" on public.app_settings for insert to authenticated with check (true);
create policy "authenticated can update app_settings" on public.app_settings for update to authenticated using (true) with check (true);

-- Bekende field_id's in app_settings (huidige stand, 20-09-2026):
--   p1_elec_price               - stroomtarief euro/kWh (uit HA-helper input_number.stroomprijs)
--   p1_gas_price                - gastarief euro/m3 (uit HA-helper input_number.gasprijs)
--   p1_overload_w                - historisch, wordt niet meer gebruikt: de app heeft de
--                                   drempel sinds 3.65 vast op 5250 W staan
--   p1_interval, p1_ip           - instellingen voor de rechtstreekse P1-verbinding
--   p1_supabase_low_interval_sec,
--   p1_supabase_threshold_w      - overgeerfd uit de oude serverversie, functie niet
--                                   opnieuw geverifieerd in dit project

-- ============================================================
-- email_settings - e-mailwaarschuwingsconfiguratie (overload/storage)
-- Bevat EmailJS service/template/public key en het bestemmings-
-- adres; geen geheime sleutels (die staan als Edge Function secrets).
-- ============================================================
create table if not exists public.email_settings (
  field_id text primary key,
  value text,
  updated_at timestamptz default now()
);

alter table public.email_settings enable row level security;
create policy "authenticated can select email_settings" on public.email_settings for select to authenticated using (true);
create policy "authenticated can insert email_settings" on public.email_settings for insert to authenticated with check (true);
create policy "authenticated can update email_settings" on public.email_settings for update to authenticated using (true) with check (true);

-- ============================================================
-- email_send_log - teller van verstuurde waarschuwingsmails
-- Wordt alleen door de Edge Function send-alert-email geschreven
-- (met de service-role-sleutel, buiten RLS om) na een geslaagde
-- verzending. Alleen leesbaar voor authenticated.
-- ============================================================
create table if not exists public.email_send_log (
  id bigint generated always as identity primary key,
  kind text not null check (kind in ('overload', 'storage')),
  sent_at timestamptz not null default now()
);

alter table public.email_send_log enable row level security;
create policy "authenticated can select email_send_log" on public.email_send_log for select to authenticated using (true);
-- Bewust geen insert/update-policy voor authenticated: alleen de Edge
-- Function (service role) schrijft hierin.

-- ============================================================
-- field_locks - (huidige status/gebruik niet volledig herzien in dit project)
-- ============================================================
create table if not exists public.field_locks (
  field_id text primary key,
  locked boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.field_locks enable row level security;
create policy "authenticated can select field_locks" on public.field_locks for select to authenticated using (true);
create policy "authenticated can insert field_locks" on public.field_locks for insert to authenticated with check (true);
create policy "authenticated can update field_locks" on public.field_locks for update to authenticated using (true) with check (true);

-- ============================================================
-- photo_meta - (huidige status/gebruik niet volledig herzien in dit project)
-- ============================================================
create table if not exists public.photo_meta (
  name text primary key,
  sort_order integer not null default 0,
  caption text,
  taken_at timestamptz,
  updated_at timestamptz not null default now()
);

alter table public.photo_meta enable row level security;
create policy "authenticated can select photo_meta" on public.photo_meta for select to authenticated using (true);
create policy "authenticated can insert photo_meta" on public.photo_meta for insert to authenticated with check (true);
create policy "authenticated can update photo_meta" on public.photo_meta for update to authenticated using (true) with check (true);
create policy "authenticated can delete photo_meta" on public.photo_meta for delete to authenticated using (true);

-- ============================================================
-- Functies
-- ============================================================

-- get_daily_totals(): kWh-totalen per dag uit minute_log, gebruikt
-- door de app voor de tabel "Verbruik per dag".
create or replace function public.get_daily_totals()
returns table (
  day date,
  wh double precision,
  l1_wh double precision,
  l2_wh double precision,
  l3_wh double precision,
  minutes_logged bigint
)
language sql
security definer
set search_path to 'public'
as $$
  select
    (log_time at time zone 'Europe/Amsterdam')::date as day,
    sum(total) / 60.0 as wh,
    sum(l1) / 60.0 as l1_wh,
    sum(l2) / 60.0 as l2_wh,
    sum(l3) / 60.0 as l3_wh,
    count(*) as minutes_logged
  from minute_log
  where total is not null
  group by 1
  order by 1;
$$;

-- ha_update_daily_cost(p_import, p_gas, p_export): wordt elke minuut
-- door Home Assistant aangeroepen (rest_command.supabase_update_cost,
-- automatisering "Kosten naar Supabase") zodat daily_cost ook bijwerkt
-- als de app niet open staat. Maakt de dagrij aan als die nog niet
-- bestaat, en slaat een onmogelijke gasstand (>100 m3 sinds
-- middernacht) over in plaats van hem te verwerken - dat voorkwam op
-- 20-09-2026 een dag met "7050 euro" gaskosten door een verkeerd
-- gekozen HA-sensor bij de dagstart.
create or replace function public.ha_update_daily_cost(
  p_import double precision,
  p_gas double precision default null,
  p_export double precision default null
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_date date := (now() at time zone 'Europe/Amsterdam')::date;
  v_ep double precision;
  v_gp double precision;
  r public.daily_cost%rowtype;
  v_exp double precision;
  v_elec double precision;
  v_gas double precision;
  v_gas_now double precision;
begin
  if p_import is null then
    return;
  end if;

  select value::double precision into v_ep from public.app_settings where field_id = 'p1_elec_price';
  select value::double precision into v_gp from public.app_settings where field_id = 'p1_gas_price';
  if v_ep is null or v_gp is null then
    return;
  end if;

  -- Dagrij aanmaken als die er (nog) niet is: start = eerste meting van de dag.
  insert into public.daily_cost
    (log_date, import_kwh_start, export_kwh_start, gas_m3_start,
     import_kwh_now, export_kwh_now, gas_m3_now, updated_at)
  values
    (v_date, p_import, 0, p_gas, p_import, coalesce(p_export, 0), p_gas, now())
  on conflict (log_date) do nothing;

  select * into r from public.daily_cost where log_date = v_date;

  -- Meterstand mag nooit onder de dagstart komen (bv. meterwissel/fout): overslaan.
  if r.import_kwh_start is null or p_import < r.import_kwh_start then
    return;
  end if;

  v_exp := coalesce(p_export, r.export_kwh_now, 0);
  v_elec := ((p_import - r.import_kwh_start) - (v_exp - coalesce(r.export_kwh_start, 0))) * v_ep;

  -- Gas: alleen bijwerken als de stand plausibel is (0-100 m3 sinds dagstart).
  -- Anders de bestaande gaskosten laten staan i.p.v. onzin (bv. 7050 euro) weg te schrijven.
  if p_gas is not null and r.gas_m3_start is not null
     and p_gas >= r.gas_m3_start and p_gas - r.gas_m3_start <= 100 then
    v_gas := (p_gas - r.gas_m3_start) * v_gp;
    v_gas_now := p_gas;
  else
    v_gas := coalesce(r.gas_cost, 0);
    v_gas_now := r.gas_m3_now;
  end if;

  update public.daily_cost
  set import_kwh_now = p_import,
      export_kwh_now = v_exp,
      gas_m3_now = v_gas_now,
      elec_cost = v_elec,
      gas_cost = v_gas,
      total_cost = v_elec + v_gas,
      updated_at = now()
  where log_date = v_date;
end;
$$;

revoke all on function public.ha_update_daily_cost(double precision, double precision, double precision) from public;
revoke all on function public.ha_update_daily_cost(double precision, double precision, double precision) from anon;
grant execute on function public.ha_update_daily_cost(double precision, double precision, double precision) to authenticated;
