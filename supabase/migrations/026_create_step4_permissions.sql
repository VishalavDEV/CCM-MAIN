-- Migration 026: Create Step 4 Permissions & Role Mappings

INSERT INTO permissions (code, name, description, module) VALUES
('FAULTY_SERVICE_VIEW', 'View Faulty Item Services', 'Allows viewing internal service records for faulty items', 'Faulty Service'),
('FAULTY_SERVICE_CREATE', 'Create Faulty Item Service', 'Allows creating new faulty item service tickets', 'Faulty Service'),
('FAULTY_SERVICE_UPDATE', 'Update Faulty Item Service', 'Allows updating service status and notes', 'Faulty Service'),
('OUTSOURCING_VIEW', 'View Vendor Outsourcing', 'Allows viewing vendor outsourcing records', 'Vendor Outsourcing'),
('OUTSOURCING_CREATE', 'Create Vendor Outsourcing', 'Allows creating vendor outsourcing requests', 'Vendor Outsourcing'),
('OUTSOURCING_UPDATE', 'Update Vendor Outsourcing', 'Allows updating vendor outsourcing status and return details', 'Vendor Outsourcing')
ON CONFLICT (code) DO UPDATE SET 
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    module = EXCLUDED.module;

-- Map permissions to ADMIN, LAB_USER, COMMERCIAL_USER
DO $$
DECLARE
    v_admin_role UUID;
    v_lab_role UUID;
    v_comm_role UUID;
BEGIN
    SELECT id INTO v_admin_role FROM roles WHERE code = 'ADMIN' LIMIT 1;
    SELECT id INTO v_lab_role FROM roles WHERE code = 'LAB_USER' LIMIT 1;
    SELECT id INTO v_comm_role FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;

    -- Admin gets all permissions
    IF v_admin_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role, id FROM permissions WHERE code IN ('FAULTY_SERVICE_VIEW', 'FAULTY_SERVICE_CREATE', 'FAULTY_SERVICE_UPDATE', 'OUTSOURCING_VIEW', 'OUTSOURCING_CREATE', 'OUTSOURCING_UPDATE')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Lab user gets Faulty Service & Outsourcing permissions
    IF v_lab_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_lab_role, id FROM permissions WHERE code IN ('FAULTY_SERVICE_VIEW', 'FAULTY_SERVICE_CREATE', 'FAULTY_SERVICE_UPDATE', 'OUTSOURCING_VIEW', 'OUTSOURCING_CREATE', 'OUTSOURCING_UPDATE')
        ON CONFLICT DO NOTHING;
    END IF;

    -- Commercial user gets Outsourcing permissions
    IF v_comm_role IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role, id FROM permissions WHERE code IN ('OUTSOURCING_VIEW', 'OUTSOURCING_CREATE', 'OUTSOURCING_UPDATE')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
