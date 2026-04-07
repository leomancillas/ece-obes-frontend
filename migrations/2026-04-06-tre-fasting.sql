-- ECE OBES — TRE / Ayuno intermitente en perfil nutricional
ALTER TABLE obes_nutrition_profile
  ADD COLUMN IF NOT EXISTS fasting_protocol TEXT,        -- tre_16_8, tre_14_10, tre_18_6, tre_20_4, omad, adf, 5_2, custom
  ADD COLUMN IF NOT EXISTS fasting_window_start TIME,    -- inicio ventana alimentación
  ADD COLUMN IF NOT EXISTS fasting_window_end TIME,      -- fin ventana alimentación
  ADD COLUMN IF NOT EXISTS fasting_days_per_week INT,
  ADD COLUMN IF NOT EXISTS fasting_adherence_pct NUMERIC,
  ADD COLUMN IF NOT EXISTS fasting_since DATE,
  ADD COLUMN IF NOT EXISTS fasting_notes TEXT;
