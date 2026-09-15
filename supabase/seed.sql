-- =============================================================================
-- CALIBRATION COMMERCIAL MODULE - STEP 1, STEP 2, STEP 3, STEP 4, STEP 5 & STEP 6 UNIFIED SEED DATA
-- =============================================================================

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_role_admin UUID;
    v_role_collection UUID;
    v_role_lab UUID;
    v_role_commercial UUID;
    v_role_approver UUID;
    v_role_dispatch UUID;

    v_agent_user_id UUID;
    v_client_abc UUID;
    v_client_precision UUID;
    
    v_item_dmm UUID;
    v_item_pg UUID;
    v_item_ts UUID;
    v_item_vc UUID;
    v_item_mc UUID;

    v_vendor_apex UUID;
    v_vendor_natmet UUID;

    v_req1_id UUID;
    v_req2_id UUID;

    v_req1_item1_id UUID;
    v_req1_item2_id UUID;
    v_req1_item3_id UUID;
    v_req2_item1_id UUID;
    v_req2_item2_id UUID;

    v_cal1_id UUID;
    v_cal2_id UUID;

    v_faulty1_id UUID;
    v_faulty2_id UUID;
    v_outsourcing1_id UUID;
    v_outsourcing2_id UUID;

    -- Step 5 & Step 6 Variables
    v_quot1_id UUID;
    v_quot2_id UUID;
    v_quot3_id UUID;
    v_quot4_id UUID;
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

    -- Step 7 Variables
    v_sig1_id UUID;
    v_sig2_id UUID;
    v_sig3_id UUID;
    v_dsp1_id UUID;
    v_dsp2_id UUID;
    v_del1_id UUID;
    v_del2_id UUID;
BEGIN

    -- 1. SEED DEMO TENANT
    INSERT INTO tenants (name, code, status)
    VALUES ('Calibration Demo Tenant', 'CAL-DEMO', 'ACTIVE')
    ON CONFLICT (code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_tenant_id;

    -- 2. SEED DEMO ORGANIZATION
    INSERT INTO organizations (tenant_id, name, code, address, phone, email, status)
    VALUES (
        v_tenant_id,
        'Main Calibration Center',
        'ORG-MAIN',
        '100 Industrial Parkway, Guindy, Chennai, TN - 600032',
        '+91 44 2250 1234',
        'main.center@cal-demo.com',
        'ACTIVE'
    )
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_org_id;

    -- 3. SEED ALL GRANULAR PERMISSIONS (STEPS 1 - 6)
    INSERT INTO permissions (code, name, description, module) VALUES
    ('ORGANIZATION_VIEW', 'View Organization Details', 'Allows viewing organization details and settings', 'Organization'),
    ('ORGANIZATION_UPDATE', 'Update Organization Details', 'Allows updating organization profile and settings', 'Organization'),
    ('USER_VIEW', 'View User Profiles', 'Allows viewing user profiles and roles', 'Users'),
    ('USER_CREATE', 'Create User Profiles', 'Allows adding new user profiles', 'Users'),
    ('USER_UPDATE', 'Update User Profiles', 'Allows modifying user profiles', 'Users'),
    ('USER_DELETE', 'Delete User Profiles', 'Allows removing user profiles', 'Users'),
    ('CLIENT_VIEW', 'View Clients', 'Allows viewing client master data', 'Clients'),
    ('CLIENT_CREATE', 'Create Clients', 'Allows adding new clients', 'Clients'),
    ('CLIENT_UPDATE', 'Update Clients', 'Allows modifying client details', 'Clients'),
    ('CLIENT_DELETE', 'Delete Clients', 'Allows removing client records', 'Clients'),
    ('VENDOR_VIEW', 'View Vendors', 'Allows viewing vendor master data', 'Vendors'),
    ('VENDOR_CREATE', 'Create Vendors', 'Allows adding new vendors', 'Vendors'),
    ('VENDOR_UPDATE', 'Update Vendors', 'Allows modifying vendor details', 'Vendors'),
    ('VENDOR_DELETE', 'Delete Vendors', 'Allows removing vendor records', 'Vendors'),
    ('ITEM_VIEW', 'View Items', 'Allows viewing item master records', 'Items'),
    ('ITEM_CREATE', 'Create Items', 'Allows adding new calibration items', 'Items'),
    ('ITEM_UPDATE', 'Update Items', 'Allows modifying item master details', 'Items'),
    ('ITEM_DELETE', 'Delete Items', 'Allows removing item records', 'Items'),
    ('REQUEST_VIEW', 'View Calibration Requests', 'Allows viewing calibration requests', 'Requests'),
    ('REQUEST_CREATE', 'Create Calibration Request', 'Allows creating new calibration requests', 'Requests'),
    ('REQUEST_UPDATE', 'Update Calibration Request', 'Allows modifying existing calibration requests', 'Requests'),
    ('REQUEST_SUBMIT', 'Submit Calibration Request', 'Allows submitting requests for verification/lab processing', 'Requests'),
    ('VERIFICATION_VIEW', 'View Verifications', 'Allows viewing verification tasks and results', 'Verification'),
    ('VERIFICATION_CREATE', 'Create Verification Task', 'Allows creating verification entries', 'Verification'),
    ('VERIFICATION_UPDATE', 'Update Verification Task', 'Allows updating verification findings', 'Verification'),
    ('CALIBRATION_VIEW', 'View Calibration Process', 'Allows viewing lab calibration records', 'Calibration'),
    ('CALIBRATION_CREATE', 'Create Calibration Entry', 'Allows entering lab calibration measurements', 'Calibration'),
    ('CALIBRATION_UPDATE', 'Update Calibration Entry', 'Allows modifying calibration certificates/data', 'Calibration'),
    ('DOCUMENT_VIEW', 'View Documents', 'Allows viewing attached documents and certificates', 'Documents'),
    ('DOCUMENT_UPLOAD', 'Upload Documents', 'Allows uploading documents and calibration sheets', 'Documents'),
    ('DOCUMENT_DELETE', 'Delete Documents', 'Allows removing uploaded documents', 'Documents'),
    ('QUOTATION_VIEW', 'View Quotations', 'Allows viewing commercial quotations', 'Quotations'),
    ('QUOTATION_CREATE', 'Create Quotation', 'Allows drafting quotations', 'Quotations'),
    ('QUOTATION_UPDATE', 'Update Quotation', 'Allows updating draft quotations', 'Quotations'),
    ('QUOTATION_SUBMIT', 'Submit Quotation', 'Allows submitting quotations for approval', 'Quotations'),
    ('QUOTATION_APPROVE', 'Approve Quotation', 'Allows approving commercial quotations', 'Quotations'),
    ('APPROVAL_VIEW', 'View Approvals', 'Allows viewing quotation approval tasks', 'Approvals'),
    ('APPROVAL_APPROVE', 'Approve Quotation Task', 'Allows approving commercial quotations', 'Approvals'),
    ('APPROVAL_REJECT', 'Reject Quotation Task', 'Allows rejecting commercial quotations', 'Approvals'),
    ('PO_VIEW', 'View Purchase Orders', 'Allows viewing purchase orders', 'Purchase Orders'),
    ('PO_CREATE', 'Create Purchase Order', 'Allows creating purchase orders', 'Purchase Orders'),
    ('PO_UPDATE', 'Update Purchase Order', 'Allows updating purchase orders', 'Purchase Orders'),
    ('PO_ISSUE', 'Issue Purchase Order', 'Allows issuing purchase orders', 'Purchase Orders'),
    ('INVOICE_VIEW', 'View Invoices', 'Allows viewing commercial invoices', 'Invoices'),
    ('INVOICE_CREATE', 'Create Invoice', 'Allows generating commercial invoices', 'Invoices'),
    ('INVOICE_UPDATE', 'Update Invoice', 'Allows modifying invoice details', 'Invoices'),
    ('INVOICE_ISSUE', 'Issue Invoice', 'Allows issuing invoices', 'Invoices'),
    ('SIGNATURE_VIEW', 'View Signatures', 'Allows viewing digital signatures', 'Signatures'),
    ('SIGNATURE_CREATE', 'Create Signature', 'Allows applying digital signatures', 'Signatures'),
    ('DISPATCH_VIEW', 'View Dispatch Tasks', 'Allows viewing dispatch status', 'Dispatch'),
    ('DISPATCH_CREATE', 'Create Dispatch Entry', 'Allows generating dispatch documents', 'Dispatch'),
    ('DISPATCH_UPDATE', 'Update Dispatch Entry', 'Allows updating dispatch tracking details', 'Dispatch'),
    ('DELIVERY_VIEW', 'View Delivery Status', 'Allows viewing delivery receipts', 'Delivery'),
    ('DELIVERY_CREATE', 'Create Delivery Receipt', 'Allows logging proof of delivery', 'Delivery'),
    ('DELIVERY_UPDATE', 'Update Delivery Status', 'Allows updating delivery details', 'Delivery'),
    ('AUDIT_VIEW', 'View Audit Logs', 'Allows inspecting system audit trails', 'Audit'),
    ('FAULTY_SERVICE_VIEW', 'View Faulty Item Services', 'Allows viewing internal service records for faulty items', 'Faulty Service'),
    ('FAULTY_SERVICE_CREATE', 'Create Faulty Item Service', 'Allows creating new faulty item service tickets', 'Faulty Service'),
    ('FAULTY_SERVICE_UPDATE', 'Update Faulty Item Service', 'Allows updating service status and notes', 'Faulty Service'),
    ('OUTSOURCING_VIEW', 'View Vendor Outsourcing', 'Allows viewing vendor outsourcing records', 'Vendor Outsourcing'),
    ('OUTSOURCING_CREATE', 'Create Vendor Outsourcing', 'Allows creating vendor outsourcing requests', 'Vendor Outsourcing'),
    ('OUTSOURCING_UPDATE', 'Update Vendor Outsourcing', 'Allows updating vendor outsourcing status and return details', 'Vendor Outsourcing')
    ON CONFLICT (code) DO UPDATE SET 
        name = EXCLUDED.name,
        description = EXCLUDED.description,
        module = EXCLUDED.module;

    -- 4. SEED ROLES FOR TENANT
    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'System Administrator', 'ADMIN', 'Full system access and tenant management', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_admin;

    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'Collection Agent', 'COLLECTION_AGENT', 'Field agent for item collection and customer requests', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_collection;

    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'Lab Calibration User', 'LAB_USER', 'Laboratory technician and calibration engineer', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_lab;

    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'Commercial User', 'COMMERCIAL_USER', 'Handles quotations, invoices, POs, and clients', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_commercial;

    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'Commercial Approver', 'APPROVER', 'Approves quotations and commercial proposals', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_approver;

    INSERT INTO roles (tenant_id, name, code, description, status) VALUES
    (v_tenant_id, 'Dispatch & Logistics User', 'DISPATCH_USER', 'Manages dispatch, signatures, and delivery receipts', 'ACTIVE')
    ON CONFLICT (tenant_id, code) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_role_dispatch;

    -- 5. MAP ROLE PERMISSIONS
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_admin, p.id FROM permissions p
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_collection, p.id FROM permissions p
    WHERE p.code IN ('CLIENT_VIEW', 'ITEM_VIEW', 'REQUEST_VIEW', 'REQUEST_CREATE', 'REQUEST_UPDATE', 'REQUEST_SUBMIT')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_lab, p.id FROM permissions p
    WHERE p.code IN ('ITEM_VIEW', 'REQUEST_VIEW', 'VERIFICATION_VIEW', 'VERIFICATION_CREATE', 'VERIFICATION_UPDATE', 'DOCUMENT_VIEW', 'DOCUMENT_UPLOAD', 'CALIBRATION_VIEW', 'CALIBRATION_CREATE', 'CALIBRATION_UPDATE', 'FAULTY_SERVICE_VIEW', 'FAULTY_SERVICE_CREATE', 'FAULTY_SERVICE_UPDATE', 'OUTSOURCING_VIEW', 'OUTSOURCING_CREATE', 'OUTSOURCING_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_commercial, p.id FROM permissions p
    WHERE p.code IN ('CLIENT_VIEW', 'VENDOR_VIEW', 'REQUEST_VIEW', 'QUOTATION_VIEW', 'QUOTATION_CREATE', 'QUOTATION_UPDATE', 'QUOTATION_SUBMIT', 'PO_VIEW', 'PO_CREATE', 'PO_UPDATE', 'PO_ISSUE', 'INVOICE_VIEW', 'INVOICE_CREATE', 'INVOICE_UPDATE', 'INVOICE_ISSUE', 'OUTSOURCING_VIEW', 'OUTSOURCING_CREATE', 'OUTSOURCING_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_approver, p.id FROM permissions p
    WHERE p.code IN ('QUOTATION_VIEW', 'QUOTATION_APPROVE', 'APPROVAL_VIEW', 'APPROVAL_APPROVE', 'APPROVAL_REJECT', 'INVOICE_VIEW', 'PO_VIEW')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_dispatch, p.id FROM permissions p
    WHERE p.code IN ('INVOICE_VIEW', 'SIGNATURE_VIEW', 'SIGNATURE_CREATE', 'DISPATCH_VIEW', 'DISPATCH_CREATE', 'DISPATCH_UPDATE', 'DELIVERY_VIEW', 'DELIVERY_CREATE', 'DELIVERY_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- 6. SEED DEMO USER PROFILE
    INSERT INTO user_profiles (tenant_id, organization_id, full_name, email, phone, status)
    VALUES (v_tenant_id, v_org_id, 'Ramesh Collection Agent', 'agent@cal-demo.com', '+91 98400 99887', 'ACTIVE')
    ON CONFLICT (tenant_id, email) DO UPDATE SET updated_at = NOW()
    RETURNING id INTO v_agent_user_id;

    -- 7. SEED DEMO CLIENTS
    INSERT INTO clients (tenant_id, organization_id, client_code, client_name, address, billing_address, gst_tax_number, contact_person, email, phone, status) VALUES
    (v_tenant_id, v_org_id, 'CL-001', 'ABC Engineering Pvt Ltd', 'Plot 45, Ambattur Industrial Estate, Chennai, TN', 'Plot 45, Ambattur Industrial Estate, Chennai, TN', '33AAACA1234A1Z5', 'Rajesh Kumar', 'rajesh@abceng.com', '+91 98400 12345', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-002', 'Chennai Industrial Systems', '12 Mount Road, Guindy, Chennai, TN', '12 Mount Road, Guindy, Chennai, TN', '33AABCC5678B1Z2', 'Srinivasan R', 'srinivasan@chennaisys.in', '+91 98410 23456', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-003', 'Precision Manufacturing India', 'Sector 3, SIPCOT Tech Park, Sriperumbudur, TN', 'Sector 3, SIPCOT Tech Park, Sriperumbudur, TN', '33AACCP9012C1Z9', 'Anand Verma', 'anand@precisionmfg.co.in', '+91 98420 34567', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-004', 'Southern Testing Labs', '88 GST Road, Chromepet, Chennai, TN', '88 GST Road, Chromepet, Chennai, TN', '33AAADS3456D1Z4', 'Dr. Meena Swaminathan', 'meena@southerntesting.org', '+91 98430 45678', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-005', 'Metro Automation Solutions', '56 IT Corridor, OMR, Perungudi, Chennai, TN', '56 IT Corridor, OMR, Perungudi, Chennai, TN', '33AAAEM7890E1Z1', 'Karthik Raja', 'karthik@metroauto.com', '+91 98440 56789', 'ACTIVE')
    ON CONFLICT (tenant_id, organization_id, client_code) DO UPDATE SET updated_at = NOW();

    SELECT id INTO v_client_abc FROM clients WHERE client_code = 'CL-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_client_precision FROM clients WHERE client_code = 'CL-003' AND tenant_id = v_tenant_id LIMIT 1;

    -- 8. SEED DEMO VENDORS
    INSERT INTO vendors (tenant_id, organization_id, vendor_code, vendor_name, address, gst_tax_number, contact_person, email, phone, serviced_categories, status) VALUES
    (v_tenant_id, v_org_id, 'VN-001', 'Apex Calibration Standards Ltd', '22 Industrial Zone, Peenya, Bengaluru, KA', '29AAACA9988A1Z0', 'Venkatesh Rao', 'vrao@apexcal.com', '+91 80 2839 1100', ARRAY['Electrical', 'Thermal'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-002', 'Precision Instruments Supply', '14 SIDCO Estate, Hosur, TN', '33AABCP7766B1Z3', 'Pravin Shah', 'pravin@precisioninst.in', '+91 4344 240 500', ARRAY['Mechanical', 'Dimensional'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-003', 'National Metrology Components', '55 Wagle Estate, Thane, MH', '27AACCN5544C1Z6', 'Milind Kulkarni', 'milind@natmetrology.com', '+91 22 2582 9911', ARRAY['Pressure', 'Flow'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-004', 'Southern Sensor Tech', '90 Electronics Complex, Coimbatore, TN', '33AAADS3322D1Z8', 'Ganesh Moorthy', 'ganesh@sensortech.co.in', '+91 422 265 4321', ARRAY['Temperature', 'Environmental'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-005', 'Transcat Calibration Services', '77 Central Park, Hyderabad, TS', '36AAAET1100E1Z2', 'Ramesh Reddy', 'ramesh@transcat.in', '+91 40 2300 8899', ARRAY['Mass', 'Torque'], 'ACTIVE')
    ON CONFLICT (tenant_id, organization_id, vendor_code) DO UPDATE SET updated_at = NOW();

    SELECT id INTO v_vendor_apex FROM vendors WHERE vendor_code = 'VN-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_vendor_natmet FROM vendors WHERE vendor_code = 'VN-003' AND tenant_id = v_tenant_id LIMIT 1;

    -- 9. SEED DEMO ITEM MASTERS
    INSERT INTO item_masters (tenant_id, organization_id, item_code, item_name, item_type, manufacturer, model, serial_number, measurement_range, least_count, standard_cost, calibration_frequency, status) VALUES
    (v_tenant_id, v_org_id, 'ITM-001', 'Digital Multimeter', 'Electrical', 'Fluke', 'Fluke 87V', 'SN-FL87V-9901', '0-1000V DC/AC', '0.001mV', 1500.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-002', 'Pressure Gauge', 'Pressure', 'WIKA', '232.50', 'SN-WK232-4410', '0-100 Bar', '0.1 Bar', 450.00, 180, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-003', 'Temperature Sensor', 'Thermal', 'Omega Engineering', 'PT100-RTD', 'SN-OMPT-8821', '-200°C to +600°C', '0.01°C', 850.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-004', 'Vernier Caliper', 'Dimensional', 'Mitutoyo', '500-196-30', 'SN-MT500-1120', '0-150 mm', '0.01 mm', 320.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-005', 'Micrometer', 'Dimensional', 'Mitutoyo', '293-240-30', 'SN-MT293-7734', '0-25 mm', '0.001 mm', 410.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-006', 'Weighing Balance', 'Mass', 'Mettler Toledo', 'ME204T', 'SN-MTME-5512', '0-220 g', '0.1 mg', 3500.00, 180, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-007', 'Digital Thermometer', 'Thermal', 'Fluke', '52 II', 'SN-FL52-6632', '-200°C to +1370°C', '0.1°C', 620.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-008', 'Pressure Transmitter', 'Pressure', 'Rosemount', '3051S', 'SN-RM3051-9011', '0-250 psi', '0.01 psi', 2100.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-009', 'Electrical Tester', 'Electrical', 'Megger', 'MIT420/2', 'SN-MG420-3341', '50V - 1000V Insulation', '0.01 MΩ', 1250.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-010', 'Torque Wrench', 'Torque', 'Stahlwille', 'Manoskop 730', 'SN-SW730-2219', '20-100 Nm', '0.5 Nm', 780.00, 180, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-011', 'Clamp Meter', 'Electrical', 'Fluke', '376 FC', 'SN-FL376-8840', '0-1000A AC/DC', '0.1A', 950.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-012', 'RTD Sensor', 'Thermal', 'Tempsens', 'PT100 4-Wire', 'SN-TS4W-1092', '-50°C to +400°C', '0.05°C', 380.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-013', 'Insulation Tester', 'Electrical', 'Chauvin Arnoux', 'CA 6545', 'SN-CA6545-6671', '10 kΩ - 10 TΩ', '1 kΩ', 2800.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-014', 'Oscilloscope', 'Electrical', 'Tektronix', 'TBS2104B', 'SN-TK2104-5002', '100 MHz 2 GS/s', '1 mV/div', 4200.00, 365, 'ACTIVE'),
    (v_tenant_id, v_org_id, 'ITM-015', 'Temperature Indicator', 'Thermal', 'Yokogawa', 'UT150', 'SN-YK150-3398', '-100°C to +1200°C', '0.1°C', 590.00, 365, 'ACTIVE')
    ON CONFLICT (tenant_id, organization_id, item_code) DO UPDATE SET updated_at = NOW();

    SELECT id INTO v_item_dmm FROM item_masters WHERE item_code = 'ITM-001' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_pg FROM item_masters WHERE item_code = 'ITM-002' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_ts FROM item_masters WHERE item_code = 'ITM-003' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_vc FROM item_masters WHERE item_code = 'ITM-004' AND tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_item_mc FROM item_masters WHERE item_code = 'ITM-005' AND tenant_id = v_tenant_id LIMIT 1;

    -- 10. SEED CALIBRATION REQUEST 1 (Status: LAB_QUEUE, Priority: NORMAL)
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
    (v_tenant_id, v_org_id, v_req1_id, v_item_dmm, 1, 1, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'Fluke 87V DMM received with test leads')
    ON CONFLICT DO NOTHING RETURNING id INTO v_req1_item1_id;

    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES 
    (v_tenant_id, v_org_id, v_req1_id, v_item_pg, 2, 2, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'WIKA pressure gauges with safety caps')
    ON CONFLICT DO NOTHING RETURNING id INTO v_req1_item2_id;

    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES 
    (v_tenant_id, v_org_id, v_req1_id, v_item_ts, 1, 1, 'GOOD', 'VERIFICATION_PENDING', 'DOCUMENT_PENDING', 'Omega PT100 sensor in protective case')
    ON CONFLICT DO NOTHING RETURNING id INTO v_req1_item3_id;

    -- 11. SEED CALIBRATION REQUEST 2 (Status: VERIFICATION, Priority: URGENT)
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
    ON CONFLICT DO NOTHING RETURNING id INTO v_req2_item1_id;

    INSERT INTO request_items (
        tenant_id, organization_id, request_id, item_master_id, quantity, received_quantity,
        item_condition, status, document_requirement_status, remarks
    ) VALUES (
        v_tenant_id, v_org_id, v_req2_id, v_item_mc, 1, 1, 'GOOD', 'DISCREPANCY', 'DOCUMENT_PENDING', 'Mitutoyo Micrometer - Serial Mismatch'
    )
    ON CONFLICT DO NOTHING RETURNING id INTO v_req2_item2_id;

    -- 12. SEED VERIFICATION RECORDS FOR REQUEST 2
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

    -- 13. SEED CALIBRATION 1 (SUCCESSFUL PASS -> CALIBRATED) - STEP 3
    IF v_req2_item1_id IS NOT NULL THEN
        INSERT INTO calibrations (
            tenant_id, organization_id, request_id, request_item_id, calibration_number,
            calibrated_by, calibration_date, calibration_method, calibration_location,
            result, outcome, remarks, calibration_frequency, next_due_date
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item1_id, 'CAL-000001',
            v_agent_user_id, NOW() - INTERVAL '1 hour', 'IS 2288:2002 / Standard Block Procedure', 'In-House Dimensional Lab 1',
            'PASS', 'CALIBRATED', 'Calibration completed cleanly within specified tolerances.', 365, NOW() + INTERVAL '365 days'
        )
        ON CONFLICT (tenant_id, organization_id, calibration_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_cal1_id;

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
            NOW(), v_agent_user_id, 'certificates/2026/CAL-000001.pdf'
        )
        ON CONFLICT (tenant_id, organization_id, certificate_number) DO UPDATE SET updated_at = NOW();
    END IF;

    -- 14. SEED CALIBRATION 2 (FAILED TEST -> FAULTY) - STEP 3
    IF v_req1_item1_id IS NOT NULL THEN
        INSERT INTO calibrations (
            tenant_id, organization_id, request_id, request_item_id, calibration_number,
            calibrated_by, calibration_date, calibration_method, calibration_location,
            result, outcome, remarks, calibration_frequency, next_due_date
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item1_id, 'CAL-000002',
            v_agent_user_id, NOW() - INTERVAL '30 minutes', 'IEEE-STD-120 / Electrical Multimeter Procedure', 'In-House Electrical Lab 2',
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
    END IF;

    -- 15. SEED FAULTY SERVICE RECORD 1 (ACTIVE IN_SERVICE TICKET) - STEP 4
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
            'Item handed over to Internal Electrical Service Lab Team', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, service_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_faulty1_id;
    END IF;

    -- 16. SEED FAULTY SERVICE RECORD 2 (COMPLETED SERVICE TICKET) - STEP 4
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
            'Pointer re-zeroed and verified against dead weight tester', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, service_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_faulty2_id;
    END IF;

    -- 17. SEED VENDOR OUTSOURCING RECORD 1 (ACTIVE IN_PROGRESS OUTSOURCING) - STEP 4
    IF v_req1_item3_id IS NOT NULL AND v_vendor_apex IS NOT NULL THEN
        INSERT INTO vendor_outsourcing (
            tenant_id, organization_id, request_id, request_item_id, vendor_id,
            outsourcing_number, outsourcing_reason, vendor_reference_number,
            sent_date, expected_return_date, outsourcing_status, vendor_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_req1_item3_id, v_vendor_apex,
            'VO-2026-000001', 'High temperature primary standard calibration requires NABL accredited external vendor',
            'APEX-REF-99210', NOW() - INTERVAL '1 day', NOW() + INTERVAL '5 days',
            'IN_PROGRESS', 'Dispatched via secure courier under tracking #APX-4412', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, outsourcing_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_outsourcing1_id;
    END IF;

    -- 18. SEED VENDOR OUTSOURCING RECORD 2 (RETURNED FROM VENDOR) - STEP 4
    IF v_req2_item1_id IS NOT NULL AND v_vendor_natmet IS NOT NULL THEN
        INSERT INTO vendor_outsourcing (
            tenant_id, organization_id, request_id, request_item_id, vendor_id,
            outsourcing_number, outsourcing_reason, vendor_reference_number,
            sent_date, expected_return_date, actual_return_date, outsourcing_status, vendor_notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_req2_item1_id, v_vendor_natmet,
            'VO-2026-000002', 'Specialized laser interferometer dimensional calibration',
            'NATMET-CERT-5012', NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day', NOW() - INTERVAL '3 hours',
            'RETURNED', 'Item returned along with vendor calibration certificate #NATMET-CERT-5012', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, outsourcing_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_outsourcing2_id;
    END IF;

    -- 19. SEED QUOTATIONS (STEP 5)
    -- Quotation 1: DRAFT
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000001',
            1, NOW(), NOW() + INTERVAL '30 days', 'DRAFT', 'INR',
            4900.00, 0.00, 882.00, 5782.00, 'Commercial quotation draft for annual calibration services', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, quotation_number, quotation_version) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_quot1_id;

        INSERT INTO quotation_items (
            tenant_id, organization_id, quotation_id, request_id, request_item_id, item_master_id,
            item_type, description, quantity, unit_price, discount_amount, tax_rate, tax_amount, line_total
        ) VALUES
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item1_id, v_item_dmm, 'CALIBRATION', 'Calibration of Digital Multimeter (Fluke 87V)', 1, 1500.00, 0.00, 18.00, 270.00, 1770.00),
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item2_id, v_item_pg, 'CALIBRATION', 'Calibration of Pressure Gauges (WIKA 232.50)', 2, 450.00, 0.00, 18.00, 162.00, 1062.00),
        (v_tenant_id, v_org_id, v_quot1_id, v_req1_id, v_req1_item3_id, v_item_ts, 'OUTSOURCING', 'NABL Accredited Vendor Outsourced Primary Standard Calibration', 1, 2500.00, 0.00, 18.00, 450.00, 2950.00)
        ON CONFLICT DO NOTHING;
    END IF;

    -- Quotation 2: UNDER_APPROVAL
    IF v_req2_id IS NOT NULL AND v_client_precision IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_client_precision, 'QT-2026-000002',
            1, NOW() - INTERVAL '2 hours', NOW() + INTERVAL '15 days', 'UNDER_APPROVAL', 'INR',
            320.00, 0.00, 57.60, 377.60, 'Urgent calibration proposal for Mitutoyo Vernier Caliper', v_agent_user_id
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

        INSERT INTO approvals (
            tenant_id, organization_id, quotation_id, request_id, approval_level,
            approver_user_id, approval_status, submitted_at
        ) VALUES (
            v_tenant_id, v_org_id, v_quot2_id, v_req2_id, 1,
            v_agent_user_id, 'PENDING', NOW() - INTERVAL '2 hours'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Quotation 3: APPROVED
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000003',
            1, NOW() - INTERVAL '1 day', NOW() + INTERVAL '30 days', 'APPROVED', 'INR',
            3500.00, 500.00, 540.00, 3540.00, 'Approved commercial contract for batch testing', v_agent_user_id
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
        ON CONFLICT DO NOTHING RETURNING id INTO v_quot3_item1_id;

        INSERT INTO approvals (
            tenant_id, organization_id, quotation_id, request_id, approval_level,
            approver_user_id, approval_status, submitted_at, action_at, comments
        ) VALUES (
            v_tenant_id, v_org_id, v_quot3_id, v_req1_id, 1,
            v_agent_user_id, 'APPROVED', NOW() - INTERVAL '1 day', NOW() - INTERVAL '20 hours', 'Approved special commercial discount.'
        )
        ON CONFLICT DO NOTHING;
    END IF;

    -- Additional Approved Quotations (QT-5, QT-6, QT-7) for Step 6
    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000005',
            1, NOW() - INTERVAL '5 days', NOW() + INTERVAL '25 days', 'APPROVED', 'INR',
            4000.00, 0.00, 720.00, 4720.00, 'Approved commercial contract for pressure calibration', v_agent_user_id
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

    IF v_req2_id IS NOT NULL AND v_client_precision IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_client_precision, 'QT-2026-000006',
            1, NOW() - INTERVAL '4 days', NOW() + INTERVAL '26 days', 'APPROVED', 'INR',
            2000.00, 0.00, 360.00, 2360.00, 'Approved caliper calibration contract', v_agent_user_id
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

    IF v_req1_id IS NOT NULL AND v_client_abc IS NOT NULL THEN
        INSERT INTO quotations (
            tenant_id, organization_id, request_id, client_id, quotation_number,
            quotation_version, quotation_date, valid_until, quotation_status, currency,
            subtotal, discount_amount, tax_amount, total_amount, notes, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_client_abc, 'QT-2026-000007',
            1, NOW() - INTERVAL '3 days', NOW() + INTERVAL '27 days', 'APPROVED', 'INR',
            5000.00, 500.00, 810.00, 5310.00, 'Approved full plant equipment calibration package', v_agent_user_id
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

    IF v_quot3_item1_id IS NULL THEN SELECT id INTO v_quot3_item1_id FROM quotation_items WHERE quotation_id = v_quot3_id LIMIT 1; END IF;
    IF v_quot5_item1_id IS NULL THEN SELECT id INTO v_quot5_item1_id FROM quotation_items WHERE quotation_id = v_quot5_id LIMIT 1; END IF;
    IF v_quot6_item1_id IS NULL THEN SELECT id INTO v_quot6_item1_id FROM quotation_items WHERE quotation_id = v_quot6_id LIMIT 1; END IF;
    IF v_quot7_item1_id IS NULL THEN SELECT id INTO v_quot7_item1_id FROM quotation_items WHERE quotation_id = v_quot7_id LIMIT 1; END IF;

    -- 20. SEED INVOICES (STEP 6)
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
            'Draft Commercial Invoice for approved calibration work', 'Payment due within 30 days', v_agent_user_id
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
            'Issued Commercial Invoice for pressure calibration batch', 'Payment due within 30 days', v_agent_user_id
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
            'Partially Paid Invoice for Caliper Calibration', 'Remaining balance due in 20 days', v_agent_user_id
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
            'Fully Paid Commercial Invoice', 'Paid in full via Bank Transfer', v_agent_user_id
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

    -- 21. SEED PURCHASE ORDERS (STEP 6)
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
            'Draft Purchase Order for approved calibration order', 'Subject to client commercial approval', v_agent_user_id
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
            'Issued Purchase Order for pressure gauge calibration batch', 'Standard delivery terms apply', v_agent_user_id
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
            'Partially Received Purchase Order for Caliper Calibration', 'First lot received at lab', v_agent_user_id
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
            'Fully Received Purchase Order for plant instrumentation', 'All items received and verified', v_agent_user_id
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

    IF v_inv1_id IS NULL THEN SELECT id INTO v_inv1_id FROM invoices WHERE invoice_number = 'INV-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv2_id IS NULL THEN SELECT id INTO v_inv2_id FROM invoices WHERE invoice_number = 'INV-2026-000002' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv3_id IS NULL THEN SELECT id INTO v_inv3_id FROM invoices WHERE invoice_number = 'INV-2026-000003' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_inv4_id IS NULL THEN SELECT id INTO v_inv4_id FROM invoices WHERE invoice_number = 'INV-2026-000004' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    IF v_po1_id IS NULL THEN SELECT id INTO v_po1_id FROM purchase_orders WHERE po_number = 'PO-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po2_id IS NULL THEN SELECT id INTO v_po2_id FROM purchase_orders WHERE po_number = 'PO-2026-000002' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po3_id IS NULL THEN SELECT id INTO v_po3_id FROM purchase_orders WHERE po_number = 'PO-2026-000003' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_po4_id IS NULL THEN SELECT id INTO v_po4_id FROM purchase_orders WHERE po_number = 'PO-2026-000004' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    -- 22. AUDIT LOG ENTRIES (STEPS 1 - 6)
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_CREATED', 'calibration_requests', v_req1_id, jsonb_build_object('request_number', 'CAL-REQ-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_SUBMITTED', 'calibration_requests', v_req1_id, jsonb_build_object('request_number', 'CAL-REQ-000001', 'status', 'LAB_QUEUE')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_CREATED', 'calibration_requests', v_req2_id, jsonb_build_object('request_number', 'CAL-REQ-000002', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_SUBMITTED', 'calibration_requests', v_req2_id, jsonb_build_object('request_number', 'CAL-REQ-000002', 'status', 'VERIFICATION')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_VERIFIED', 'verifications', v_req2_item1_id, jsonb_build_object('result', 'VERIFIED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_DISCREPANCY', 'verifications', v_req2_item2_id, jsonb_build_object('result', 'DISCREPANCY', 'reason', 'Serial mismatch')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CALIBRATION_CREATED', 'calibrations', v_cal1_id, jsonb_build_object('calibration_number', 'CAL-000001', 'result', 'PASS')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CALIBRATION_RESULT_RECORDED', 'calibrations', v_cal1_id, jsonb_build_object('outcome', 'CALIBRATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CERTIFICATE_ISSUED', 'certificates', v_cal1_id, jsonb_build_object('certificate_number', 'CERT-2026-000001')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CALIBRATION_CREATED', 'calibrations', v_cal2_id, jsonb_build_object('calibration_number', 'CAL-000002', 'result', 'FAIL')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CALIBRATION_OUTCOME_CHANGED', 'calibrations', v_cal2_id, jsonb_build_object('outcome', 'FAULTY')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'FAULTY_ITEM_CREATED', 'faulty_services', v_faulty1_id, jsonb_build_object('service_number', 'FS-2026-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'FAULTY_SERVICE_STARTED', 'faulty_services', v_faulty1_id, jsonb_build_object('service_number', 'FS-2026-000001', 'status', 'IN_SERVICE')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'FAULTY_SERVICE_COMPLETED', 'faulty_services', v_faulty2_id, jsonb_build_object('service_number', 'FS-2026-000002', 'status', 'SERVICE_COMPLETED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_OUTSOURCED', 'vendor_outsourcing', v_outsourcing1_id, jsonb_build_object('outsourcing_number', 'VO-2026-000001', 'status', 'CREATED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'SENT_TO_VENDOR', 'vendor_outsourcing', v_outsourcing1_id, jsonb_build_object('outsourcing_number', 'VO-2026-000001', 'status', 'IN_PROGRESS')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'ITEM_RETURNED_FROM_VENDOR', 'vendor_outsourcing', v_outsourcing2_id, jsonb_build_object('outsourcing_number', 'VO-2026-000002', 'status', 'RETURNED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'INVOICE_CREATED', 'invoices', v_inv1_id, jsonb_build_object('invoice_number', 'INV-2026-000001', 'status', 'DRAFT')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'INVOICE_ISSUED', 'invoices', v_inv2_id, jsonb_build_object('invoice_number', 'INV-2026-000002', 'status', 'ISSUED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'INVOICE_MARKED_PARTIALLY_PAID', 'invoices', v_inv3_id, jsonb_build_object('invoice_number', 'INV-2026-000003', 'status', 'PARTIALLY_PAID', 'paid_amount', 1000.00)),
    (v_tenant_id, v_org_id, v_agent_user_id, 'INVOICE_MARKED_PAID', 'invoices', v_inv4_id, jsonb_build_object('invoice_number', 'INV-2026-000004', 'status', 'PAID', 'paid_amount', 5310.00)),
    (v_tenant_id, v_org_id, v_agent_user_id, 'PO_CREATED', 'purchase_orders', v_po1_id, jsonb_build_object('po_number', 'PO-2026-000001', 'status', 'DRAFT')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'PO_ISSUED', 'purchase_orders', v_po2_id, jsonb_build_object('po_number', 'PO-2026-000002', 'status', 'ISSUED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'PO_PARTIALLY_RECEIVED', 'purchase_orders', v_po3_id, jsonb_build_object('po_number', 'PO-2026-000003', 'status', 'PARTIALLY_RECEIVED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'PO_RECEIVED', 'purchase_orders', v_po4_id, jsonb_build_object('po_number', 'PO-2026-000004', 'status', 'RECEIVED'));

    -- 23. SEED SIGNATURES (STEP 7)
    IF v_req1_id IS NOT NULL THEN
        INSERT INTO signatures (
            tenant_id, organization_id, request_id, signature_type, signed_by_name,
            signed_by_user_id, signature_status, signed_at, signature_reference, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'CLIENT_INVOICE', 'Rajesh Kumar (Client Rep)',
            v_agent_user_id, 'SIGNED', NOW() - INTERVAL '2 days', 'SIG-REF-INV-9901', 'Commercial invoice approved and signed digitally by client.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_sig1_id;

        INSERT INTO signatures (
            tenant_id, organization_id, request_id, signature_type, signed_by_name,
            signed_by_user_id, signature_status, signed_at, signature_reference, remarks
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'CLIENT_DELIVERY', 'Rajesh Kumar (Client Rep)',
            v_agent_user_id, 'SIGNED', NOW() - INTERVAL '4 hours', 'SIG-REF-DEL-8802', 'Received items in good physical condition and signed delivery acknowledgement.'
        )
        ON CONFLICT DO NOTHING RETURNING id INTO v_sig2_id;
    END IF;

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

    -- 24. SEED DISPATCHES (STEP 7)
    IF v_req1_id IS NOT NULL THEN
        INSERT INTO dispatches (
            tenant_id, organization_id, request_id, dispatch_number, dispatch_date,
            dispatch_status, courier_name, tracking_number, tracking_url,
            expected_delivery_date, actual_dispatch_date, remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, 'DSP-2026-000001', NOW() - INTERVAL '1 day',
            'DELIVERED', 'BlueDart Express', 'BD-99201142', 'https://bluedart.example.com/track/BD-99201142',
            NOW() - INTERVAL '4 hours', NOW() - INTERVAL '1 day', 'Dispatched calibrated multimeters & pressure gauges under secure packing', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, dispatch_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_dsp1_id;

        IF v_dsp1_id IS NOT NULL THEN
            INSERT INTO dispatch_items (
                tenant_id, organization_id, dispatch_id, request_id, request_item_id, item_master_id, quantity, remarks
            ) VALUES
            (v_tenant_id, v_org_id, v_dsp1_id, v_req1_id, v_req1_item1_id, v_item_dmm, 1, 'Fluke 87V DMM packed in hardcase'),
            (v_tenant_id, v_org_id, v_dsp1_id, v_req1_id, v_req1_item2_id, v_item_pg, 2, 'WIKA Pressure Gauges packed in foam box')
            ON CONFLICT DO NOTHING;
        END IF;
    END IF;

    IF v_req2_id IS NOT NULL THEN
        INSERT INTO dispatches (
            tenant_id, organization_id, request_id, dispatch_number, dispatch_date,
            dispatch_status, courier_name, remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, 'DSP-2026-000002', NOW(),
            'DRAFT', 'Professional Couriers', 'Draft dispatch note for Vernier Caliper return', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, dispatch_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_dsp2_id;
    END IF;

    -- 25. SEED DELIVERIES (STEP 7)
    IF v_req1_id IS NOT NULL AND v_dsp1_id IS NOT NULL THEN
        INSERT INTO deliveries (
            tenant_id, organization_id, request_id, dispatch_id, delivery_number,
            delivery_date, delivery_status, received_by_name, received_by_contact, delivery_remarks, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req1_id, v_dsp1_id, 'DEL-2026-000001',
            NOW() - INTERVAL '4 hours', 'DELIVERY_SIGNED', 'Rajesh Kumar', '+91 98400 12345',
            'Delivered and verified in-person at ABC Engineering plant receiving dock', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, delivery_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_del1_id;
    END IF;

    IF v_req2_id IS NOT NULL AND v_dsp2_id IS NOT NULL THEN
        INSERT INTO deliveries (
            tenant_id, organization_id, request_id, dispatch_id, delivery_number,
            delivery_date, delivery_status, created_by
        ) VALUES (
            v_tenant_id, v_org_id, v_req2_id, v_dsp2_id, 'DEL-2026-000002',
            NOW(), 'PENDING', v_agent_user_id
        )
        ON CONFLICT (tenant_id, organization_id, delivery_number) DO UPDATE SET updated_at = NOW()
        RETURNING id INTO v_del2_id;
    END IF;

    -- 26. EXECUTE SERVER-CONTROLLED FINAL REQUEST COMPLETION FOR REQUEST 1
    IF v_req1_id IS NOT NULL THEN
        PERFORM complete_calibration_request(v_req1_id, v_agent_user_id);
    END IF;

    IF v_sig1_id IS NULL THEN SELECT id INTO v_sig1_id FROM signatures WHERE request_id = v_req1_id AND signature_type = 'CLIENT_INVOICE' LIMIT 1; END IF;
    IF v_sig2_id IS NULL THEN SELECT id INTO v_sig2_id FROM signatures WHERE request_id = v_req1_id AND signature_type = 'CLIENT_DELIVERY' LIMIT 1; END IF;
    IF v_dsp1_id IS NULL THEN SELECT id INTO v_dsp1_id FROM dispatches WHERE dispatch_number = 'DSP-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;
    IF v_del1_id IS NULL THEN SELECT id INTO v_del1_id FROM deliveries WHERE delivery_number = 'DEL-2026-000001' AND tenant_id = v_tenant_id LIMIT 1; END IF;

    -- 27. AUDIT LOG ENTRIES (STEP 7)
    INSERT INTO audit_logs (tenant_id, organization_id, user_id, action, entity_type, entity_id, new_data) VALUES
    (v_tenant_id, v_org_id, v_agent_user_id, 'CLIENT_SIGNATURE_SIGNED', 'signatures', v_sig1_id, jsonb_build_object('signature_type', 'CLIENT_INVOICE', 'signed_by', 'Rajesh Kumar')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'DISPATCH_CREATED', 'dispatches', v_dsp1_id, jsonb_build_object('dispatch_number', 'DSP-2026-000001', 'status', 'READY')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'DISPATCHED', 'dispatches', v_dsp1_id, jsonb_build_object('dispatch_number', 'DSP-2026-000001', 'status', 'DISPATCHED', 'courier', 'BlueDart')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'DELIVERY_CREATED', 'deliveries', v_del1_id, jsonb_build_object('delivery_number', 'DEL-2026-000001', 'status', 'PENDING')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'CLIENT_RECEIVED', 'deliveries', v_del1_id, jsonb_build_object('delivery_number', 'DEL-2026-000001', 'status', 'CLIENT_RECEIVED')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'DELIVERY_SIGNATURE_SIGNED', 'signatures', v_sig2_id, jsonb_build_object('signature_type', 'CLIENT_DELIVERY', 'signed_by', 'Rajesh Kumar')),
    (v_tenant_id, v_org_id, v_agent_user_id, 'REQUEST_MARKED_READY_TO_DISPATCH', 'calibration_requests', v_req1_id, jsonb_build_object('request_id', v_req1_id, 'status', 'READY_TO_DISPATCH'));

END $$;

