-- Migration 011: Create Request Items Table

CREATE TABLE IF NOT EXISTS request_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    item_master_id UUID NOT NULL REFERENCES item_masters(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    received_quantity INTEGER NOT NULL DEFAULT 0 CHECK (received_quantity >= 0),
    item_condition VARCHAR(30) NOT NULL DEFAULT 'GOOD' CHECK (item_condition IN ('GOOD', 'DAMAGED', 'FAULTY', 'UNKNOWN')),
    status VARCHAR(30) NOT NULL DEFAULT 'ADDED' CHECK (status IN ('ADDED', 'RECEIVED', 'VERIFICATION_PENDING', 'VERIFIED', 'DISCREPANCY', 'SHORT', 'REJECTED', 'ON_HOLD')),
    document_requirement_status VARCHAR(30) NOT NULL DEFAULT 'DOCUMENT_PENDING' CHECK (document_requirement_status IN ('DOCUMENT_REQUIRED', 'DOCUMENT_PENDING', 'DOCUMENT_RECEIVED', 'DOCUMENT_VERIFIED')),
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_request_items_updated_at ON request_items;
CREATE TRIGGER update_request_items_updated_at
BEFORE UPDATE ON request_items
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
