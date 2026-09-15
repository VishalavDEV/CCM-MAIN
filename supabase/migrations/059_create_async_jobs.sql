-- Migration 059: Create async_jobs Table

CREATE TABLE IF NOT EXISTS async_jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    job_type VARCHAR(100) NOT NULL CHECK (job_type IN (
        'GENERATE_CALIBRATION_CERTIFICATE',
        'GENERATE_QUOTATION_PDF',
        'GENERATE_INVOICE_PDF',
        'GENERATE_PURCHASE_ORDER_PDF'
    )),
    entity_type VARCHAR(50) NOT NULL CHECK (entity_type IN (
        'CERTIFICATE',
        'QUOTATION',
        'INVOICE',
        'PURCHASE_ORDER'
    )),
    entity_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'QUEUED' CHECK (status IN (
        'QUEUED',
        'PROCESSING',
        'COMPLETED',
        'FAILED',
        'CANCELLED'
    )),
    attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
    max_attempts INTEGER NOT NULL DEFAULT 3 CHECK (max_attempts > 0),
    requested_by UUID NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    error_code VARCHAR(100),
    error_message TEXT,
    result_metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_async_jobs_updated_at ON async_jobs;
CREATE TRIGGER update_async_jobs_updated_at
BEFORE UPDATE ON async_jobs
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
