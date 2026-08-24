# Source System Landscape

## Project Context

This project models a higher-education data integration environment inspired by publicly documented university systems and workflows.

Operational student, admissions, learning, and enterprise records used in this project are synthetic and do not represent actual University records or internal database schemas. Public institutional data is separately identified and sourced.

## Source Systems

### 1. Student Information System (SIS)

**Reference system:** University of Michigan M-Pathways Student Administration

**Business purpose:**  
Represents the authoritative academic student record environment used to maintain student programs, terms, course enrollment, academic progress, grading, and completion-related information.

**Publicly documented U-M functions used as reference:**
- Student academic program maintenance
- Enrollment / registration
- Grading
- Graduation
- Term activation
- Course and class information
- Academic standing
- Official reporting

**Project implementation:**  
This project does not connect to or reproduce the University of Michigan's internal M-Pathways database. Instead, it creates a synthetic SIS-like dataset based on publicly documented higher-education business functions.

**Planned synthetic SIS entities:**
- Students
- Academic programs
- Terms
- Courses
- Class sections
- Enrollment
- Completions

**Governance role:**  
The SIS-like source will serve as the authoritative source for official student enrollment and academic program information.

### 2. Learning Management System (LMS)

**Reference system:** Canvas at the University of Michigan

**Business purpose:**  
Represents the university's course-delivery and learning-activity environment. It captures how students interact with course content, assignments, grades, and other learning resources.

**Publicly documented U-M functions used as reference:**
- Course learning materials
- Assignments
- Grades
- Course resources
- Student engagement with course materials
- Course-level learning analytics

**Project implementation:**  
This project does not access or reproduce University of Michigan Canvas data or internal schemas. It creates a synthetic LMS-like dataset based on publicly documented Canvas functions.

**Planned synthetic LMS entities:**
- Courses
- Course sections
- Student course enrollments
- Assignments
- Assignment submissions
- Grades
- Course activity / resource access

**Governance role:**  
The LMS-like source will serve as the authoritative source for course engagement and learning-activity data, but not for official institutional enrollment.

### 3. Admissions / CRM

**Reference environment:** University of Michigan Recruiting/Admissions and Enrollment Connect (Slate)

**Business purpose:**  
Represents the prospective-student and admissions lifecycle before matriculation, including prospect information, applications, admissions stages, decisions, recruiting interactions, and communications.

**Publicly documented U-M functions used as reference:**
- Prospect data
- Applicant data and applications
- Admissions decisions
- Prospect/applicant communications
- Admissions reporting
- Event and interaction information
- Sharing admissions information across university units

**Project implementation:**  
This project does not access or reproduce University of Michigan admissions records or internal Slate/M-Pathways schemas. It creates a synthetic CRM/admissions dataset representing publicly documented higher-education admissions workflows.

**Planned synthetic CRM entities:**
- Prospects
- Applicants
- Applications
- Admissions stages
- Admissions decisions
- Recruiting interactions
- Admissions events

**Governance role:**  
The CRM-like source will serve as the authoritative source for pre-matriculation admissions status and recruiting activity.

### 4. ERP / Human Capital Management (HCM)

**Reference environment:** University of Michigan M-Pathways Human Resource Management and Financials

**Business purpose:**  
Represents enterprise administrative information used to manage employees, departments, organizational structures, financial units, and cost centers.

**Publicly documented functions used as reference:**
- Employee and workforce administration
- Organizational information
- Departmental structures
- Financial administration
- Accounting and financial operations
- Institutional administrative reporting

**Project implementation:**  
This project does not access or reproduce University of Michigan HR, financial, employee, or internal M-Pathways data. It creates synthetic ERP/HCM-like datasets representing common higher-education organizational and administrative structures.

**Planned synthetic ERP/HCM entities:**
- Employees
- Departments
- Organizational units
- Colleges / schools
- Positions
- Cost centers

**Governance role:**  
The ERP/HCM-like source will serve as the authoritative source for organizational hierarchy, departments, employees, and cost-center mappings used by the analytical platform.

### 5. IPEDS / Public Institutional Data

**Source:** Integrated Postsecondary Education Data System (IPEDS), National Center for Education Statistics (NCES)

**Business purpose:**  
Provides standardized public higher-education data that can be used for institutional benchmarking, trend analysis, and comparison with peer institutions.

**Relevant IPEDS components for V1:**
- Institutional Characteristics (IC)
- Fall Enrollment (EF)
- Admissions (ADM)
- Completions (C)
- Graduation Rates (GR)

**Project implementation:**  
Unlike the synthetic operational SIS, LMS, CRM, and ERP/HCM datasets, IPEDS data used in this project will come from publicly available NCES/IPEDS sources.

IPEDS data will be maintained separately from synthetic student-level operational data because IPEDS provides aggregated institutional measures rather than individual student records.

**Planned analytical use:**
- Institutional benchmarking
- Enrollment trends
- Admissions comparisons
- Completion trends
- Graduation-rate comparisons
- Peer institution analysis

**Governance role:**  
IPEDS serves as an external public benchmark and is not the authoritative source for internal student-level operational records.