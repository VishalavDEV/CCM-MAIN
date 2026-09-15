-- Migration 057: Step 9 Seed Data for Demo Documents Metadata

DO $$
DECLARE
    v_tenant_id UUID;
    v_org_id UUID;
    v_user_id UUID;
    v_request_id UUID;
    v_req_item_id UUID;
BEGIN
    SELECT id INTO v_tenant_id FROM tenants WHERE code = 'CAL-DEMO' LIMIT 1;
    SELECT id INTO v_org_id FROM organizations WHERE code = 'ORG-MAIN' LIMIT 1;
    SELECT id INTO v_user_id FROM user_profiles WHERE tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_request_id FROM calibration_requests WHERE tenant_id = v_tenant_id LIMIT 1;
    SELECT id INTO v_req_item_id FROM request_items WHERE tenant_id = v_tenant_id LIMIT 1;

    IF v_tenant_id IS NOT NULL AND v_org_id IS NOT NULL AND v_user_id IS NOT NULL AND v_request_id IS NOT NULL THEN
        -- Seed Verification Proof Document Metadata
        INSERT INTO documents (
            tenant_id, organization_id, request_id, request_item_id,
            document_type, file_name, file_extension, mime_type, file_size,
            storage_provider, storage_bucket, storage_key, document_status,
            uploaded_by, version, is_current, description
        ) VALUES (
            v_tenant_id, v_org_id, v_request_id, v_req_item_id,
            'VERIFICATION_PROOF', 'verification_proof_001.pdf', 'pdf', 'application/pdf', 245800,
            'CLOUDFLARE_R2', 'ccm-documents',
            'tenant/' || v_tenant_id || '/organization/' || v_org_id || '/requests/' || v_request_id || '/items/' || v_req_item_id || '/documents/demo_verification_proof.pdf',
            'ACTIVE', v_user_id, 1, true, 'Verification inspection proof photo & report'
        ) ON CONFLICT DO NOTHING;

        -- Seed Calibration Document Metadata
        INSERT INTO documents (
            tenant_id, organization_id, request_id, request_item_id,
            document_type, file_name, file_extension, mime_type, file_size,
            storage_provider, storage_bucket, storage_key, document_status,
            uploaded_by, version, is_current, description
        ) VALUES (
            v_tenant_id, v_org_id, v_request_id, v_req_item_id,
            'CALIBRATION_DOCUMENT', 'raw_calibration_datasheet.pdf', 'pdf', 'application/pdf', 512000,
            'CLOUDFLARE_R2', 'ccm-documents',
            'tenant/' || v_tenant_id || '/organization/' || v_org_id || '/requests/' || v_request_id || '/items/' || v_req_item_id || '/documents/demo_calibration_datasheet.pdf',
            'ACTIVE', v_user_id, 1, true, 'Raw lab measurement raw data sheet'
        ) ON CONFLICT DO NOTHING;
    END IF;
END $$;
