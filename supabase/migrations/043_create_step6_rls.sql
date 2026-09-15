-- Migration 043: Create Step 6 Row Level Security (RLS) Policies

ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE po_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS invoices_isolation_policy ON invoices;
CREATE POLICY invoices_isolation_policy ON invoices
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS invoice_items_isolation_policy ON invoice_items;
CREATE POLICY invoice_items_isolation_policy ON invoice_items
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS purchase_orders_isolation_policy ON purchase_orders;
CREATE POLICY purchase_orders_isolation_policy ON purchase_orders
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS po_items_isolation_policy ON po_items;
CREATE POLICY po_items_isolation_policy ON po_items
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
