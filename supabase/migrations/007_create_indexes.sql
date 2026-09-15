-- Migration 007: Performance & Multi-Tenant Isolation Indexes

-- Organization indexes
CREATE INDEX IF NOT EXISTS idx_organizations_tenant_id ON organizations(tenant_id);

-- User Profile indexes
CREATE INDEX IF NOT EXISTS idx_user_profiles_tenant_org ON user_profiles(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_auth_user ON user_profiles(auth_user_id);

-- Role indexes
CREATE INDEX IF NOT EXISTS idx_roles_tenant_id ON roles(tenant_id);

-- User Roles & Role Permissions
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX IF NOT EXISTS idx_role_permissions_permission_id ON role_permissions(permission_id);

-- Client Master indexes
CREATE INDEX IF NOT EXISTS idx_clients_tenant_id ON clients(tenant_id);
CREATE INDEX IF NOT EXISTS idx_clients_tenant_org ON clients(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_clients_tenant_client_id ON clients(tenant_id, id);
CREATE INDEX IF NOT EXISTS idx_clients_tenant_code ON clients(tenant_id, client_code);
CREATE INDEX IF NOT EXISTS idx_clients_created_at ON clients(tenant_id, created_at);

-- Vendor Master indexes
CREATE INDEX IF NOT EXISTS idx_vendors_tenant_id ON vendors(tenant_id);
CREATE INDEX IF NOT EXISTS idx_vendors_tenant_org ON vendors(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_vendors_tenant_code ON vendors(tenant_id, vendor_code);

-- Item Master indexes
CREATE INDEX IF NOT EXISTS idx_item_masters_tenant_id ON item_masters(tenant_id);
CREATE INDEX IF NOT EXISTS idx_item_masters_tenant_org ON item_masters(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_item_masters_tenant_item_code ON item_masters(tenant_id, item_code);
CREATE INDEX IF NOT EXISTS idx_item_masters_tenant_serial ON item_masters(tenant_id, serial_number);
CREATE INDEX IF NOT EXISTS idx_item_masters_created_at ON item_masters(tenant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_item_masters_status ON item_masters(tenant_id, organization_id, status);

-- Audit Log indexes
CREATE INDEX IF NOT EXISTS idx_audit_logs_tenant_org ON audit_logs(tenant_id, organization_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON audit_logs(tenant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(tenant_id, entity_type, entity_id);
