-- Migration 061: Indexes for Async Jobs Table

CREATE INDEX IF NOT EXISTS idx_async_jobs_tenant_org ON async_jobs (tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_async_jobs_status ON async_jobs (status);
CREATE INDEX IF NOT EXISTS idx_async_jobs_type ON async_jobs (job_type);
CREATE INDEX IF NOT EXISTS idx_async_jobs_entity ON async_jobs (entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_async_jobs_created_at ON async_jobs (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_async_jobs_requested_by ON async_jobs (requested_by);
