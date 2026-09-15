-- Migration 033: Create Step 5 Permissions & Role Mappings

INSERT INTO permissions (code, name, description, module) VALUES
('QUOTATION_SUBMIT', 'Submit Quotation', 'Allows submitting quotations for approval', 'Quotations'),
('APPROVAL_VIEW', 'View Approvals', 'Allows viewing quotation approval tasks', 'Approvals'),
('APPROVAL_APPROVE', 'Approve Quotation', 'Allows approving commercial quotations', 'Approvals'),
('APPROVAL_REJECT', 'Reject Quotation', 'Allows rejecting commercial quotations with reasons', 'Approvals')
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

    -- Admin gets all permissions
    IF v_admin_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role, id FROM permissions WHERE code IN ('QUOTATION_SUBMIT', 'APPROVAL_VIEW', 'APPROVAL_APPROVE', 'APPROVAL_REJECT')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Commercial user gets QUOTATION_SUBMIT & APPROVAL_VIEW
    IF v_comm_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role, id FROM permissions WHERE code IN ('QUOTATION_SUBMIT', 'APPROVAL_VIEW')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Approver gets APPROVAL_VIEW, APPROVAL_APPROVE, APPROVAL_REJECT
    IF v_appr_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_appr_role, id FROM permissions WHERE code IN ('APPROVAL_VIEW', 'APPROVAL_APPROVE', 'APPROVAL_REJECT')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
