-- Migration 041: Create Step 6 Permissions & Role Mappings

INSERT INTO permissions (code, name, description, module) VALUES
('INVOICE_VIEW', 'View Invoices', 'Allows viewing commercial invoices and invoice items', 'Invoices'),
('INVOICE_CREATE', 'Create Invoice', 'Allows creating draft invoices from approved quotations', 'Invoices'),
('INVOICE_UPDATE', 'Update Invoice', 'Allows modifying draft invoices', 'Invoices'),
('INVOICE_ISSUE', 'Issue Invoice', 'Allows issuing draft invoices to clients', 'Invoices'),
('PO_VIEW', 'View Purchase Orders', 'Allows viewing purchase orders and PO items', 'Purchase Orders'),
('PO_CREATE', 'Create Purchase Order', 'Allows creating purchase orders from approved quotations', 'Purchase Orders'),
('PO_UPDATE', 'Update Purchase Order', 'Allows modifying draft purchase orders', 'Purchase Orders'),
('PO_ISSUE', 'Issue Purchase Order', 'Allows issuing purchase orders', 'Purchase Orders')
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    module = EXCLUDED.module;

DO $$
DECLARE
    v_admin_role UUID;
    v_comm_role UUID;
    v_appr_role UUID;
BEGIN
    SELECT id INTO v_admin_role FROM roles WHERE code = 'ADMIN' LIMIT 1;
    SELECT id INTO v_comm_role FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;
    SELECT id INTO v_appr_role FROM roles WHERE code = 'APPROVER' LIMIT 1;

    -- Admin gets all Step 6 permissions
    IF v_admin_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role, id FROM permissions WHERE code IN (
            'INVOICE_VIEW', 'INVOICE_CREATE', 'INVOICE_UPDATE', 'INVOICE_ISSUE',
            'PO_VIEW', 'PO_CREATE', 'PO_UPDATE', 'PO_ISSUE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Commercial user gets all Step 6 permissions
    IF v_comm_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role, id FROM permissions WHERE code IN (
            'INVOICE_VIEW', 'INVOICE_CREATE', 'INVOICE_UPDATE', 'INVOICE_ISSUE',
            'PO_VIEW', 'PO_CREATE', 'PO_UPDATE', 'PO_ISSUE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Approver gets view permissions
    IF v_appr_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_appr_role, id FROM permissions WHERE code IN ('INVOICE_VIEW', 'PO_VIEW')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
