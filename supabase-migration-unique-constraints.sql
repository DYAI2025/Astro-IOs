-- ============================================================
-- MIGRATION: Enforce one-per-user constraints
-- Run in Supabase SQL Editor ONCE on existing databases.
-- Safe to run multiple times (idempotent).
-- ============================================================

-- Step 1: Remove duplicate birth_data rows (keep one per user)
DELETE FROM birth_data a
USING birth_data b
WHERE a.user_id = b.user_id
  AND a.ctid > b.ctid;

-- Step 2: Remove duplicate natal_charts rows (keep one per user)
DELETE FROM natal_charts a
USING natal_charts b
WHERE a.user_id = b.user_id
  AND a.ctid > b.ctid;

-- Step 3: Add UNIQUE constraints
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'birth_data_user_id_key') THEN
    ALTER TABLE birth_data ADD CONSTRAINT birth_data_user_id_key UNIQUE (user_id);
    RAISE NOTICE 'Added UNIQUE constraint to birth_data.user_id';
  ELSE
    RAISE NOTICE 'birth_data.user_id UNIQUE constraint already exists';
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'natal_charts_user_id_key') THEN
    ALTER TABLE natal_charts ADD CONSTRAINT natal_charts_user_id_key UNIQUE (user_id);
    RAISE NOTICE 'Added UNIQUE constraint to natal_charts.user_id';
  ELSE
    RAISE NOTICE 'natal_charts.user_id UNIQUE constraint already exists';
  END IF;
END $$;

-- Step 4: Verify astro_profiles PK
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE table_name = 'astro_profiles'
      AND constraint_type = 'PRIMARY KEY'
  ) THEN
    RAISE NOTICE 'astro_profiles PK on user_id confirmed ✓';
  ELSE
    RAISE WARNING 'astro_profiles has no PRIMARY KEY — this is unexpected!';
  END IF;
END $$;

-- Step 5: Tighten RLS — INSERT-only (no UPDATE/DELETE via client)
DROP POLICY IF EXISTS "Users upsert own astro_profile" ON astro_profiles;
DROP POLICY IF EXISTS "Users read own astro_profile" ON astro_profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON astro_profiles;
DROP POLICY IF EXISTS "Users can insert own profile once" ON astro_profiles;

CREATE POLICY "Users can read own profile" ON astro_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile once" ON astro_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
