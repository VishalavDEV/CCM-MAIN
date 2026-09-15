-- Migration 056: Step 9 Row Level Security (RLS) for Documents Table

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS documents_tenant_org_isolation ON documents;

CREATE POLICY documents_tenant_org_isolation ON documents
    FOR ALL
    USING (
        tenant_id = (current_setting('app.current_tenant_id', true))::uuid
        AND organization_id = (current_setting('app.current_organization_id', true))::uuid
    )
    WITH CHECK (
        tenant_id = (current_setting('app.current_tenant_id', true))::uuid
        AND organization_id = (current_setting('app.current_organization_id', true))::uuid
    );
