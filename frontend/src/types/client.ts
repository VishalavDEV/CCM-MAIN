export type ClientAccountStatus = 'Active' | 'Inactive' | 'Pending' | 'Suspended';

export interface Client {
  id: string;
  tenantId: string;
  organizationId: string;
  // Client Information
  clientName: string;
  clientCode: string;
  businessType: string;
  gstNumber?: string;
  contactPersonName: string;
  contactPersonContactNumber: string;

  // Contact Address
  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  state: string;
  country: string;
  pincode: string;

  // Business Setup
  currency: string;
  numberOfBranches: number;
  numberOfWarehouses: number;
  onboardingDate: string;
  accountStatus: ClientAccountStatus;
  msmeNumber?: string;

  activeRequestsCount?: number;
  createdAt: string;
}

export interface ClientFormData {
  clientName: string;
  clientCode: string;
  businessType: string;
  gstNumber?: string;
  contactPersonName: string;
  contactPersonContactNumber: string;

  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  state: string;
  country: string;
  pincode: string;

  currency: string;
  numberOfBranches: number;
  numberOfWarehouses: number;
  onboardingDate: string;
  accountStatus: ClientAccountStatus;
  msmeNumber?: string;
}
