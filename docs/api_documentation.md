# Calibration Commercial Module — REST API & Architecture Documentation

## 1. Overview & Architecture

The **Calibration Commercial Module (CCM) REST API Architecture** is built on top of Cloudflare Workers and Hono router framework, providing high-performance, edge-ready API gateway functionality backed by Supabase PostgreSQL.

### System Architecture Flow

```text
[ CLIENT ]
    │ (HTTP REST JSON)
    ▼
[ API GATEWAY (Hono Router / Wrangler Worker) ]
    │
    ├─► Auth Middleware (JWT Verification via 'jose')
    ├─► Tenant Middleware (Tenant & Organization Context Validation)
    ├─► RBAC Middleware (Role & Permission Authorization)
    └─► Zod Validation Middleware (Request Body & Query Validation)
            │
            ▼
[ DOMAIN WORKERS / ROUTERS ]
    ├── Identity & Master Domain (/api/auth, /api/users, /api/clients, /api/vendors, /api/items)
    ├── Operations Domain (/api/requests, /api/lab/queue, /api/calibrations, /api/faulty-services, /api/vendor-outsourcing)
    ├── Commercial Domain (/api/quotations, /api/invoices, /api/purchase-orders)
    ├── Execution Domain (/api/signatures, /api/dispatches, /api/deliveries)
    └── Document Domain (/api/documents) ──► Cloudflare R2 Private Bucket (`DOCUMENTS_BUCKET`)
            │
            ▼
[ CONTROLLER LAYER ] (Standard HTTP response formatting)
            │
            ▼
[ SERVICE LAYER ] (Business rules validation & audit log generation)
            │
            ▼
[ REPOSITORY LAYER ] (Parameterized SQL execution & PostgreSQL RLS context)
            │
            ▼
[ SUPABASE POSTGRESQL DATABASE ]
```

---

## 2. Security & Middleware Pipeline

Every incoming request passes through an enforced multi-stage security pipeline:

1. **Cors & Body Parsing Middleware**: Standard CORS header validation and JSON parsing.
2. **JWT Authentication Middleware (`auth.middleware.ts`)**:
   - Extracts `Authorization: Bearer <token>` header.
   - Verifies HS256 JWT signatures using `jose`.
   - Populates user identity context (`userId`, `tenantId`, `organizationId`, `roles`, `permissions`).
3. **Tenant Context Middleware (`tenant.middleware.ts`)**:
   - Checks `x-tenant-id` header (if provided) against token payload to prevent cross-tenant request spoofing.
   - Enforces strict single-tenant database transaction boundaries.
4. **RBAC Middleware (`rbac.middleware.ts`)**:
   - Validates user roles (`ADMIN`, `LAB_USER`, `COMMERCIAL_USER`, etc.) or explicit permission codes (`REQUEST_CREATE`, `CALIBRATION_MEASURE`, `DOCUMENT_CREATE`, etc.).
5. **Zod Input Validation (`zod.middleware.ts`)**:
   - Strict schema validation for body payloads and UUID URL parameters.
   - Rejects invalid requests with structured `400 Bad Request` responses before invoking business logic.

---

## 3. REST API Endpoint Directory

### A. Identity & Auth Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/auth/login` | Public | Authenticates user credentials and returns JWT bearer token |
| `GET` | `/api/auth/me` | Authenticated | Returns logged in user profile & permissions |
| `GET` | `/api/users` | `ADMIN` / `USER_VIEW` | Paginated user profiles list |
| `GET` | `/api/roles` | `ADMIN` / `ROLE_VIEW` | Roles directory |

### B. Master Data Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/clients` | `CLIENT_VIEW` | List all client companies |
| `GET` | `/api/clients/:id` | `CLIENT_VIEW` | Get specific client detail |
| `POST` | `/api/clients` | `CLIENT_CREATE` | Create new client record |
| `PUT` | `/api/clients/:id` | `CLIENT_EDIT` | Update client record |
| `GET` | `/api/vendors` | `VENDOR_VIEW` | List calibration vendors |
| `POST` | `/api/vendors` | `VENDOR_CREATE` | Register vendor company |
| `GET` | `/api/item-masters` | `ITEM_MASTER_VIEW` | Catalog of equipment item masters |
| `POST` | `/api/item-masters` | `ITEM_MASTER_CREATE` | Create item master catalog entry |

### C. Calibration Request & Operations Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/requests` | `REQUEST_VIEW` | List calibration requests |
| `POST` | `/api/requests` | `REQUEST_CREATE` | Create calibration request with line items |
| `POST` | `/api/requests/:id/submit` | `REQUEST_CREATE` | Submit request (updates status to SUBMITTED) |
| `GET` | `/api/lab/queue` | `LAB_VIEW` | Retrieve items waiting in lab queue |
| `POST` | `/api/requests/:id/items/:itemId/verify` | `VERIFICATION_EXECUTE` | Perform physical verification on received item |

### D. Calibration & Measurement Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/calibrations` | `CALIBRATION_VIEW` | List calibrations |
| `POST` | `/api/calibrations` | `CALIBRATION_CREATE` | Initiate calibration for verified item |
| `POST` | `/api/calibrations/:id/measurements` | `CALIBRATION_MEASURE` | Record parameter measurement (evaluates PASS/FAIL) |
| `POST` | `/api/calibrations/:id/complete` | `CALIBRATION_COMPLETE` | Complete calibration process |
| `GET` | `/api/certificates` | `CERTIFICATE_VIEW` | List generated certificate metadata |
| `GET` | `/api/due-list` | `DUE_LIST_VIEW` | View upcoming equipment calibration due dates |

### E. Faulty Service & Vendor Outsourcing Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/faulty-services` | `FAULTY_SERVICE_VIEW` | List faulty item service logs |
| `POST` | `/api/faulty-services` | `FAULTY_SERVICE_CREATE` | Log faulty item for internal repair |
| `POST` | `/api/faulty-services/:id/complete` | `FAULTY_SERVICE_UPDATE` | Complete faulty item repair service |
| `GET` | `/api/vendor-outsourcing` | `VENDOR_OUTSOURCING_VIEW` | List outsourced vendor jobs |
| `POST` | `/api/vendor-outsourcing` | `VENDOR_OUTSOURCING_CREATE` | Dispatch item to external vendor |
| `POST` | `/api/vendor-outsourcing/:id/return` | `VENDOR_OUTSOURCING_UPDATE` | Record return from external vendor |

### F. Commercial Domain (Quotations, Invoices, POs)

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/quotations` | `QUOTATION_VIEW` | List commercial quotations |
| `POST` | `/api/quotations` | `QUOTATION_CREATE` | Generate commercial quotation draft |
| `POST` | `/api/quotations/:id/approve` | `QUOTATION_APPROVE` | Approve or reject quotation |
| `GET` | `/api/invoices` | `INVOICE_VIEW` | List commercial invoices |
| `POST` | `/api/invoices` | `INVOICE_CREATE` | Create invoice from APPROVED quotation |
| `POST` | `/api/invoices/:id/issue` | `INVOICE_CREATE` | Issue invoice to client |
| `GET` | `/api/purchase-orders` | `PO_VIEW` | List client purchase orders |
| `POST` | `/api/purchase-orders` | `PO_CREATE` | Record client PO for APPROVED quotation |

### G. Execution & Dispatch Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `POST` | `/api/signatures` | `SIGNATURE_CREATE` | Record digital client invoice/delivery signature |
| `GET` | `/api/dispatches` | `DISPATCH_VIEW` | List dispatches |
| `POST` | `/api/dispatches` | `DISPATCH_CREATE` | Create dispatch package with courier tracking |
| `POST` | `/api/dispatches/:id/dispatch` | `DISPATCH_EXECUTE` | Execute dispatch (status -> DISPATCHED) |
| `POST` | `/api/deliveries` | `DELIVERY_CREATE` | Create delivery confirmation record |
| `POST` | `/api/deliveries/:id/receive` | `DELIVERY_UPDATE` | Mark delivery as received by client |
| `POST` | `/api/deliveries/:id/sign` | `DELIVERY_SIGN` | Attach delivery signoff |
| `POST` | `/api/requests/:id/complete` | `REQUEST_COMPLETE` | Final procedural completion of request |

### H. Cloudflare R2 Document Storage Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/documents` | `DOCUMENT_VIEW` | List document metadata with request filtering |
| `GET` | `/api/documents/:id` | `DOCUMENT_VIEW` | Get specific document metadata record |
| `POST` | `/api/documents` | `DOCUMENT_CREATE` | Upload binary object to R2 + store metadata in PostgreSQL |
| `POST` | `/api/documents/:id/signed-url` | `DOCUMENT_DOWNLOAD` | Generate short-lived signed access URL (`TTL = 300s`) |
| `GET` | `/api/documents/:id/download` | Token Query (`?token=`) | Stream private document content from R2 storage |
| `POST` | `/api/documents/:id/replace` | `DOCUMENT_UPDATE` | Upload replacement version (marks V1 as `REPLACED`) |
| `DELETE` | `/api/documents/:id` | `DOCUMENT_DELETE` | Soft delete document metadata and remove R2 object |

### J. Cloudflare Queues & Workflows Async Processing Domain

| Method | Endpoint | Permission / Role | Description |
| :--- | :--- | :--- | :--- |
| `GET` | `/api/jobs` | `ASYNC_JOB_VIEW` | Paginated listing of background async processing jobs with status/type filters |
| `GET` | `/api/jobs/:id` | `ASYNC_JOB_VIEW` | Retrieve detailed status, attempt count, and result metadata for a specific job |
| `POST` | `/api/jobs/:id/cancel` | `ASYNC_JOB_CANCEL` | Cancel a background job in `QUEUED` status (marks status as `CANCELLED`) |
| `POST` | `/api/jobs/:id/retry` | `ASYNC_JOB_RETRY` | Retry a background job in `FAILED` status (resets error state, marks status as `QUEUED`, re-dispatches to Queue) |

---

## 4. End-to-End Integration Test Suites

### Step 8 API Gateway Test Suite (`test-api-e2e.mjs`) — 21 / 21 Passed
```text
RESULTS: 21 / 21 E2E API TESTS PASSED SUCCESSFULLY!
```

### Step 9 Cloudflare R2 Document Storage Test Suite (`test-api-step9.mjs`) — 17 / 17 Passed
```text
=====================================================
STEP 9 — CLOUDFLARE R2 DOCUMENT STORAGE E2E TEST SUITE
=====================================================

✅ [PASS] API Gateway Health Check
✅ [PASS] Auth Guard: Reject Missing Token (401)
✅ [PASS] Auth Guard: Reject Invalid Token (401)
✅ [PASS] RBAC Guard: Reject Unprivileged User (403)
✅ [PASS] Tenant Guard: Reject Tenant Mismatch Header (403)
✅ [PASS] Zod Guard: Reject Invalid Payload Body (400)
✅ [PASS] REST API POST /api/documents (Upload to R2 & DB Metadata Created)
✅ [PASS] REST API GET /api/documents/:id (Fetch Metadata)
✅ [PASS] REST API GET /api/documents (Filter by requestId)
✅ [PASS] REST API POST /api/documents/:id/signed-url (Generate Short-lived Access URL)
✅ [PASS] REST API GET /api/documents/:id/download (Stream File from R2)
✅ [PASS] Download Token Guard: Reject Invalid Token (401)
✅ [PASS] Multi-Tenant Guard: Tenant B cannot access Tenant A document (404)
✅ [PASS] REST API POST /api/documents/:id/replace (Versioning: V2 Created, V1 REPLACED)
✅ [PASS] REST API DELETE /api/documents/:id (Soft Delete & R2 Cleanup)
✅ [PASS] Deleted Document Guard: Reject Signed URL for Deleted Document (409 Conflict / 400 Bad Request)
✅ [PASS] Audit Trail Verification: Document operations recorded in audit_logs

=====================================================
RESULTS: 17 / 17 STEP 9 INTEGRATION TESTS PASSED!
=====================================================
```

### Step 10 Puppeteer HTML → PDF Document Generation Test Suite (`test-api-step10.mjs`) — 9 / 9 Passed
```text
=====================================================
STEP 10 — PUPPETEER HTML -> PDF DOCUMENT GENERATION E2E TEST SUITE
=====================================================

✅ [PASS] API Gateway Health Check
✅ [PASS] Puppeteer PDF: POST /api/certificates/:id/generate (Job Enqueued)
✅ [PASS] Certificate Document Metadata Created
✅ [PASS] Private R2 Access: Download Generated PDF via Signed URL (%PDF- Header Valid)
✅ [PASS] Puppeteer PDF: POST /api/quotations/:id/generate-pdf (Quotation PDF Created)
✅ [PASS] Puppeteer PDF: POST /api/invoices/:id/generate-pdf (Invoice PDF Created)
✅ [PASS] Puppeteer PDF: POST /api/purchase-orders/:id/generate-pdf (Purchase Order PDF Created)
✅ [PASS] Document Versioning: Regeneration creates next version (version > 1)
✅ [PASS] Multi-Tenant Security: Tenant B denied access to Tenant A certificate (404/403)

=====================================================
RESULTS: 9 / 9 STEP 10 INTEGRATION TESTS PASSED!
=====================================================
```

### Step 11 Cloudflare Queues + Workflows Async Processing Test Suite (`test-api-step11.mjs`) — 16 / 16 Passed
```text
=====================================================
STEP 11 — CLOUDFLARE QUEUES + WORKFLOWS E2E TEST SUITE
=====================================================

✅ [PASS] API Gateway Health Check
✅ [PASS] Auth Guard: Reject Missing Token on /api/jobs (401)
✅ [PASS] RBAC Guard: Reject Unprivileged User on /api/jobs (403)
✅ [PASS] Tenant Guard: Reject Tenant Mismatch Header on /api/jobs (403)
✅ [PASS] REST API POST /api/certificates/:id/generate (Enqueues async job & returns QUEUED status)
✅ [PASS] Background Queue Consumer & Workflow: Process Certificate Job to COMPLETED
✅ [PASS] REST API POST /api/quotations/:id/generate-pdf (Async queueing & completion)
✅ [PASS] REST API POST /api/invoices/:id/generate-pdf (Async queueing & completion)
✅ [PASS] REST API POST /api/purchase-orders/:id/generate-pdf (Async queueing & completion)
✅ [PASS] REST API GET /api/jobs (Lists and filters background jobs)
✅ [PASS] REST API POST /api/jobs/:id/cancel (Cancels a QUEUED job)
✅ [PASS] Business Guard: Reject cancelling a COMPLETED job (400)
✅ [PASS] REST API POST /api/jobs/:id/retry (Retries a FAILED job)
✅ [PASS] Business Guard: Reject retrying a COMPLETED job (400)
✅ [PASS] Multi-Tenant Isolation: Tenant B denied access to Tenant A job (404/403)
✅ [PASS] Audit Trail Verification: Async job and workflow operations recorded in audit_logs

=====================================================
RESULTS: 16 / 16 STEP 11 INTEGRATION TESTS PASSED!
=====================================================
```

---

## 5. React + Vite Frontend Architecture (Step 12)

The **Step 12 React + Vite Frontend Foundation** provides a single-page application (SPA) built with:
- **Core Framework**: React 19, Vite 6, TypeScript 5
- **Styling & UI**: Tailwind CSS v4, Lucide Icons, Glassmorphism design system
- **Routing**: React Router 7 (`react-router-dom`) with `ProtectedRoute` and `PermissionGuard`
- **Authentication**: Supabase Auth client (`supabaseClient.ts`), `AuthProvider`, and automatic Bearer JWT token injection
- **API Client**: Centralized native `fetch` wrapper (`apiClient.ts`) consuming the edge API Gateway (`http://localhost:3000`)
- **Pages**:
  - `/login`: Professional glassmorphism login portal
  - `/dashboard`: Live KPI metrics, quick actions, system architecture status, and activity feed
  - Domain Routes: `/clients`, `/vendors`, `/items`, `/requests`, `/lab/queue`, `/calibrations`, `/quotations`, `/approvals`, `/invoices`, `/purchase-orders`, `/signatures`, `/dispatches`, `/deliveries`, `/documents`, `/jobs`

