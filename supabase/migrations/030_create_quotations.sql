-- Migration 030: Create Quotations Table & Sequence

CREATE SEQUENCE IF NOT EXISTS quotation_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS quotations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    quotation_number VARCHAR(50) NOT NULL,
    quotation_version INTEGER NOT NULL DEFAULT 1,
    parent_quotation_id UUID REFERENCES quotations(id) ON DELETE SET NULL,
    quotation_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    quotation_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (quotation_status IN ('DRAFT', 'SUBMITTED', 'UNDER_APPROVAL', 'APPROVED', 'REJECTED', 'EXPIRED', 'CANCELLED')),
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    subtotal NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    total_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    notes TEXT,
    terms_and_conditions TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_quotation_num UNIQUE (tenant_id, organization_id, quotation_number, quotation_version)
);

CREATE OR REPLACE FUNCTION generate_quotation_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.quotation_number IS NULL OR NEW.quotation_number = '' THEN
        v_seq_num := nextval('quotation_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.quotation_number := 'QT-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_quotation_number ON quotations;
CREATE TRIGGER trigger_generate_quotation_number
BEFORE INSERT ON quotations
FOR EACH ROW
EXECUTE FUNCTION generate_quotation_number();

DROP TRIGGER IF EXISTS update_quotations_updated_at ON quotations;
CREATE TRIGGER update_quotations_updated_at
BEFORE UPDATE ON quotations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
