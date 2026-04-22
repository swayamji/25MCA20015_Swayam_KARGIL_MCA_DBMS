-- ============================================================
--   HOSPITAL MANAGEMENT SYSTEM
--   PostgreSQL / pgAdmin Project
--   Covers: Tables, Functions, Stored Procedures, Triggers,
--           Views, Initial Data, Advanced SELECT Queries
-- ============================================================


-- ============================================================
-- 0. SETUP
-- ============================================================

DROP SCHEMA IF EXISTS hms CASCADE;
CREATE SCHEMA hms;
SET search_path = hms;


-- ============================================================
-- 1. TABLES
-- ============================================================

CREATE TABLE departments (
    dept_id     SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    location    VARCHAR(100),
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE doctors (
    doctor_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    specialization VARCHAR(100),
    dept_id     INT REFERENCES departments(dept_id) ON DELETE SET NULL,
    phone       VARCHAR(20),
    email       VARCHAR(100) UNIQUE,
    is_active   BOOLEAN DEFAULT TRUE,
    joined_at   TIMESTAMP DEFAULT NOW()
);

CREATE TABLE patients (
    patient_id  SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)  NOT NULL,
    last_name   VARCHAR(50)  NOT NULL,
    dob         DATE         NOT NULL,
    gender      CHAR(1)      CHECK (gender IN ('M','F','O')),
    phone       VARCHAR(20),
    email       VARCHAR(100),
    address     TEXT,
    blood_group VARCHAR(5),
    registered_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE appointments (
    appt_id     SERIAL PRIMARY KEY,
    patient_id  INT  REFERENCES patients(patient_id)  ON DELETE CASCADE,
    doctor_id   INT  REFERENCES doctors(doctor_id)    ON DELETE SET NULL,
    appt_date   DATE         NOT NULL,
    appt_time   TIME         NOT NULL,
    status      VARCHAR(20)  DEFAULT 'Scheduled'
                    CHECK (status IN ('Scheduled','Completed','Cancelled','No-Show')),
    reason      TEXT,
    created_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE medical_records (
    record_id   SERIAL PRIMARY KEY,
    patient_id  INT  REFERENCES patients(patient_id)  ON DELETE CASCADE,
    doctor_id   INT  REFERENCES doctors(doctor_id)    ON DELETE SET NULL,
    appt_id     INT  REFERENCES appointments(appt_id) ON DELETE SET NULL,
    diagnosis   TEXT,
    notes       TEXT,
    recorded_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE prescriptions (
    rx_id       SERIAL PRIMARY KEY,
    record_id   INT  REFERENCES medical_records(record_id) ON DELETE CASCADE,
    medicine    VARCHAR(150) NOT NULL,
    dosage      VARCHAR(100),
    duration    VARCHAR(50),
    issued_at   TIMESTAMP DEFAULT NOW()
);

-- Audit log — every appointment status change is tracked
CREATE TABLE appointment_audit (
    audit_id    SERIAL PRIMARY KEY,
    appt_id     INT,
    old_status  VARCHAR(20),
    new_status  VARCHAR(20),
    changed_at  TIMESTAMP DEFAULT NOW(),
    changed_by  VARCHAR(100) DEFAULT CURRENT_USER
);

-- Doctor availability (days of week: 0=Sun … 6=Sat)
CREATE TABLE doctor_schedule (
    schedule_id SERIAL PRIMARY KEY,
    doctor_id   INT REFERENCES doctors(doctor_id) ON DELETE CASCADE,
    day_of_week SMALLINT CHECK (day_of_week BETWEEN 0 AND 6),
    start_time  TIME NOT NULL,
    end_time    TIME NOT NULL
);


-- ============================================================
-- 2. INITIAL DATA
-- ============================================================

-- Departments
INSERT INTO departments (name, location) VALUES
  ('Cardiology',        'Block A – Floor 2'),
  ('Neurology',         'Block B – Floor 3'),
  ('Orthopedics',       'Block C – Floor 1'),
  ('General Medicine',  'Block A – Floor 1'),
  ('Pediatrics',        'Block D – Floor 2'),
  ('Radiology',         'Block B – Floor 1');

-- Doctors
INSERT INTO doctors (first_name, last_name, specialization, dept_id, phone, email) VALUES
  ('Arjun',   'Sharma',    'Cardiologist',        1, '9810001111', 'arjun.sharma@hms.in'),
  ('Priya',   'Mehta',     'Neurologist',         2, '9810002222', 'priya.mehta@hms.in'),
  ('Rohit',   'Verma',     'Orthopedic Surgeon',  3, '9810003333', 'rohit.verma@hms.in'),
  ('Sunita',  'Nair',      'General Physician',   4, '9810004444', 'sunita.nair@hms.in'),
  ('Deepak',  'Patel',     'Pediatrician',        5, '9810005555', 'deepak.patel@hms.in'),
  ('Kavya',   'Reddy',     'Radiologist',         6, '9810006666', 'kavya.reddy@hms.in');

-- Doctor Schedules (Mon–Fri for each doctor)
INSERT INTO doctor_schedule (doctor_id, day_of_week, start_time, end_time)
SELECT d.doctor_id, dow, '09:00', '17:00'
FROM doctors d, generate_series(1,5) AS dow;

-- Patients
INSERT INTO patients (first_name, last_name, dob, gender, phone, blood_group) VALUES
  ('Ravi',    'Kumar',    '1985-03-12', 'M', '9700011111', 'B+'),
  ('Anita',   'Singh',    '1990-07-22', 'F', '9700022222', 'O+'),
  ('Suresh',  'Gupta',    '1978-11-05', 'M', '9700033333', 'A+'),
  ('Meena',   'Joshi',    '2000-01-30', 'F', '9700044444', 'AB+'),
  ('Aakash',  'Tiwari',   '1995-06-18', 'M', '9700055555', 'O-'),
  ('Pooja',   'Yadav',    '2012-09-09', 'F', '9700066666', 'B-'),
  ('Harish',  'Desai',    '1965-02-14', 'M', '9700077777', 'A-'),
  ('Nisha',   'Pillai',   '1988-12-25', 'F', '9700088888', 'O+');

-- Appointments
INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time, status, reason) VALUES
  (1, 1, CURRENT_DATE - 10, '10:00', 'Completed',  'Chest pain follow-up'),
  (2, 2, CURRENT_DATE -  7, '11:00', 'Completed',  'Headache & dizziness'),
  (3, 3, CURRENT_DATE -  5, '09:30', 'Completed',  'Knee replacement consult'),
  (4, 4, CURRENT_DATE -  3, '14:00', 'Completed',  'Routine check-up'),
  (5, 1, CURRENT_DATE -  1, '10:30', 'Completed',  'ECG review'),
  (6, 5, CURRENT_DATE,      '09:00', 'Scheduled',  'Vaccination'),
  (7, 4, CURRENT_DATE,      '15:00', 'Scheduled',  'Diabetes management'),
  (8, 2, CURRENT_DATE +  2, '11:30', 'Scheduled',  'MRI discussion'),
  (1, 4, CURRENT_DATE +  3, '10:00', 'Scheduled',  'Blood pressure review'),
  (3, 6, CURRENT_DATE -  2, '13:00', 'Cancelled',  'X-Ray knee');

-- Medical Records (only for completed appointments)
INSERT INTO medical_records (patient_id, doctor_id, appt_id, diagnosis, notes) VALUES
  (1, 1, 1, 'Mild Angina',           'Prescribed nitrates; lifestyle changes advised'),
  (2, 2, 2, 'Migraine',              'MRI ordered; painkiller course started'),
  (3, 3, 3, 'Osteoarthritis – knee', 'Surgery scheduled in 4 weeks'),
  (4, 4, 4, 'Hypertension Stage 1',  'Low-sodium diet; BP medication prescribed'),
  (5, 1, 5, 'Arrhythmia (mild)',     'Holter monitor fitted; review in 1 week');

-- Prescriptions
INSERT INTO prescriptions (record_id, medicine, dosage, duration) VALUES
  (1, 'Isosorbide Mononitrate', '20 mg once daily',      '30 days'),
  (1, 'Aspirin',                '75 mg once daily',      '30 days'),
  (2, 'Sumatriptan',            '50 mg as needed',       '15 days'),
  (2, 'Ibuprofen',              '400 mg thrice daily',   '7 days'),
  (3, 'Diclofenac',             '50 mg twice daily',     '14 days'),
  (4, 'Amlodipine',             '5 mg once daily',       '60 days'),
  (5, 'Metoprolol',             '25 mg twice daily',     '30 days');


-- ============================================================
-- 3. VIEWS
-- ============================================================

-- Full appointment detail view
CREATE OR REPLACE VIEW vw_appointment_details AS
SELECT
    a.appt_id,
    a.appt_date,
    a.appt_time,
    a.status,
    a.reason,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.blood_group,
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dep.name AS department
FROM appointments a
JOIN patients  p   ON p.patient_id = a.patient_id
JOIN doctors   d   ON d.doctor_id  = a.doctor_id
JOIN departments dep ON dep.dept_id = d.dept_id;

-- Patient summary view
CREATE OR REPLACE VIEW vw_patient_summary AS
SELECT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.dob,
    DATE_PART('year', AGE(p.dob))::INT AS age,
    p.blood_group,
    COUNT(DISTINCT a.appt_id)   AS total_appointments,
    COUNT(DISTINCT mr.record_id) AS total_records
FROM patients p
LEFT JOIN appointments    a  ON a.patient_id  = p.patient_id
LEFT JOIN medical_records mr ON mr.patient_id = p.patient_id
GROUP BY p.patient_id;


-- ============================================================
-- 4. FUNCTIONS
-- ============================================================

-- 4a. Calculate patient age
CREATE OR REPLACE FUNCTION fn_patient_age(p_dob DATE)
RETURNS INT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN DATE_PART('year', AGE(p_dob))::INT;
END;
$$;

-- 4b. Count appointments for a patient
CREATE OR REPLACE FUNCTION fn_count_patient_appointments(p_patient_id INT)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM appointments
    WHERE patient_id = p_patient_id;
    RETURN v_count;
END;
$$;

-- 4c. Get next available appointment slot for a doctor
--     Returns the next weekday date on which the doctor works
--     and has fewer than 10 appointments already booked.
CREATE OR REPLACE FUNCTION fn_next_available_slot(p_doctor_id INT)
RETURNS DATE
LANGUAGE plpgsql
AS $$
DECLARE
    v_date DATE := CURRENT_DATE;
    v_dow  SMALLINT;
    v_count INT;
    v_max_iter INT := 30;   -- look at most 30 days ahead
BEGIN
    LOOP
        v_dow := EXTRACT(DOW FROM v_date)::SMALLINT;

        -- Check doctor is scheduled on this day
        IF EXISTS (
            SELECT 1 FROM doctor_schedule
            WHERE doctor_id = p_doctor_id AND day_of_week = v_dow
        ) THEN
            SELECT COUNT(*) INTO v_count
            FROM appointments
            WHERE doctor_id = p_doctor_id
              AND appt_date  = v_date
              AND status NOT IN ('Cancelled','No-Show');

            IF v_count < 10 THEN
                RETURN v_date;
            END IF;
        END IF;

        v_date := v_date + INTERVAL '1 day';
        v_max_iter := v_max_iter - 1;
        EXIT WHEN v_max_iter <= 0;
    END LOOP;

    RETURN NULL;   -- no slot found within 30 days
END;
$$;

-- 4d. Get full prescription list for a patient (returns TABLE)
CREATE OR REPLACE FUNCTION fn_patient_prescriptions(p_patient_id INT)
RETURNS TABLE (
    medicine    VARCHAR,
    dosage      VARCHAR,
    duration    VARCHAR,
    diagnosis   TEXT,
    doctor_name TEXT,
    issued_at   TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rx.medicine,
        rx.dosage,
        rx.duration,
        mr.diagnosis,
        (d.first_name || ' ' || d.last_name)::TEXT,
        rx.issued_at
    FROM prescriptions rx
    JOIN medical_records mr ON mr.record_id = rx.record_id
    JOIN doctors          d  ON d.doctor_id  = mr.doctor_id
    WHERE mr.patient_id = p_patient_id
    ORDER BY rx.issued_at DESC;
END;
$$;


-- ============================================================
-- 5. STORED PROCEDURES
-- ============================================================

-- 5a. Book an appointment
--     Validates doctor availability before inserting.
CREATE OR REPLACE PROCEDURE sp_book_appointment(
    p_patient_id  INT,
    p_doctor_id   INT,
    p_appt_date   DATE,
    p_appt_time   TIME,
    p_reason      TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dow      SMALLINT := EXTRACT(DOW FROM p_appt_date)::SMALLINT;
    v_conflict INT;
BEGIN
    -- 1. Doctor must be scheduled on that day
    IF NOT EXISTS (
        SELECT 1 FROM doctor_schedule
        WHERE doctor_id = p_doctor_id AND day_of_week = v_dow
    ) THEN
        RAISE EXCEPTION 'Doctor % is not available on %', p_doctor_id, p_appt_date;
    END IF;

    -- 2. No double-booking for the same doctor + date + time
    SELECT COUNT(*) INTO v_conflict
    FROM appointments
    WHERE doctor_id = p_doctor_id
      AND appt_date  = p_appt_date
      AND appt_time  = p_appt_time
      AND status NOT IN ('Cancelled','No-Show');

    IF v_conflict > 0 THEN
        RAISE EXCEPTION 'Time slot % on % is already booked for doctor %',
                        p_appt_time, p_appt_date, p_doctor_id;
    END IF;

    -- 3. Insert
    INSERT INTO appointments (patient_id, doctor_id, appt_date, appt_time, reason)
    VALUES (p_patient_id, p_doctor_id, p_appt_date, p_appt_time, p_reason);

    RAISE NOTICE 'Appointment booked successfully for patient % with doctor % on % at %',
                  p_patient_id, p_doctor_id, p_appt_date, p_appt_time;
END;
$$;

-- 5b. Cancel an appointment
CREATE OR REPLACE PROCEDURE sp_cancel_appointment(p_appt_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE appointments
    SET status = 'Cancelled'
    WHERE appt_id = p_appt_id
      AND status  = 'Scheduled';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Appointment % not found or already not in Scheduled state', p_appt_id;
    END IF;

    RAISE NOTICE 'Appointment % cancelled.', p_appt_id;
END;
$$;

-- 5c. Complete an appointment and create medical record
CREATE OR REPLACE PROCEDURE sp_complete_appointment(
    p_appt_id    INT,
    p_diagnosis  TEXT,
    p_notes      TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_patient_id INT;
    v_doctor_id  INT;
    v_record_id  INT;
BEGIN
    -- Mark appointment completed
    UPDATE appointments
    SET status = 'Completed'
    WHERE appt_id = p_appt_id AND status = 'Scheduled'
    RETURNING patient_id, doctor_id
    INTO v_patient_id, v_doctor_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Appointment % not found or not in Scheduled state', p_appt_id;
    END IF;

    -- Create medical record
    INSERT INTO medical_records (patient_id, doctor_id, appt_id, diagnosis, notes)
    VALUES (v_patient_id, v_doctor_id, p_appt_id, p_diagnosis, p_notes)
    RETURNING record_id INTO v_record_id;

    RAISE NOTICE 'Appointment % completed. Medical record % created.', p_appt_id, v_record_id;
END;
$$;

-- 5d. Add prescription to a medical record
CREATE OR REPLACE PROCEDURE sp_add_prescription(
    p_record_id INT,
    p_medicine  VARCHAR,
    p_dosage    VARCHAR DEFAULT NULL,
    p_duration  VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM medical_records WHERE record_id = p_record_id) THEN
        RAISE EXCEPTION 'Medical record % does not exist', p_record_id;
    END IF;

    INSERT INTO prescriptions (record_id, medicine, dosage, duration)
    VALUES (p_record_id, p_medicine, p_dosage, p_duration);

    RAISE NOTICE 'Prescription for "%" added to record %.', p_medicine, p_record_id;
END;
$$;

-- 5e. Deactivate a doctor (sets is_active = FALSE)
CREATE OR REPLACE PROCEDURE sp_deactivate_doctor(p_doctor_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE doctors SET is_active = FALSE
    WHERE doctor_id = p_doctor_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Doctor % not found', p_doctor_id;
    END IF;

    -- Cancel all future scheduled appointments
    UPDATE appointments
    SET status = 'Cancelled'
    WHERE doctor_id  = p_doctor_id
      AND appt_date  >= CURRENT_DATE
      AND status     = 'Scheduled';

    RAISE NOTICE 'Doctor % deactivated and future appointments cancelled.', p_doctor_id;
END;
$$;


-- ============================================================
-- 6. TRIGGERS
-- ============================================================

-- 6a. Audit trigger: log every appointment status change
CREATE OR REPLACE FUNCTION trg_fn_appointment_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO appointment_audit (appt_id, old_status, new_status)
        VALUES (NEW.appt_id, OLD.status, NEW.status);
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_appointment_audit
AFTER UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_appointment_audit();

-- 6b. Prevent booking appointments on weekends
CREATE OR REPLACE FUNCTION trg_fn_no_weekend_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXTRACT(DOW FROM NEW.appt_date) IN (0, 6) THEN
        RAISE EXCEPTION 'Appointments cannot be scheduled on weekends (date: %)', NEW.appt_date;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_no_weekend_booking
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_no_weekend_booking();

-- 6c. Auto-set appointment status to 'No-Show'
--     when a Scheduled appointment is updated with a past date
CREATE OR REPLACE FUNCTION trg_fn_auto_noshow()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = 'Scheduled' AND NEW.appt_date < CURRENT_DATE THEN
        NEW.status := 'No-Show';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_auto_noshow
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION trg_fn_auto_noshow();

-- 6d. Prevent updating completed medical records
CREATE OR REPLACE FUNCTION trg_fn_lock_medical_record()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE EXCEPTION 'Medical record % is locked and cannot be modified. Create a new record instead.', OLD.record_id;
END;
$$;

CREATE TRIGGER trg_lock_medical_record
BEFORE UPDATE ON medical_records
FOR EACH ROW
EXECUTE FUNCTION trg_fn_lock_medical_record();

-- 6e. Timestamp update on new prescription
CREATE OR REPLACE FUNCTION trg_fn_rx_issued_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.issued_at := NOW();
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_rx_issued_at
BEFORE INSERT ON prescriptions
FOR EACH ROW
EXECUTE FUNCTION trg_fn_rx_issued_at();


-- ============================================================
-- 7. DEMO: CALLING PROCEDURES & FUNCTIONS
-- ============================================================

-- Book a new appointment (Mon–Fri only)
-- CALL sp_book_appointment(2, 3, CURRENT_DATE + 1, '14:30', 'Shoulder pain');

-- Complete an appointment and record diagnosis
-- CALL sp_complete_appointment(6, 'Routine vaccination completed', 'No adverse reaction');

-- Add prescription to a record
-- CALL sp_add_prescription(1, 'Atorvastatin', '10 mg once nightly', '90 days');

-- Cancel an appointment
-- CALL sp_cancel_appointment(8);

-- Get next available slot for doctor 1
-- SELECT fn_next_available_slot(1);

-- Get all prescriptions for patient 1
-- SELECT * FROM fn_patient_prescriptions(1);

-- Get patient age
-- SELECT fn_patient_age('1985-03-12');


-- ============================================================
-- 8. ADVANCED SELECT QUERIES
-- ============================================================

-- ── Q1. All upcoming appointments with doctor & patient details ──────────
SELECT
    appt_id,
    appt_date,
    appt_time,
    status,
    patient_name,
    blood_group,
    doctor_name,
    specialization,
    department,
    reason
FROM vw_appointment_details
WHERE appt_date >= CURRENT_DATE
  AND status = 'Scheduled'
ORDER BY appt_date, appt_time;


-- ── Q2. Doctor workload – appointments per doctor this month ─────────────
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    dep.name                            AS department,
    COUNT(a.appt_id)                    AS total_appointments,
    COUNT(a.appt_id) FILTER (WHERE a.status = 'Completed')  AS completed,
    COUNT(a.appt_id) FILTER (WHERE a.status = 'Cancelled')  AS cancelled,
    COUNT(a.appt_id) FILTER (WHERE a.status = 'Scheduled')  AS upcoming
FROM doctors d
JOIN departments dep ON dep.dept_id = d.dept_id
LEFT JOIN appointments a
    ON a.doctor_id = d.doctor_id
   AND DATE_TRUNC('month', a.appt_date) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY d.doctor_id, doctor_name, dep.name
ORDER BY total_appointments DESC;


-- ── Q3. Patient history – visits + diagnoses (latest first) ─────────────
SELECT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    fn_patient_age(p.dob)              AS age,
    p.blood_group,
    a.appt_date,
    a.status,
    mr.diagnosis,
    d.first_name || ' ' || d.last_name AS treating_doctor,
    dep.name                           AS department
FROM patients p
JOIN appointments a     ON a.patient_id = p.patient_id
JOIN doctors      d     ON d.doctor_id  = a.doctor_id
JOIN departments  dep   ON dep.dept_id  = d.dept_id
LEFT JOIN medical_records mr ON mr.appt_id = a.appt_id
ORDER BY p.patient_id, a.appt_date DESC;


-- ── Q4. Most prescribed medicines ───────────────────────────────────────
SELECT
    rx.medicine,
    COUNT(*)                              AS times_prescribed,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM prescriptions rx
GROUP BY rx.medicine
ORDER BY times_prescribed DESC;


-- ── Q5. Patients with more than 1 appointment (frequent visitors) ────────
SELECT
    ps.patient_id,
    ps.patient_name,
    ps.age,
    ps.blood_group,
    ps.total_appointments,
    ps.total_records
FROM vw_patient_summary ps
WHERE ps.total_appointments > 1
ORDER BY ps.total_appointments DESC;


-- ── Q6. Appointment audit trail ──────────────────────────────────────────
SELECT
    aa.audit_id,
    aa.appt_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    aa.old_status,
    aa.new_status,
    aa.changed_at,
    aa.changed_by
FROM appointment_audit aa
JOIN appointments a ON a.appt_id   = aa.appt_id
JOIN patients     p ON p.patient_id = a.patient_id
ORDER BY aa.changed_at DESC;


-- ── Q7. Department summary – doctors, appointments, completion rate ───────
SELECT
    dep.name                                                AS department,
    COUNT(DISTINCT d.doctor_id)                             AS num_doctors,
    COUNT(DISTINCT a.appt_id)                               AS total_appointments,
    COUNT(DISTINCT a.appt_id) FILTER (WHERE a.status = 'Completed')  AS completed,
    ROUND(
        100.0 * COUNT(DISTINCT a.appt_id) FILTER (WHERE a.status = 'Completed')
        / NULLIF(COUNT(DISTINCT a.appt_id), 0), 2
    )                                                       AS completion_rate_pct
FROM departments dep
LEFT JOIN doctors      d   ON d.dept_id    = dep.dept_id
LEFT JOIN appointments a   ON a.doctor_id  = d.doctor_id
GROUP BY dep.dept_id, dep.name
ORDER BY total_appointments DESC;


-- ── Q8. Patients without any appointment (new / inactive) ────────────────
SELECT
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.registered_at::DATE              AS registered_on
FROM patients p
WHERE NOT EXISTS (
    SELECT 1 FROM appointments a WHERE a.patient_id = p.patient_id
)
ORDER BY p.registered_at;


-- ── Q9. Running total of appointments per day (last 30 days) ─────────────
SELECT
    appt_date,
    COUNT(*)                                                     AS daily_count,
    SUM(COUNT(*)) OVER (ORDER BY appt_date ROWS UNBOUNDED PRECEDING) AS running_total
FROM appointments
WHERE appt_date BETWEEN CURRENT_DATE - 30 AND CURRENT_DATE
GROUP BY appt_date
ORDER BY appt_date;


-- ── Q10. Top patients by prescription count (ranked with DENSE_RANK) ─────
SELECT
    p.first_name || ' ' || p.last_name   AS patient_name,
    COUNT(rx.rx_id)                       AS prescriptions_received,
    DENSE_RANK() OVER (ORDER BY COUNT(rx.rx_id) DESC) AS rnk
FROM patients p
JOIN medical_records mr ON mr.patient_id = p.patient_id
JOIN prescriptions   rx ON rx.record_id  = mr.record_id
GROUP BY p.patient_id
ORDER BY rnk;


-- ── Q11. Doctors available TODAY (based on schedule) ─────────────────────
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    dep.name                           AS department,
    ds.start_time,
    ds.end_time,
    fn_next_available_slot(d.doctor_id) AS next_free_date
FROM doctors d
JOIN departments   dep ON dep.dept_id   = d.dept_id
JOIN doctor_schedule ds ON ds.doctor_id = d.doctor_id
WHERE ds.day_of_week = EXTRACT(DOW FROM CURRENT_DATE)::SMALLINT
  AND d.is_active = TRUE
ORDER BY dep.name, doctor_name;


-- ── Q12. CTE – patients who visited multiple departments ─────────────────
WITH patient_depts AS (
    SELECT
        a.patient_id,
        d.dept_id
    FROM appointments a
    JOIN doctors d ON d.doctor_id = a.doctor_id
    WHERE a.status = 'Completed'
    GROUP BY a.patient_id, d.dept_id
),
multi_dept_patients AS (
    SELECT patient_id, COUNT(DISTINCT dept_id) AS dept_count
    FROM patient_depts
    GROUP BY patient_id
    HAVING COUNT(DISTINCT dept_id) > 1
)
SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    mdp.dept_count,
    STRING_AGG(dep.name, ', ' ORDER BY dep.name) AS departments_visited
FROM multi_dept_patients mdp
JOIN patients p ON p.patient_id = mdp.patient_id
JOIN patient_depts pd  ON pd.patient_id = mdp.patient_id
JOIN departments   dep ON dep.dept_id   = pd.dept_id
GROUP BY p.patient_id, patient_name, mdp.dept_count
ORDER BY mdp.dept_count DESC;
