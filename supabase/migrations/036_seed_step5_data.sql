-- Migration 036: Seed Step 5 Quotations, Quotation Items, and Approval Workflow Data

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_user_id UUID;

    v_client_abc UUID;
    v_client_precision UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req1_item2_id UUID;
    v_req1_item3_id UUID;
    v_req2_item1_id UUID;

    v_item_dmm UUID;
    v_item_pg UUID;
    v_item_ts UUID;
    v_item_vc UUID;

    v_quot1_id UUID;
    v_quot2_id UUID;
    v_quot3_id UUID;
    v_quot4_id UUID;

    v_appr2_id UUID;
    v_appr3_id UUID;
    v_appr4_id UUID;
BEGIN
    -- 1. GET DEMO TENANT, ORG & USER
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_user_id FROM user_profiles WHERE tenant_id = v_tenant_id AND email = 'agent@cal-demo.com' LIMIT 1;

    -- 2. GET CLIENTS
    SELECT id INTO v_client_abc FROM clients WHERE client_code = 'CL-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_client_precision FROM clients WHERE client_code = 'CL-003' AND tenant_id = v_tenant_id LIMIT 1;

    -- 3. GET REQUESTS & ITEMS
    SELECT id INTO v_req1_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_req2_id FROM calibration_requests WHERE request_number = 'CAL-REQ-000002' AND tenant_id = v_tenant_id LIMIT 1;

    SELECT id INTO v_req1_item1_id FROM request_items WHERE request_id = v_req1_id LIMIT 1;
    SELECT id INTO v_req1_item2_id FROM request_items WHERE request_id = v_req1_id OFFSET 1 LIMIT 1;
    SELECT id INTO v_req1_item3_id FROM request_items WHERE request_id = v_req1_id OFFSET 2 LIMIT 1;
    SELECT id INTO v_req2_item1_id FROM request_items WHERE request_id = v_req2_id LIMIT 1;

    SELECT id INTO v_item_dmm FROM item_masters WHERE item_code = 'ITM-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_pg FROM item_masters WHERE item_code = 'ITM-002' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_ts FROM item_masters WHERE item_code = 'ITM-003' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_vc FROM item_masters WHERE item_code = 'ITM-004' AND tenant_id = v_tenant_id LIMIT 1;

    -- 4. SEED QUOTATION 1 (Status: DRAFT)
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000001',
            1, NOW(), NOW() + INTERVAL '30 days', 'DRAFT', 'INR',
            4900.00, 0.00, 882.00, 5782.00, 'Commercial quotation draft for annual calibration services', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot1_id;

        -- Quotation Items
        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item1_id, v_item_dmm, 'CALIBRATION', 'Calibration of Digital Multimeter (Fluke 87V)', 1, 1500.00, 0.00, 18.00, 270.00, 1770.00),
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item2_id, v_item_pg, 'CALIBRATION', 'Calibration of Pressure Gauges (WIKA 232.50)', 2, 450.00, 0.00, 18.00, 162.00, 1062.00),
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item3_id, v_item_ts, 'OUTSOURCING', 'NABL Accredited Vendor Outsourced Primary Standard Calibration', 1, 2500.00, 0.00, 18.00, 450.00, 2950.00)
        ON CONFLICT DO NOTHING;
    END IF;

    -- 5. SEED QUOTATION 2 (Status: UNDER_APPROVAL, Approval PENDING)
    IF v_req2_id IS NOT NULL AND v_client_precision IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_client_precision, 'QT-2026-000002',
            1, NOW() - INTERVAL '2 hours', NOW() + INTERVAL '15 days', 'UNDER_APPROVAL', 'INR',
            320.00, 0.00, 57.60, 377.60, 'Urgent calibration proposal for Mitutoyo Vernier Caliper', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot2_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot2_id, v_req2_id, v_req2_item1_id, v_item_vc,
            'CALIBRATION', 'Calibration of Mitutoyo Vernier Caliper 0-150mm', 1, 320.00, 0.00, 18.00, 57.60, 377.60
        )
        ON CONFLICT DO NOTHING;

        -- Approval record
        INSERT INTO approvals (
            tenant_id, organization_id, quotation_id, request_id, approval_level,
            approver_user_id, approval_status, submitted_at
        ) VALUES (
            v_tenant_id, v_org_id, v_quot2_id, v_req2_id, 1,
            v_user_id, 'PENDING', NOW() - INTERVAL '2 hours'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_appr2_id;
    END IF;

    -- 6. SEED QUOTATION 3 (Status: APPROVED, Approval APPROVED)
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000003',
            1, NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', 'APPROVED', 'INR',
            3500.00, 500.00, 540.00, 3540.00, 'Approved commercial contract for batch testing', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot3_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot3_id, v_req1_id, v_req1_item1_id, v_item_dmm,
            'CALIBRATION', 'Precision DMM Calibration with discount package', 1, 3500.00, 500.00, 18.00, 540.00, 3540.00
        )
        ON CONFLICT DO NOTHING;

        INSERT INTO approvals (
            tenant_id, organization_id, quotation_id, request_id, approval_level,
            approver_user_id, approval_status, submitted_at, action_at, comments
        ) VALUES (
            v_tenant_id, v_org_id, v_quot3_id, v_req1_id, 1,
            v_user_id, 'APPROVED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '20 hours', 'Approved special commercial discount.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_appr3_id;
    END IF;

    -- 7. SEED QUOTATION 4 (Status: REJECTED, Approval REJECTED)
    IF v_req2_id IS NOT NULL AND v_client_precision IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_client_precision, 'QT-2026-000004',
            1, NOW() - INTERVAL '2 days', NOW() + INTERVAL '10 days', 'REJECTED', 'INR',
            10000.00, 4000.00, 1080.00, 7080.00, 'Rejected proposal due to non-standard discount percentage', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot4_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot4_id, v_req2_id, v_req2_item1_id, v_item_vc,
            'CALIBRATION', 'Custom calibration suite with 40% promotional discount', 1, 10000.00, 4000.00, 18.00, 1080.00, 7080.00
        )
        ON CONFLICT DO NOTHING;

        INSERT INTO approvals (
            tenant_id, organization_id, quotation_id, request_id, approval_level,
            approver_user_id, approval_status, submitted_at, action_at, comments, rejection_reason
        ) VALUES (
            v_tenant_id, v_org_id, v_quot4_id, v_req2_id, 1,
            v_user_id, 'REJECTED', NOW() - INTERVAL '2 days', NOW() - INTERVAL '1 day',
            'Discount policy violation.', 'Requested discount amount of 40% exceeds the maximum authorized 20% limit for standard calibration services.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_appr4_id;
    END IF;

    -- 8. AUDIT LOG ENTRIES FOR STEP 5
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_user_id, 'QUOTATION_CREATED', 'quotations', v_quot1_id, jsonb_build_object('quotation_number', 'QT-2026-000001', 'status', 'DRAFT')),
    (v_tenant_id, v_org_id, v_user_id, 'QUOTATION_SUBMITTED', 'quotations', v_quot2_id, jsonb_build_object('quotation_number', 'QT-2026-000002', 'status', 'UNDER_APPROVAL')),
    (v_tenant_id, v_org_id, v_user_id, 'QUOTATION_APPROVED', 'quotations', v_quot3_id, jsonb_build_object('quotation_number', 'QT-2026-000003', 'status', 'APPROVED')),
    (v_tenant_id, v_org_id, v_user_id, 'QUOTATION_REJECTED', 'quotations', v_quot4_id, jsonb_build_object('quotation_number', 'QT-2026-000004', 'status', 'REJECTED', 'reason', 'Discount limit exceeded'));

END $$;
