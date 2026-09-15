-- Migration 051: Create Step 7 Row Level Security (RLS) Policies

ALTER TABLE signatures ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatches ENABLE ROW LEVEL SECURITY;
ALTER TABLE dispatch_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS signatures_isolation_policy ON signatures;
CREATE POLICY signatures_isolation_policy ON signatures
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS dispatches_isolation_policy ON dispatches;
CREATE POLICY dispatches_isolation_policy ON dispatches
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS dispatch_items_isolation_policy ON dispatch_items;
CREATE POLICY dispatch_items_isolation_policy ON dispatch_items
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS deliveries_isolation_policy ON deliveries;
CREATE POLICY deliveries_isolation_policy ON deliveries
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
