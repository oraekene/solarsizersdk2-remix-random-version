-- SQL Schema for Supabase (PostgreSQL)
-- Copy and paste this into the Supabase SQL Editor

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE,
  name TEXT,
  picture TEXT,
  provider TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  name TEXT,
  region TEXT,
  battery_preference TEXT,
  devices JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create results table
CREATE TABLE IF NOT EXISTS results (
  id TEXT PRIMARY KEY,
  user_id TEXT REFERENCES users(id) ON DELETE CASCADE,
  profile_name TEXT,
  data JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create hardware table
CREATE TABLE IF NOT EXISTS hardware (
  id TEXT PRIMARY KEY,
  user_id TEXT, -- 'system' or a user id
  type TEXT, -- 'inverter', 'panel', 'battery', 'powerstation', 'accessory'
  data JSONB,
  tags JSONB DEFAULT '[]',
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create master devices table
CREATE TABLE IF NOT EXISTS devices_master (
  id TEXT PRIMARY KEY,
  name TEXT,
  category TEXT,
  default_watts REAL,
  tags JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create products table
CREATE TABLE IF NOT EXISTS products (
  id TEXT PRIMARY KEY,
  name TEXT,
  description TEXT,
  type TEXT, -- 'standalone' or 'combination'
  combination_data JSONB, -- JSON if type is combination
  tags JSONB DEFAULT '[]',
  price REAL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
-- Note: These rules are simple. For production, refine based on your needs.
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE results ENABLE ROW LEVEL SECURITY;
ALTER TABLE hardware ENABLE ROW LEVEL SECURITY;
ALTER TABLE devices_master ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies (Allow users to see and modify only their own data)
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can manage own profiles" ON profiles FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own results" ON results FOR ALL USING (user_id = auth.uid());
CREATE POLICY "Users can manage own hardware" ON hardware FOR ALL USING (user_id = auth.uid() OR user_id = 'system');

-- Public read for master data
CREATE POLICY "Public view master devices" ON devices_master FOR SELECT USING (true);
CREATE POLICY "Public view products" ON products FOR SELECT USING (true);
CREATE POLICY "Public view system hardware" ON hardware FOR SELECT USING (user_id = 'system');

-- Admin write policies (simplified for now, ideally check a role or secret)
CREATE POLICY "Admin manage master devices" ON devices_master FOR ALL USING (true);
CREATE POLICY "Admin manage products" ON products FOR ALL USING (true);
CREATE POLICY "Admin manage system hardware" ON hardware FOR ALL USING (user_id = 'system');
