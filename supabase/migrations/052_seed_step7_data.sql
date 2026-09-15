-- Migration 052: Seed Step 7 Signatures, Dispatches, Deliveries, and Complete Request Lifecycle Data

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_user_id UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req1_item2_id UUID;

    v_item_dmm UUID;
    v_item_pg UUID;

    v_sig1_id UUID;
    v_sig2_id UUID;
    v_sig3_id UUID;

    v_dsp1_id UUID;
    v_dsp2_id UUID;

    v_del1_id UUID;
    v_del2_id UUID;

    v_completed BOOLEAN;
BEGIN
    -- 1. GET DEMO TENANT, ORG & USER
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_user_id FROM user_profiles WHERE tenant_id = v_tenant_id AND email = 'agent@cal-demo.com' LIMIT 1;

    -- 2. GET REQUESTS & ITEMS
    SELECT id INTO v_req1_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_req2_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000002' AND tenant_id = v_tenant_id LIMIT 1;

    SELECT id INTO v_req1_item1_id FROM request_items WHERE request_id = v_req1_id LIMIT 1;
    SELECT id INTO v_req1_item2_id FROM request_items WHERE request_id = v_req1_id OFFSET 1 LIMIT 1;

    SELECT id INTO v_item_dmm FROM item_masters WHERE item_code = 'ITM-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_pg FROM item_masters WHERE item_code = 'ITM-002' AND tenant_id = v_tenant_id LIMIT 1;

    -- 3. SEED SIGNATURES
    -- Signature 1: Signed Client Invoice Signature for Request 1
    IF v_req1_id IS NOT NULL THEN
        INSERT INTO signatures (
            tenant_id, organization_id, request_id, signature_type, signed_by_name,
            signed_by_user_id, signature_status, signed_at, signature_reference, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'CLIENT_INVOICE', 'Rajesh Kumar (Client Rep)',
            v_user_id, 'SIGNED', NOW() - INTERVAL '2 days', 'SIG-REF-INV-9901', 'Commercial invoice approved and signed digitally by client.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_sig1_id;

        -- Signature 2: Signed Client Delivery Signature for Request 1
        INSERT INTO signatures (
            tenant_id, organization_id, request_id, signature_type, signed_by_name,
            signed_by_user_id, signature_status, signed_at, signature_reference, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'CLIENT_DELIVERY', 'Rajesh Kumar (Client Rep)',
            v_user_id, 'SIGNED', NOW() - INTERVAL '4 hours', 'SIG-REF-DEL-8802', 'Received items in good physical condition and signed delivery acknowledgement.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_sig2_id;
    END IF;

    -- Signature 3: Pending Client Invoice Signature for Request 2
    IF v_req2_id IS NOT NULL THEN
        INSERT INTO signatures (
            tenant_id, organization_id, request_id, signature_type, signed_by_name,
            signature_status, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, 'CLIENT_INVOICE', 'Anand Verma (Client Rep)',
            'PENDING', 'Signature pending commercial review.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_sig3_id;
    END IF;

    -- 4. SEED DISPATCHES
    -- Dispatch 1: DELIVERED status for Request 1
    IF v_req1_id IS NOT NULL THEN
        INSERT INTO dispatches (
            tenant_id, organization_id, request_id, dispatch_number, dispatch_date,
            dispatch_status, courier_name, tracking_number, tracking_url,
            expected_delivery_date, actual_dispatch_date, remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'DSP-2026-000001', NOW() - INTERVAL '1 day',
            'DELIVERED', 'BlueDart Express', 'BD-99201142', 'https://bluedart.example.com/track/BD-99201142',
            NOW() - INTERVAL '4 hours', NOW() - INTERVAL '1 day', 'Dispatched calibrated multimeters & pressure gauges under secure packing', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, dispatch_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_dsp1_id;

        -- Dispatch Items for Dispatch 1
        IF v_dsp1_id IS NOT NULL THEN
            INSERT INTO dispatch_items (
                tenant_id, organization_id, dispatch_id, request_id, request_item_id, item_master_id, quantity, remarks
            ) VALUES
            (v_tenant_id, v_org_id, v_dsp1_id, v_req1_id, v_req1_item1_id, v_item_dmm, 1, 'Fluke 87V DMM packed in hardcase'),
            (v_tenant_id, v_org_id, v_dsp1_id, v_req1_id, v_req1_item2_id, v_item_pg, 2, 'WIKA Pressure Gauges packed in foam box')
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    -- Dispatch 2: DRAFT status for Request 2
    IF v_req2_id IS NOT NULL THEN
        INSERT INTO dispatches (
            tenant_id, organization_id, request_id, dispatch_number, dispatch_date,
            dispatch_status, courier_name, remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, 'DSP-2026-000002', NOW(),
            'DRAFT', 'Professional Couriers', 'Draft dispatch note for Vernier Caliper return', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, dispatch_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_dsp2_id;
    END IF;

    -- 5. SEED DELIVERIES
    -- Delivery 1: DELIVERY_SIGNED status for Request 1 & Dispatch 1
    IF v_req1_id IS NOT NULL AND v_dsp1_id IS NOT NULL THEN
        INSERT INTO deliveries (
            tenant_id, organization_id, request_id, dispatch_id, delivery_number,
            delivery_date, delivery_status, received_by_name, received_by_contact, delivery_remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_dsp1_id, 'DEL-2026-000001',
            NOW() - INTERVAL '4 hours', 'DELIVERY_SIGNED', 'Rajesh Kumar', '+91 98400 12345',
            'Delivered and verified in-person at ABC Engineering plant receiving dock', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, delivery_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_del1_id;
    END IF;

    -- Delivery 2: PENDING status for Request 2 & Dispatch 2
    IF v_req2_id IS NOT NULL AND v_dsp2_id IS NOT NULL THEN
        INSERT INTO deliveries (
            tenant_id, organization_id, request_id, dispatch_id, delivery_number,
            delivery_date, delivery_status, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_dsp2_id, 'DEL-2026-000002',
            NOW(), 'PENDING', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, delivery_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_del2_id;
    END IF;

    -- 6. EXECUTE SERVER-CONTROLLED FINAL REQUEST COMPLETION FOR REQUEST 1
    IF v_req1_id IS NOT NULL THEN
        v_completed := complete_calibration_request(v_req1_id, v_user_id);
    END IF;

    -- Ensure IDs are fetched for audit logging if RETURNING was skipped
    IF v_sig1_id IS NULL THEN SELECT id INTO v_sig1_id FROM signatures WHERE request_id = v_req1_id AND signature_type = 'CLIENT_INVOICE' LIMIT 1; END IF;
    IF v_sig2_id IS NULL THEN SELECT id INTO v_sig2_id FROM signatures WHERE request_id = v_req1_id AND signature_type = 'CLIENT_DELIVERY' LIMIT 1; END IF;
    IF v_dsp1_id IS NULL THEN SELECT id INTO v_dsp1_id FROM dispatches WHERE dispatch_number = 'DSP-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_del1_id IS NULL THEN SELECT id INTO v_del1_id FROM deliveries WHERE delivery_number = 'DEL-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    -- 7. AUDIT LOG ENTRIES FOR STEP 7
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_user_id, 'CLIENT_SIGNATURE_SIGNED', 'signatures', v_sig1_id, jsonb_build_object('signature_type', 'CLIENT_INVOICE', 'signed_by', 'Rajesh Kumar')),
    (v_tenant_id, v_org_id, v_user_id, 'DISPATCH_CREATED', 'dispatches', v_dsp1_id, jsonb_build_object('dispatch_number', 'DSP-2026-000001', 'status', 'READY')),
    (v_tenant_id, v_org_id, v_user_id, 'DISPATCHED', 'dispatches', v_dsp1_id, jsonb_build_object('dispatch_number', 'DSP-2026-000001', 'status', 'DISPATCHED', 'courier', 'BlueDart')),
    (v_tenant_id, v_org_id, v_user_id, 'DELIVERY_CREATED', 'deliveries', v_del1_id, jsonb_build_object('delivery_number', 'DEL-2026-000001', 'status', 'PENDING')),
    (v_tenant_id, v_org_id, v_user_id, 'CLIENT_RECEIVED', 'deliveries', v_del1_id, jsonb_build_object('delivery_number', 'DEL-2026-000001', 'status', 'CLIENT_RECEIVED')),
    (v_tenant_id, v_org_id, v_user_id, 'DELIVERY_SIGNATURE_SIGNED', 'signatures', v_sig2_id, jsonb_build_object('signature_type', 'CLIENT_DELIVERY', 'signed_by', 'Rajesh Kumar')),
    (v_tenant_id, v_org_id, v_user_id, 'REQUEST_MARKED_READY_TO_DISPATCH', 'calibration_requests', v_req1_id, jsonb_build_object('request_id', v_req1_id, 'status', 'READY_TO_DISPATCH'));

END $$;
