import { Tenant, TenantFormData } from '../types/tenant';
import { mockStore } from '../mock/initialStore';
import { apiClient } from '../lib/api/apiClient';

export const tenantService = {
  async getAll(): Promise<Tenant[]> {
    try {
      const res = await apiClient.get('/api/master/tenants');
      if (res && res.success && Array.isArray(res.data)) {
        return res.data.map((t: any) => ({
          id: t.id,
          name: t.name,
          code: t.code,
          tenantType: t.tenantType || 'Enterprise',
          registrationNumber: t.registrationNumber || '',
          gstNumber: t.gstNumber || '',
          contactEmail: t.contactEmail || t.contact_email || '',
          contactPhone: t.contactPhone || t.contact_phone || '',
          addressLine1: t.addressLine1 || '',
          addressLine2: t.addressLine2 || '',
          city: t.city || 'Bangalore',
          state: t.state || 'Karnataka',
          country: t.country || 'India',
          pincode: t.pincode || '',
          timezone: t.timezone || 'Asia/Kolkata (IST)',
          currency: t.currency || 'INR (₹)',
          numberOfBranches: Number(t.numberOfBranches) || 1,
          adminName: t.adminName || '',
          adminEmail: t.adminEmail || '',
          status: t.status || 'ACTIVE',
          organizationsCount: t.organizationsCount || 0,
          usersCount: t.usersCount || 0,
          createdDate: t.created_at?.split('T')[0] || t.createdDate || new Date().toISOString().split('T')[0],
          updatedDate: t.updated_at?.split('T')[0] || t.updatedDate || new Date().toISOString().split('T')[0],
          description: t.description || '',
        }));
      }
    } catch (err) {
      console.warn('tenantService.getAll API warning:', err);
    }
    return [...mockStore.data.tenants];
  },

  async getById(id: string): Promise<Tenant | null> {
    const list = await this.getAll();
    const tenant = list.find((t) => t.id === id);
    return tenant ? { ...tenant } : null;
  },

  async create(data: TenantFormData): Promise<Tenant> {
    const newTenant: Tenant = {
      id: `ten-${Date.now()}`,
      name: data.name,
      code: data.code.toUpperCase(),
      tenantType: data.tenantType || 'Enterprise',
      registrationNumber: data.registrationNumber || '',
      gstNumber: data.gstNumber ? data.gstNumber.toUpperCase() : '',
      contactEmail: data.contactEmail,
      contactPhone: data.contactPhone,
      addressLine1: data.addressLine1 || '',
      addressLine2: data.addressLine2 || '',
      city: data.city || '',
      state: data.state || '',
      country: data.country || 'India',
      pincode: data.pincode || '',
      timezone: data.timezone || 'Asia/Kolkata (IST)',
      currency: data.currency || 'INR (₹)',
      numberOfBranches: Number(data.numberOfBranches) || 1,
      adminName: data.adminName || '',
      adminEmail: data.adminEmail || '',
      status: 'ACTIVE',
      organizationsCount: 0,
      usersCount: 1,
      createdDate: new Date().toISOString().split('T')[0],
      updatedDate: new Date().toISOString().split('T')[0],
      description: data.description || '',
    };
    mockStore.data.tenants.unshift(newTenant);
    return newTenant;
  },

  async update(id: string, data: Partial<TenantFormData>): Promise<Tenant> {
    const index = mockStore.data.tenants.findIndex((t) => t.id === id);
    if (index !== -1) {
      const updated: Tenant = {
        ...mockStore.data.tenants[index],
        ...data,
        updatedDate: new Date().toISOString().split('T')[0],
      };
      mockStore.data.tenants[index] = updated;
      return updated;
    }
    throw new Error('Tenant not found');
  },

  async delete(id: string): Promise<void> {
    mockStore.data.tenants = mockStore.data.tenants.filter((t) => t.id !== id);
  },
};
