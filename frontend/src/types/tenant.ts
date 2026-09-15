export type StatusType = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';

export interface Tenant {
  id: string;
  name: string;
  code: string;
  status: StatusType;
  organizationsCount: number;
  usersCount: number;
  contactEmail: string;
  contactPhone: string;
  createdDate: string;
  updatedDate: string;
  description?: string;
}

export interface TenantFormData {
  name: string;
  code: string;
  contactEmail: string;
  contactPhone: string;
  status: StatusType;
  description?: string;
}
