-- Migration 023: Seed Step 3 Calibration, Measurement, and Certificate Demo Data

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_user_id UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req2_item1_id UUID;

    v_cal1_id UUID;
    v_cal2_id UUID;
BEGIN
    -- 1. GET DEMO TENANT, ORG & USER
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_user_id FROM user_profiles WHERE tenant_id = v_tenant_id AND email = 'agent@cal-demo.com' LIMIT 1;

    -- 2. GET DEMO REQUESTS & ITEMS
    SELECT id INTO v_req1_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_req2_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000002' AND tenant_id = v_tenant_id LIMIT 1;

    -- Get verified item 1 from Request 2 (Vernier Caliper)
    SELECT id INTO v_req2_item1_id FROM request_items WHERE request_id = v_req2_id AND status = 'VERIFIED' LIMIT 1;

    -- Get item 1 from Request 1 (Digital Multimeter)
    SELECT id INTO v_req1_item1_id FROM request_items WHERE request_id = v_req1_id LIMIT 1;

    -- 3. SEED CALIBRATION 1 (SUCCESSFUL PASS -> CALIBRATED)
    IF v_req2_item1_id IS NOT NULL THEN
        INSERT INTO calibrations (
            tenant_id, organization_id, request_id, request_item_id, calibration_number,
            calibrated_by, calibration_date, calibration_method, calibration_location,
            result, outcome, remarks, calibration_frequency, next_due_date
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item1_id, 'CAL-000001',
            v_user_id, NOW() - INTERVAL '1 hour', 'IS 2288:2002 / Standard Block Procedure', 'In-House Dimensional Lab 1',
            'PASS', 'CALIBRATED', 'Calibration completed cleanly within specified tolerances.', 365, NOW() + INTERVAL '365 days'
        )
        ON CONFLICT (tenant_id, organization_id, calibration_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_cal1_id;

        -- Update request item status to CALIBRATED
        UPDATE request_items SET status = 'VERIFIED', updated_at = NOW() WHERE id = v_req2_item1_id;

        -- Measurements for Calibration 1
        INSERT INTO calibration_measurements (
            tenant_id, organization_id, calibration_id, parameter_name, nominal_value,
            measured_value, unit, tolerance_min, tolerance_max, result, remarks
        ) VALUES
        (v_tenant_id, v_org_id, v_cal1_id, '0.00 mm Check', 0.0000, 0.0000, 'mm', -0.0100, 0.0100, 'PASS', 'Zero point check'),
        (v_tenant_id, v_org_id, v_cal1_id, '25.00 mm Check', 25.0000, 25.0050, 'mm', 24.9900, 25.0100, 'PASS', 'Mid range check'),
        (v_tenant_id, v_org_id, v_cal1_id, '50.00 mm Check', 50.0000, 50.0080, 'mm', 49.9900, 50.0100, 'PASS', 'Mid range check'),
        (v_tenant_id, v_org_id, v_cal1_id, '100.00 mm Check', 100.0000, 100.0020, 'mm', 99.9800, 100.0200, 'PASS', 'Full scale check')
        ON CONFLICT DO NOTHING;

        -- Certificate Metadata for Calibration 1
        INSERT INTO certificates (
            tenant_id, organization_id, calibration_id, request_id, request_item_id,
            certificate_number, certificate_date, certificate_status, certificate_version,
            issued_at, issued_by, storage_key
        ) VALUES (
            v_tenant_id, v_org_id, v_cal1_id, v_req2_id, v_req2_item1_id,
            'CERT-2026-000001', NOW(), 'ISSUED', 1,
            NOW(), v_user_id, 'certificates/2026/CAL-000001.pdf'
        )
        ON CONFLICT (tenant_id, organization_id, certificate_number) DO UPDATE SET updated_at = NOW();

        -- Audit Log entries
        INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
        (v_tenant_id, v_org_id, v_user_id, 'CALIBRATION_CREATED', 'calibrations', v_cal1_id, jsonb_build_object('calibration_number', 'CAL-000001', 'result', 'PASS')),
        (v_tenant_id, v_org_id, v_user_id, 'CALIBRATION_RESULT_RECORDED', 'calibrations', v_cal1_id, jsonb_build_object('outcome', 'CALIBRATED')),
        (v_tenant_id, v_org_id, v_user_id, 'CERTIFICATE_ISSUED', 'certificates', v_cal1_id, jsonb_build_object('certificate_number', 'CERT-2026-000001'));
    END IF;

    -- 4. SEED CALIBRATION 2 (FAILED TEST -> FAULTY)
    IF v_req1_item1_id IS NOT NULL THEN
        INSERT INTO calibrations (
            tenant_id, organization_id, request_id, request_item_id, calibration_number,
            calibrated_by, calibration_date, calibration_method, calibration_location,
            result, outcome, remarks, calibration_frequency, next_due_date
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item1_id, 'CAL-000002',
            v_user_id, NOW() - INTERVAL '30 minutes', 'IEEE-STD-120 / Electrical Multimeter Procedure', 'In-House Electrical Lab 2',
            'FAIL', 'FAULTY', 'AC Current range out of tolerance. Flagged for service.', 365, NOW() + INTERVAL '365 days'
        )
        ON CONFLICT (tenant_id, organization_id, calibration_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_cal2_id;

        -- Measurements for Calibration 2
        INSERT INTO calibration_measurements (
            tenant_id, organization_id, calibration_id, parameter_name, nominal_value,
            measured_value, unit, tolerance_min, tolerance_max, result, remarks
        ) VALUES
        (v_tenant_id, v_org_id, v_cal2_id, '10.00 V DC Accuracy', 10.0000, 10.0010, 'V', 9.9900, 10.0100, 'PASS', 'DC Voltage check within limits'),
        (v_tenant_id, v_org_id, v_cal2_id, '1.000 A AC Current Range', 1.0000, 1.0850, 'A', 0.9900, 1.0100, 'FAIL', 'Excessive drift on AC current scale')
        ON CONFLICT DO NOTHING;

        -- Draft Certificate Metadata for Calibration 2
        INSERT INTO certificates (
            tenant_id, organization_id, calibration_id, request_id, request_item_id,
            certificate_number, certificate_date, certificate_status, certificate_version,
            storage_key
        ) VALUES (
            v_tenant_id, v_org_id, v_cal2_id, v_req1_id, v_req1_item1_id,
            'CERT-2026-000002', NOW(), 'DRAFT', 1,
            'certificates/2026/CAL-000002-draft.pdf'
        )
        ON CONFLICT (tenant_id, organization_id, certificate_number) DO UPDATE SET updated_at = NOW();

        -- Audit Log entries
        INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
        (v_tenant_id, v_org_id, v_user_id, 'CALIBRATION_CREATED', 'calibrations', v_cal2_id, jsonb_build_object('calibration_number', 'CAL-000002', 'result', 'FAIL')),
        (v_tenant_id, v_org_id, v_user_id, 'CALIBRATION_OUTCOME_CHANGED', 'calibrations', v_cal2_id, jsonb_build_object('outcome', 'FAULTY'));
    END IF;

END $$;
