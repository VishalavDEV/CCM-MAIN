-- Migration 034: Create Step 5 Performance & Isolation Indexes

CREATE INDEX IF NOT EXISTS idx_quotations_tenant_num ON quotations(tenant_id, quotation_number);
CREATE INDEX IF NOT EXISTS idx_quotations_tenant_org ON quotations(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_quotations_req ON quotations(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_quotations_client ON quotations(tenant_id, client_id);
CREATE INDEX IF NOT EXISTS idx_quotations_status ON quotations(tenant_id, quotation_status);

CREATE INDEX IF NOT EXISTS idx_quotation_items_quot_id ON quotation_items(tenant_id, quotation_id);
CREATE INDEX IF NOT EXISTS idx_quotation_items_req ON quotation_items(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_quotation_items_req_item ON quotation_items(tenant_id, request_item_id);

CREATE INDEX IF NOT EXISTS idx_approvals_quot_id ON approvals(tenant_id, quotation_id);
CREATE INDEX IF NOT EXISTS idx_approvals_req ON approvals(tenant_id, request_id);
CREATE INDEX IF NOT EXISTS idx_approvals_approver ON approvals(tenant_id, approver_user_id);
CREATE INDEX IF NOT EXISTS idx_approvals_status ON approvals(tenant_id, approval_status);
