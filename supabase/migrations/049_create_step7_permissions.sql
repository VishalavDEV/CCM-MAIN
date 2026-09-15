-- Migration 049: Create Step 7 Permissions & Role Mappings

INSERT INTO permissions (code, name, description, module) VALUES
('SIGNATURE_VIEW', 'View Signatures', 'Allows viewing client and delivery signatures', 'Signatures'),
('SIGNATURE_CREATE', 'Create Signature Request', 'Allows creating signature requests', 'Signatures'),
('SIGNATURE_SIGN', 'Sign Document', 'Allows recording signed digital signatures', 'Signatures'),
('DISPATCH_VIEW', 'View Dispatch Tasks', 'Allows viewing dispatch status and dispatch items', 'Dispatch'),
('DISPATCH_CREATE', 'Create Dispatch Entry', 'Allows creating dispatch entries', 'Dispatch'),
('DISPATCH_UPDATE', 'Update Dispatch Entry', 'Allows modifying dispatch details and tracking numbers', 'Dispatch'),
('DISPATCH_EXECUTE', 'Execute Dispatch', 'Allows executing dispatch state transitions', 'Dispatch'),
('DELIVERY_VIEW', 'View Delivery Status', 'Allows viewing delivery receipts and status', 'Delivery'),
('DELIVERY_CREATE', 'Create Delivery Receipt', 'Allows logging proof of delivery', 'Delivery'),
('DELIVERY_UPDATE', 'Update Delivery Status', 'Allows updating delivery details', 'Delivery'),
('DELIVERY_COMPLETE', 'Complete Delivery Lifecycle', 'Allows executing final request completion', 'Delivery')
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    module = EXCLUDED.module;

DO $$
DECLARE
    v_admin_role UUID;
    v_comm_role UUID;
    v_dispatch_role UUID;
    v_appr_role UUID;
BEGIN
    SELECT id INTO v_admin_role FROM roles WHERE code = 'ADMIN' LIMIT 1;
    SELECT id INTO v_comm_role FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;
    SELECT id INTO v_dispatch_role FROM roles WHERE code = 'DISPATCH_USER' LIMIT 1;
    SELECT id INTO v_appr_role FROM roles WHERE code = 'APPROVER' LIMIT 1;

    -- Admin gets all Step 7 permissions
    IF v_admin_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role, id FROM permissions WHERE code IN (
            'SIGNATURE_VIEW', 'SIGNATURE_CREATE', 'SIGNATURE_SIGN',
            'DISPATCH_VIEW', 'DISPATCH_CREATE', 'DISPATCH_UPDATE', 'DISPATCH_EXECUTE',
            'DELIVERY_VIEW', 'DELIVERY_CREATE', 'DELIVERY_UPDATE', 'DELIVERY_COMPLETE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Commercial user gets signature, dispatch, delivery permissions
    IF v_comm_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role, id FROM permissions WHERE code IN (
            'SIGNATURE_VIEW', 'SIGNATURE_CREATE', 'SIGNATURE_SIGN',
            'DISPATCH_VIEW', 'DISPATCH_CREATE', 'DISPATCH_UPDATE', 'DISPATCH_EXECUTE',
            'DELIVERY_VIEW', 'DELIVERY_CREATE', 'DELIVERY_UPDATE', 'DELIVERY_COMPLETE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Dispatch user gets dispatch and delivery execution permissions
    IF v_dispatch_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_dispatch_role, id FROM permissions WHERE code IN (
            'SIGNATURE_VIEW', 'SIGNATURE_SIGN',
            'DISPATCH_VIEW', 'DISPATCH_CREATE', 'DISPATCH_UPDATE', 'DISPATCH_EXECUTE',
            'DELIVERY_VIEW', 'DELIVERY_CREATE', 'DELIVERY_UPDATE', 'DELIVERY_COMPLETE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Approver gets view permissions
    IF v_appr_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_appr_role, id FROM permissions WHERE code IN ('SIGNATURE_VIEW', 'DISPATCH_VIEW', 'DELIVERY_VIEW')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
