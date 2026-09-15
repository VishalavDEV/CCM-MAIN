-- Migration 037: Create Invoices Table, Sequence, and Triggers

CREATE SEQUENCE IF NOT EXISTS invoice_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    invoice_number VARCHAR(50) NOT NULL,
    invoice_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    due_date TIMESTAMPTZ,
    invoice_status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (invoice_status IN ('DRAFT', 'ISSUED', 'PARTIALLY_PAID', 'PAID', 'OVERDUE', 'CANCELLED')),
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    subtotal NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (subtotal >= 0),
    discount_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (discount_amount >= 0),
    tax_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (tax_amount >= 0),
    total_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (total_amount >= 0),
    paid_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (paid_amount >= 0),
    balance_amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (balance_amount >= 0),
    notes TEXT,
    terms_and_conditions TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_invoice_num UNIQUE (tenant_id, organization_id, invoice_number),
    CONSTRAINT check_paid_amount_le_total CHECK (paid_amount <= total_amount),
    CONSTRAINT check_balance_equals_total_minus_paid CHECK (balance_amount = (total_amount - paid_amount))
);

-- Trigger Function: Generate Invoice Number (INV-YYYY-XXXXXX)
CREATE OR REPLACE FUNCTION generate_invoice_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.invoice_number IS NULL OR NEW.invoice_number = '' THEN
        v_seq_num := nextval('invoice_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.invoice_number := 'INV-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_invoice_number ON invoices;
CREATE TRIGGER trigger_generate_invoice_number
BEFORE INSERT ON invoices
FOR EACH ROW
EXECUTE FUNCTION generate_invoice_number();

-- Trigger Function: Validate Approved Quotation & Parent Match for Invoice
CREATE OR REPLACE FUNCTION validate_invoice_quotation()
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
        RAISE EXCEPTION 'Invoices can only be created from APPROVED quotations. Current quotation status: %', v_q_status;
    END IF;

    IF v_q_tenant != NEW.tenant_id OR v_q_org != NEW.organization_id THEN
        RAISE EXCEPTION 'Invoice tenant/organization does not match the referenced quotation.';
    END IF;

    IF v_q_req != NEW.request_id OR v_q_client != NEW.client_id THEN
        RAISE EXCEPTION 'Invoice request/client does not match the referenced quotation.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_invoice_quotation ON invoices;
CREATE TRIGGER trigger_validate_invoice_quotation
BEFORE INSERT OR UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION validate_invoice_quotation();

DROP TRIGGER IF EXISTS update_invoices_updated_at ON invoices;
CREATE TRIGGER update_invoices_updated_at
BEFORE UPDATE ON invoices
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
