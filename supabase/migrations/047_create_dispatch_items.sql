-- Migration 047: Create Dispatch Items Table

CREATE TABLE IF NOT EXISTS dispatch_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    dispatch_id UUID NOT NULL REFERENCES dispatches(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    item_master_id UUID REFERENCES item_masters(id) ON DELETE SET NULL,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_dispatch_items_updated_at ON dispatch_items;
CREATE TRIGGER update_dispatch_items_updated_at
BEFORE UPDATE ON dispatch_items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
