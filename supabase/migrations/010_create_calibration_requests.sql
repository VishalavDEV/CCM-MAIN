-- Migration 010: Create Calibration Requests Table & Request Number Auto-Generator

CREATE SEQUENCE IF NOT EXISTS calibration_request_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS calibration_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_number VARCHAR(50) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    collection_agent_id UUID REFERENCES user_profiles(id) ON DELETE RESTRICT,
    collection_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    priority VARCHAR(20) NOT NULL DEFAULT 'NORMAL' CHECK (priority IN ('NORMAL', 'URGENT')),
    status VARCHAR(30) NOT NULL DEFAULT 'CREATED' CHECK (status IN ('CREATED', 'COLLECTED', 'LAB_QUEUE', 'VERIFICATION', 'ON_HOLD', 'DISCREPANCY', 'REJECTED', 'CANCELLED')),
    remarks TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_request_num UNIQUE (tenant_id, organization_id, request_number)
);

-- Trigger for auto-generating human-readable request numbers (CAL-REQ-000001)
CREATE OR REPLACE FUNCTION generate_request_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
BEGIN
    IF NEW.request_number IS NULL OR NEW.request_number = '' THEN
        v_seq_num := nextval('calibration_request_seq');
        NEW.request_number := 'CAL-REQ-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_request_number ON calibration_requests;
CREATE TRIGGER trigger_generate_request_number
BEFORE INSERT ON calibration_requests
FOR EACH ROW
EXECUTE FUNCTION generate_request_number();

DROP TRIGGER IF EXISTS update_calibration_requests_updated_at ON calibration_requests;
CREATE TRIGGER update_calibration_requests_updated_at
BEFORE UPDATE ON calibration_requests
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
