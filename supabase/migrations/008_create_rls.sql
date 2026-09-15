-- Migration 008: Row Level Security (RLS) Foundation

-- Context Helper Functions (SECURITY DEFINER allows reading profile context safely)
CREATE OR REPLACE FUNCTION current_user_tenant_id()
RETURNS UUID AS $$
    SELECT tenant_id FROM user_profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_organization_id()
RETURNS UUID AS $$
    SELECT organization_id FROM user_profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION current_user_profile_id()
RETURNS UUID AS $$
    SELECT id FROM user_profiles WHERE auth_user_id = auth.uid() LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Enable RLS on all application tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE item_masters ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Tenants Policy (Users can access their assigned tenant)
DROP POLICY IF EXISTS tenants_isolation_policy ON tenants;
CREATE POLICY tenants_isolation_policy ON tenants
    FOR ALL USING (id = current_user_tenant_id());

-- Organizations Policy (Tenant scoped access)
DROP POLICY IF EXISTS organizations_isolation_policy ON organizations;
CREATE POLICY organizations_isolation_policy ON organizations
    FOR ALL USING (tenant_id = current_user_tenant_id());

-- User Profiles Policy (Tenant & Org isolated)
DROP POLICY IF EXISTS user_profiles_isolation_policy ON user_profiles;
CREATE POLICY user_profiles_isolation_policy ON user_profiles
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

-- Roles Policy (Tenant scoped access)
DROP POLICY IF EXISTS roles_isolation_policy ON roles;
CREATE POLICY roles_isolation_policy ON roles
    FOR ALL USING (tenant_id = current_user_tenant_id());

-- Permissions Policy (Readable by any authenticated user)
DROP POLICY IF EXISTS permissions_read_policy ON permissions;
CREATE POLICY permissions_read_policy ON permissions
    FOR SELECT TO authenticated USING (true);

-- User Roles Policy (Tenant & Org isolated)
DROP POLICY IF EXISTS user_roles_isolation_policy ON user_roles;
CREATE POLICY user_roles_isolation_policy ON user_roles
    FOR ALL USING (
        user_id IN (
            SELECT id FROM user_profiles 
            WHERE tenant_id = current_user_tenant_id() 
            AND organization_id = current_user_organization_id()
        )
    );

-- Role Permissions Policy (Tenant isolated via role link)
DROP POLICY IF EXISTS role_permissions_isolation_policy ON role_permissions;
CREATE POLICY role_permissions_isolation_policy ON role_permissions
    FOR ALL USING (
        role_id IN (
            SELECT id FROM roles 
            WHERE tenant_id = current_user_tenant_id()
        )
    );

-- Clients Policy (Tenant + Organization isolated)
DROP POLICY IF EXISTS clients_isolation_policy ON clients;
CREATE POLICY clients_isolation_policy ON clients
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

-- Vendors Policy (Tenant + Organization isolated)
DROP POLICY IF EXISTS vendors_isolation_policy ON vendors;
CREATE POLICY vendors_isolation_policy ON vendors
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

-- Item Masters Policy (Tenant + Organization isolated)
DROP POLICY IF EXISTS item_masters_isolation_policy ON item_masters;
CREATE POLICY item_masters_isolation_policy ON item_masters
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );

-- Audit Logs Policy (Tenant + Organization isolated)
DROP POLICY IF EXISTS audit_logs_isolation_policy ON audit_logs;
CREATE POLICY audit_logs_isolation_policy ON audit_logs
    FOR ALL USING (
        tenant_id = current_user_tenant_id() 
        AND organization_id = current_user_organization_id()
    );
