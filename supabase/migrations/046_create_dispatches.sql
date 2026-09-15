-- Migration 046: Create Dispatches Table, Sequence, and Triggers

CREATE SEQUENCE IF NOT EXISTS dispatch_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS dispatches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    dispatch_number VARCHAR(50) NOT NULL,
    dispatch_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dispatch_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (dispatch_status IN ('DRAFT', 'READY', 'DISPATCHED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')),
    courier_name VARCHAR(255),
    tracking_number VARCHAR(100),
    tracking_url TEXT,
    expected_delivery_date TIMESTAMPTZ,
    actual_dispatch_date TIMESTAMPTZ,
    remarks TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_dispatch_num UNIQUE (tenant_id, organization_id, dispatch_number)
);

-- Trigger Function: Generate Dispatch Number (DSP-YYYY-XXXXXX)
CREATE OR REPLACE FUNCTION generate_dispatch_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.dispatch_number IS NULL OR NEW.dispatch_number = '' THEN
        v_seq_num := nextval('dispatch_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.dispatch_number := 'DSP-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_dispatch_number ON dispatches;
CREATE TRIGGER trigger_generate_dispatch_number
BEFORE INSERT ON dispatches
FOR EACH ROW
EXECUTE FUNCTION generate_dispatch_number();

-- Trigger Function: Validate Dispatch Eligibility (Client Invoice Signature Required for READY/DISPATCHED)
CREATE OR REPLACE FUNCTION validate_dispatch_eligibility()
RETURNS TRIGGER AS $$
DECLARE
    v_signed_count INTEGER;
BEGIN
    IF NEW.dispatch_status IN ('READY', 'DISPATCHED', 'IN_TRANSIT', 'DELIVERED') THEN
        SELECT COUNT(*) INTO v_signed_count
        FROM signatures
        WHERE request_id = NEW.request_id
          AND tenant_id = NEW.tenant_id
          AND organization_id = NEW.organization_id
          AND signature_type = 'CLIENT_INVOICE'
          AND signature_status = 'SIGNED';

        IF v_signed_count = 0 THEN
            RAISE EXCEPTION 'Dispatch cannot proceed to % status until Client Invoice Signature is completed and SIGNED for request %.', NEW.dispatch_status, NEW.request_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_dispatch_eligibility ON dispatches;
CREATE TRIGGER trigger_validate_dispatch_eligibility
BEFORE INSERT OR UPDATE ON dispatches
FOR EACH ROW
EXECUTE FUNCTION validate_dispatch_eligibility();

DROP TRIGGER IF EXISTS update_dispatches_updated_at ON dispatches;
CREATE TRIGGER update_dispatches_updated_at
BEFORE UPDATE ON dispatches
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
