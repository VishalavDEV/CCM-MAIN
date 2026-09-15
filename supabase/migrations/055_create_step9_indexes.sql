-- Migration 055: Step 9 Indexes for Document Storage Performance

CREATE INDEX IF NOT EXISTS idx_documents_tenant ON documents(tenant_id);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_org ON documents(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_request ON documents(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_req_item ON documents(tenant_id, request_item_id);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_type ON documents(tenant_id, document_type);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_status ON documents(tenant_id, document_status);
CREATE INDEX IF NOT EXISTS idx_documents_tenant_created ON documents(tenant_id, created_at DESC);
