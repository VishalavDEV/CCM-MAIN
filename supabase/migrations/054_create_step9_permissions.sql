-- Migration 054: Step 9 Permissions for Document Storage & Management

DO $$
DECLARE
    v_admin_role_id UUID;
    v_lab_role_id UUID;
    v_comm_role_id UUID;
    v_dispatch_role_id UUID;
BEGIN
    -- 1. Insert Document Management Permissions
    INSERT INTO permissions (code, name, description, module) VALUES
    ('DOCUMENT_VIEW', 'View Documents', 'Allows viewing document metadata and details', 'Documents'),
    ('DOCUMENT_CREATE', 'Upload Documents', 'Allows uploading new documents', 'Documents'),
    ('DOCUMENT_UPDATE', 'Update/Replace Documents', 'Allows updating document details and upload replacements', 'Documents'),
    ('DOCUMENT_DELETE', 'Archive/Delete Documents', 'Allows marking documents as deleted or archived', 'Documents'),
    ('DOCUMENT_DOWNLOAD', 'Download Documents', 'Allows requesting short-lived signed URLs to download documents', 'Documents'),
    ('DOCUMENT_MANAGE', 'Manage All Documents', 'Full administrative management of document repository', 'Documents')
    ON CONFLICT (code) DO NOTHING;

    -- 2. Map Permissions to Admin Role
    SELECT id INTO v_admin_role_id FROM roles WHERE code = 'ADMIN' LIMIT 1;
    IF v_admin_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role_id, id FROM permissions WHERE module = 'Documents'
        ON CONFLICT DO NOTHING;
    END IF;

    -- 3. Map Permissions to Lab Role
    SELECT id INTO v_lab_role_id FROM roles WHERE code = 'LAB_USER' LIMIT 1;
    IF v_lab_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_lab_role_id, id FROM permissions WHERE code IN ('DOCUMENT_VIEW', 'DOCUMENT_CREATE', 'DOCUMENT_DOWNLOAD')
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4. Map Permissions to Commercial Role
    SELECT id INTO v_comm_role_id FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;
    IF v_comm_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role_id, id FROM permissions WHERE code IN ('DOCUMENT_VIEW', 'DOCUMENT_CREATE', 'DOCUMENT_DOWNLOAD')
        ON CONFLICT DO NOTHING;
    END IF;

    -- 5. Map Permissions to Dispatch Role
    SELECT id INTO v_dispatch_role_id FROM roles WHERE code = 'DISPATCH_USER' LIMIT 1;
    IF v_dispatch_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_dispatch_role_id, id FROM permissions WHERE code IN ('DOCUMENT_VIEW', 'DOCUMENT_CREATE', 'DOCUMENT_DOWNLOAD')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
