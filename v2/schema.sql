-- ============================================================
-- Dusit Connect v2 — Supabase Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- 1. STAFF TABLE
CREATE TABLE IF NOT EXISTS staff (
  id          TEXT PRIMARY KEY,            -- e.g. hk001, sup001
  password    TEXT NOT NULL,
  name        TEXT NOT NULL,
  nickname    TEXT NOT NULL DEFAULT '',
  role        TEXT NOT NULL CHECK (role IN ('supervisor','housekeeper','frontdesk','manager','admin')),
  status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active','inactive'))
);

-- 2. ROOMS TABLE (one row per room per day)
CREATE TABLE IF NOT EXISTS rooms (
  id            BIGSERIAL PRIMARY KEY,
  room_no       TEXT NOT NULL,
  floor         INTEGER NOT NULL,
  date          DATE NOT NULL,
  status        TEXT NOT NULL DEFAULT 'unassigned'
                  CHECK (status IN ('unassigned','pending','cleaning','done','passed','ack')),
  assigned_to   TEXT REFERENCES staff(id) ON DELETE SET NULL,
  assigned_name TEXT NOT NULL DEFAULT '',
  start_time    TIMESTAMPTZ,
  end_time      TIMESTAMPTZ,
  note          TEXT NOT NULL DEFAULT '',
  UNIQUE (room_no, date)
);

CREATE INDEX IF NOT EXISTS rooms_date_idx   ON rooms (date);
CREATE INDEX IF NOT EXISTS rooms_status_idx ON rooms (status);

-- 3. HISTORY TABLE
CREATE TABLE IF NOT EXISTS history (
  id         BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  room_no    TEXT NOT NULL,
  user_id    TEXT NOT NULL,
  user_name  TEXT NOT NULL DEFAULT '',
  action     TEXT NOT NULL,
  note       TEXT NOT NULL DEFAULT ''
);

CREATE INDEX IF NOT EXISTS history_room_idx ON history (room_no);
CREATE INDEX IF NOT EXISTS history_date_idx ON history (created_at);

-- 4. REGISTRATIONS TABLE (from LINE LIFF register page)
CREATE TABLE IF NOT EXISTS registrations (
  id                BIGSERIAL PRIMARY KEY,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  line_user_id      TEXT NOT NULL,
  line_display_name TEXT NOT NULL DEFAULT '',
  branch            TEXT NOT NULL DEFAULT '',
  full_name         TEXT NOT NULL,
  nickname          TEXT NOT NULL DEFAULT '',
  phone             TEXT NOT NULL DEFAULT '',
  role              TEXT NOT NULL,
  department        TEXT NOT NULL,
  status            TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected'))
);

-- ============================================================
-- ROW LEVEL SECURITY
-- The app uses custom username/password auth (not Supabase Auth).
-- We allow anon access to all tables since auth is enforced client-side.
-- For production, consider restricting with JWT claims or Edge Functions.
-- ============================================================

ALTER TABLE staff   ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms   ENABLE ROW LEVEL SECURITY;
ALTER TABLE history ENABLE ROW LEVEL SECURITY;

ALTER TABLE registrations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_all" ON staff;
DROP POLICY IF EXISTS "anon_all" ON rooms;
DROP POLICY IF EXISTS "anon_all" ON history;
DROP POLICY IF EXISTS "anon_all" ON registrations;

CREATE POLICY "anon_all" ON staff         FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON rooms         FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON history       FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_all" ON registrations FOR ALL TO anon USING (true) WITH CHECK (true);

-- ============================================================
-- SEED: STAFF DATA
-- ============================================================

INSERT INTO staff (id, password, name, nickname, role, status) VALUES
  ('admin001','1234','ผู้ดูแลระบบ','แอดมิน','admin','active'),
  ('sup001','1234','สมชาย ดูแลดี','ชาย','supervisor','active'),
  ('sup002','1234','สุดา ใจดี','สุดา','supervisor','active'),
  ('hk001','1234','สมหญิง ใจดี','หญิง','housekeeper','active'),
  ('hk002','1234','มาลี รักงาน','มาลี','housekeeper','active'),
  ('hk003','1234','นุ่น สวยงาม','นุ่น','housekeeper','active'),
  ('hk004','1234','แอ๊ม ขยัน','แอ๊ม','housekeeper','active'),
  ('hk005','1234','นภา ทองดี','นภา','housekeeper','active'),
  ('hk006','1234','กัญญา ใจงาม','กัญญา','housekeeper','active'),
  ('hk007','1234','มยุรี แสงจันทร์','มยุรี','housekeeper','active'),
  ('hk008','1234','ฝน พรมดี','ฝน','housekeeper','active'),
  ('hk009','1234','จิรา สุขใจ','จิรา','housekeeper','active'),
  ('hk010','1234','ดาว ชมพู','ดาว','housekeeper','active'),
  ('hk011','1234','อ้อย มีสุข','อ้อย','housekeeper','active'),
  ('hk012','1234','แป้ง รักดี','แป้ง','housekeeper','active'),
  ('hk013','1234','ปุ้ย ทำงาน','ปุ้ย','housekeeper','active'),
  ('hk014','1234','หน่อย ขันที','หน่อย','housekeeper','active'),
  ('hk015','1234','กิ๊ฟ งานดี','กิ๊ฟ','housekeeper','active'),
  ('hk016','1234','Aye Aye Khin','Aye','housekeeper','active'),
  ('hk017','1234','Phyu Phyu Win','Phyu','housekeeper','active'),
  ('hk018','1234','Moe Moe Lwin','Moe','housekeeper','active'),
  ('hk019','1234','Su Su Htwe','Su','housekeeper','active'),
  ('hk020','1234','Win Win Myint','Win','housekeeper','active'),
  ('hk021','1234','Khin Khin Oo','Khin','housekeeper','active'),
  ('hk022','1234','Thin Thin Aung','Thin','housekeeper','active'),
  ('hk023','1234','Nwe Nwe Soe','Nwe','housekeeper','active'),
  ('hk024','1234','May May Thwe','May','housekeeper','active'),
  ('hk025','1234','Hnin Hnin Wai','Hnin','housekeeper','active'),
  ('hk026','1234','Ei Ei Mon','Ei','housekeeper','active'),
  ('hk027','1234','Cho Cho Zin','Cho','housekeeper','active'),
  ('hk028','1234','Zin Zin Aye','Zin','housekeeper','active'),
  ('hk029','1234','Yee Yee Naing','Yee','housekeeper','active'),
  ('hk030','1234','San San Myat','San','housekeeper','active'),
  ('fd001','1234','วิชัย ต้อนรับ','วิชัย','frontdesk','active'),
  ('fd002','1234','กมล สวัสดี','กมล','frontdesk','active'),
  ('mgr001','1234','พิมพ์ใจ บริหาร','พิมพ์','manager','active')
ON CONFLICT (id) DO NOTHING;
