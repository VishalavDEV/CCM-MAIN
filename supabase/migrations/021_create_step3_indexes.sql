-- Migration 021: Create Step 3 Performance & Isolation Indexes

-- Calibrations Indexes
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_cal_num ON calibrations(tenant_id, calibration_number);
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_req ON calibrations(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_req_item ON calibrations(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_due ON calibrations(tenant_id, next_due_date);
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_cal_date ON calibrations(tenant_id, calibration_date);
CREATE INDEX IF NOT EXISTS idx_calibrations_tenant_org_due ON calibrations(tenant_id, organization_id, next_due_date);

-- Calibration Measurements Indexes
CREATE INDEX IF NOT EXISTS idx_cal_measurements_cal_id ON calibration_measurements(calibration_id);
CREATE INDEX IF NOT EXISTS idx_cal_measurements_tenant_org ON calibration_measurements(tenant_id, organization_id);

-- Certificates Indexes
CREATE INDEX IF NOT EXISTS idx_certificates_cal_id ON certificates(calibration_id);
CREATE INDEX IF NOT EXISTS idx_certificates_tenant_cert_num ON certificates(tenant_id, certificate_number);
CREATE INDEX IF NOT EXISTS idx_certificates_tenant_org ON certificates(tenant_id, organization_id);
