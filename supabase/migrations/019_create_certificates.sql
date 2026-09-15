-- Migration 019: Create Certificates Metadata Table & Sequence

CREATE SEQUENCE IF NOT EXISTS certificate_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS certificates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    calibration_id UUID NOT NULL REFERENCES calibrations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    certificate_number VARCHAR(50) NOT NULL,
    certificate_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    certificate_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (certificate_status IN ('DRAFT', 'GENERATING', 'GENERATED', 'ISSUED', 'REVOKED')),
    certificate_version INTEGER NOT NULL DEFAULT 1,
    issued_at TIMESTAMPTZ,
    issued_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    storage_key TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_cert_num UNIQUE (tenant_id, organization_id, certificate_number)
);

CREATE OR REPLACE FUNCTION generate_certificate_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.certificate_number IS NULL OR NEW.certificate_number = '' THEN
        v_seq_num := nextval('certificate_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.certificate_number := 'CERT-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_certificate_number ON certificates;
CREATE TRIGGER trigger_generate_certificate_number
BEFORE INSERT ON certificates
FOR EACH ROW
EXECUTE FUNCTION generate_certificate_number();

DROP TRIGGER IF EXISTS update_certificates_updated_at ON certificates;
CREATE TRIGGER update_certificates_updated_at
BEFORE UPDATE ON certificates
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
