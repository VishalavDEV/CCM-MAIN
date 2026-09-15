-- Migration 009: Seed Initial Master Data & RBAC Setup

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

    -- 3. SEED ALL GRANULAR PERMISSIONS
    INSERT INTO permissions (code, name, description, module) VALUES
    -- Organization
    ('ORGANIZATION_VIEW', 'View Organization Details', 'Allows viewing organization details and settings', 'Organization'),
    ('ORGANIZATION_UPDATE', 'Update Organization Details', 'Allows updating organization profile and settings', 'Organization'),
    -- Users
    ('USER_VIEW', 'View User Profiles', 'Allows viewing user profiles and roles', 'Users'),
    ('USER_CREATE', 'Create User Profiles', 'Allows adding new user profiles', 'Users'),
    ('USER_UPDATE', 'Update User Profiles', 'Allows modifying user profiles', 'Users'),
    ('USER_DELETE', 'Delete User Profiles', 'Allows removing user profiles', 'Users'),
    -- Clients
    ('CLIENT_VIEW', 'View Clients', 'Allows viewing client master data', 'Clients'),
    ('CLIENT_CREATE', 'Create Clients', 'Allows adding new clients', 'Clients'),
    ('CLIENT_UPDATE', 'Update Clients', 'Allows modifying client details', 'Clients'),
    ('CLIENT_DELETE', 'Delete Clients', 'Allows removing client records', 'Clients'),
    -- Vendors
    ('VENDOR_VIEW', 'View Vendors', 'Allows viewing vendor master data', 'Vendors'),
    ('VENDOR_CREATE', 'Create Vendors', 'Allows adding new vendors', 'Vendors'),
    ('VENDOR_UPDATE', 'Update Vendors', 'Allows modifying vendor details', 'Vendors'),
    ('VENDOR_DELETE', 'Delete Vendors', 'Allows removing vendor records', 'Vendors'),
    -- Items
    ('ITEM_VIEW', 'View Items', 'Allows viewing item master records', 'Items'),
    ('ITEM_CREATE', 'Create Items', 'Allows adding new calibration items', 'Items'),
    ('ITEM_UPDATE', 'Update Items', 'Allows modifying item master details', 'Items'),
    ('ITEM_DELETE', 'Delete Items', 'Allows removing item records', 'Items'),
    -- Requests
    ('REQUEST_VIEW', 'View Calibration Requests', 'Allows viewing calibration requests', 'Requests'),
    ('REQUEST_CREATE', 'Create Calibration Request', 'Allows creating new calibration requests', 'Requests'),
    ('REQUEST_UPDATE', 'Update Calibration Request', 'Allows modifying existing calibration requests', 'Requests'),
    ('REQUEST_SUBMIT', 'Submit Calibration Request', 'Allows submitting requests for verification/lab processing', 'Requests'),
    -- Verification
    ('VERIFICATION_VIEW', 'View Verifications', 'Allows viewing verification tasks and results', 'Verification'),
    ('VERIFICATION_CREATE', 'Create Verification Task', 'Allows creating verification entries', 'Verification'),
    ('VERIFICATION_UPDATE', 'Update Verification Task', 'Allows updating verification findings', 'Verification'),
    -- Calibration
    ('CALIBRATION_VIEW', 'View Calibration Process', 'Allows viewing lab calibration records', 'Calibration'),
    ('CALIBRATION_CREATE', 'Create Calibration Entry', 'Allows entering lab calibration measurements', 'Calibration'),
    ('CALIBRATION_UPDATE', 'Update Calibration Entry', 'Allows modifying calibration certificates/data', 'Calibration'),
    -- Documents
    ('DOCUMENT_VIEW', 'View Documents', 'Allows viewing attached documents and certificates', 'Documents'),
    ('DOCUMENT_UPLOAD', 'Upload Documents', 'Allows uploading documents and calibration sheets', 'Documents'),
    ('DOCUMENT_DELETE', 'Delete Documents', 'Allows removing uploaded documents', 'Documents'),
    -- Quotations
    ('QUOTATION_VIEW', 'View Quotations', 'Allows viewing commercial quotations', 'Quotations'),
    ('QUOTATION_CREATE', 'Create Quotation', 'Allows drafting quotations', 'Quotations'),
    ('QUOTATION_UPDATE', 'Update Quotation', 'Allows updating draft quotations', 'Quotations'),
    ('QUOTATION_APPROVE', 'Approve Quotation', 'Allows approving commercial quotations', 'Quotations'),
    -- Purchase Orders
    ('PO_VIEW', 'View Purchase Orders', 'Allows viewing purchase orders', 'Purchase Orders'),
    ('PO_CREATE', 'Create Purchase Order', 'Allows creating purchase orders', 'Purchase Orders'),
    ('PO_UPDATE', 'Update Purchase Order', 'Allows updating purchase orders', 'Purchase Orders'),
    -- Invoices
    ('INVOICE_VIEW', 'View Invoices', 'Allows viewing commercial invoices', 'Invoices'),
    ('INVOICE_CREATE', 'Create Invoice', 'Allows generating commercial invoices', 'Invoices'),
    ('INVOICE_UPDATE', 'Update Invoice', 'Allows modifying invoice details', 'Invoices'),
    -- Signatures
    ('SIGNATURE_VIEW', 'View Signatures', 'Allows viewing digital signatures', 'Signatures'),
    ('SIGNATURE_CREATE', 'Create Signature', 'Allows applying digital signatures', 'Signatures'),
    -- Dispatch
    ('DISPATCH_VIEW', 'View Dispatch Tasks', 'Allows viewing dispatch status', 'Dispatch'),
    ('DISPATCH_CREATE', 'Create Dispatch Entry', 'Allows generating dispatch documents', 'Dispatch'),
    ('DISPATCH_UPDATE', 'Update Dispatch Entry', 'Allows updating dispatch tracking details', 'Dispatch'),
    -- Delivery
    ('DELIVERY_VIEW', 'View Delivery Status', 'Allows viewing delivery receipts', 'Delivery'),
    ('DELIVERY_CREATE', 'Create Delivery Receipt', 'Allows logging proof of delivery', 'Delivery'),
    ('DELIVERY_UPDATE', 'Update Delivery Status', 'Allows updating delivery details', 'Delivery'),
    -- Audit
    ('AUDIT_VIEW', 'View Audit Logs', 'Allows inspecting system audit trails', 'Audit')
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

    -- ADMIN: All permissions
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_admin, p.id FROM permissions p
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- COLLECTION_AGENT
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_collection, p.id FROM permissions p
    WHERE p.code IN ('CLIENT_VIEW', 'ITEM_VIEW', 'REQUEST_VIEW', 'REQUEST_CREATE', 'REQUEST_UPDATE', 'REQUEST_SUBMIT')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- LAB_USER
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_lab, p.id FROM permissions p
    WHERE p.code IN ('ITEM_VIEW', 'REQUEST_VIEW', 'VERIFICATION_VIEW', 'VERIFICATION_CREATE', 'VERIFICATION_UPDATE', 'DOCUMENT_VIEW', 'DOCUMENT_UPLOAD', 'CALIBRATION_VIEW', 'CALIBRATION_CREATE', 'CALIBRATION_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- COMMERCIAL_USER
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_commercial, p.id FROM permissions p
    WHERE p.code IN ('CLIENT_VIEW', 'VENDOR_VIEW', 'REQUEST_VIEW', 'QUOTATION_VIEW', 'QUOTATION_CREATE', 'QUOTATION_UPDATE', 'PO_VIEW', 'PO_CREATE', 'PO_UPDATE', 'INVOICE_VIEW', 'INVOICE_CREATE', 'INVOICE_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- APPROVER
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_approver, p.id FROM permissions p
    WHERE p.code IN ('QUOTATION_VIEW', 'QUOTATION_APPROVE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- DISPATCH_USER
    INSERT INTO role_permissions (role_id, permission_id)
    SELECT v_role_dispatch, p.id FROM permissions p
    WHERE p.code IN ('INVOICE_VIEW', 'SIGNATURE_VIEW', 'SIGNATURE_CREATE', 'DISPATCH_VIEW', 'DISPATCH_CREATE', 'DISPATCH_UPDATE', 'DELIVERY_VIEW', 'DELIVERY_CREATE', 'DELIVERY_UPDATE')
    ON CONFLICT (role_id, permission_id) DO NOTHING;

    -- 6. SEED DEMO CLIENTS (5 realistic clients)
    INSERT INTO clients (tenant_id, organization_id, client_code, client_name, address, billing_address, gst_tax_number, contact_person, email, phone, status) VALUES
    (v_tenant_id, v_org_id, 'CL-001', 'ABC Engineering Pvt Ltd', 'Plot 45, Ambattur Industrial Estate, Chennai, TN', 'Plot 45, Ambattur Industrial Estate, Chennai, TN', '33AAACA1234A1Z5', 'Rajesh Kumar', 'rajesh@abceng.com', '+91 98400 12345', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-002', 'Chennai Industrial Systems', '12 Mount Road, Guindy, Chennai, TN', '12 Mount Road, Guindy, Chennai, TN', '33AABCC5678B1Z2', 'Srinivasan R', 'srinivasan@chennaisys.in', '+91 98410 23456', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-003', 'Precision Manufacturing India', 'Sector 3, SIPCOT Tech Park, Sriperumbudur, TN', 'Sector 3, SIPCOT Tech Park, Sriperumbudur, TN', '33AACCP9012C1Z9', 'Anand Verma', 'anand@precisionmfg.co.in', '+91 98420 34567', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-004', 'Southern Testing Labs', '88 GST Road, Chromepet, Chennai, TN', '88 GST Road, Chromepet, Chennai, TN', '33AAADS3456D1Z4', 'Dr. Meena Swaminathan', 'meena@southerntesting.org', '+91 98430 45678', 'ACTIVE'),
    (v_tenant_id, v_org_id, 'CL-005', 'Metro Automation Solutions', '56 IT Corridor, OMR, Perungudi, Chennai, TN', '56 IT Corridor, OMR, Perungudi, Chennai, TN', '33AAAEM7890E1Z1', 'Karthik Raja', 'karthik@metroauto.com', '+91 98440 56789', 'ACTIVE')
    ON CONFLICT (tenant_id, organization_id, client_code) DO UPDATE SET updated_at = NOW();

    -- 7. SEED DEMO VENDORS (5 realistic vendors)
    INSERT INTO vendors (tenant_id, organization_id, vendor_code, vendor_name, address, gst_tax_number, contact_person, email, phone, serviced_categories, status) VALUES
    (v_tenant_id, v_org_id, 'VN-001', 'Apex Calibration Standards Ltd', '22 Industrial Zone, Peenya, Bengaluru, KA', '29AAACA9988A1Z0', 'Venkatesh Rao', 'vrao@apexcal.com', '+91 80 2839 1100', ARRAY['Electrical', 'Thermal'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-002', 'Precision Instruments Supply', '14 SIDCO Estate, Hosur, TN', '33AABCP7766B1Z3', 'Pravin Shah', 'pravin@precisioninst.in', '+91 4344 240 500', ARRAY['Mechanical', 'Dimensional'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-003', 'National Metrology Components', '55 Wagle Estate, Thane, MH', '27AACCN5544C1Z6', 'Milind Kulkarni', 'milind@natmetrology.com', '+91 22 2582 9911', ARRAY['Pressure', 'Flow'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-004', 'Southern Sensor Tech', '90 Electronics Complex, Coimbatore, TN', '33AAADS3322D1Z8', 'Ganesh Moorthy', 'ganesh@sensortech.co.in', '+91 422 265 4321', ARRAY['Temperature', 'Environmental'], 'ACTIVE'),
    (v_tenant_id, v_org_id, 'VN-005', 'Transcat Calibration Services', '77 Central Park, Hyderabad, TS', '36AAAET1100E1Z2', 'Ramesh Reddy', 'ramesh@transcat.in', '+91 40 2300 8899', ARRAY['Mass', 'Torque'], 'ACTIVE')
    ON CONFLICT (tenant_id, organization_id, vendor_code) DO UPDATE SET updated_at = NOW();

    -- 8. SEED DEMO ITEM MASTERS (15 realistic items)
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

END $$;
