-- Migration 053: Create Documents Table

CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    request_id UUID REFERENCES calibration_requests(id) ON DELETE SET NULL,
    request_item_id UUID REFERENCES request_items(id) ON DELETE SET NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN (
        'VERIFICATION_PROOF',
        'CALIBRATION_DOCUMENT',
        'CALIBRATION_CERTIFICATE',
        'QUOTATION_DOCUMENT',
        'APPROVAL_DOCUMENT',
        'INVOICE_DOCUMENT',
        'PURCHASE_ORDER_DOCUMENT',
        'CLIENT_SIGNATURE',
        'DISPATCH_DOCUMENT',
        'DELIVERY_DOCUMENT',
        'OTHER'
    )),
    file_name VARCHAR(255) NOT NULL,
    file_extension VARCHAR(20),
    mime_type VARCHAR(100) NOT NULL,
    file_size BIGINT NOT NULL CHECK (file_size > 0),
    storage_provider VARCHAR(50) NOT NULL DEFAULT 'CLOUDFLARE_R2',
    storage_bucket VARCHAR(100) NOT NULL DEFAULT 'ccm-documents',
    storage_key TEXT NOT NULL,
    document_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (document_status IN (
        'UPLOADING',
        'UPLOADED',
        'ACTIVE',
        'REPLACED',
        'ARCHIVED',
        'DELETED'
    )),
    uploaded_by UUID NOT NULL REFERENCES user_profiles(id) ON DELETE RESTRICT,
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version INTEGER NOT NULL DEFAULT 1 CHECK (version > 0),
    is_current BOOLEAN NOT NULL DEFAULT true,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS update_documents_updated_at ON documents;
CREATE TRIGGER update_documents_updated_at
BEFORE UPDATE ON documents
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
