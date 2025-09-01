# 🏥 Clinic Booking System – Database Project

## 📌 Project Description
This project is a **Clinic Booking System** designed and implemented in **MySQL**.  
It demonstrates good database design principles, normalization, and the use of proper constraints and relationships.  

The system manages:
- Patient registration and profiles  
- Staff (doctors, nurses, admin) and their specialties  
- Clinic rooms and appointments  
- Prescriptions and medications  
- Invoices and payments  

It showcases **1–1, 1–M, and M–M relationships**, data integrity with constraints, and normalization up to 3NF.

---

## 🎯 Objectives
- Build a well-structured relational database.  
- Apply **normalization** techniques to reduce redundancy and improve integrity.  
- Define relationships with **Primary Keys, Foreign Keys, UNIQUE, NOT NULL, and CHECK** constraints.  
- Provide a real-world use case (Clinic Booking System).  

---

## Entity Relationship Diagram (ERD)

![Clinic Booking System ERD] https://i.postimg.cc/hGFFF9wp/ERD-diagram.png

---

## ⚙️ How to Run / Setup
1. Install [MySQL 8.0+](https://dev.mysql.com/downloads/).  
2. Clone this repository:
   ```bash
   git clone https://github.com/adebayofunsho22-dot>/Week-8-Assignment-Project-Submission.git
   cd  https://github.com/<adebayofunsho22-dot>/<Week-8-Assignment-Project-Submission>.git

---

🗄️ Database Design
✅ Entities & Relationships

patients (1–1) patient_profile

patients (1–M) appointments

doctors (M–M) specialties via doctor_specialty

appointments (1–M) prescriptions (M–M) medications via prescription_items

appointments (1–1) invoices (1–M) payments

📊 Entity Relationship Diagram (ERD)

Here’s the ERD of the system:

📂 Repository Contents

clinic_db_schema.sql → Database schema with all CREATE TABLE statements.

README.md → Project documentation.

docs/ERD.png → Entity Relationship Diagram.

my ERD diagram.mwb → MySQL Workbench model file.

👨‍💻 Author

Adebayo Funsho

Database Design & Normalization Assignment

[My GitHub Profile](https://github.com/adebayofunsho22-dot)   
   

