# Calibration Commercial Module (CCM) — Scope & User Stories (US) Specification

## Executive Summary
The **Calibration Commercial Module (CCM)** is a cloud-native enterprise application designed to streamline calibration laboratory operations, commercial billing, compliance verification, and logistics. It connects collection agents, lab technicians, commercial managers, approvers, and dispatch teams into a unified multi-tenant workflow.

---

## 1. Project Scope & Architecture

### 1.1 In-Scope Functionality
* **Master Data Management**: Full lifecycle management of Clients, Vendors, and Item Masters (equipment parameters, standard rates, GST details).
* **Equipment Intake & Intake Requests**: Registration of calibration requests, collection agent handoffs, equipment condition tagging, and lab queue routing.
* **Lab Operations & Calibration Verification**: Verification proof uploads, calibration test result logging, parameter compliance checks, and automated certificate generation.
* **Commercial & Financial Workflows**: Multi-item Quotation generation, hierarchical approval routing, automated Invoice calculation (with GST breakdown), and Purchase Order tracking.
* **Logistics & Execution**: Dispatch routing, delivery tracking, and client digital signature capture upon handover.
* **Security & Multi-Tenancy**: Row Level Security (RLS), multi-tenant isolation, Role-Based Access Control (RBAC), and immutable audit logs.

### 1.2 Technology Stack
* **Frontend**: React, TypeScript, Tailwind CSS (Light Theme UI), Vite
* **API Gateway**: Cloudflare Workers / Hono REST API Gateway running on `http://localhost:3000`
* **Backend / Database**: Supabase PostgreSQL with Row Level Security (RLS) policies
* **Authentication**: Supabase Auth with custom role-based JWT claims (`jose`)
* **Storage**: Cloudflare R2 / Private bucket storage with signed URLs

---

## 2. User Personas & Roles

| Role Code | Role Name | Primary Responsibility |
| :--- | :--- | :--- |
| `SUPER_ADMIN` / `ADMIN` | System Administrator | Platform configuration, user management, global master data, full audit access |
| `COLLECTION_AGENT` | Intake & Logistics Agent | Physical equipment pickup, collection verification, intake request creation |
| `LAB_USER` | Lab Technician / Calibration Engineer | Calibration testing, parameter measurement logging, verification proof, certificate generation |
| `COMMERCIAL_USER` | Commercial Executive | Quotation drafting, pricing calculations, invoice issuance, PO matching |
| `APPROVER` | Commercial Manager / Lab Head | Reviewing high-value quotations, approving discounts, commercial clearance |
| `DISPATCH_USER` | Logistics & Dispatch User | Dispatch scheduling, gate pass generation, client signature capture |

---

## 3. Detailed User Stories (US)

### Module 1: Master Data Management

#### US-MD-001: Client Master Data Management
* **As a** Commercial User / Admin,
* **I want to** create, update, search, and view client profiles (Company Name, Code, Contact Person, Email, Phone, Address, GSTIN, Status),
* **So that** all intake requests and billing documents are linked to validated client accounts.
* **Acceptance Criteria**:
  - Modal form (`ClientFormModal`) allows adding and editing clients with required validation.
  - Submitting saves to `POST /api/clients` and refreshes the table dynamically.
  - GSTIN must validate standard format when provided.

#### US-MD-002: Vendor Master Data Management
* **As a** Lab User / Admin,
* **I want to** manage vendor profiles for external calibration and subcontracting (Name, Code, Contact Person, Email, Phone, Address, GSTIN),
* **So that** out-sourced calibration jobs can be tracked against registered vendors.
* **Acceptance Criteria**:
  - Modal form (`VendorFormModal`) provides interactive client-side entry.
  - API endpoint `POST /api/vendors` persists data under active tenant isolation.

#### US-MD-003: Equipment & Item Master Catalog
* **As a** Lab User / Admin,
* **I want to** manage item master templates including default ranges, tolerances, callout fees, and standard calibration rates,
* **So that** calibration requests and quotations can automatically populate pricing and testing standards.

---

### Module 2: Requests & Collection Workflow

#### US-REC-001: Calibration Request Creation
* **As a** Collection Agent / Admin,
* **I want to** register new calibration intake requests for client instruments,
* **So that** physical equipment entering the lab is cataloged with priority (`NORMAL`, `URGENT`) and condition tags.
* **Acceptance Criteria**:
  - Auto-generates unique request numbers (`REQ-YYYY-XXXX`).
  - Supports multi-item equipment lists with serial numbers and target calibration dates.

#### US-REC-002: Equipment Collection Handoff
* **As a** Collection Agent,
* **I want to** mark equipment as `COLLECTED` and submit collection notes,
* **So that** the lab team receives instant notification of incoming physical inventory.

---

### Module 3: Lab Verification & Calibration Operations

#### US-LAB-001: Lab Queue & Queue Management
* **As a** Lab User,
* **I want to** view all incoming calibration requests categorized by priority and lab status (`LAB_QUEUE`, `VERIFICATION`, `ON_HOLD`),
* **So that** technician workload can be prioritized effectively.

#### US-LAB-002: Calibration Testing & Certificate Generation
* **As a** Lab User,
* **I want to** record calibration measurement values, upload verification proofs (images/documents), and generate compliance certificates,
* **So that** clients receive traceable calibration reports.
* **Acceptance Criteria**:
  - Validates measured values against defined tolerances in the item master.
  - Generates downloadable PDF certificates stored securely in Cloudflare R2 storage.

---

### Module 4: Commercial Workflow (Quotations & Invoices)

#### US-COM-001: Quotation Creation & Line-Item Pricing
* **As a** Commercial User,
* **I want to** convert calibration requests into formal quotations with line items, discounts, and tax breakdowns,
* **So that** clients receive official commercial estimates for approval.

#### US-COM-002: Quotation Approval Workflow
* **As an** Approver,
* **I want to** review draft quotations above specified financial thresholds and approve or reject them with feedback,
* **So that** margin rules and commercial guidelines are enforced.

#### US-COM-003: Automated Invoice Generation
* **As a** Commercial User,
* **I want to** generate GST-compliant invoices upon job completion,
* **So that** payments can be collected from clients against issued Purchase Orders (POs).

---

### Module 5: Dispatch & Client Digital Signatures

#### US-DSP-001: Dispatch Scheduling & Delivery Pass
* **As a** Dispatch User,
* **I want to** group completed equipment into dispatch packages and generate delivery gate passes,
* **So that** instruments are returned safely to client premises.

#### US-DSP-002: Client Handover & Digital Signature Capture
* **As a** Dispatch User / Delivery Agent,
* **I want to** capture client digital signatures directly on touchscreen/device screens upon handover,
* **So that** proof of delivery is permanently logged and legally verified.

---

## 4. Non-Functional Requirements & Security

1. **Tenant Isolation**: Every database query and API call strictly enforces `tenant_id` and `organization_id` filters via Row Level Security (RLS).
2. **Performance**: API responses complete within < 200ms; frontend bundle is optimized with dynamic imports.
3. **UI/UX Standard**: Modern, crisp Light Theme interface (`slate-900` text, `white` cards, `indigo-600` primary accents) with responsive mobile/desktop layouts.
4. **Auditability**: Every INSERT, UPDATE, and DELETE operation generates an audit event recording user ID, timestamp, and payload diff.
