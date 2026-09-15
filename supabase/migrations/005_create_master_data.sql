-- Migration 005: Create Master Data Tables (Clients, Vendors, Item Masters)

CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    client_code VARCHAR(50) NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    address TEXT,
    billing_address TEXT,
    gst_tax_number VARCHAR(50),
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_client_code UNIQUE (tenant_id, organization_id, client_code)
);

DROP TRIGGER IF EXISTS update_clients_updated_at ON clients;
CREATE TRIGGER update_clients_updated_at
BEFORE UPDATE ON clients
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    vendor_code VARCHAR(50) NOT NULL,
    vendor_name VARCHAR(255) NOT NULL,
    address TEXT,
    gst_tax_number VARCHAR(50),
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    serviced_categories TEXT[] DEFAULT '{}',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_vendor_code UNIQUE (tenant_id, organization_id, vendor_code)
);

DROP TRIGGER IF EXISTS update_vendors_updated_at ON vendors;
CREATE TRIGGER update_vendors_updated_at
BEFORE UPDATE ON vendors
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TABLE IF NOT EXISTS item_masters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    item_code VARCHAR(50) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_type VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(255),
    model VARCHAR(255),
    serial_number VARCHAR(100),
    measurement_range VARCHAR(255),
    least_count VARCHAR(100),
    standard_cost NUMERIC(12, 2) DEFAULT 0.00,
    calibration_frequency INTEGER, -- frequency in days
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'RETIRED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_tenant_org_item_code UNIQUE (tenant_id, organization_id, item_code),
    CONSTRAINT unique_tenant_org_serial UNIQUE (tenant_id, organization_id, serial_number)
);

DROP TRIGGER IF EXISTS update_item_masters_updated_at ON item_masters;
CREATE TRIGGER update_item_masters_updated_at
BEFORE UPDATE ON item_masters
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
