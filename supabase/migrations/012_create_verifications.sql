-- Migration 012: Create Verifications Table

CREATE TABLE IF NOT EXISTS verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    verified_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    verified_at TIMESTAMPTZ DEFAULT NOW(),
    verified_quantity INTEGER NOT NULL CHECK (verified_quantity >= 0),
    expected_quantity INTEGER NOT NULL CHECK (expected_quantity > 0),
    observed_serial_number VARCHAR(100),
    observed_item_condition VARCHAR(30) NOT NULL CHECK (observed_item_condition IN ('GOOD', 'DAMAGED', 'FAULTY', 'UNKNOWN')),
    result VARCHAR(30) NOT NULL CHECK (result IN ('VERIFIED', 'DISCREPANCY', 'SHORT', 'REJECTED', 'ON_HOLD')),
    discrepancy_reason TEXT,
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_verifications_updated_at ON verifications;
CREATE TRIGGER update_verifications_updated_at
BEFORE UPDATE ON verifications
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
