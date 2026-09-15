-- Migration 042: Create Step 6 Indexes for Invoices and Purchase Orders

-- Invoices Indexes
CREATE INDEX IF NOT EXISTS idx_invoices_tenant ON invoices(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_org ON invoices(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_request ON invoices(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_quotation ON invoices(tenant_id, quotation_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_client ON invoices(tenant_id, client_id);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_status ON invoices(tenant_id, invoice_status);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_number ON invoices(tenant_id, invoice_number);
CREATE INDEX IF NOT EXISTS idx_invoices_tenant_date ON invoices(tenant_id, invoice_date);

-- Invoice Items Indexes
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant ON invoice_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant_org ON invoice_items(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant_invoice ON invoice_items(tenant_id, invoice_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant_request ON invoice_items(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant_req_item ON invoice_items(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_invoice_items_tenant_quot_item ON invoice_items(tenant_id, quotation_item_id);

-- Purchase Orders Indexes
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant ON purchase_orders(tenant_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_org ON purchase_orders(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_request ON purchase_orders(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_quotation ON purchase_orders(tenant_id, quotation_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_client ON purchase_orders(tenant_id, client_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_status ON purchase_orders(tenant_id, po_status);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_number ON purchase_orders(tenant_id, po_number);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_tenant_date ON purchase_orders(tenant_id, po_date);

-- PO Items Indexes
CREATE INDEX IF NOT EXISTS idx_po_items_tenant ON po_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_po_items_tenant_org ON po_items(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_po_items_tenant_po ON po_items(tenant_id, purchase_order_id);
CREATE INDEX IF NOT EXISTS idx_po_items_tenant_request ON po_items(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_po_items_tenant_req_item ON po_items(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_po_items_tenant_quot_item ON po_items(tenant_id, quotation_item_id);
