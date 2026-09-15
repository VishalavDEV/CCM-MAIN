-- Migration 032: Create Approvals Table

CREATE TABLE IF NOT EXISTS approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    quotation_id UUID NOT NULL REFERENCES quotations(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES calibration_requests(id) ON DELETE CASCADE,
    approval_level INTEGER NOT NULL DEFAULT 1 CHECK (approval_level > 0),
    approver_user_id UUID REFERENCES user_profiles(id) ON DELETE SET NULL,
    approval_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED')),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    action_at TIMESTAMPTZ,
    comments TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_approvals_updated_at ON approvals;
CREATE TRIGGER update_approvals_updated_at
BEFORE UPDATE ON approvals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
