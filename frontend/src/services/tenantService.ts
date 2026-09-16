import { Tenant, TenantFormData } from '../types/tenant';
import { mockStore } from '../mock/initialStore';

export const tenantService = {
  async getAll(): Promise<Tenant[]> {
    await new Promise((res) => setTimeout(res, 150));
    return [...mockStore.data.tenants];
  },

  async getById(id: string): Promise<Tenant | null> {
    await new Promise((res) => setTimeout(res, 100));
    const tenant = mockStore.data.tenants.find((t) => t.id === id);
    return tenant ? { ...tenant } : null;
  },

  async create(data: TenantFormData): Promise<Tenant> {
    await new Promise((res) => setTimeout(res, 200));
    const newTenant: Tenant = {
      id: `ten-${Date.now()}`,
      // 1. Tenant Info
      name: data.name,
      code: data.code.toUpperCase(),
      tenantType: data.tenantType || 'Enterprise',
      registrationNumber: data.registrationNumber || '',
      gstNumber: data.gstNumber ? data.gstNumber.toUpperCase() : '',
      contactEmail: data.contactEmail,
      contactPhone: data.contactPhone,

      // 2. Address Details
      addressLine1: data.addressLine1 || '',
      addressLine2: data.addressLine2 || '',
      city: data.city || '',
      state: data.state || '',
      country: data.country || 'India',
      pincode: data.pincode || '',
      timezone: data.timezone || 'Asia/Kolkata (IST)',
      currency: data.currency || 'INR (₹)',

      // 3. Inventory Setup
      numberOfBranches: Number(data.numberOfBranches) || 1,

      // 4. Administration
      adminName: data.adminName || '',
      adminEmail: data.adminEmail || '',

      // Status & System Metadata
      status: data.status || 'ACTIVE',
      organizationsCount: 0,
      usersCount: 1,
      description: data.description || '',
      createdDate: new Date().toISOString().split('T')[0],
      updatedDate: new Date().toISOString().split('T')[0],
    };

    mockStore.data.tenants.unshift(newTenant);
    return newTenant;
  },

  async update(id: string, data: Partial<TenantFormData>): Promise<Tenant> {
    await new Promise((res) => setTimeout(res, 200));
    const index = mockStore.data.tenants.findIndex((t) => t.id === id);
    if (index === -1) throw new Error('Tenant not found');

    const current = mockStore.data.tenants[index];
    const updated: Tenant = {
      ...current,
      ...data,
      code: data.code ? data.code.toUpperCase() : current.code,
      gstNumber: data.gstNumber ? data.gstNumber.toUpperCase() : current.gstNumber,
      updatedDate: new Date().toISOString().split('T')[0],
    };
    mockStore.data.tenants[index] = updated;
    return updated;
  },

  async delete(id: string): Promise<void> {
    await new Promise((res) => setTimeout(res, 200));
    mockStore.data.tenants = mockStore.data.tenants.filter((t) => t.id !== id);
  },

  async toggleStatus(id: string): Promise<Tenant> {
    await new Promise((res) => setTimeout(res, 150));
    const tenant = mockStore.data.tenants.find((t) => t.id === id);
    if (!tenant) throw new Error('Tenant not found');
    tenant.status = tenant.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    tenant.updatedDate = new Date().toISOString().split('T')[0];
    return { ...tenant };
  },
};
