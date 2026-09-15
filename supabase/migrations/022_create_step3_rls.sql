-- Migration 022: Create Step 3 Row Level Security (RLS) Policies

ALTER TABLE calibrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE calibration_measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS calibrations_isolation_policy ON calibrations;
CREATE POLICY calibrations_isolation_policy ON calibrations
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS calibration_measurements_isolation_policy ON calibration_measurements;
CREATE POLICY calibration_measurements_isolation_policy ON calibration_measurements
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

DROP POLICY IF EXISTS certificates_isolation_policy ON certificates;
CREATE POLICY certificates_isolation_policy ON certificates
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
