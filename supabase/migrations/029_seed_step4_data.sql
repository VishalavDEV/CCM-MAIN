-- Migration 029: Seed Step 4 Faulty Item Service & Vendor Outsourcing Demo Data

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_user_id UUID;
    v_vendor_apex UUID;
    v_vendor_natmet UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req1_item2_id UUID;
    v_req1_item3_id UUID;
    v_req2_item1_id UUID;

    v_cal2_id UUID;

    v_faulty1_id UUID;
    v_faulty2_id UUID;
    v_outsourcing1_id UUID;
    v_outsourcing2_id UUID;
BEGIN
    -- 1. GET DEMO TENANT, ORG & USER
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_user_id FROM user_profiles WHERE tenant_id = v_tenant_id AND email = 'agent@cal-demo.com' LIMIT 1;

    -- 2. GET DEMO VENDORS
    SELECT id INTO v_vendor_apex FROM vendors WHERE vendor_code = 'VN-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_vendor_natmet FROM vendors WHERE vendor_code = 'VN-003' AND tenant_id = v_tenant_id LIMIT 1;

    -- 3. GET DEMO REQUESTS, ITEMS & CALIBRATIONS
    SELECT id INTO v_req1_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_req2_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000002' AND tenant_id = v_tenant_id LIMIT 1;

    -- Multimeter item from Request 1 (Failed calibration in Step 3)
    SELECT id INTO v_req1_item1_id FROM request_items WHERE request_id = v_req1_id LIMIT 1;
    -- Pressure Gauge item from Request 1
    SELECT id INTO v_req1_item2_id FROM request_items WHERE request_id = v_req1_id OFFSET 1 LIMIT 1;
    -- Temperature Sensor item from Request 1
    SELECT id INTO v_req1_item3_id FROM request_items WHERE request_id = v_req1_id OFFSET 2 LIMIT 1;
    -- Vernier Caliper item from Request 2
    SELECT id INTO v_req2_item1_id FROM request_items WHERE request_id = v_req2_id LIMIT 1;

    -- Failed calibration ID
    SELECT id INTO v_cal2_id FROM calibrations WHERE calibration_number = 'CAL-000002' AND tenant_id = v_tenant_id LIMIT 1;

    -- 4. SEED FAULTY SERVICE RECORD 1 (ACTIVE IN_SERVICE TICKET)
    IF v_req1_item1_id IS NOT NULL THEN
        INSERT INTO faulty_services (
            tenant_id, organization_id, request_id, request_item_id, calibration_id,
            service_number, service_type, fault_description, service_required,
            service_status, service_start_date, expected_completion_date, service_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item1_id, v_cal2_id,
            'FS-2026-000001', 'REPAIR', 'Excessive AC Current measurement drift observed during calibration check',
            'Replace AC current sensing shunt and recalibrate analog front-end',
            'IN_SERVICE', NOW() - INTERVAL '4 hours', NOW() + INTERVAL '2 days',
            'Item handed over to Internal Electrical Service Lab Team', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, service_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_faulty1_id;

        -- Update request item status to FAULTY
        UPDATE request_items SET status = 'ON_HOLD', remarks = 'Item in internal repair (FS-2026-000001)' WHERE id = v_req1_item1_id;
    END IF;

    -- 5. SEED FAULTY SERVICE RECORD 2 (COMPLETED SERVICE TICKET)
    IF v_req1_item2_id IS NOT NULL THEN
        INSERT INTO faulty_services (
            tenant_id, organization_id, request_id, request_item_id,
            service_number, service_type, fault_description, service_required,
            service_status, service_start_date, expected_completion_date, actual_completion_date, service_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item2_id,
            'FS-2026-000002', 'ADJUSTMENT', 'Pressure gauge dial zero pointer misaligned by +2 Bar',
            'Zero pointer mechanical adjustment and pressure recalibration',
            'SERVICE_COMPLETED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour',
            'Pointer re-zeroed and verified against dead weight tester', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, service_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_faulty2_id;
    END IF;

    -- 6. SEED VENDOR OUTSOURCING RECORD 1 (ACTIVE IN_PROGRESS OUTSOURCING)
    IF v_req1_item3_id IS NOT NULL AND v_vendor_apex IS NOT NULL THEN
        INSERT INTO vendor_outsourcing (
            tenant_id, organization_id, request_id, request_item_id, vendor_id,
            outsourcing_number, outsourcing_reason, vendor_reference_number,
            sent_date, expected_return_date, outsourcing_status, vendor_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item3_id, v_vendor_apex,
            'VO-2026-000001', 'High temperature primary standard calibration requires NABL accredited external vendor',
            'APEX-REF-99210', NOW() - INTERVAL '1 day', NOW() + INTERVAL '5 days',
            'IN_PROGRESS', 'Dispatched via secure courier under tracking #APX-4412', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, outsourcing_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_outsourcing1_id;

        -- Update request item status to OUTSOURCED
        UPDATE request_items SET status = 'ON_HOLD', remarks = 'Outsourced to Apex Calibration Standards (VO-2026-000001)' WHERE id = v_req1_item3_id;
    END IF;

    -- 7. SEED VENDOR OUTSOURCING RECORD 2 (RETURNED FROM VENDOR)
    IF v_req2_item1_id IS NOT NULL AND v_vendor_natmet IS NOT NULL THEN
        INSERT INTO vendor_outsourcing (
            tenant_id, organization_id, request_id, request_item_id, vendor_id,
            outsourcing_number, outsourcing_reason, vendor_reference_number,
            sent_date, expected_return_date, actual_return_date, outsourcing_status, vendor_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item1_id, v_vendor_natmet,
            'VO-2026-000002', 'Specialized laser interferometer dimensional calibration',
            'NATMET-CERT-5012', NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', NOW() - INTERVAL '3 hours',
            'RETURNED', 'Item returned along with vendor calibration certificate #NATMET-CERT-5012', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, outsourcing_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_outsourcing2_id;
    END IF;

    -- 8. AUDIT LOG ENTRIES FOR STEP 4
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_user_id, 'FAULTY_ITEM_CREATED', 'faulty_services', v_faulty1_id, jsonb_build_object('service_number', 'FS-2026-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_user_id, 'FAULTY_SERVICE_STARTED', 'faulty_services', v_faulty1_id, jsonb_build_object('service_number', 'FS-2026-000001', 'status', 'IN_SERVICE')),
    (v_tenant_id, v_org_id, v_user_id, 'FAULTY_SERVICE_COMPLETED', 'faulty_services', v_faulty2_id, jsonb_build_object('service_number', 'FS-2026-000002', 'status', 'SERVICE_COMPLETED')),
    (v_tenant_id, v_org_id, v_user_id, 'ITEM_OUTSOURCED', 'vendor_outsourcing', v_outsourcing1_id, jsonb_build_object('outsourcing_number', 'VO-2026-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_user_id, 'SENT_TO_VENDOR', 'vendor_outsourcing', v_outsourcing1_id, jsonb_build_object('outsourcing_number', 'VO-2026-000001', 'status', 'IN_PROGRESS')),
    (v_tenant_id, v_org_id, v_user_id, 'ITEM_RETURNED_FROM_VENDOR', 'vendor_outsourcing', v_outsourcing2_id, jsonb_build_object('outsourcing_number', 'VO-2026-000002', 'status', 'RETURNED'));

END $$;
