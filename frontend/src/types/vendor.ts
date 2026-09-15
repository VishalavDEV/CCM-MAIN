export type CreditLevel = 'Excellent' | 'Good' | 'Average' | 'High Risk';

export interface Vendor {
  id: string;
  tenantId: string;
  organizationId: string;

  // Vendor Information
  vendorName: string;
  vendorCode: string;
  businessType: string;
  contactPersonName: string;
  gstNumber?: string;
  panNumber?: string;

  // Contact Address
  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  state: string;
  country: string;
  pincode: string;

  // Commercial Information
  creditScore: number;
  creditLevel: CreditLevel;
  paymentDetails: string;
  termsAndConditions: string;

  status: 'ACTIVE' | 'INACTIVE';
  activePOCount?: number;
  createdAt: string;
}

export interface VendorFormData {
  vendorName: string;
  vendorCode: string;
  businessType: string;
  contactPersonName: string;
  gstNumber?: string;
  panNumber?: string;

  email: string;
  phoneNumber: string;
  address: string;
  city: string;
  state: string;
  country: string;
  pincode: string;

  creditScore: number;
  creditLevel: CreditLevel;
  paymentDetails: string;
  termsAndConditions: string;
}
