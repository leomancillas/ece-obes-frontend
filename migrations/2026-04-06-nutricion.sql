-- ═══════════════════════════════════════════════════════════════════════════
-- ECE OBES — Migración módulo Nutrición (2026-04-06)
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Composición corporal ampliada ───────────────────────────────────────────
ALTER TABLE obes_measurements
  ADD COLUMN IF NOT EXISTS body_fat_pct NUMERIC,
  ADD COLUMN IF NOT EXISTS fat_mass_kg NUMERIC,
  ADD COLUMN IF NOT EXISTS lean_mass_kg NUMERIC,
  ADD COLUMN IF NOT EXISTS muscle_mass_kg NUMERIC,
  ADD COLUMN IF NOT EXISTS visceral_fat_level NUMERIC,
  ADD COLUMN IF NOT EXISTS body_water_pct NUMERIC,
  ADD COLUMN IF NOT EXISTS bone_mass_kg NUMERIC,
  ADD COLUMN IF NOT EXISTS ffmi NUMERIC,
  ADD COLUMN IF NOT EXISTS fmi NUMERIC,
  ADD COLUMN IF NOT EXISTS asmi NUMERIC,
  ADD COLUMN IF NOT EXISTS bai NUMERIC,
  ADD COLUMN IF NOT EXISTS skinfold_tricipital NUMERIC,
  ADD COLUMN IF NOT EXISTS skinfold_subscapular NUMERIC,
  ADD COLUMN IF NOT EXISTS skinfold_suprailiac NUMERIC,
  ADD COLUMN IF NOT EXISTS arm_circumference NUMERIC,
  ADD COLUMN IF NOT EXISTS thigh_circumference NUMERIC,
  ADD COLUMN IF NOT EXISTS calf_circumference NUMERIC,
  ADD COLUMN IF NOT EXISTS systolic_bp NUMERIC,
  ADD COLUMN IF NOT EXISTS diastolic_bp NUMERIC;

-- ── Plan nutricional estructurado ──────────────────────────────────────────
ALTER TABLE obes_nutrition_plans
  ADD COLUMN IF NOT EXISTS tmb_kcal NUMERIC,
  ADD COLUMN IF NOT EXISTS get_kcal NUMERIC,
  ADD COLUMN IF NOT EXISTS deficit_pct NUMERIC,
  ADD COLUMN IF NOT EXISTS protein_g_per_kg_lean NUMERIC,
  ADD COLUMN IF NOT EXISTS protein_g NUMERIC,
  ADD COLUMN IF NOT EXISTS carbs_g NUMERIC,
  ADD COLUMN IF NOT EXISTS fats_g NUMERIC,
  ADD COLUMN IF NOT EXISTS fiber_g NUMERIC,
  ADD COLUMN IF NOT EXISTS sodium_mg NUMERIC,
  ADD COLUMN IF NOT EXISTS water_ml NUMERIC,
  ADD COLUMN IF NOT EXISTS meals_per_day INT,
  ADD COLUMN IF NOT EXISTS dietary_pattern TEXT,
  ADD COLUMN IF NOT EXISTS activity_factor NUMERIC,
  ADD COLUMN IF NOT EXISTS adherence_pct NUMERIC,
  ADD COLUMN IF NOT EXISTS plan_structure JSONB,
  ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS start_date DATE DEFAULT CURRENT_DATE;

-- ── Calorimetría indirecta ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS obes_calorimetry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  measure_date DATE DEFAULT CURRENT_DATE,
  method TEXT,                          -- indirect_canopy, indirect_mask, doubly_labeled_water, predictive
  ree_measured_kcal NUMERIC,            -- REE medido
  ree_predicted_kcal NUMERIC,           -- REE predicho (Mifflin)
  ree_ratio NUMERIC,                    -- medido/predicho
  rq NUMERIC,                           -- cociente respiratorio
  vo2_ml_min NUMERIC,
  vco2_ml_min NUMERIC,
  substrate_oxidation TEXT,             -- carbs_dominant, balanced, fat_dominant
  metabolic_status TEXT,                -- hipometabólico, normometabólico, hipermetabólico
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_calorimetry_patient ON obes_calorimetry(patient_id, measure_date DESC);

-- ── Recordatorio 24h / diario alimentario ──────────────────────────────────
CREATE TABLE IF NOT EXISTS obes_food_recalls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  recall_date DATE DEFAULT CURRENT_DATE,
  recall_type TEXT,                     -- 24h, 3day, 7day, food_diary
  total_kcal NUMERIC,
  protein_g NUMERIC,
  carbs_g NUMERIC,
  fats_g NUMERIC,
  fiber_g NUMERIC,
  sodium_mg NUMERIC,
  water_ml NUMERIC,
  meals_logged INT,
  ultra_processed_pct NUMERIC,           -- % calorías ultraprocesados
  fruits_servings NUMERIC,
  vegetables_servings NUMERIC,
  added_sugar_g NUMERIC,
  alcohol_g NUMERIC,
  meals_detail JSONB,                    -- array de comidas estructuradas
  hunger_score INT,                      -- 0-10 promedio
  satiety_score INT,                     -- 0-10 promedio
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_food_recalls_patient ON obes_food_recalls(patient_id, recall_date DESC);

-- ── Conducta alimentaria (TFEQ-R21 + adherencia) ────────────────────────────
CREATE TABLE IF NOT EXISTS obes_eating_behavior (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  assessment_date DATE DEFAULT CURRENT_DATE,
  -- TFEQ-R21 subscales (0-100)
  tfeq_cognitive_restraint NUMERIC,
  tfeq_uncontrolled_eating NUMERIC,
  tfeq_emotional_eating NUMERIC,
  -- Mediterranean adherence (PREDIMED 14)
  predimed_score INT,
  predimed_category TEXT,                -- baja, media, alta
  -- Self-reported adherence to plan
  adherence_pct NUMERIC,
  hunger_pattern TEXT,                   -- normal, hyperphagia, grazing, night_eating
  emotional_triggers TEXT[],
  binge_episodes_week INT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_eating_behavior_patient ON obes_eating_behavior(patient_id, assessment_date DESC);

-- ── Intolerancias, preferencias, riesgo nutricional ────────────────────────
CREATE TABLE IF NOT EXISTS obes_nutrition_profile (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID UNIQUE NOT NULL,
  -- Intolerancias y alergias
  food_allergies TEXT[],                 -- mariscos, nueces, soya, lácteos, gluten, etc.
  food_intolerances TEXT[],              -- lactosa, fructosa, FODMAPs, histamina, etc.
  -- Preferencias
  dietary_preferences TEXT[],            -- vegetariano, vegano, pescetariano, halal, kosher, sin_cerdo
  cultural_pattern TEXT,                 -- mexicano, mediterraneo, asiatico, etc.
  food_dislikes TEXT[],
  -- Comorbilidades nutricionales relevantes
  has_dm2 BOOLEAN,
  has_erc BOOLEAN,
  has_dyslipidemia BOOLEAN,
  has_hta BOOLEAN,
  has_masld BOOLEAN,
  has_celiac BOOLEAN,
  has_ibd BOOLEAN,
  has_sii BOOLEAN,
  has_hyperuricemia BOOLEAN,
  -- Riesgo nutricional
  must_score INT,                        -- Malnutrition Universal Screening Tool 0-6
  must_category TEXT,                    -- bajo, medio, alto
  micronutrient_deficiencies TEXT[],     -- vit_d, b12, hierro, folato, zinc, etc.
  -- Hábitos
  alcohol_units_week NUMERIC,
  smoking BOOLEAN,
  budget_constraint TEXT,                -- bajo, medio, alto
  cooking_skill TEXT,                    -- ninguno, basico, intermedio, avanzado
  meal_environment TEXT,                 -- casa, oficina, restaurante, calle
  notes TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_nutrition_profile_patient ON obes_nutrition_profile(patient_id);

-- ── RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE obes_calorimetry ENABLE ROW LEVEL SECURITY;
ALTER TABLE obes_food_recalls ENABLE ROW LEVEL SECURITY;
ALTER TABLE obes_eating_behavior ENABLE ROW LEVEL SECURITY;
ALTER TABLE obes_nutrition_profile ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS obes_calo_all ON obes_calorimetry;
CREATE POLICY obes_calo_all ON obes_calorimetry FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS obes_recall_all ON obes_food_recalls;
CREATE POLICY obes_recall_all ON obes_food_recalls FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS obes_eb_all ON obes_eating_behavior;
CREATE POLICY obes_eb_all ON obes_eating_behavior FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS obes_np_all ON obes_nutrition_profile;
CREATE POLICY obes_np_all ON obes_nutrition_profile FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
