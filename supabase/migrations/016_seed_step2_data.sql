-- Migration 016: Seed Step 2 Demo Calibration Requests & Verification Data

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_agent_user_id UUID;
    v_client_abc UUID;
    v_client_precision UUID;
    
    v_item_dmm UUID;
    v_item_pg UUID;
    v_item_ts UUID;
    v_item_vc UUID;
    v_item_mc UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req1_item2_id UUID;
    v_req1_item3_id UUID;
    v_req2_item1_id UUID;
    v_req2_item2_id UUID;
BEGIN
    -- 1. GET DEMO TENANT & ORGANIZATION
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' AND tenant_id = v_tenant_id LIMIT 1;

    -- 2. ENSURE DEMO COLLECTION AGENT USER PROFILE EXISTS
    INSERT INTO user_profiles (tenant_id, organization_id, full_name, email, phone, status)
    VALUES (v_tenant_id, v_org_id, 'Ramesh Collection Agent', 'agent@cal-demo.com', '+91 98400 99887', 'ACTIVE')
    ON CONFLICT (tenant_id, email) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_agent_user_id;

    -- 3. GET SEEDED CLIENTS
    SELECT id INTO v_client_abc FROM clients WHERE client_code = 'CL-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_client_precision FROM clients WHERE client_code = 'CL-003' AND tenant_id = v_tenant_id LIMIT 1;

    -- 4. GET SEEDED ITEMS
    SELECT id INTO v_item_dmm FROM item_masters WHERE item_code = 'ITM-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_pg FROM item_masters WHERE item_code = 'ITM-002' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_ts FROM item_masters WHERE item_code = 'ITM-003' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_vc FROM item_masters WHERE item_code = 'ITM-004' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_mc FROM item_masters WHERE item_code = 'ITM-005' AND tenant_id = v_tenant_id LIMIT 1;

    -- 5. SEED CALIBRATION REQUEST 1 (Status: LAB_QUEUE, Priority: NORMAL)
    INSERT INTO calibration_requests (
        tenant_id, organization_id, request_number, client_id, collection_agent_id,
        collection_date, priority, status, remarks, created_by
    ) VALUES (
        v_tenant_id, v_org_id, 'CAL-REQ-000001', v_client_abc, v_agent_user_id,
        NOW() - INTERVAL '2 days', 'NORMAL', 'LAB_QUEUE', 'Routine annual calibration request collected from Ambattur plant', v_agent_user_id
    )
    ON CONFLICT (tenant_id, organization_id, request_number) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_req1_id;

    -- Request 1 Items
    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES 
    (v_tenant_id, v_org_id, v_req1_id, v_item_dmm, 1, 1, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'Fluke 87V DMM received with test leads'),
    (v_tenant_id, v_org_id, v_req1_id, v_item_pg, 2, 2, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'WIKA pressure gauges with safety caps'),
    (v_tenant_id, v_org_id, v_req1_id, v_item_ts, 1, 1, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'Omega PT100 sensor in protective case')
    ON CONFLICT DO NOTHING;

    -- 6. SEED CALIBRATION REQUEST 2 (Status: VERIFICATION, Priority: URGENT)
    INSERT INTO calibration_requests (
        tenant_id, organization_id, request_number, client_id, collection_agent_id,
        collection_date, priority, status, remarks, created_by
    ) VALUES (
        v_tenant_id, v_org_id, 'CAL-REQ-000002', v_client_precision, v_agent_user_id,
        NOW() - INTERVAL '1 day', 'URGENT', 'VERIFICATION', 'Urgent calibration required for audit compliance', v_agent_user_id
    )
    ON CONFLICT (tenant_id, organization_id, request_number) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_req2_id;

    -- Request 2 Items
    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES (
        v_tenant_id, v_org_id, v_req2_id, v_item_vc, 1, 1, 'GOOD', 'VERIFIED', 'DOCUMENT_VERIFIED', 'Mitutoyo Vernier Caliper'
    )
    RETURNING id INTO v_req2_item1_id;

    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES (
        v_tenant_id, v_org_id, v_req2_id, v_item_mc, 1, 1, 'GOOD', 'DISCREPANCY', 'DOCUMENT_PENDING', 'Mitutoyo Micrometer - Serial Mismatch'
    )
    RETURNING id INTO v_req2_item2_id;

    -- 7. SEED VERIFICATION RECORDS FOR REQUEST 2
    IF v_req2_item1_id IS NOT NULL THEN
        INSERT INTO verifications (
            tenant_id, organization_id, request_id, request_item_id, verified_by,
            verified_quantity, expected_quantity, observed_serial_number, observed_item_condition,
            result, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item1_id, v_agent_user_id,
            1, 1, 'SN-MT500-1120', 'GOOD', 'VERIFIED', 'Serial number and physical condition verified matching master record.'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    IF v_req2_item2_id IS NOT NULL THEN
        INSERT INTO verifications (
            tenant_id, organization_id, request_id, request_item_id, verified_by,
            verified_quantity, expected_quantity, observed_serial_number, observed_item_condition,
            result, discrepancy_reason, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item2_id, v_agent_user_id,
            1, 1, 'SN-MT293-9999-MISMATCH', 'GOOD', 'DISCREPANCY',
            'Observed serial number SN-MT293-9999-MISMATCH does not match expected master serial SN-MT293-7734.',
            'Discrepancy logged for commercial team review.'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- 8. AUDIT LOG ENTRIES
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_CREATED', 'calibration_requests', v_req1_id, jsonb_build_object('request_number', 'CAL-REQ-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_SUBMITTED', 'calibration_requests', v_req1_id, jsonb_build_object('request_number', 'CAL-REQ-000001', 'status', 'LAB_QUEUE')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_CREATED', 'calibration_requests', v_req2_id, jsonb_build_object('request_number', 'CAL-REQ-000002', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_SUBMITTED', 'calibration_requests', v_req2_id, jsonb_build_object('request_number', 'CAL-REQ-000002', 'status', 'VERIFICATION')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_VERIFIED', 'verifications', v_req2_item1_id, jsonb_build_object('result', 'VERIFIED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_DISCREPANCY', 'verifications', v_req2_item2_id, jsonb_build_object('result', 'DISCREPANCY', 'reason', 'Serial mismatch'));

END $$;
