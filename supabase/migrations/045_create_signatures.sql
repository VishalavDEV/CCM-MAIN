-- Migration 045: Create Signatures Table

CREATE TABLE IF NOT EXISTS signatures (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    signature_type VARCHAR(50) NOT NULL CHECK (signature_type IN ('CLIENT_INVOICE', 'CLIENT_DELIVERY')),
    signed_by_name VARCHAR(255) NOT NULL,
    signed_by_user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    signature_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (signature_status IN ('PENDING', 'SIGNED', 'REJECTED', 'CANCELLED')),
    signed_at TIMESTAMPTZ,
    signature_reference VARCHAR(255),
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_signatures_updated_at ON signatures;
CREATE TRIGGER update_signatures_updated_at
BEFORE UPDATE ON signatures
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE calibration_requests DROP CONSTRAINT IF EXISTS calibration_requests_status_check;
ALTER TABLE calibration_requests ADD CONSTRAINT calibration_requests_status_check CHECK (status IN ('CREATED', 'COLLECTED', 'LAB_QUEUE', 'VERIFICATION', 'READY_TO_DISPATCH', 'DISPATCHED', 'CLIENT_RECEIVED', 'DELIVERY_SIGNED', 'COMPLETED', 'ON_HOLD', 'DISCREPANCY', 'REJECTED', 'CANCELLED', 'PARTIALLY_COMPLETED'));
