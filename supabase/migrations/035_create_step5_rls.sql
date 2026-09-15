-- Migration 035: Create Step 5 Row Level Security (RLS) Policies

ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotation_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE approvals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS quotations_isolation_policy ON quotations;
CREATE POLICY quotations_isolation_policy ON quotations
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS quotation_items_isolation_policy ON quotation_items;
CREATE POLICY quotation_items_isolation_policy ON quotation_items
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS approvals_isolation_policy ON approvals;
CREATE POLICY approvals_isolation_policy ON approvals
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
