-- Migration 025: Create Vendor Outsourcing Table & Sequence

CREATE SEQUENCE IF NOT EXISTS vendor_outsourcing_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS vendor_outsourcing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    calibration_id UUID REFERENCES calibrations(id) ON DELETE SET NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE RESTRICT,
    outsourcing_number VARCHAR(50) NOT NULL,
    outsourcing_reason TEXT NOT NULL,
    vendor_reference_number VARCHAR(100),
    sent_date TIMESTAMPTZ,
    expected_return_date TIMESTAMPTZ,
    actual_return_date TIMESTAMPTZ,
    outsourcing_status VARCHAR(30) NOT NULL DEFAULT 'CREATED' CHECK (outsourcing_status IN ('CREATED', 'SENT_TO_VENDOR', 'IN_PROGRESS', 'ON_HOLD', 'RETURNED', 'VERIFIED', 'REJECTED', 'CANCELLED')),
    vendor_notes TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_outsourcing_num UNIQUE (tenant_id, organization_id, outsourcing_number)
);

CREATE OR REPLACE FUNCTION generate_outsourcing_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.outsourcing_number IS NULL OR NEW.outsourcing_number = '' THEN
        v_seq_num := nextval('vendor_outsourcing_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.outsourcing_number := 'VO-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_outsourcing_number ON vendor_outsourcing;
CREATE TRIGGER trigger_generate_outsourcing_number
BEFORE INSERT ON vendor_outsourcing
FOR EACH ROW
EXECUTE FUNCTION generate_outsourcing_number();

DROP TRIGGER IF EXISTS update_vendor_outsourcing_updated_at ON vendor_outsourcing;
CREATE TRIGGER update_vendor_outsourcing_updated_at
BEFORE UPDATE ON vendor_outsourcing
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
