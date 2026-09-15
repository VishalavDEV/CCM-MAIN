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
      name: data.name,
      code: data.code.toUpperCase(),
      status: data.status,
      organizationsCount: 0,
      usersCount: 1,
      contactEmail: data.contactEmail,
      contactPhone: data.contactPhone,
      description: data.description,
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

    const updated: Tenant = {
      ...mockStore.data.tenants[index],
      ...data,
      code: data.code ? data.code.toUpperCase() : mockStore.data.tenants[index].code,
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
