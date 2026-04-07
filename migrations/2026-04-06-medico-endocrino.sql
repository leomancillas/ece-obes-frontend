-- ═══════════════════════════════════════════════════════════════════════════
-- ECE OBES — Migración módulo Médico/Endocrinología (2026-04-06)
-- Expande labs endocrinos, farmacoterapia, tamizaje secundario, notas clínicas
-- ═══════════════════════════════════════════════════════════════════════════

-- ── Labs endocrino-metabólicos ampliados ───────────────────────────────────
ALTER TABLE obes_lab_results
  ADD COLUMN IF NOT EXISTS homa_beta NUMERIC,
  ADD COLUMN IF NOT EXISTS quicki NUMERIC,
  ADD COLUMN IF NOT EXISTS tyg_index NUMERIC,
  ADD COLUMN IF NOT EXISTS t4_libre NUMERIC,
  ADD COLUMN IF NOT EXISTS t3_libre NUMERIC,
  ADD COLUMN IF NOT EXISTS anti_tpo NUMERIC,
  ADD COLUMN IF NOT EXISTS cortisol_am NUMERIC,
  ADD COLUMN IF NOT EXISTS acth NUMERIC,
  ADD COLUMN IF NOT EXISTS prolactina NUMERIC,
  ADD COLUMN IF NOT EXISTS testosterona_total NUMERIC,
  ADD COLUMN IF NOT EXISTS testosterona_libre NUMERIC,
  ADD COLUMN IF NOT EXISTS shbg NUMERIC,
  ADD COLUMN IF NOT EXISTS lh NUMERIC,
  ADD COLUMN IF NOT EXISTS fsh NUMERIC,
  ADD COLUMN IF NOT EXISTS estradiol NUMERIC,
  ADD COLUMN IF NOT EXISTS igf1 NUMERIC,
  ADD COLUMN IF NOT EXISTS leptina NUMERIC,
  ADD COLUMN IF NOT EXISTS adiponectina NUMERIC,
  ADD COLUMN IF NOT EXISTS pth NUMERIC,
  ADD COLUMN IF NOT EXISTS creatinina NUMERIC,
  ADD COLUMN IF NOT EXISTS egfr NUMERIC,
  ADD COLUMN IF NOT EXISTS microalbuminuria NUMERIC;

-- ── Farmacoterapia anti-obesidad ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS obes_medications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  drug_class TEXT NOT NULL,           -- glp1, glp1_gip, naltrexona_bupropion, fentermina_topiramato, orlistat, setmelanotida, metformina, otro
  drug_name TEXT NOT NULL,            -- semaglutida, tirzepatida, liraglutida, etc.
  dose TEXT,                          -- "0.5 mg sc/sem"
  start_date DATE,
  escalation_plan TEXT,               -- esquema de titulación
  status TEXT DEFAULT 'activo',       -- activo, suspendido, completado
  stop_date DATE,
  stop_reason TEXT,                   -- intolerancia, falta_respuesta, costo, contraindicacion, meta_alcanzada, otro
  baseline_weight_kg NUMERIC,
  current_twl_pct NUMERIC,            -- %TWL alcanzado
  current_ewl_pct NUMERIC,            -- %EWL alcanzado
  adverse_effects TEXT,
  contraindications_checked BOOLEAN DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_medications_patient ON obes_medications(patient_id, start_date DESC);

-- ── Tamizaje endocrino secundario ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS obes_endocrine_screen (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  screen_date DATE DEFAULT CURRENT_DATE,
  -- Cushing
  cushing_clinical_flags TEXT[],       -- estrias_violaceas, cara_luna, joroba, hta_dificil, etc.
  cushing_cortisol_libre_24h NUMERIC,
  cushing_supresion_dexa NUMERIC,
  cushing_status TEXT,                 -- no_evaluado, normal, sospechoso, confirmado
  -- Hipotiroidismo
  hipotiroidismo_status TEXT,          -- no_evaluado, eutiroideo, subclinico, clinico
  -- SOP (Rotterdam)
  sop_oligo_anovulacion BOOLEAN,
  sop_hiperandrogenismo_clinico BOOLEAN,
  sop_hiperandrogenismo_bioquimico BOOLEAN,
  sop_ovarios_poliquisticos_us BOOLEAN,
  sop_status TEXT,                     -- no_evaluado, no_cumple, cumple_rotterdam
  -- Hipogonadismo masculino
  hipogonadismo_status TEXT,           -- no_evaluado, normal, sospechoso, confirmado
  hipogonadismo_sintomas TEXT[],
  -- Deficit GH
  gh_deficit_sospecha BOOLEAN,
  -- Monogénicas
  obesidad_inicio_temprano BOOLEAN,    -- antes 5 años
  consanguinidad BOOLEAN,
  hiperfagia_severa BOOLEAN,
  panel_genetico_solicitado BOOLEAN,
  panel_genetico_resultado TEXT,       -- MC4R, leptina, POMC, otra, negativo
  -- Hipotalámica / iatrogénica
  causa_iatrogenica TEXT,              -- corticoides, antipsicoticos, antidepresivos, insulina_alta_dosis, etc.
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_endocrine_screen_patient ON obes_endocrine_screen(patient_id, screen_date DESC);

-- ── Notas clínicas estructuradas para investigación ────────────────────────
CREATE TABLE IF NOT EXISTS obes_clinical_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id UUID NOT NULL,
  note_date DATE DEFAULT CURRENT_DATE,
  visit_type TEXT,                     -- inicial, seguimiento, urgencia, alta
  visit_number INT,
  -- Estructurados (para investigación)
  motivo_consulta TEXT,
  hpi TEXT,                            -- historia padecimiento actual
  antecedentes_familiares_relevantes TEXT,
  ant_personales_obesidad TEXT,        -- edad inicio, eventos disparadores
  ant_intentos_perdida_peso TEXT,
  exploracion_fisica TEXT,
  acantosis_nigricans BOOLEAN,
  estrias_violaceas BOOLEAN,
  hirsutismo BOOLEAN,
  ginecomastia BOOLEAN,
  edema BOOLEAN,
  -- Plan estructurado
  plan_dx TEXT,
  plan_tx TEXT,
  plan_seguimiento TEXT,
  proxima_cita DATE,
  -- Investigación
  consentimiento_investigacion BOOLEAN DEFAULT FALSE,
  candidato_protocolos TEXT[],         -- IDs de research_protocols donde podría enrolarse
  research_tags TEXT[],                -- libre etiquetado para query futuro
  notes_libres TEXT,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_obes_clinical_notes_patient ON obes_clinical_notes(patient_id, note_date DESC);

-- ── RLS policies ───────────────────────────────────────────────────────────
ALTER TABLE obes_medications ENABLE ROW LEVEL SECURITY;
ALTER TABLE obes_endocrine_screen ENABLE ROW LEVEL SECURITY;
ALTER TABLE obes_clinical_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS obes_meds_all ON obes_medications;
CREATE POLICY obes_meds_all ON obes_medications FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS obes_endo_all ON obes_endocrine_screen;
CREATE POLICY obes_endo_all ON obes_endocrine_screen FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS obes_notes_all ON obes_clinical_notes;
CREATE POLICY obes_notes_all ON obes_clinical_notes FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
