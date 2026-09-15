import { Organization, OrganizationFormData } from '../types/organization';
import { mockStore } from '../mock/initialStore';

export const organizationService = {
  async getAll(tenantId?: string): Promise<Organization[]> {
    await new Promise((res) => setTimeout(res, 150));
    if (tenantId) {
      return mockStore.data.organizations.filter((o) => o.tenantId === tenantId);
    }
    return [...mockStore.data.organizations];
  },

  async getById(id: string): Promise<Organization | null> {
    await new Promise((res) => setTimeout(res, 100));
    const org = mockStore.data.organizations.find((o) => o.id === id);
    return org ? { ...org } : null;
  },

  async create(data: OrganizationFormData): Promise<Organization> {
    await new Promise((res) => setTimeout(res, 250));
    const newOrg: Organization = {
      id: `org-${Date.now()}`,
      tenantId: data.tenantId,
      companyName: data.companyName,
      companyCode: data.companyCode.toUpperCase(),
      companyType: data.companyType,
      businessType: data.businessType,
      registrationNumber: data.registrationNumber,
      gstNumber: data.gstNumber,
      companyEmail: data.companyEmail,
      companyPhone: data.companyPhone,
      addressLine1: data.addressLine1,
      addressLine2: data.addressLine2,
      city: data.city,
      state: data.state,
      country: data.country,
      pincode: data.pincode,
      timezone: data.timezone,
      currency: data.currency,
      numberOfBranches: Number(data.numberOfBranches) || 1,
      numberOfWarehouses: Number(data.numberOfWarehouses) || 1,
      msmeNumber: data.msmeNumber,
      adminName: data.adminName,
      adminEmail: data.adminEmail,
      status: 'ACTIVE',
      createdDate: new Date().toISOString().split('T')[0],
      usersCount: 1,
    };
    mockStore.data.organizations.unshift(newOrg);

    // Update parent tenant count
    const parentTenant = mockStore.data.tenants.find((t) => t.id === data.tenantId);
    if (parentTenant) {
      parentTenant.organizationsCount += 1;
    }

    return newOrg;
  },

  async update(id: string, data: Partial<OrganizationFormData>): Promise<Organization> {
    await new Promise((res) => setTimeout(res, 200));
    const index = mockStore.data.organizations.findIndex((o) => o.id === id);
    if (index === -1) throw new Error('Organization not found');

    const updated: Organization = {
      ...mockStore.data.organizations[index],
      ...data,
      companyCode: data.companyCode ? data.companyCode.toUpperCase() : mockStore.data.organizations[index].companyCode,
      numberOfBranches: data.numberOfBranches !== undefined ? Number(data.numberOfBranches) : mockStore.data.organizations[index].numberOfBranches,
      numberOfWarehouses: data.numberOfWarehouses !== undefined ? Number(data.numberOfWarehouses) : mockStore.data.organizations[index].numberOfWarehouses,
    };
    mockStore.data.organizations[index] = updated;
    return updated;
  },

  async delete(id: string): Promise<void> {
    await new Promise((res) => setTimeout(res, 200));
    const org = mockStore.data.organizations.find((o) => o.id === id);
    if (org) {
      const parentTenant = mockStore.data.tenants.find((t) => t.id === org.tenantId);
      if (parentTenant && parentTenant.organizationsCount > 0) {
        parentTenant.organizationsCount -= 1;
      }
    }
    mockStore.data.organizations = mockStore.data.organizations.filter((o) => o.id !== id);
  },

  async toggleStatus(id: string): Promise<Organization> {
    await new Promise((res) => setTimeout(res, 150));
    const org = mockStore.data.organizations.find((o) => o.id === id);
    if (!org) throw new Error('Organization not found');
    org.status = org.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    return { ...org };
  },
};
