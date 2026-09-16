import React, { createContext, useContext, useState } from 'react';
import { User, UserRole } from '../types/user';
import { Tenant } from '../types/tenant';
import { Organization } from '../types/organization';
import { authService, createUserForEmail } from '../services/authService';

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

const DEFAULT_TENANT: Tenant = {
  id: '00000000-0000-0000-0000-000000000001',
  name: 'Apex Metrology Group',
  code: 'APEX',
  status: 'ACTIVE',
  organizationsCount: 1,
  usersCount: 5,
  contactEmail: 'contact@apexmetrology.com',
  contactPhone: '+91 80 2845 0001',
  createdDate: '2025-01-15',
  updatedDate: '2026-09-10',
  description: 'Primary Calibration Laboratory Network'
};

const DEFAULT_ORGANIZATION: Organization = {
  id: '00000000-0000-0000-0000-000000000001',
  tenantId: '00000000-0000-0000-0000-000000000001',
  companyName: 'Apex Precision Labs Bangalore',
  companyCode: 'APX-BLR',
  companyType: 'Private Limited',
  businessType: 'Calibration',
  registrationNumber: 'U74999KA2020PTC139822',
  gstNumber: '29AAACA1234F1Z5',
  companyEmail: 'bangalore.lab@apexmetrology.com',
  companyPhone: '+91 80 4123 7890',
  addressLine1: 'Plot 42, Electronic City Phase 1',
  addressLine2: 'Hosur Road',
  city: 'Bengaluru',
  state: 'Karnataka',
  country: 'India',
  pincode: '560100',
  timezone: 'Asia/Kolkata (IST)',
  currency: 'INR (₹)',
  numberOfBranches: 1,
  numberOfWarehouses: 1,
  msmeNumber: 'UDYAM-KR-03-0028192',
  adminName: 'Nethra BV',
  adminEmail: 'bvnethra2005@gmail.com',
  status: 'ACTIVE',
  createdDate: '2025-02-01',
  usersCount: 5
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(() => {
    return createUserForEmail('bvnethra2005@gmail.com');
  });
  const [token, setToken] = useState<string | null>('mock-jwt-token-active');

  const [currentTenant, setCurrentTenant] = useState<Tenant | null>(DEFAULT_TENANT);
  const [currentOrganization, setCurrentOrganization] = useState<Organization | null>(DEFAULT_ORGANIZATION);

  const login = async (email: string, password?: string) => {
    const res = await authService.login(email, password);
    setUser(res.user);
    setToken(res.token);
  };

  const logout = () => {
    setUser(null);
    setToken(null);
  };

  const switchRole = (newRole: UserRole) => {
    if (!user) return;
    const roleName = newRole.replace('_', ' ').toLowerCase().replace(/\b\w/g, c => c.toUpperCase());
    setUser({
      ...user,
      role: newRole,
      roleName: `${roleName} User`
    });
  };

  const switchTenant = (tenantId: string) => {
    if (user) {
      setUser({
        ...user,
        tenantId,
        tenantName: 'Primary Tenant'
      });
    }
  };

  const switchOrganization = (orgId: string) => {
    if (user) {
      setUser({
        ...user,
        organizationId: orgId,
        organizationName: 'Primary Organization'
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
