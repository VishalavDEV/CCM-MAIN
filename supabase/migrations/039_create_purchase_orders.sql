-- Migration 039: Create Purchase Orders Table, Sequence, and Triggers

CREATE SEQUENCE IF NOT EXISTS po_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    po_number VARCHAR(50) NOT NULL,
    po_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expected_date TIMESTAMPTZ,
    po_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (po_status IN ('DRAFT', 'ISSUED', 'PARTIALLY_RECEIVED', 'RECEIVED', 'CANCELLED')),
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
    CONSTRAINT unique_tenant_org_po_num UNIQUE (tenant_id, organization_id, po_number)
);

-- Trigger Function: Generate Purchase Order Number (PO-YYYY-XXXXXX)
CREATE OR REPLACE FUNCTION generate_po_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.po_number IS NULL OR NEW.po_number = '' THEN
        v_seq_num := nextval('po_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.po_number := 'PO-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_po_number ON purchase_orders;
CREATE TRIGGER trigger_generate_po_number
BEFORE INSERT ON purchase_orders
FOR EACH ROW
EXECUTE FUNCTION generate_po_number();

-- Trigger Function: Validate Approved Quotation & Parent Match for Purchase Order
CREATE OR REPLACE FUNCTION validate_po_quotation()
RETURNS TRIGGER AS $$
DECLARE
    v_q_status VARCHAR(30);
    v_q_tenant UUID;
    v_q_org UUID;
    v_q_req UUID;
    v_q_client UUID;
BEGIN
    SELECT quotation_status, tenant_id, organization_id, request_id, client_id
    INTO v_q_status, v_q_tenant, v_q_org, v_q_req, v_q_client
    FROM quotations
    WHERE id = NEW.quotation_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Referenced quotation % does not exist.', NEW.quotation_id;
    END IF;

    IF v_q_status != 'APPROVED' THEN
        RAISE EXCEPTION 'Purchase orders can only be created from APPROVED quotations. Current quotation status: %', v_q_status;
    END IF;

    IF v_q_tenant != NEW.tenant_id OR v_q_org != NEW.organization_id THEN
        RAISE EXCEPTION 'Purchase order tenant/organization does not match the referenced quotation.';
    END IF;

    IF v_q_req != NEW.request_id OR v_q_client != NEW.client_id THEN
        RAISE EXCEPTION 'Purchase order request/client does not match the referenced quotation.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_po_quotation ON purchase_orders;
CREATE TRIGGER trigger_validate_po_quotation
BEFORE INSERT OR UPDATE ON purchase_orders
FOR EACH ROW
EXECUTE FUNCTION validate_po_quotation();

DROP TRIGGER IF EXISTS update_purchase_orders_updated_at ON purchase_orders;
CREATE TRIGGER update_purchase_orders_updated_at
BEFORE UPDATE ON purchase_orders
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
