-- Migration 028: Create Step 4 Row Level Security (RLS) Policies

ALTER TABLE faulty_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_outsourcing ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS faulty_services_isolation_policy ON faulty_services;
CREATE POLICY faulty_services_isolation_policy ON faulty_services
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS vendor_outsourcing_isolation_policy ON vendor_outsourcing;
CREATE POLICY vendor_outsourcing_isolation_policy ON vendor_outsourcing
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
