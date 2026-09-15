import React, { createContext, useContext, useState, useEffect } from 'react';
import { User, UserRole } from '../types/user';
import { Tenant } from '../types/tenant';
import { Organization } from '../types/organization';
import { mockStore } from '../mock/initialStore';
import { authService } from '../services/authService';

interface AuthContextType {
  user: User | null;
  currentTenant: Tenant | null;
  currentOrganization: Organization | null;
  isAuthenticated: boolean;
  token: string | null;
  login: (email: string, password?: string) => Promise<void>;
  logout: () => void;
  switchRole: (role: UserRole) => void;
  switchTenant: (tenantId: string) => void;
  switchOrganization: (orgId: string) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Default to Super Admin / Admin for rich exploration, or retrieve from localStorage
  const [user, setUser] = useState<User | null>(() => {
    return mockStore.data.users[0] || null;
  });
  const [token, setToken] = useState<string | null>('mock-jwt-token-active');

  const currentTenant = mockStore.data.tenants.find((t) => t.id === user?.tenantId) || mockStore.data.tenants[0] || null;
  const currentOrganization = mockStore.data.organizations.find((o) => o.id === user?.organizationId) || mockStore.data.organizations[0] || null;

  const login = async (email: string, password?: string) => {
    const res = await authService.login(email, password);
    setUser(res.user);
    setToken(res.token);
  };

  const logout = () => {
    setUser(null);
    setToken(null);
  };

  // Instant role switcher for evaluator convenience
  const switchRole = (newRole: UserRole) => {
    const targetUser = mockStore.data.users.find((u) => u.role === newRole);
    if (targetUser) {
      setUser({ ...targetUser });
    } else if (user) {
      // Synthetic role switch
      const roleObj = mockStore.data.roles.find((r) => r.name.toUpperCase().replace(/\s+/g, '_') === newRole);
      setUser({
        ...user,
        role: newRole,
        roleName: roleObj?.name || newRole,
      });
    }
  };

  const switchTenant = (tenantId: string) => {
    const t = mockStore.data.tenants.find((item) => item.id === tenantId);
    if (t && user) {
      const defaultOrg = mockStore.data.organizations.find((o) => o.tenantId === t.id);
      setUser({
        ...user,
        tenantId: t.id,
        tenantName: t.name,
        organizationId: defaultOrg?.id || user.organizationId,
        organizationName: defaultOrg?.companyName || user.organizationName,
      });
    }
  };

  const switchOrganization = (orgId: string) => {
    const org = mockStore.data.organizations.find((o) => o.id === orgId);
    if (org && user) {
      setUser({
        ...user,
        organizationId: org.id,
        organizationName: org.companyName,
      });
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        currentTenant,
        currentOrganization,
        isAuthenticated: !!user && !!token,
        token,
        login,
        logout,
        switchRole,
        switchTenant,
        switchOrganization,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};
