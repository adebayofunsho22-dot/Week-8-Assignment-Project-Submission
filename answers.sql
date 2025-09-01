CREATE DATABASE IF NOT EXISTS clinic_db;
USE clinic_db;
-- =============================================================
-- Project: Clinic Booking System - Relational Database Schema
-- Author: (Adebayo Funsho)
-- MySQL Version: 8.0+ (CHECK constraints enforced in 8.0.16+)
-- Engine: InnoDB, Charset: utf8mb4
-- Deliverable: Single .sql file with CREATE TABLE statements
-- =============================================================

-- Safety: create database. Comment out if your environment forbids CREATE DATABASE.
-- CREATE DATABASE IF NOT EXISTS clinic_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
-- USE clinic_db;

-- =============================================================
-- Table: patients
-- Purpose: Stores core patient identity.
-- Notes: email/phone set UNIQUE to prevent duplicates.
-- =============================================================
CREATE TABLE IF NOT EXISTS patients (
    patient_id      BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(100)        NOT NULL,
    last_name       VARCHAR(100)        NOT NULL,
    date_of_birth   DATE                NOT NULL,
    sex             ENUM('M','F','Other') NOT NULL,
    email           VARCHAR(255)        NOT NULL UNIQUE,
    phone           VARCHAR(30)         NOT NULL UNIQUE,
    created_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP           NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: patient_profile (1:1 with patients)
-- Purpose: Optional clinical profile per patient.
-- 1:1 achieved by sharing PK with patients and UNIQUE FK.
-- ON DELETE CASCADE deletes profile when patient is deleted.
-- =============================================================
CREATE TABLE IF NOT EXISTS patient_profile (
    patient_id                  BIGINT UNSIGNED PRIMARY KEY,
    blood_type                  ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NULL,
    emergency_contact_name      VARCHAR(150),
    emergency_contact_phone     VARCHAR(30),
    allergies                   TEXT,
    CONSTRAINT fk_profile_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: staff
-- Purpose: All staff members (doctors, nurses, admin, etc.).
-- Notes: email UNIQUE, role constrained via ENUM.
-- =============================================================
CREATE TABLE IF NOT EXISTS staff (
    staff_id    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    role        ENUM('Doctor','Nurse','Admin','LabTech') NOT NULL,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    phone       VARCHAR(30)     NULL,
    hire_date   DATE            NOT NULL,
    active      BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: doctors (subset of staff)
-- Purpose: Ensures we can FK specifically to doctors.
-- Implementation: PK also a FK to staff.
-- =============================================================
CREATE TABLE IF NOT EXISTS doctors (
    doctor_id BIGINT UNSIGNED PRIMARY KEY,
    CONSTRAINT fk_doctor_staff
        FOREIGN KEY (doctor_id) REFERENCES staff(staff_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: specialties
-- Purpose: Medical specialties (e.g., Cardiology, Dermatology).
-- =============================================================
CREATE TABLE IF NOT EXISTS specialties (
    specialty_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name         VARCHAR(120) NOT NULL UNIQUE,
    description  VARCHAR(255) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: doctor_specialty (M:N doctors <-> specialties)
-- Composite PK to prevent duplicates.
-- =============================================================
CREATE TABLE IF NOT EXISTS doctor_specialty (
    doctor_id    BIGINT UNSIGNED NOT NULL,
    specialty_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (doctor_id, specialty_id),
    CONSTRAINT fk_ds_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ds_specialty
        FOREIGN KEY (specialty_id) REFERENCES specialties(specialty_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: rooms
-- Purpose: Physical rooms for appointments.
-- =============================================================
CREATE TABLE IF NOT EXISTS rooms (
    room_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name    VARCHAR(50) NOT NULL UNIQUE,
    type    ENUM('Consultation','Surgery','Lab','Ward') NOT NULL DEFAULT 'Consultation'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: appointments
-- Purpose: Patient bookings with a doctor and optional room.
-- Notes: Time sanity check, status lifecycle.
-- Indexes on FKs for performance.
-- =============================================================
CREATE TABLE IF NOT EXISTS appointments (
    appointment_id   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    patient_id       BIGINT UNSIGNED NOT NULL,
    doctor_id        BIGINT UNSIGNED NOT NULL,
    room_id          BIGINT UNSIGNED NULL,
    scheduled_start  DATETIME NOT NULL,
    scheduled_end    DATETIME NOT NULL,
    status           ENUM('Scheduled','CheckedIn','Completed','Cancelled','NoShow') NOT NULL DEFAULT 'Scheduled',
    reason           VARCHAR(255) NULL,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_appt_time CHECK (scheduled_end > scheduled_start),
    CONSTRAINT fk_appt_patient
        FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_appt_doctor
        FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_appt_room
        FOREIGN KEY (room_id) REFERENCES rooms(room_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_appt_patient (patient_id),
    INDEX idx_appt_doctor (doctor_id),
    INDEX idx_appt_room (room_id),
    INDEX idx_appt_start (scheduled_start)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: prescriptions
-- Purpose: Medications prescribed during/after an appointment.
-- Notes: Typically 1:N appointment -> prescriptions.
-- =============================================================
CREATE TABLE IF NOT EXISTS prescriptions (
    prescription_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    appointment_id  BIGINT UNSIGNED NOT NULL,
    issued_at       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes           TEXT NULL,
    CONSTRAINT fk_rx_appointment
        FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_rx_appt (appointment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: medications
-- Purpose: Master list of medications.
-- =============================================================
CREATE TABLE IF NOT EXISTS medications (
    medication_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name          VARCHAR(150) NOT NULL UNIQUE,
    form          ENUM('Tablet','Capsule','Syrup','Injection','Ointment','Other') NOT NULL DEFAULT 'Other',
    strength      VARCHAR(50) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: prescription_items (M:N prescriptions <-> medications)
-- Composite PK ensures each medication appears once per prescription.
-- =============================================================
CREATE TABLE IF NOT EXISTS prescription_items (
    prescription_id BIGINT UNSIGNED NOT NULL,
    medication_id   BIGINT UNSIGNED NOT NULL,
    dosage          VARCHAR(50)  NOT NULL, -- e.g., "500 mg"
    frequency       VARCHAR(50)  NOT NULL, -- e.g., "2x/day"
    duration_days   INT UNSIGNED NOT NULL,
    PRIMARY KEY (prescription_id, medication_id),
    CONSTRAINT chk_duration CHECK (duration_days > 0),
    CONSTRAINT fk_pitem_rx
        FOREIGN KEY (prescription_id) REFERENCES prescriptions(prescription_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pitem_med
        FOREIGN KEY (medication_id) REFERENCES medications(medication_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: invoices (1:1 with appointments)
-- Purpose: Billing for a specific appointment.
-- 1:1 achieved by UNIQUE FK on appointment_id.
-- =============================================================
CREATE TABLE IF NOT EXISTS invoices (
    invoice_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    appointment_id BIGINT UNSIGNED NOT NULL UNIQUE,
    amount         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    status         ENUM('Pending','Paid','Cancelled','Refunded') NOT NULL DEFAULT 'Pending',
    issued_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_amount_nonneg CHECK (amount >= 0),
    CONSTRAINT fk_invoice_appt
        FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Table: payments
-- Purpose: Payments made toward invoices.
-- Notes: Multiple payments per invoice allowed.
-- =============================================================
CREATE TABLE IF NOT EXISTS payments (
    payment_id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    invoice_id BIGINT UNSIGNED NOT NULL,
    amount     DECIMAL(10,2) NOT NULL,
    method     ENUM('Cash','Card','Transfer','Mobile') NOT NULL,
    paid_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_payment_invoice (invoice_id),
    INDEX idx_payment_paid_at (paid_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- =============================================================
-- Helpful Views/Indexes/Triggers could be added in separate tasks.
-- For this deliverable, only CREATE TABLE statements are included.
-- =============================================================
