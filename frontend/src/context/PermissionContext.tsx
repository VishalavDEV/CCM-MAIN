import React, { createContext, useContext, useMemo } from 'react';
import { useAuth } from './AuthContext';
import { DEFAULT_ROLE_PERMISSIONS, PERMISSION_CODES } from '../constants/permissions';
import { mockStore } from '../mock/initialStore';

interface PermissionContextType {
  hasPermission: (permission: string) => boolean;
  can: (module: string, action: string) => boolean;
  userPermissions: string[];
}

const PermissionContext = createContext<PermissionContextType | undefined>(undefined);

export const PermissionProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { user } = useAuth();

  const userPermissions = useMemo<string[]>(() => {
    if (!user) return [];

    // If super admin, has all permissions
    if (user.role === 'SUPER_ADMIN') {
      return Object.values(PERMISSION_CODES);
    }

    // Lookup in store role
    const roleObj = mockStore.data.roles.find((r) => r.id === user.roleId || r.name === user.roleName);
    if (roleObj && roleObj.permissions && roleObj.permissions.length > 0) {
      return roleObj.permissions;
    }

    // Fallback to default role permissions
    return DEFAULT_ROLE_PERMISSIONS[user.role] || [];
  }, [user]);

  const hasPermission = (permission: string): boolean => {
    if (!user) return false;
    if (user.role === 'SUPER_ADMIN') return true;
    return userPermissions.includes(permission);
  };

  const can = (module: string, action: string): boolean => {
    const code = `${module.toLowerCase().replace(/s$/, '')}.${action.toLowerCase()}`;
    return hasPermission(code);
  };

  return (
    <PermissionContext.Provider value={{ hasPermission, can, userPermissions }}>
      {children}
    </PermissionContext.Provider>
  );
};

export const usePermission = () => {
  const context = useContext(PermissionContext);
  if (!context) throw new Error('usePermission must be used within a PermissionProvider');
  return context;
};
