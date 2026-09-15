-- Migration 024: Create Faulty Services Table & Sequence

CREATE SEQUENCE IF NOT EXISTS faulty_service_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS faulty_services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    calibration_id UUID REFERENCES calibrations(id) ON DELETE SET NULL,
    service_number VARCHAR(50) NOT NULL,
    service_type VARCHAR(50) NOT NULL CHECK (service_type IN ('INTERNAL_SERVICE', 'REPAIR', 'MAINTENANCE', 'ADJUSTMENT', 'INSPECTION')),
    fault_description TEXT NOT NULL,
    service_required TEXT,
    service_status VARCHAR(30) NOT NULL DEFAULT 'CREATED' CHECK (service_status IN ('CREATED', 'IN_SERVICE', 'ON_HOLD', 'SERVICE_COMPLETED', 'RETURNED_TO_CALIBRATION', 'CANCELLED')),
    service_start_date TIMESTAMPTZ,
    expected_completion_date TIMESTAMPTZ,
    actual_completion_date TIMESTAMPTZ,
    service_notes TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_service_num UNIQUE (tenant_id, organization_id, service_number)
);

CREATE OR REPLACE FUNCTION generate_faulty_service_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.service_number IS NULL OR NEW.service_number = '' THEN
        v_seq_num := nextval('faulty_service_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.service_number := 'FS-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_faulty_service_number ON faulty_services;
CREATE TRIGGER trigger_generate_faulty_service_number
BEFORE INSERT ON faulty_services
FOR EACH ROW
EXECUTE FUNCTION generate_faulty_service_number();

DROP TRIGGER IF EXISTS update_faulty_services_updated_at ON faulty_services;
CREATE TRIGGER update_faulty_services_updated_at
BEFORE UPDATE ON faulty_services
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
