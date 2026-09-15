-- Migration 060: Step 11 Permissions for Async Jobs & Background Workflows

DO $$
DECLARE
    v_admin_role_id UUID;
    v_lab_role_id UUID;
    v_comm_role_id UUID;
BEGIN
    -- 1. Register Async Job Permissions
    INSERT INTO permissions (code, name, description, module) VALUES
    ('ASYNC_JOB_VIEW', 'View Async Jobs', 'Allows viewing status and details of background async processing jobs', 'AsyncProcessing'),
    ('ASYNC_JOB_CANCEL', 'Cancel Async Job', 'Allows cancelling queued background jobs', 'AsyncProcessing'),
    ('ASYNC_JOB_RETRY', 'Retry Async Job', 'Allows retrying failed background jobs', 'AsyncProcessing'),
    ('ASYNC_JOB_MANAGE', 'Manage Async Jobs', 'Full administrative control over background job queues and workflows', 'AsyncProcessing')
    ON CONFLICT (code) DO NOTHING;

    -- 2. Map Permissions to Admin Role
    SELECT id INTO v_admin_role_id FROM roles WHERE code = 'ADMIN' LIMIT 1;
    IF v_admin_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_admin_role_id, id FROM permissions WHERE code IN (
            'ASYNC_JOB_VIEW', 'ASYNC_JOB_CANCEL', 'ASYNC_JOB_RETRY', 'ASYNC_JOB_MANAGE'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- 3. Map Permissions to Lab Role
    SELECT id INTO v_lab_role_id FROM roles WHERE code = 'LAB_USER' LIMIT 1;
    IF v_lab_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_lab_role_id, id FROM permissions WHERE code IN ('ASYNC_JOB_VIEW', 'ASYNC_JOB_RETRY')
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4. Map Permissions to Commercial Role
    SELECT id INTO v_comm_role_id FROM roles WHERE code = 'COMMERCIAL_USER' LIMIT 1;
    IF v_comm_role_id IS NOT NULL THEN
        INSERT INTO role_permissions (role_id, permission_id)
        SELECT v_comm_role_id, id FROM permissions WHERE code IN ('ASYNC_JOB_VIEW', 'ASYNC_JOB_CANCEL', 'ASYNC_JOB_RETRY')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;
