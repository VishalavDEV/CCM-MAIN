-- Migration 015: Create Step 2 Row Level Security (RLS) Policies

ALTER TABLE calibration_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE request_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE verifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS calibration_requests_isolation_policy ON calibration_requests;
CREATE POLICY calibration_requests_isolation_policy ON calibration_requests
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS request_items_isolation_policy ON request_items;
CREATE POLICY request_items_isolation_policy ON request_items
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS verifications_isolation_policy ON verifications;
CREATE POLICY verifications_isolation_policy ON verifications
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
