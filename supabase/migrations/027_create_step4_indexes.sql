-- Migration 027: Create Step 4 Performance & Isolation Indexes

CREATE INDEX IF NOT EXISTS idx_faulty_services_tenant_num ON faulty_services(tenant_id, service_number);
CREATE INDEX IF NOT EXISTS idx_faulty_services_tenant_org ON faulty_services(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_faulty_services_req ON faulty_services(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_faulty_services_req_item ON faulty_services(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_faulty_services_cal ON faulty_services(tenant_id, calibration_id);
CREATE INDEX IF NOT EXISTS idx_faulty_services_status ON faulty_services(tenant_id, service_status);

CREATE INDEX IF NOT EXISTS idx_outsourcing_tenant_num ON vendor_outsourcing(tenant_id, outsourcing_number);
CREATE INDEX IF NOT EXISTS idx_outsourcing_tenant_org ON vendor_outsourcing(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_outsourcing_req ON vendor_outsourcing(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_outsourcing_req_item ON vendor_outsourcing(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_outsourcing_vendor ON vendor_outsourcing(tenant_id, vendor_id);
CREATE INDEX IF NOT EXISTS idx_outsourcing_status ON vendor_outsourcing(tenant_id, outsourcing_status);
