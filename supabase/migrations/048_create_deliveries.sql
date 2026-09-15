-- Migration 048: Create Deliveries Table, Sequence, Triggers, and Server-Side Final Completion Function

CREATE SEQUENCE IF NOT EXISTS delivery_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    dispatch_id UUID NOT NULL REFERENCES dispatches(id) ON DELETE CASCADE,
    delivery_number VARCHAR(50) NOT NULL,
    delivery_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivery_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (delivery_status IN ('PENDING', 'IN_TRANSIT', 'CLIENT_RECEIVED', 'DELIVERY_SIGNED', 'FAILED', 'CANCELLED')),
    received_by_name VARCHAR(255),
    received_by_contact VARCHAR(100),
    delivery_remarks TEXT,
    created_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_delivery_num UNIQUE (tenant_id, organization_id, delivery_number)
);

-- Trigger Function: Generate Delivery Number (DEL-YYYY-XXXXXX)
CREATE OR REPLACE FUNCTION generate_delivery_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
    v_year TEXT;
BEGIN
    IF NEW.delivery_number IS NULL OR NEW.delivery_number = '' THEN
        v_seq_num := nextval('delivery_seq');
        v_year := TO_CHAR(NOW(), 'YYYY');
        NEW.delivery_number := 'DEL-' || v_year || '-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_delivery_number ON deliveries;
CREATE TRIGGER trigger_generate_delivery_number
BEFORE INSERT ON deliveries
FOR EACH ROW
EXECUTE FUNCTION generate_delivery_number();

-- Trigger Function: Validate Delivery and Dispatch Parent Match
CREATE OR REPLACE FUNCTION validate_delivery_dispatch_match()
RETURNS TRIGGER AS $$
DECLARE
    v_dsp_req UUID;
    v_dsp_tenant UUID;
    v_dsp_org UUID;
BEGIN
    SELECT request_id, tenant_id, organization_id
    INTO v_dsp_req, v_dsp_tenant, v_dsp_org
    FROM dispatches
    WHERE id = NEW.dispatch_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Referenced dispatch % does not exist.', NEW.dispatch_id;
    END IF;

    IF v_dsp_req != NEW.request_id THEN
        RAISE EXCEPTION 'Delivery request_id % does not match dispatch request_id %.', NEW.request_id, v_dsp_req;
    END IF;

    IF v_dsp_tenant != NEW.tenant_id OR v_dsp_org != NEW.organization_id THEN
        RAISE EXCEPTION 'Delivery tenant/organization does not match referenced dispatch.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_validate_delivery_dispatch_match ON deliveries;
CREATE TRIGGER trigger_validate_delivery_dispatch_match
BEFORE INSERT OR UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION validate_delivery_dispatch_match();

DROP TRIGGER IF EXISTS update_deliveries_updated_at ON deliveries;
CREATE TRIGGER update_deliveries_updated_at
BEFORE UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Server-Side Controlled Final Completion Function
CREATE OR REPLACE FUNCTION complete_calibration_request(
    p_request_id UUID,
    p_user_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_req_status VARCHAR(30);
    v_quot_approved INTEGER;
    v_invoice_sig_signed INTEGER;
    v_dispatch_completed INTEGER;
    v_delivery_received INTEGER;
    v_delivery_sig_signed INTEGER;
BEGIN
    -- 1. Get Request details
    SELECT tenant_id, organization_id, status
    INTO v_tenant_id, v_org_id, v_req_status
    FROM calibration_requests
    WHERE id = p_request_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Calibration Request % not found.', p_request_id;
    END IF;

    -- 2. Verify Approved Quotation
    SELECT COUNT(*) INTO v_quot_approved
    FROM quotations
    WHERE request_id = p_request_id AND quotation_status = 'APPROVED';
    IF v_quot_approved = 0 THEN
        RAISE EXCEPTION 'Cannot complete request: No APPROVED quotation found for request %.', p_request_id;
    END IF;

    -- 3. Verify Client Invoice Signature
    SELECT COUNT(*) INTO v_invoice_sig_signed
    FROM signatures
    WHERE request_id = p_request_id AND signature_type = 'CLIENT_INVOICE' AND signature_status = 'SIGNED';
    IF v_invoice_sig_signed = 0 THEN
        RAISE EXCEPTION 'Cannot complete request: Client Invoice Signature is missing or not SIGNED for request %.', p_request_id;
    END IF;

    -- 4. Verify Dispatch Status
    SELECT COUNT(*) INTO v_dispatch_completed
    FROM dispatches
    WHERE request_id = p_request_id AND dispatch_status IN ('DISPATCHED', 'IN_TRANSIT', 'DELIVERED');
    IF v_dispatch_completed = 0 THEN
        RAISE EXCEPTION 'Cannot complete request: Dispatch is incomplete or missing for request %.', p_request_id;
    END IF;

    -- 5. Verify Delivery Status
    SELECT COUNT(*) INTO v_delivery_received
    FROM deliveries
    WHERE request_id = p_request_id AND delivery_status IN ('CLIENT_RECEIVED', 'DELIVERY_SIGNED');
    IF v_delivery_received = 0 THEN
        RAISE EXCEPTION 'Cannot complete request: Delivery record is not CLIENT_RECEIVED or DELIVERY_SIGNED for request %.', p_request_id;
    END IF;

    -- 6. Verify Delivery Signature
    SELECT COUNT(*) INTO v_delivery_sig_signed
    FROM signatures
    WHERE request_id = p_request_id AND signature_type = 'CLIENT_DELIVERY' AND signature_status = 'SIGNED';
    IF v_delivery_sig_signed = 0 THEN
        RAISE EXCEPTION 'Cannot complete request: Delivery Signature is missing or not SIGNED for request %.', p_request_id;
    END IF;

    -- 7. Update Request Status to COMPLETED
    UPDATE calibration_requests
    SET status = 'COMPLETED',
        updated_at = NOW()
    WHERE id = p_request_id;

    -- 8. Record Audit Log
    INSERT INTO audit_logs (
        tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data
    ) VALUES (
        v_tenant_id, v_org_id, p_user_id, 'REQUEST_MARKED_COMPLETED', 'calibration_requests', p_request_id,
        jsonb_build_object('request_id', p_request_id, 'status', 'COMPLETED', 'completed_at', NOW())
    );

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
