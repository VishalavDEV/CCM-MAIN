import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { usePermission } from '../context/PermissionContext';

export const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const location = useLocation();

  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  return <>{children}</>;
};

export const PermissionRoute: React.FC<{
  permission: string;
  children: React.ReactNode;
}> = ({ permission, children }) => {
  const { hasPermission } = usePermission();

  if (!hasPermission(permission)) {
    return <Navigate to="/403" replace />;
  }

  return <>{children}</>;
};
