export const PERMISSION_CODES = {
  // Tenant
  TENANT_VIEW: 'tenant.view',
  TENANT_CREATE: 'tenant.create',
  TENANT_UPDATE: 'tenant.update',
  TENANT_DELETE: 'tenant.delete',

  // Organization
  ORGANIZATION_VIEW: 'organization.view',
  ORGANIZATION_CREATE: 'organization.create',
  ORGANIZATION_UPDATE: 'organization.update',
  ORGANIZATION_DELETE: 'organization.delete',

  // User
  USER_VIEW: 'user.view',
  USER_CREATE: 'user.create',
  USER_UPDATE: 'user.update',
  USER_DELETE: 'user.delete',

  // Role
  ROLE_VIEW: 'role.view',
  ROLE_CREATE: 'role.create',
  ROLE_UPDATE: 'role.update',
  ROLE_DELETE: 'role.delete',

  // Permission
  PERMISSION_VIEW: 'permission.view',

  // Client
  CLIENT_VIEW: 'client.view',
  CLIENT_CREATE: 'client.create',
  CLIENT_UPDATE: 'client.update',
  CLIENT_DELETE: 'client.delete',

  // Vendor
  VENDOR_VIEW: 'vendor.view',
  VENDOR_CREATE: 'vendor.create',
  VENDOR_UPDATE: 'vendor.update',
  VENDOR_DELETE: 'vendor.delete',

  // Item
  ITEM_VIEW: 'item.view',
  ITEM_CREATE: 'item.create',
  ITEM_UPDATE: 'item.update',
  ITEM_DELETE: 'item.delete',

  // Request & Collection
  REQUEST_VIEW: 'request.view',
  REQUEST_CREATE: 'request.create',
  REQUEST_UPDATE: 'request.update',
  REQUEST_SUBMIT: 'request.submit',
  REQUEST_DELETE: 'request.delete',

  // Verification
  VERIFICATION_VIEW: 'verification.view',
  VERIFICATION_CREATE: 'verification.create',
  VERIFICATION_UPDATE: 'verification.update',

  // Calibration & Certificate
  CALIBRATION_VIEW: 'calibration.view',
  CALIBRATION_CREATE: 'calibration.create',
  CALIBRATION_UPDATE: 'calibration.update',

  // Quotation
  QUOTATION_VIEW: 'quotation.view',
  QUOTATION_CREATE: 'quotation.create',
  QUOTATION_UPDATE: 'quotation.update',
  QUOTATION_APPROVE: 'quotation.approve',

  // Purchase Order
  PO_VIEW: 'purchase_order.view',
  PO_CREATE: 'purchase_order.create',
  PO_UPDATE: 'purchase_order.update',

  // Invoice
  INVOICE_VIEW: 'invoice.view',
  INVOICE_CREATE: 'invoice.create',
  INVOICE_UPDATE: 'invoice.update',

  // Signature
  SIGNATURE_VIEW: 'signature.view',
  SIGNATURE_CREATE: 'signature.create',

  // Dispatch & Delivery
  DISPATCH_VIEW: 'dispatch.view',
  DISPATCH_CREATE: 'dispatch.create',
  DELIVERY_VIEW: 'delivery.view',
  DELIVERY_UPDATE: 'delivery.update',

  // Audit
  AUDIT_VIEW: 'audit.view',
} as const;

export const MODULES_METADATA = [
  { id: 'tenants', name: 'Tenants', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'organizations', name: 'Organizations', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'users', name: 'Users', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'roles', name: 'Roles', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'clients', name: 'Clients', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'vendors', name: 'Vendors', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'items', name: 'Items', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'requests', name: 'Requests', actions: ['view', 'create', 'edit', 'delete'] },
  { id: 'calibration', name: 'Calibration', actions: ['view', 'create', 'edit'] },
  { id: 'quotations', name: 'Quotation', actions: ['view', 'create', 'edit', 'approve'] },
  { id: 'approvals', name: 'Approval', actions: ['view', 'approve'] },
  { id: 'invoices', name: 'Invoice', actions: ['view', 'create', 'edit'] },
  { id: 'dispatch', name: 'Dispatch', actions: ['view', 'create', 'edit'] },
  { id: 'auditLogs', name: 'Audit Logs', actions: ['view'] },
] as const;

// Default permissions assigned to each role for mock demo
export const DEFAULT_ROLE_PERMISSIONS: Record<string, string[]> = {
  SUPER_ADMIN: Object.values(PERMISSION_CODES),
  ADMIN: [
    PERMISSION_CODES.ORGANIZATION_VIEW,
    PERMISSION_CODES.USER_VIEW, PERMISSION_CODES.USER_CREATE, PERMISSION_CODES.USER_UPDATE,
    PERMISSION_CODES.ROLE_VIEW,
    PERMISSION_CODES.CLIENT_VIEW, PERMISSION_CODES.CLIENT_CREATE, PERMISSION_CODES.CLIENT_UPDATE, PERMISSION_CODES.CLIENT_DELETE,
    PERMISSION_CODES.VENDOR_VIEW, PERMISSION_CODES.VENDOR_CREATE, PERMISSION_CODES.VENDOR_UPDATE,
    PERMISSION_CODES.ITEM_VIEW, PERMISSION_CODES.ITEM_CREATE, PERMISSION_CODES.ITEM_UPDATE,
    PERMISSION_CODES.REQUEST_VIEW, PERMISSION_CODES.REQUEST_CREATE, PERMISSION_CODES.REQUEST_UPDATE,
    PERMISSION_CODES.VERIFICATION_VIEW, PERMISSION_CODES.CALIBRATION_VIEW,
    PERMISSION_CODES.QUOTATION_VIEW, PERMISSION_CODES.INVOICE_VIEW,
    PERMISSION_CODES.DISPATCH_VIEW, PERMISSION_CODES.DELIVERY_VIEW,
    PERMISSION_CODES.AUDIT_VIEW,
  ],
  COLLECTION_AGENT: [
    PERMISSION_CODES.CLIENT_VIEW,
    PERMISSION_CODES.ITEM_VIEW,
    PERMISSION_CODES.REQUEST_VIEW, PERMISSION_CODES.REQUEST_CREATE, PERMISSION_CODES.REQUEST_UPDATE, PERMISSION_CODES.REQUEST_SUBMIT,
  ],
  LAB_USER: [
    PERMISSION_CODES.REQUEST_VIEW,
    PERMISSION_CODES.ITEM_VIEW,
    PERMISSION_CODES.VERIFICATION_VIEW, PERMISSION_CODES.VERIFICATION_CREATE, PERMISSION_CODES.VERIFICATION_UPDATE,
    PERMISSION_CODES.CALIBRATION_VIEW, PERMISSION_CODES.CALIBRATION_CREATE, PERMISSION_CODES.CALIBRATION_UPDATE,
  ],
  COMMERCIAL_USER: [
    PERMISSION_CODES.CLIENT_VIEW,
    PERMISSION_CODES.VENDOR_VIEW,
    PERMISSION_CODES.REQUEST_VIEW,
    PERMISSION_CODES.QUOTATION_VIEW, PERMISSION_CODES.QUOTATION_CREATE, PERMISSION_CODES.QUOTATION_UPDATE,
    PERMISSION_CODES.PO_VIEW, PERMISSION_CODES.PO_CREATE,
    PERMISSION_CODES.INVOICE_VIEW, PERMISSION_CODES.INVOICE_CREATE,
  ],
  APPROVER: [
    PERMISSION_CODES.REQUEST_VIEW,
    PERMISSION_CODES.QUOTATION_VIEW,
    PERMISSION_CODES.QUOTATION_APPROVE,
    PERMISSION_CODES.INVOICE_VIEW,
  ],
  DISPATCH_USER: [
    PERMISSION_CODES.REQUEST_VIEW,
    PERMISSION_CODES.DISPATCH_VIEW, PERMISSION_CODES.DISPATCH_CREATE,
    PERMISSION_CODES.DELIVERY_VIEW, PERMISSION_CODES.DELIVERY_UPDATE,
    PERMISSION_CODES.SIGNATURE_VIEW, PERMISSION_CODES.SIGNATURE_CREATE,
  ],
};
