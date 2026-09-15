-- Migration 044: Seed Step 6 Invoices, Purchase Orders, and Items Data

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
    v_req2_item1_id UUID;

    v_item_dmm UUID;
    v_item_pg UUID;
    v_item_vc UUID;

    v_quot3_id UUID;
    v_quot5_id UUID;
    v_quot6_id UUID;
    v_quot7_id UUID;

    v_quot3_item1_id UUID;
    v_quot5_item1_id UUID;
    v_quot6_item1_id UUID;
    v_quot7_item1_id UUID;

    v_inv1_id UUID;
    v_inv2_id UUID;
    v_inv3_id UUID;
    v_inv4_id UUID;

    v_po1_id UUID;
    v_po2_id UUID;
    v_po3_id UUID;
    v_po4_id UUID;
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
    SELECT id INTO v_req2_item1_id FROM request_items WHERE request_id = v_req2_id LIMIT 1;

    SELECT id INTO v_item_dmm FROM item_masters WHERE item_code = 'ITM-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_pg FROM item_masters WHERE item_code = 'ITM-002' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_vc FROM item_masters WHERE item_code = 'ITM-004' AND tenant_id = v_tenant_id LIMIT 1;

    -- 4. GET OR CREATE APPROVED QUOTATIONS FOR SEEDING INVOICES/POS
    SELECT id INTO v_quot3_id FROM quotations WHERE quotation_number = 'QT-2026-000003' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_quot3_item1_id FROM quotation_items WHERE quotation_id = v_quot3_id LIMIT 1;

    -- Seed Quotation 5 (Approved)
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000005',
            1, NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days', 'APPROVED', 'INR',
            4000.00, 0.00, 720.00, 4720.00, 'Approved commercial contract for pressure calibration', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot5_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot5_id, v_req1_id, v_req1_item2_id, v_item_pg,
            'CALIBRATION', 'Calibration of Pressure Gauges Package', 2, 2000.00, 0.00, 18.00, 720.00, 4720.00
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_quot5_item1_id;
    END IF;

    -- Seed Quotation 6 (Approved)
    IF v_req2_id IS NOT NULL AND v_client_precision IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_client_precision, 'QT-2026-000006',
            1, NOW() - INTERVAL '4 days', NOW() + INTERVAL '26 days', 'APPROVED', 'INR',
            2000.00, 0.00, 360.00, 2360.00, 'Approved caliper calibration contract', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot6_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot6_id, v_req2_id, v_req2_item1_id, v_item_vc,
            'CALIBRATION', 'Calibration of Vernier Caliper Precision Unit', 1, 2000.00, 0.00, 18.00, 360.00, 2360.00
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_quot6_item1_id;
    END IF;

    -- Seed Quotation 7 (Approved)
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000007',
            1, NOW() - INTERVAL '3 days', NOW() + INTERVAL '27 days', 'APPROVED', 'INR',
            5000.00, 500.00, 810.00, 5310.00, 'Approved full plant equipment calibration package', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot7_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES (
            v_tenant_id, v_org_id, v_quot7_id, v_req1_id, v_req1_item1_id, v_item_dmm,
            'CALIBRATION', 'Multimeter & Plant Instrumentation Suite', 1, 5000.00, 500.00, 18.00, 810.00, 5310.00
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_quot7_item1_id;
    END IF;

    -- Ensure quotation item IDs are populated if RETURNING was skipped
    IF v_quot5_item1_id IS NULL THEN SELECT id INTO v_quot5_item1_id FROM quotation_items WHERE quotation_id = v_quot5_id LIMIT 1; END IF;
    IF v_quot6_item1_id IS NULL THEN SELECT id INTO v_quot6_item1_id FROM quotation_items WHERE quotation_id = v_quot6_id LIMIT 1; END IF;
    IF v_quot7_item1_id IS NULL THEN SELECT id INTO v_quot7_item1_id FROM quotation_items WHERE quotation_id = v_quot7_id LIMIT 1; END IF;

    -- 5. SEED INVOICES
    -- Invoice 1: Status = DRAFT
    IF v_quot3_id IS NOT NULL THEN
        INSERT INTO invoices (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            invoice_number, invoice_date, due_date, invoice_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, paid_amount, balance_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot3_id, v_client_abc,
            'INV-2026-000001', NOW(), NOW() + INTERVAL '30 days', 'DRAFT', 'INR',
            3500.00, 500.00, 540.00, 3540.00, 0.00, 3540.00,
            'Draft Commercial Invoice for approved calibration work', 'Payment due within 30 days', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, invoice_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_inv1_id;

        INSERT INTO invoice_items (
            tenant_id, organization_id, invoice_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_inv1_id, v_req1_id, v_req1_item1_id, v_quot3_id, v_quot3_item1_id,
            v_item_dmm, 'Precision DMM Calibration with discount package', 1, 3500.00, 500.00, 18.00, 540.00, 3540.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Invoice 2: Status = ISSUED
    IF v_quot5_id IS NOT NULL THEN
        INSERT INTO invoices (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            invoice_number, invoice_date, due_date, invoice_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, paid_amount, balance_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot5_id, v_client_abc,
            'INV-2026-000002', NOW() - INTERVAL '2 days', NOW() + INTERVAL '28 days', 'ISSUED', 'INR',
            4000.00, 0.00, 720.00, 4720.00, 0.00, 4720.00,
            'Issued Commercial Invoice for pressure calibration batch', 'Payment due within 30 days', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, invoice_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_inv2_id;

        INSERT INTO invoice_items (
            tenant_id, organization_id, invoice_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_inv2_id, v_req1_id, v_req1_item2_id, v_quot5_id, v_quot5_item1_id,
            v_item_pg, 'Calibration of Pressure Gauges Package', 2, 2000.00, 0.00, 18.00, 720.00, 4720.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Invoice 3: Status = PARTIALLY_PAID
    IF v_quot6_id IS NOT NULL THEN
        INSERT INTO invoices (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            invoice_number, invoice_date, due_date, invoice_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, paid_amount, balance_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_quot6_id, v_client_precision,
            'INV-2026-000003', NOW() - INTERVAL '10 days', NOW() + INTERVAL '20 days', 'PARTIALLY_PAID', 'INR',
            2000.00, 0.00, 360.00, 2360.00, 1000.00, 1360.00,
            'Partially Paid Invoice for Caliper Calibration', 'Remaining balance due in 20 days', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, invoice_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_inv3_id;

        INSERT INTO invoice_items (
            tenant_id, organization_id, invoice_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_inv3_id, v_req2_id, v_req2_item1_id, v_quot6_id, v_quot6_item1_id,
            v_item_vc, 'Calibration of Vernier Caliper Precision Unit', 1, 2000.00, 0.00, 18.00, 360.00, 2360.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Invoice 4: Status = PAID
    IF v_quot7_id IS NOT NULL THEN
        INSERT INTO invoices (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            invoice_number, invoice_date, due_date, invoice_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, paid_amount, balance_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot7_id, v_client_abc,
            'INV-2026-000004', NOW() - INTERVAL '15 days', NOW() + INTERVAL '15 days', 'PAID', 'INR',
            5000.00, 500.00, 810.00, 5310.00, 5310.00, 0.00,
            'Fully Paid Commercial Invoice', 'Paid in full via Bank Transfer', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, invoice_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_inv4_id;

        INSERT INTO invoice_items (
            tenant_id, organization_id, invoice_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_inv4_id, v_req1_id, v_req1_item1_id, v_quot7_id, v_quot7_item1_id,
            v_item_dmm, 'Multimeter & Plant Instrumentation Suite', 1, 5000.00, 500.00, 18.00, 810.00, 5310.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- 6. SEED PURCHASE ORDERS
    -- PO 1: Status = DRAFT
    IF v_quot3_id IS NOT NULL THEN
        INSERT INTO purchase_orders (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            po_number, po_date, expected_date, po_status, currency,
            subtotal, discount_amount, tax_amount, total_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot3_id, v_client_abc,
            'PO-2026-000001', NOW(), NOW() + INTERVAL '14 days', 'DRAFT', 'INR',
            3500.00, 500.00, 540.00, 3540.00,
            'Draft Purchase Order for approved calibration order', 'Subject to client commercial approval', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, po_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_po1_id;

        INSERT INTO po_items (
            tenant_id, organization_id, purchase_order_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_po1_id, v_req1_id, v_req1_item1_id, v_quot3_id, v_quot3_item1_id,
            v_item_dmm, 'Precision DMM Calibration with discount package', 1, 3500.00, 500.00, 18.00, 540.00, 3540.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- PO 2: Status = ISSUED
    IF v_quot5_id IS NOT NULL THEN
        INSERT INTO purchase_orders (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            po_number, po_date, expected_date, po_status, currency,
            subtotal, discount_amount, tax_amount, total_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot5_id, v_client_abc,
            'PO-2026-000002', NOW() - INTERVAL '1 day', NOW() + INTERVAL '13 days', 'ISSUED', 'INR',
            4000.00, 0.00, 720.00, 4720.00,
            'Issued Purchase Order for pressure gauge calibration batch', 'Standard delivery terms apply', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, po_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_po2_id;

        INSERT INTO po_items (
            tenant_id, organization_id, purchase_order_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_po2_id, v_req1_id, v_req1_item2_id, v_quot5_id, v_quot5_item1_id,
            v_item_pg, 'Calibration of Pressure Gauges Package', 2, 2000.00, 0.00, 18.00, 720.00, 4720.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- PO 3: Status = PARTIALLY_RECEIVED
    IF v_quot6_id IS NOT NULL THEN
        INSERT INTO purchase_orders (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            po_number, po_date, expected_date, po_status, currency,
            subtotal, discount_amount, tax_amount, total_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_quot6_id, v_client_precision,
            'PO-2026-000003', NOW() - INTERVAL '5 days', NOW() + INTERVAL '5 days', 'PARTIALLY_RECEIVED', 'INR',
            2000.00, 0.00, 360.00, 2360.00,
            'Partially Received Purchase Order for Caliper Calibration', 'First lot received at lab', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, po_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_po3_id;

        INSERT INTO po_items (
            tenant_id, organization_id, purchase_order_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_po3_id, v_req2_id, v_req2_item1_id, v_quot6_id, v_quot6_item1_id,
            v_item_vc, 'Calibration of Vernier Caliper Precision Unit', 1, 2000.00, 0.00, 18.00, 360.00, 2360.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- PO 4: Status = RECEIVED
    IF v_quot7_id IS NOT NULL THEN
        INSERT INTO purchase_orders (
            tenant_id, organization_id, request_id, quotation_id, client_id,
            po_number, po_date, expected_date, po_status, currency,
            subtotal, discount_amount, tax_amount, total_amount,
            notes, terms_and_conditions, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_quot7_id, v_client_abc,
            'PO-2026-000004', NOW() - INTERVAL '10 days', NOW() - INTERVAL '1 day', 'RECEIVED', 'INR',
            5000.00, 500.00, 810.00, 5310.00,
            'Fully Received Purchase Order for plant instrumentation', 'All items received and verified', v_user_id
        )
        ON CONFLICT (tenant_id, organization_id, po_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_po4_id;

        INSERT INTO po_items (
            tenant_id, organization_id, purchase_order_id, request_id, request_item_id, quotation_id, quotation_item_id,
            item_master_id, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total, item_type
        ) VALUES (
            v_tenant_id, v_org_id, v_po4_id, v_req1_id, v_req1_item1_id, v_quot7_id, v_quot7_item1_id,
            v_item_dmm, 'Multimeter & Plant Instrumentation Suite', 1, 5000.00, 500.00, 18.00, 810.00, 5310.00, 'CALIBRATION'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Ensure document IDs exist for audit logs if RETURNING was skipped
    IF v_inv1_id IS NULL THEN SELECT id INTO v_inv1_id FROM invoices WHERE invoice_number = 'INV-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv2_id IS NULL THEN SELECT id INTO v_inv2_id FROM invoices WHERE invoice_number = 'INV-2026-000002' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv3_id IS NULL THEN SELECT id INTO v_inv3_id FROM invoices WHERE invoice_number = 'INV-2026-000003' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv4_id IS NULL THEN SELECT id INTO v_inv4_id FROM invoices WHERE invoice_number = 'INV-2026-000004' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    IF v_po1_id IS NULL THEN SELECT id INTO v_po1_id FROM purchase_orders WHERE po_number = 'PO-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po2_id IS NULL THEN SELECT id INTO v_po2_id FROM purchase_orders WHERE po_number = 'PO-2026-000002' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po3_id IS NULL THEN SELECT id INTO v_po3_id FROM purchase_orders WHERE po_number = 'PO-2026-000003' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po4_id IS NULL THEN SELECT id INTO v_po4_id FROM purchase_orders WHERE po_number = 'PO-2026-000004' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    -- 7. AUDIT LOG ENTRIES FOR STEP 6
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_user_id, 'INVOICE_CREATED', 'invoices', v_inv1_id, jsonb_build_object('invoice_number', 'INV-2026-000001', 'status', 'DRAFT')),
    (v_tenant_id, v_org_id, v_user_id, 'INVOICE_ISSUED', 'invoices', v_inv2_id, jsonb_build_object('invoice_number', 'INV-2026-000002', 'status', 'ISSUED')),
    (v_tenant_id, v_org_id, v_user_id, 'INVOICE_MARKED_PARTIALLY_PAID', 'invoices', v_inv3_id, jsonb_build_object('invoice_number', 'INV-2026-000003', 'status', 'PARTIALLY_PAID', 'paid_amount', 1000.00)),
    (v_tenant_id, v_org_id, v_user_id, 'INVOICE_MARKED_PAID', 'invoices', v_inv4_id, jsonb_build_object('invoice_number', 'INV-2026-000004', 'status', 'PAID', 'paid_amount', 5310.00)),
    (v_tenant_id, v_org_id, v_user_id, 'PO_CREATED', 'purchase_orders', v_po1_id, jsonb_build_object('po_number', 'PO-2026-000001', 'status', 'DRAFT')),
    (v_tenant_id, v_org_id, v_user_id, 'PO_ISSUED', 'purchase_orders', v_po2_id, jsonb_build_object('po_number', 'PO-2026-000002', 'status', 'ISSUED')),
    (v_tenant_id, v_org_id, v_user_id, 'PO_PARTIALLY_RECEIVED', 'purchase_orders', v_po3_id, jsonb_build_object('po_number', 'PO-2026-000003', 'status', 'PARTIALLY_RECEIVED')),
    (v_tenant_id, v_org_id, v_user_id, 'PO_RECEIVED', 'purchase_orders', v_po4_id, jsonb_build_object('po_number', 'PO-2026-000004', 'status', 'RECEIVED'));

END $$;
