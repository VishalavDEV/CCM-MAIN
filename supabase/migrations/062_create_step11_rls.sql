-- Migration 062: Row Level Security (RLS) for Async Jobs Table

ALTER TABLE async_jobs ENABLE ROW LEVEL SECURITY;

-- 1. Select Policy: Users can view async jobs in their tenant and organization
DROP POLICY IF EXISTS async_jobs_select_policy ON async_jobs;
CREATE POLICY async_jobs_select_policy ON async_jobs
    FOR SELECT
    USING (
        tenant_id = (current_setting('app.current_tenant_id', true))::uuid
        AND organization_id = (current_setting('app.current_organization_id', true))::uuid
    );

-- 2. Insert Policy: Users can create async jobs in their tenant and organization
DROP POLICY IF EXISTS async_jobs_insert_policy ON async_jobs;
CREATE POLICY async_jobs_insert_policy ON async_jobs
    FOR INSERT
    WITH CHECK (
        tenant_id = (current_setting('app.current_tenant_id', true))::uuid
        AND organization_id = (current_setting('app.current_organization_id', true))::uuid
    );

-- 3. Update Policy: Users can update async jobs in their tenant and organization
DROP POLICY IF EXISTS async_jobs_update_policy ON async_jobs;
CREATE POLICY async_jobs_update_policy ON async_jobs
    FOR UPDATE
    USING (
        tenant_id = (current_setting('app.current_tenant_id', true))::uuid
        AND organization_id = (current_setting('app.current_organization_id', true))::uuid
    );
