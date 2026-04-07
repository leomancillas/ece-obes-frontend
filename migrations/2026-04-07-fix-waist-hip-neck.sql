-- Faltaban las circunferencias clásicas en obes_measurements
ALTER TABLE obes_measurements
  ADD COLUMN IF NOT EXISTS waist_cm NUMERIC,
  ADD COLUMN IF NOT EXISTS hip_cm NUMERIC,
  ADD COLUMN IF NOT EXISTS neck_cm NUMERIC;
