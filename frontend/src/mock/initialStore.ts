import { Tenant } from '../types/tenant';
import { Organization } from '../types/organization';
import { User } from '../types/user';
import { Role } from '../types/role';
import { Client } from '../types/client';
import { Vendor } from '../types/vendor';
import { Item } from '../types/item';
import { CalibrationRequest } from '../types/request';
import { Quotation } from '../types/quotation';
import { ApprovalRecord } from '../types/approval';
import { PurchaseOrder } from '../types/purchaseOrder';
import { Invoice } from '../types/invoice';
import { DigitalSignature, DispatchRecord, DeliveryRecord, AuditLogEntry } from '../types/dispatch';
import { DocumentRecord } from '../types/verification';
import { CalibrationDueItem } from '../types/calibration';

export interface AppStore {
  tenants: Tenant[];
  organizations: Organization[];
  users: User[];
  roles: Role[];
  clients: Client[];
  vendors: Vendor[];
  items: Item[];
  requests: CalibrationRequest[];
  documents: DocumentRecord[];
  quotations: Quotation[];
  approvals: ApprovalRecord[];
  purchaseOrders: PurchaseOrder[];
  invoices: Invoice[];
  signatures: DigitalSignature[];
  dispatches: DispatchRecord[];
  deliveries: DeliveryRecord[];
  auditLogs: AuditLogEntry[];
  dueList: CalibrationDueItem[];
}

export const initialTenants: Tenant[] = [
  {
    id: '00000000-0000-0000-0000-000000000001',
    name: 'Apex Metrology Group',
    code: 'APEX',
    tenantType: 'Enterprise',
    registrationNumber: 'CIN-U74999KA2020PTC139822',
    gstNumber: '29AAACA1234F1Z5',
    contactEmail: 'contact@apexmetrology.com',
    contactPhone: '+91 80 2845 0001',
    addressLine1: 'Plot 42, Electronic City Phase 1',
    addressLine2: 'Hosur Road Industrial Corridor',
    city: 'Bengaluru',
    state: 'Karnataka',
    country: 'India',
    pincode: '560100',
    timezone: 'Asia/Kolkata (IST)',
    currency: 'INR (₹)',
    numberOfBranches: 3,
    adminName: 'Apex Super Admin',
    adminEmail: 'admin@apexmetrology.com',
    status: 'ACTIVE',
    organizationsCount: 1,
    usersCount: 5,
    createdDate: '2025-01-15',
    updatedDate: '2026-09-10',
    description: 'Primary Calibration Laboratory Network for Aerospace & Precision Engineering',
  },
];
export const initialOrganizations: Organization[] = [];
export const initialUsers: User[] = [];
export const initialRoles: Role[] = [];
export const initialClients: Client[] = [];
export const initialVendors: Vendor[] = [];
export const initialItems: Item[] = [];
export const initialRequests: CalibrationRequest[] = [];
export const initialDocuments: DocumentRecord[] = [];
export const initialQuotations: Quotation[] = [];
export const initialApprovals: ApprovalRecord[] = [];
export const initialPurchaseOrders: PurchaseOrder[] = [];
export const initialInvoices: Invoice[] = [];
export const initialSignatures: DigitalSignature[] = [];
export const initialDispatches: DispatchRecord[] = [];
export const initialDeliveries: DeliveryRecord[] = [];
export const initialAuditLogs: AuditLogEntry[] = [];
export const initialDueList: CalibrationDueItem[] = [];

// Persistent reactive in-memory store (starts empty)
class MockDataStore {
  private store: AppStore;

  constructor() {
    this.store = {
      tenants: [...initialTenants],
      organizations: [...initialOrganizations],
      users: [...initialUsers],
      roles: [...initialRoles],
      clients: [...initialClients],
      vendors: [...initialVendors],
      items: [...initialItems],
      requests: [...initialRequests],
      documents: [...initialDocuments],
      quotations: [...initialQuotations],
      approvals: [...initialApprovals],
      purchaseOrders: [...initialPurchaseOrders],
      invoices: [...initialInvoices],
      signatures: [...initialSignatures],
      dispatches: [...initialDispatches],
      deliveries: [...initialDeliveries],
      auditLogs: [...initialAuditLogs],
      dueList: [...initialDueList],
    };
  }

  get data(): AppStore {
    return this.store;
  }

  set data(newData: AppStore) {
    this.store = newData;
  }
}

export const mockStore = new MockDataStore();
