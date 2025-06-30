# College Open Elective Subject Tracking - Weekly Assignment 5

**Author:** Kumar Saurav

---

## 📸 Output Screenshot

![Screenshot 2025-06-30 224920](https://github.com/user-attachments/assets/4aae1b91-87b0-4d3b-980a-2adf4714388e)


---

## 📋 Assignment Brief

> This was my fifth weekly assignment for the company.  
> The goal was to design and implement a system to track and manage students' choices of open elective subjects in the college database.  

Colleges often allow students to switch elective subjects at the start of the year. The requirement was to **preserve the entire history of changes** while also clearly marking the current active subject for each student.  

---

## 🧩 Problem Statement

- Students can request to change their elective subjects.
- The college wants to **see the entire timeline of choices**, not just the latest one.
- The `SubjectAllotments` table stores:
  - `StudentId` (identifier)
  - `SubjectId` (the subject code)
  - `Is_Valid` (bit flag: 1 = active choice, 0 = historical/inactive)

- Students submit change requests in the `SubjectRequest` table:
  - `StudentId`
  - `SubjectId`

**Key business rules to implement:**

1. If the student is **new** (not in `SubjectAllotments` at all), their request is simply inserted as the current active subject (`Is_Valid = 1`).
2. If the student has an **existing active subject**, and they request a **different** subject:
   - Mark the previous active subject as inactive (`Is_Valid = 0`).
   - Insert the new requested subject as active (`Is_Valid = 1`).
3. If the student requests the **same** subject as already active:
   - Do nothing (no redundant insert or update).

The final result should preserve *all previous choices* in history while ensuring **only one subject per student is active at a time.**

---

## 💻 Technology Used

- **Microsoft SQL Server (MSSQL)**
- Transact-SQL (T-SQL) stored procedures and standard SQL DDL/DML

---

## 🏗️ Tables Used

### 1️⃣ SubjectAllotments
Holds the entire history of student-subject mappings.

| Column     | Type      | Description                    |
|------------|-----------|--------------------------------|
| StudentId  | VARCHAR   | Student identifier             |
| SubjectId  | VARCHAR   | Subject code                   |
| Is_Valid   | BIT       | 1 = Active, 0 = Historical     |

---

### 2️⃣ SubjectRequest
Holds new change requests from students.

| Column     | Type      | Description                  |
|------------|-----------|-----------------------------|
| StudentId  | VARCHAR   | Student identifier          |
| SubjectId  | VARCHAR   | Requested subject code      |

---

## ⚙️ Solution Overview

I implemented a **stored procedure** in T-SQL that processes all entries in the `SubjectRequest` table.

**Key steps in the procedure:**

- For each student in `SubjectRequest`:
  1. Check if the student has any **active** subject in `SubjectAllotments`.
  2. **If not found** (new student):
     - Insert the requested subject as **active** (`Is_Valid = 1`).
  3. **If found**, compare:
     - If the requested subject **matches** the active one: *do nothing*.
     - If it’s **different**:
       - Update old record to **Is_Valid = 0** (make it inactive).
       - Insert new requested subject with **Is_Valid = 1**.

---

## 🧭 Implementation Details

- Used a T-SQL **cursor** to loop through each request in `SubjectRequest`.
- Used conditional logic to:
  - Insert new records for new students.
  - Update and insert for existing students switching subjects.
- Preserved **all historical choices** in `SubjectAllotments`.
- Ensured **only one active subject** per student at any time.
- Used standard SQL Server syntax compatible with Microsoft SQL Server Management Studio (SSMS).

---

## ✅ How to Use

1. Create the two tables if they don’t exist.
2. Insert sample or real data into `SubjectAllotments` and `SubjectRequest`.
3. Run the stored procedure `ProcessSubjectRequests`.
4. View the `SubjectAllotments` table to confirm changes:
   - New students added.
   - Existing students switched with old subjects marked inactive.
   - No duplicates if requested subject is already active.

---

## 📌 Example Scenario

**Before:**

_SubjectAllotments_
| StudentId  | SubjectId | Is_Valid |
|------------|-----------|----------|
| 159103036  | PO1491    | 1        |
| 159103036  | PO1492    | 0        |
| ...        | ...       | ...      |

_SubjectRequest_
| StudentId  | SubjectId |
|------------|-----------|
| 159103036  | PO1496    |

**After running the procedure:**

_SubjectAllotments_
| StudentId  | SubjectId | Is_Valid |
|------------|-----------|----------|
| 159103036  | PO1496    | 1        |
| 159103036  | PO1491    | 0        |
| 159103036  | PO1492    | 0        |
| ...        | ...       | ...      |

---

## 📜 Notes

- The procedure also handles **brand-new students** automatically.
- All history is preserved for audit and reporting.
- Business logic strictly enforces **one active subject per student**.

---

## 🖊️ Author

Kumar Saurav

---
