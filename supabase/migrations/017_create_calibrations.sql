-- Migration 017: Create Calibrations Table & Number Sequence

CREATE SEQUENCE IF NOT EXISTS calibration_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE IF NOT EXISTS calibrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    request_item_id UUID NOT NULL REFERENCES request_items(id) ON DELETE CASCADE,
    calibration_number VARCHAR(50) NOT NULL,
    calibrated_by UUID NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
    calibration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    calibration_method VARCHAR(255),
    calibration_location VARCHAR(255),
    result VARCHAR(20) NOT NULL CHECK (result IN ('PASS', 'FAIL')),
    outcome VARCHAR(30) NOT NULL DEFAULT 'CALIBRATED' CHECK (outcome IN ('CALIBRATED', 'FAULTY', 'OUTSOURCED')),
    remarks TEXT,
    calibration_frequency INTEGER, -- frequency in days
    next_due_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_cal_num UNIQUE (tenant_id, organization_id, calibration_number)
);

-- Trigger for auto-generating calibration numbers (CAL-000001) & computing next_due_date
CREATE OR REPLACE FUNCTION generate_calibration_number()
RETURNS TRIGGER AS $$
DECLARE
    v_seq_num BIGINT;
BEGIN
    IF NEW.calibration_number IS NULL OR NEW.calibration_number = '' THEN
        v_seq_num := nextval('calibration_seq');
        NEW.calibration_number := 'CAL-' || LPAD(v_seq_num::TEXT, 6, '0');
    END IF;
    
    -- Calculate next_due_date if omitted and frequency is specified
    IF NEW.next_due_date IS NULL AND NEW.calibration_frequency IS NOT NULL AND NEW.calibration_frequency > 0 THEN
        NEW.next_due_date := NEW.calibration_date + (NEW.calibration_frequency || ' days')::INTERVAL;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_calibration_number ON calibrations;
CREATE TRIGGER trigger_generate_calibration_number
BEFORE INSERT ON calibrations
FOR EACH ROW
EXECUTE FUNCTION generate_calibration_number();

DROP TRIGGER IF EXISTS update_calibrations_updated_at ON calibrations;
CREATE TRIGGER update_calibrations_updated_at
BEFORE UPDATE ON calibrations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
