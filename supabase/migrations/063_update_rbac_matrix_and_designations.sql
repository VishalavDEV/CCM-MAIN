-- Migration 063: Add admin designations and sync canonical RBAC roles & permissions
-- Ensures seamless alignment between multi-tenant organization onboarding and RBAC security matrix

-- 1. ADD DESIGNATION AND RBAC ROLE COLUMNS TO TENANTS & ORGANIZATIONS
ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS admin_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS admin_email VARCHAR(255),
ADD COLUMN IF NOT EXISTS admin_designation VARCHAR(150),
ADD COLUMN IF NOT EXISTS admin_role VARCHAR(100) DEFAULT 'SUPER_ADMIN';

ALTER TABLE organizations 
ADD COLUMN IF NOT EXISTS admin_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS admin_email VARCHAR(255),
ADD COLUMN IF NOT EXISTS admin_designation VARCHAR(150),
ADD COLUMN IF NOT EXISTS admin_role VARCHAR(100) DEFAULT 'ADMIN';

-- 2. SEED ALL 53 CANONICAL PERMISSIONS
INSERT INTO permissions (code, name, description, module) VALUES
-- Tenants Management
('tenant.view', 'View Tenants', 'Allows viewing tenant records and profiles', 'tenants'),
('tenant.create', 'Create Tenants', 'Allows onboarding new enterprise tenants', 'tenants'),
('tenant.update', 'Edit Tenants', 'Allows modifying tenant details and configuration', 'tenants'),
('tenant.delete', 'Delete Tenants', 'Allows decommissioning tenant accounts', 'tenants'),

-- Organizations
('organization.view', 'View Organizations', 'Allows viewing facility organizations and branches', 'organizations'),
('organization.create', 'Create Organizations', 'Allows provisioning new facility organizations', 'organizations'),
('organization.update', 'Edit Organizations', 'Allows modifying organization settings', 'organizations'),
('organization.delete', 'Delete Organizations', 'Allows removing organization records', 'organizations'),

-- User Accounts
('user.view', 'View Users', 'Allows viewing corporate user profiles', 'users'),
('user.create', 'Create Users', 'Allows provisioning new user accounts', 'users'),
('user.update', 'Edit Users', 'Allows updating user profiles and role assignments', 'users'),
('user.delete', 'Delete Users', 'Allows revoking user accounts', 'users'),

-- Roles & Permissions
('role.view', 'View Roles', 'Allows viewing RBAC security roles and matrices', 'roles'),
('role.create', 'Create Roles', 'Allows authoring custom security roles', 'roles'),
('role.update', 'Edit Roles', 'Allows modifying role permissions matrices', 'roles'),
('role.delete', 'Delete Roles', 'Allows deleting custom security roles', 'roles'),
('permission.view', 'View Permissions Directory', 'Allows inspecting system-wide permission catalog', 'roles'),

-- Clients & Customers
('client.view', 'View Clients', 'Allows viewing client master accounts', 'clients'),
('client.create', 'Create Clients', 'Allows onboarding new client organizations', 'clients'),
('client.update', 'Edit Clients', 'Allows updating client profiles and billing terms', 'clients'),
('client.delete', 'Delete Clients', 'Allows removing client accounts', 'clients'),

-- Vendors & Suppliers
('vendor.view', 'View Vendors', 'Allows viewing external calibration vendors', 'vendors'),
('vendor.create', 'Create Vendors', 'Allows registering subcontracting vendors', 'vendors'),
('vendor.update', 'Edit Vendors', 'Allows updating vendor accreditation records', 'vendors'),
('vendor.delete', 'Delete Vendors', 'Allows removing vendor records', 'vendors'),

-- Items & Gauges Master
('item.view', 'View Items', 'Allows viewing instruments and gauge masters', 'items'),
('item.create', 'Create Items', 'Allows registering new instruments in master database', 'items'),
('item.update', 'Edit Items', 'Allows modifying instrument specifications and intervals', 'items'),
('item.delete', 'Delete Items', 'Allows archiving instrument records', 'items'),

-- Calibration Requests
('request.view', 'View Requests', 'Allows viewing service intake requests', 'requests'),
('request.create', 'Create Requests', 'Allows creating new calibration orders', 'requests'),
('request.update', 'Edit Requests', 'Allows editing order items and scheduling', 'requests'),
('request.submit', 'Submit Requests', 'Allows transitioning intake orders to laboratory queue', 'requests'),
('request.delete', 'Delete Requests', 'Allows cancelling calibration requests', 'requests'),

-- Lab Verification
('verification.view', 'View Verification Reports', 'Allows inspecting physical and visual verification sheets', 'verification'),
('verification.create', 'Create Verification', 'Allows generating initial intake check records', 'verification'),
('verification.update', 'Edit Verification', 'Allows revising verification assessments', 'verification'),

-- Calibration & Certificates
('calibration.view', 'View Calibrations', 'Allows viewing test run observations and reports', 'calibration'),
('calibration.create', 'Perform Calibration', 'Allows recording environmental readings and measurements', 'calibration'),
('calibration.update', 'Update Calibration Certificates', 'Allows amending certificates and uncertainty budgets', 'calibration'),

-- Commercial Quotations
('quotation.view', 'View Quotations', 'Allows viewing commercial price proposals', 'quotations'),
('quotation.create', 'Create Quotations', 'Allows drafting commercial quotations', 'quotations'),
('quotation.update', 'Edit Quotations', 'Allows revising quotation rates and terms', 'quotations'),
('quotation.approve', 'Approve Quotations', 'Allows approving quotations exceeding margin limits', 'quotations'),

-- Purchase Orders
('purchase_order.view', 'View Purchase Orders', 'Allows viewing customer and subcontract POs', 'purchaseOrders'),
('purchase_order.create', 'Create Purchase Orders', 'Allows logging client PO agreements', 'purchaseOrders'),
('purchase_order.update', 'Edit Purchase Orders', 'Allows updating PO allocations and line items', 'purchaseOrders'),

-- Invoices & Billing
('invoice.view', 'View Invoices', 'Allows viewing tax invoices and payment status', 'invoices'),
('invoice.create', 'Generate Invoices', 'Allows issuing commercial tax invoices', 'invoices'),
('invoice.update', 'Edit Invoices', 'Allows revising invoice adjustments and notes', 'invoices'),

-- Digital Signatures
('signature.view', 'View Signatures', 'Allows inspecting crypto signature verification stamps', 'signatures'),
('signature.create', 'Sign Documents', 'Allows applying authorized digital signature to certificates', 'signatures'),

-- Dispatch & Deliveries
('dispatch.view', 'View Dispatches', 'Allows viewing outbound delivery manifests and gate passes', 'dispatch'),
('dispatch.create', 'Create Gate Passes', 'Allows issuing equipment security dispatch passes', 'dispatch'),
('delivery.view', 'View Deliveries', 'Allows tracking courier and in-transit shipments', 'dispatch'),
('delivery.update', 'Update Delivery Status', 'Allows capturing customer delivery acknowledgments', 'dispatch'),

-- System Audit Logs
('audit.view', 'View Audit Logs', 'Allows reviewing immutable compliance audit trails', 'auditLogs')

ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    module = EXCLUDED.module;

-- 3. POPULATE INITIAL ROLES AND ASSIGN CANONICAL PERMISSIONS
DO $$
DECLARE
    v_role_id UUID;
    v_tenant_id UUID;
BEGIN
    SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
    IF v_tenant_id IS NULL THEN
        INSERT INTO tenants (name, code, status) 
        VALUES ('Primary Calibration Enterprise', 'PRIM-TENANT', 'ACTIVE')
        RETURNING id INTO v_tenant_id;
    END IF;

    -- Super Admin
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Super Administrator', 'SUPER_ADMIN', 'Complete unrestricted platform authority across all modules.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Tenant Admin
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Tenant Administrator', 'TENANT_ADMIN', 'Enterprise tenant management, lab facility oversight, and staff access controls.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'organization.view', 'organization.create', 'organization.update',
        'user.view', 'user.create', 'user.update',
        'role.view', 'permission.view',
        'client.view', 'client.create', 'client.update',
        'vendor.view', 'vendor.create', 'vendor.update',
        'item.view', 'item.create', 'item.update',
        'request.view', 'request.create', 'request.update', 'request.submit',
        'verification.view', 'verification.create',
        'calibration.view', 'calibration.create',
        'quotation.view', 'quotation.create', 'quotation.update',
        'purchase_order.view', 'purchase_order.create',
        'invoice.view', 'invoice.create',
        'signature.view', 'signature.create',
        'dispatch.view', 'dispatch.create',
        'delivery.view', 'delivery.update',
        'audit.view'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Calibration Lab Engineer
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Calibration Lab Engineer', 'LAB_USER', 'Execution of metrological tests, measurement readings, and certificates.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'item.view', 'item.create', 'item.update',
        'request.view', 'request.update', 'request.submit',
        'verification.view', 'verification.create', 'verification.update',
        'calibration.view', 'calibration.create', 'calibration.update',
        'signature.create'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Commercial Manager
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Commercial Manager', 'COMMERCIAL_USER', 'Management of proposals, rate sheets, quotations, POs, and invoicing.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'client.view', 'client.create', 'client.update', 'client.delete',
        'vendor.view', 'vendor.create', 'vendor.update', 'vendor.delete',
        'item.view',
        'request.view', 'request.create',
        'quotation.view', 'quotation.create', 'quotation.update', 'quotation.approve',
        'purchase_order.view', 'purchase_order.create', 'purchase_order.update',
        'invoice.view', 'invoice.create', 'invoice.update',
        'dispatch.view'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Quality Approver / Lab Director
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Quality Approver / Lab Director', 'APPROVER', 'Quality validation, ISO 17025 compliance sign-off, and digital certificate release.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'request.view',
        'verification.view', 'verification.update',
        'calibration.view', 'calibration.update',
        'quotation.view', 'quotation.approve',
        'signature.view', 'signature.create',
        'audit.view'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Field Collection Agent
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Field Collection Agent', 'COLLECTION_AGENT', 'Instrument pickup logistics, intake documentation, and custody transit.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'client.view',
        'item.view', 'item.create',
        'request.view', 'request.create', 'request.submit',
        'dispatch.view', 'delivery.view'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- Dispatch & Logistics Officer
    INSERT INTO roles (tenant_id, name, code, description, status)
    VALUES (v_tenant_id, 'Dispatch & Logistics Officer', 'DISPATCH_USER', 'Post-calibration packaging, courier manifests, and delivery acknowledgments.', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description
    RETURNING id INTO v_role_id;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_id, p.id FROM permissions p
    WHERE p.code IN (
        'request.view',
        'dispatch.view', 'dispatch.create',
        'delivery.view', 'delivery.update',
        'signature.view', 'signature.create'
    )
    ON CONFLICT (role_id, permission_id) DO NOTHING;

END $$;
