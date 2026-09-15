-- Migration 050: Create Step 7 Indexes for Signatures, Dispatches, and Deliveries

-- Signatures Indexes
CREATE INDEX IF NOT EXISTS idx_signatures_tenant ON signatures(tenant_id);
CREATE INDEX IF NOT EXISTS idx_signatures_tenant_org ON signatures(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_signatures_tenant_request ON signatures(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_signatures_tenant_type ON signatures(tenant_id, signature_type);
CREATE INDEX IF NOT EXISTS idx_signatures_tenant_status ON signatures(tenant_id, signature_status);

-- Dispatches Indexes
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant ON dispatches(tenant_id);
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant_org ON dispatches(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant_request ON dispatches(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant_status ON dispatches(tenant_id, dispatch_status);
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant_number ON dispatches(tenant_id, dispatch_number);
CREATE INDEX IF NOT EXISTS idx_dispatches_tenant_tracking ON dispatches(tenant_id, tracking_number);

-- Dispatch Items Indexes
CREATE INDEX IF NOT EXISTS idx_dispatch_items_tenant ON dispatch_items(tenant_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_items_tenant_org ON dispatch_items(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_items_tenant_dispatch ON dispatch_items(tenant_id, dispatch_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_items_tenant_request ON dispatch_items(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_dispatch_items_tenant_req_item ON dispatch_items(tenant_id, request_item_id);

-- Deliveries Indexes
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant ON deliveries(tenant_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant_org ON deliveries(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant_request ON deliveries(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant_dispatch ON deliveries(tenant_id, dispatch_id);
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant_status ON deliveries(tenant_id, delivery_status);
CREATE INDEX IF NOT EXISTS idx_deliveries_tenant_number ON deliveries(tenant_id, delivery_number);
