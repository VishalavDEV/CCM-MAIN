-- Migration 014: Create Step 2 Performance & Isolation Indexes

-- Calibration Requests Indexes
CREATE INDEX IF NOT EXISTS idx_cal_req_tenant_req_num ON calibration_requests(tenant_id, request_number);
CREATE INDEX IF NOT EXISTS idx_cal_req_tenant_client ON calibration_requests(tenant_id, client_id);
CREATE INDEX IF NOT EXISTS idx_cal_req_tenant_status ON calibration_requests(tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_cal_req_tenant_org_status ON calibration_requests(tenant_id, organization_id, status);
CREATE INDEX IF NOT EXISTS idx_cal_req_tenant_created ON calibration_requests(tenant_id, created_at);

-- Request Items Indexes
CREATE INDEX IF NOT EXISTS idx_req_items_request_id ON request_items(request_id);
CREATE INDEX IF NOT EXISTS idx_req_items_tenant_org ON request_items(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_req_items_tenant_status ON request_items(tenant_id, status);
CREATE INDEX IF NOT EXISTS idx_req_items_item_master ON request_items(item_master_id);

-- Verification Indexes
CREATE INDEX IF NOT EXISTS idx_verifications_req_item ON verifications(request_item_id);
CREATE INDEX IF NOT EXISTS idx_verifications_request_id ON verifications(request_id);
CREATE INDEX IF NOT EXISTS idx_verifications_tenant_org ON verifications(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_verifications_result ON verifications(tenant_id, result);
