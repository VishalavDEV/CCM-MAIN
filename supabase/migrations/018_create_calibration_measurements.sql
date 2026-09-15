-- Migration 018: Create Calibration Measurements Table

CREATE TABLE IF NOT EXISTS calibration_measurements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    calibration_id UUID NOT NULL REFERENCES calibrations(id) ON DELETE CASCADE,
    parameter_name VARCHAR(255) NOT NULL,
    nominal_value NUMERIC(15, 4) NOT NULL,
    measured_value NUMERIC(15, 4) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    tolerance_min NUMERIC(15, 4) NOT NULL,
    tolerance_max NUMERIC(15, 4) NOT NULL,
    result VARCHAR(20) NOT NULL CHECK (result IN ('PASS', 'FAIL')),
    remarks TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_calibration_measurements_updated_at ON calibration_measurements;
CREATE TRIGGER update_calibration_measurements_updated_at
BEFORE UPDATE ON calibration_measurements
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
