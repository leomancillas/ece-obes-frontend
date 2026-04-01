# ECE OBES — Expediente Clínico Multidisciplinario de Obesidad

## Qué es este proyecto

Aplicación web independiente para el manejo multidisciplinario de pacientes con sobrepeso y obesidad. Proyecto hermano de **ECE META CORE** — mismo backend Supabase, repo de GitHub separado, desplegado en GitHub Pages como archivo HTML único.

El sistema tiene **3 capas**:
1. **Atención clínica** — 7 módulos especializados integrados en un expediente unificado
2. **Analítica poblacional** — todos los campos tipados y consultables en SQL
3. **Proyectos de investigación** — protocolos, CRF, exportación REDCap

---

## Stack técnico

| Capa | Tecnología |
|------|------------|
| Frontend | HTML / CSS / JavaScript vanilla — archivo único index.html |
| Hosting | GitHub Pages |
| Backend | Supabase (PostgreSQL + Auth + Storage + Realtime) — mismo proyecto que ECE META CORE |
| Gráficas | Chart.js / SVG nativo |
| Exportación | CSV, SheetJS (Excel), PDF imprimible |
| IA (roadmap) | OpenAI / Anthropic API para extracción PDF y dictado |

---

## Repositorios y URLs

| Recurso | URL |
|---------|-----|
| ECE OBES repo | github.com/leomancillas/ece-obes-frontend (por crear) |
| ECE OBES app | leomancillas.github.io/ece-obes-frontend (por desplegar) |
| ECE META CORE repo | github.com/leomancillas/ece-metacore-frontend |
| ECE META CORE app | leomancillas.github.io/ece-metacore-frontend |
| Supabase | Mismo proyecto que ECE META CORE (ver supabaseUrl y supabaseKey en index.html de META CORE) |

---

## Los 7 módulos clínicos

| # | Módulo | Color | Instrumentos clave |
|---|--------|-------|-------------------|
| 1 | Médico / Endocrinología | #1A5276 | EOSS, HOMA-IR, ASCVD 10 años, %EWL, %TWL |
| 2 | Nutrición | #1D8348 | Mifflin-St Jeor, Recordatorio 24h, TFEQ-R21 |
| 3 | Psicología | #6C3483 | BES, PHQ-9, GAD-7, Prochaska |
| 4 | Rehabilitación / Deporte | #C0392B | 6MWT, PAR-Q, IPAQ-SF, FITT |
| 5 | Dental | #0E6655 | DMFT, BOP, OHIP-14 |
| 6 | Medicina del Sueño | #154360 | STOP-BANG, Epworth, PSQI |
| 7 | Módulos ad hoc | #7D6608 | Configurable (PCOS, MASLD, Cardio preventiva, Nefrología) |

---

## Base de datos — tablas principales

Todas las variables cuantitativas tienen columna tipada propia (no JSON blobs).

```
obes_patients          — referencia al patient_id de ECE META CORE
obes_measurements      — peso, talla, IMC, ICC, ICT, circunferencias, BIA, labs (~40 columnas)
obes_assessments       — instrumentos validados (BES, PHQ9, GAD7, STOP-BANG, Epworth, etc.)
obes_vitals            — PA, FC, FR, Temp, SpO2
obes_notes             — notas de seguimiento por módulo (tipo + especialidad)
obes_medications       — farmacoterapia anti-obesidad (GLP-1, etc.)
obes_procedures        — procedimientos bariátricos
obes_lab_results       — laboratorios (glucosa, HbA1c, insulina, lípidos, etc.)
obes_sleep_studies     — polisomnografía, AHI, CPAP
obes_nutrition_plans   — planes nutricionales, distribución de macros
obes_exercise_rx       — prescripción FITT, MET-min/sem
obes_dental_records    — DMFT, BOP, registros periodontales
research_protocols     — protocolos de investigación
research_enrollments   — consentimiento, elegibilidad, fechas
research_crf_data      — datos de CRF por visita y variable
```

Esquema SQL completo en: ECE_OBES_Diseño_Maestro.docx → Sección 4

---

## Documento de diseño maestro

ECE_OBES_Diseño_Maestro.docx — contiene:
- Especificación completa de los 7 módulos con tablas de instrumentos, fórmulas y puntos de corte
- Esquema PostgreSQL completo (SQL listo para ejecutar)
- Flujos UX y 3 journeys de usuario
- Arquitectura de la capa de analítica y de investigación
- Roadmap en 4 fases

---

## Convenciones de código (heredadas de ECE META CORE)

- Archivo único index.html — CSS embebido en style, JS en script
- Variables CSS: --primary, --secondary, --border, --bg, --surface
- Supabase client: const supabase = supabase.createClient(url, key)
- Estado global: let currentPatient = null, let currentUser = null
- Modales: openModal(id) / closeModal(id)
- Toast notifications: showToast(msg, type='success', ms=3400) — no usar alert()
- Auto-draft en formularios largos (localStorage, clave = ece_ndraft_{userId}_{patientId})
- Ctrl+Enter para guardar en cualquier modal
- Colores por módulo como variables CSS: --mod-medico, --mod-nutri, etc.

---

## Estado actual del proyecto (Abril 2026)

- [x] Diseño maestro completo documentado
- [x] Esquema de base de datos diseñado
- [x] Flujos UX definidos
- [ ] Repositorio GitHub creado
- [ ] Estructura HTML base (scaffold index.html)
- [ ] Módulo 1: Médico — primera prioridad (EOSS + mediciones)
- [ ] Módulo 2: Nutrición
- [ ] Módulos 3–7
- [ ] Capa de analítica
- [ ] Capa de investigación

**Siguiente paso**: crear el repo en GitHub, scaffold del index.html base, construir módulo médico.

---

## Relación con ECE META CORE

- Los pacientes viven en ECE META CORE; ECE OBES los referencia por patient_id
- Desde el expediente general del paciente → botón 'Abrir expediente OBES'
- Desde ECE OBES → breadcrumb de regreso a ECE META CORE
- Mismo supabaseUrl + supabaseKey, mismo sistema de auth

---

## Contacto / owner

- Leo Mancillas — leomancillas@gmail.com
