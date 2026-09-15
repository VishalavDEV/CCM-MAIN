-- Migration 058: Step 10 Permissions for HTML -> PDF Document Generation

DO $$
DECLARE
    v_admin_role_id UUID;
    v_lab_role_id UUID;
    v_comm_role_id UUID;
BEGIN
    -- 1. Register PDF Generation Permissions
    INSERT INTO permissions (code, name, description, module) VALUES
    ('CERTIFICATE_GENERATE', 'Generate Calibration Certificate PDF', 'Allows generating official PDF certificates from calibration records', 'Documents'),
    ('QUOTATION_PDF_GENERATE', 'Generate Quotation PDF', 'Allows generating PDF document for approved quotations', 'Documents'),
    ('INVOICE_PDF_GENERATE', 'Generate Invoice PDF', 'Allows generating PDF document for issued invoices', 'Documents'),
    ('PURCHASE_ORDER_PDF_GENERATE', 'Generate Purchase Order PDF', 'Allows generating PDF document for client purchase orders', 'Documents'),
    ('DOCUMENT_GENERATE', 'Generate All Business Documents', 'Full administrative authority to generate all document PDFs', 'Documents')
    ON CONFLICT (code) DO NOTHING;

    -- 2. Map Permissions to Admin Role
    SELECT id INTO v_admin_role_id FROM roles WHERE code = 'ADMIN' LIMIT 1;
    IF v_admin_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role_id, id FROM permissions WHERE code IN (
            'CERTIFICATE_GENERATE', 'QUOTATION_PDF_GENERATE', 'INVOICE_PDF_GENERATE', 'PURCHASE_ORDER_PDF_GENERATE', 'DOCUMENT_GENERATE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- 3. Map Permissions to Lab Role
    SELECT id INTO v_lab_role_id FROM roles WHERE code = 'LAB_USER' LIMIT 1;
    IF v_lab_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_lab_role_id, id FROM permissions WHERE code IN ('CERTIFICATE_GENERATE')
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4. Map Permissions to Commercial Role
    SELECT id INTO v_comm_role_id FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;
    IF v_comm_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role_id, id FROM permissions WHERE code IN ('QUOTATION_PDF_GENERATE', 'INVOICE_PDF_GENERATE', 'PURCHASE_ORDER_PDF_GENERATE')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
