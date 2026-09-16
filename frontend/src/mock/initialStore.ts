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

export const initialTenants: Tenant[] = [];
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
