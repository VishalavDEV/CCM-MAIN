import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Building2,
  Plus,
  Edit2,
  Trash2,
  Eye,
  Building,
  Users,
  Shield,
  Activity,
  CheckCircle,
  CheckCircle2,
  ArrowLeft,
  ArrowRight,
  Save,
  MapPin,
  Boxes,
  KeyRound,
  FileText,
  Lock,
  Globe,
  DollarSign,
  Clock,
  Phone,
  Mail,
  Hash,
  Power,
  Warehouse,
} from 'lucide-react';
import { Tenant, TenantFormData, TenantType } from '../../types/tenant';
import { Organization } from '../../types/organization';
import { tenantService } from '../../services/tenantService';
import { organizationService } from '../../services/organizationService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { DeleteModal, Modal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';

export const TenantListPage: React.FC = () => {
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [tenantToDelete, setTenantToDelete] = useState<Tenant | null>(null);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadTenants = async () => {
    setLoading(true);
    try {
      const data = await tenantService.getAll();
      setTenants(data);
    } catch {
      showToast('Unable to load tenants', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadTenants();
  }, []);

  const handleDelete = async () => {
    if (!tenantToDelete) return;
    try {
      await tenantService.delete(tenantToDelete.id);
      showToast('Tenant deleted successfully', 'info');
      setDeleteModalOpen(false);
      setTenantToDelete(null);
      loadTenants();
    } catch {
      showToast('Failed to delete tenant', 'error');
    }
  };

  const columns: Column<Tenant>[] = [
    {
      key: 'name',
      header: 'Tenant Entity',
      sortable: true,
      render: (t) => (
        <div>
          <span className="font-semibold text-slate-900 block text-xs">{t.name}</span>
          <div className="flex items-center gap-1.5 mt-0.5">
            <span className="text-[10px] text-indigo-700 font-mono font-bold bg-indigo-50 px-1.5 py-0.2 rounded border border-indigo-200/50">
              {t.code}
            </span>
            <span className="text-[10px] text-slate-400 font-medium">
              {t.tenantType || 'Enterprise'}
            </span>
          </div>
        </div>
      ),
    },
    {
      key: 'gstNumber',
      header: 'Identifiers',
      render: (t) => (
        <div className="text-xs space-y-0.5">
          {t.gstNumber && (
            <div className="font-mono text-[11px] text-slate-700 font-semibold">
              GST: {t.gstNumber}
            </div>
          )}
          {t.registrationNumber && (
            <div className="text-[10px] text-slate-400 font-mono">
              Reg: {t.registrationNumber}
            </div>
          )}
          {!t.gstNumber && !t.registrationNumber && (
            <span className="text-[11px] text-slate-400 italic">Not specified</span>
          )}
        </div>
      ),
    },
    {
      key: 'city',
      header: 'Address / Location',
      render: (t) => (
        <div className="text-xs text-slate-600">
          <div>{t.city ? `${t.city}, ${t.state}` : 'Headquarters'}</div>
          <span className="text-[10px] text-slate-400">{t.country || 'India'}</span>
        </div>
      ),
    },
    {
      key: 'contactEmail',
      header: 'Contact Info',
      render: (t) => (
        <div className="text-xs text-slate-600">
          <div>{t.contactEmail}</div>
          <span className="text-[10px] text-slate-400 font-mono">{t.contactPhone}</span>
        </div>
      ),
    },
    {
      key: 'numberOfBranches',
      header: 'Setup & Scale',
      render: (t) => (
        <div className="text-xs space-y-0.5">
          <span className="font-mono font-bold text-slate-700 bg-slate-100 px-2 py-0.5 rounded text-[11px] inline-block">
            {t.numberOfBranches || 1} Branches
          </span>
          <div className="text-[10px] text-slate-400">
            {t.organizationsCount || 0} Registered Labs
          </div>
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (t) => <StatusBadge status={t.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (t) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={() => navigate(`/admin/tenants/${t.id}`)}
            className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition"
            title="View Tenant Details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => navigate(`/admin/tenants/edit/${t.id}`)}
            className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition"
            title="Edit Tenant"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => {
              setTenantToDelete(t);
              setDeleteModalOpen(true);
            }}
            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition"
            title="Delete Tenant"
          >
            <Trash2 className="w-4 h-4" />
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Enterprise Tenants</h1>
          <p className="text-xs text-slate-500 mt-1">
            Top-level multi-tenant enterprise isolation accounts managing laboratory networks and multi-facility organizations.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/tenants/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          Onboard New Tenant
        </button>
      </div>

      <DataTable data={tenants} columns={columns} loading={loading} />

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete Tenant Group"
        itemName={tenantToDelete?.name}
        message="Are you sure you want to permanently remove this enterprise tenant? All linked organizations will be affected."
      />
    </div>
  );
};

export const AddTenantPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id;

  const navigate = useNavigate();
  const { showToast } = useNotification();
  const [submitting, setSubmitting] = useState(false);
  const [currentStep, setCurrentStep] = useState(1);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const [formData, setFormData] = useState<TenantFormData>({
    // 1. Tenant Info
    name: '',
    code: '',
    tenantType: 'Enterprise',
    registrationNumber: '',
    gstNumber: '',
    contactEmail: '',
    contactPhone: '',

    // 2. Address Details
    addressLine1: '',
    addressLine2: '',
    city: '',
    state: '',
    country: 'India',
    pincode: '',
    timezone: 'Asia/Kolkata (IST)',
    currency: 'INR (₹)',

    // 3. Inventory Setup
    numberOfBranches: 1,

    // 4. Administration
    adminName: '',
    adminEmail: '',
    adminPassword: '',

    status: 'ACTIVE',
    description: '',
  });

  useEffect(() => {
    if (isEdit && id) {
      tenantService.getById(id).then((t) => {
        if (t) {
          setFormData({
            name: t.name,
            code: t.code,
            tenantType: t.tenantType || 'Enterprise',
            registrationNumber: t.registrationNumber || '',
            gstNumber: t.gstNumber || '',
            contactEmail: t.contactEmail,
            contactPhone: t.contactPhone,
            addressLine1: t.addressLine1 || '',
            addressLine2: t.addressLine2 || '',
            city: t.city || '',
            state: t.state || '',
            country: t.country || 'India',
            pincode: t.pincode || '',
            timezone: t.timezone || 'Asia/Kolkata (IST)',
            currency: t.currency || 'INR (₹)',
            numberOfBranches: t.numberOfBranches || 1,
            adminName: t.adminName || '',
            adminEmail: t.adminEmail || '',
            adminPassword: '',
            status: t.status,
            description: t.description || '',
          });
        }
      });
    }
  }, [id, isEdit]);

  const stepsList = [
    { num: 1, title: 'Tenant Info', icon: <Building2 className="w-4 h-4" /> },
    { num: 2, title: 'Address Details', icon: <MapPin className="w-4 h-4" /> },
    { num: 3, title: 'Inventory Setup', icon: <Boxes className="w-4 h-4" /> },
    { num: 4, title: 'Administration', icon: <KeyRound className="w-4 h-4" /> },
    { num: 5, title: 'Review & Confirm', icon: <CheckCircle className="w-4 h-4" /> },
  ];

  const validateStep = (stepNumber: number): boolean => {
    const newErrors: Record<string, string> = {};

    if (stepNumber === 1) {
      if (!formData.name.trim()) newErrors.name = 'Tenant name is required';
      if (!formData.code.trim()) newErrors.code = 'Tenant ID/Code is required';
      if (!formData.contactEmail.trim()) newErrors.contactEmail = 'Tenant email is required';
      if (!formData.contactPhone.trim()) newErrors.contactPhone = 'Tenant phone number is required';
      if (formData.gstNumber && formData.gstNumber.trim().length !== 15) {
        newErrors.gstNumber = 'GST number must be 15 alphanumeric characters';
      }
    }

    if (stepNumber === 2) {
      if (!formData.addressLine1.trim()) newErrors.addressLine1 = 'Address line 1 is required';
      if (!formData.city.trim()) newErrors.city = 'City is required';
      if (!formData.state.trim()) newErrors.state = 'State is required';
      if (!formData.pincode.trim()) newErrors.pincode = 'Pincode is required';
    }

    if (stepNumber === 3) {
      if (formData.numberOfBranches < 1) newErrors.numberOfBranches = 'At least 1 branch is required';
    }

    if (stepNumber === 4) {
      if (!formData.adminName.trim()) newErrors.adminName = 'Administrator name is required';
      if (!formData.adminEmail.trim()) newErrors.adminEmail = 'Administrator email is required';
      if (!isEdit && !formData.adminPassword) {
        newErrors.adminPassword = 'Password is required for tenant administrator account';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep(currentStep)) {
      setCurrentStep((prev) => Math.min(prev + 1, 5));
    } else {
      showToast('Please complete required fields before proceeding', 'warning');
    }
  };

  const handleBack = () => {
    setCurrentStep((prev) => Math.max(prev - 1, 1));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    // Validate all steps
    if (!validateStep(1) || !validateStep(2) || !validateStep(3) || !validateStep(4)) {
      showToast('Please fix validation errors before submitting', 'error');
      return;
    }

    setSubmitting(true);
    try {
      if (isEdit && id) {
        await tenantService.update(id, formData);
        showToast('Tenant profile updated successfully', 'success');
      } else {
        await tenantService.create(formData);
        showToast('Enterprise Tenant onboarded successfully', 'success');
      }
      navigate('/admin/tenants');
    } catch {
      showToast('Failed to save tenant profile', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Top Header */}
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs font-mono font-bold text-indigo-700 bg-indigo-50 px-2.5 py-0.5 rounded-full uppercase tracking-wider border border-indigo-200/60">
            Tenant Onboarding Wizard
          </span>
          <h1 className="text-xl font-bold text-slate-900 mt-1.5">
            {isEdit ? 'Edit Tenant Profile' : 'Enterprise Tenant Onboarding'}
          </h1>
          <p className="text-xs text-slate-500">
            Provision a multi-tenant enterprise account with regional, inventory, and administration settings.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/tenants')}
          className="inline-flex items-center gap-1.5 px-3 py-2 text-xs font-semibold text-slate-600 bg-white border border-slate-200 hover:bg-slate-50 rounded-xl transition cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Cancel</span>
        </button>
      </div>

      {/* Stepper Navigation */}
      <div className="bg-white rounded-2xl border border-slate-200/90 p-4 shadow-subtle overflow-x-auto">
        <div className="flex items-center justify-between min-w-[620px]">
          {stepsList.map((s, idx) => {
            const isCompleted = currentStep > s.num;
            const isCurrent = currentStep === s.num;

            return (
              <React.Fragment key={s.num}>
                <div
                  className="flex items-center gap-2.5 cursor-pointer"
                  onClick={() => {
                    if (s.num < currentStep) setCurrentStep(s.num);
                  }}
                >
                  <div
                    className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold transition ${
                      isCompleted
                        ? 'bg-emerald-600 text-white'
                        : isCurrent
                        ? 'bg-indigo-600 text-white ring-4 ring-indigo-100'
                        : 'bg-slate-100 text-slate-400'
                    }`}
                  >
                    {isCompleted ? <CheckCircle2 className="w-4 h-4" /> : s.num}
                  </div>
                  <span
                    className={`text-xs ${
                      isCurrent
                        ? 'font-bold text-slate-900'
                        : isCompleted
                        ? 'font-semibold text-emerald-700'
                        : 'text-slate-400 font-medium'
                    }`}
                  >
                    {s.title}
                  </span>
                </div>
                {idx < stepsList.length - 1 && <div className="flex-1 h-0.5 bg-slate-200 mx-3" />}
              </React.Fragment>
            );
          })}
        </div>
      </div>

      {/* Wizard Form Content */}
      <div className="bg-white rounded-3xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle">
        {/* STEP 1: TENANT INFO */}
        {currentStep === 1 && (
          <div className="space-y-4 animate-fade-in">
            <div className="border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2 text-indigo-600">
                <Building2 className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900">Step 1 — Tenant Information</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Specify primary legal identity, corporate identifiers, and organizational contact credentials.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="1. Tenant Name"
                required
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                placeholder="e.g. Apex Metrology Group"
                error={errors.name}
              />
              <TextInput
                label="2. Tenant ID / CODE"
                required
                value={formData.code}
                onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                placeholder="e.g. APEX"
                helperText="Unique uppercase prefix used across tenant facilities"
                error={errors.code}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <SelectInput
                label="3. Tenant Type"
                required
                value={formData.tenantType}
                onChange={(e) => setFormData({ ...formData, tenantType: e.target.value })}
                options={[
                  { value: 'Enterprise', label: 'Enterprise Network' },
                  { value: 'Calibration Laboratory Network', label: 'Calibration Laboratory Network' },
                  { value: 'Private Limited', label: 'Private Limited Company' },
                  { value: 'Public Limited', label: 'Public Limited Company' },
                  { value: 'Partnership', label: 'Partnership Firm' },
                  { value: 'Proprietorship', label: 'Proprietorship' },
                  { value: 'OEM Group', label: 'OEM Calibration Partner' },
                  { value: 'Subcontract Partner', label: 'Subcontract Calibration Partner' },
                ]}
              />
              <TextInput
                label="4. Registration Number"
                value={formData.registrationNumber}
                onChange={(e) => setFormData({ ...formData, registrationNumber: e.target.value })}
                placeholder="e.g. CIN-U74999KA2020PTC139822"
                helperText="Corporate Identification / Registrar of Companies"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="5. GST Number"
                value={formData.gstNumber}
                onChange={(e) => setFormData({ ...formData, gstNumber: e.target.value.toUpperCase() })}
                placeholder="e.g. 29AAACA1234F1Z5"
                helperText="15-character GSTIN for billing and tax invoices"
                error={errors.gstNumber}
              />
              <TextInput
                type="email"
                label="6. Tenant Email"
                required
                value={formData.contactEmail}
                onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
                placeholder="contact@apexmetrology.com"
                error={errors.contactEmail}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="7. Tenant Phone Number"
                required
                value={formData.contactPhone}
                onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
                placeholder="+91 80 2845 0001"
                error={errors.contactPhone}
              />
              <SelectInput
                label="Tenant Status"
                value={formData.status}
                onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
                options={[
                  { value: 'ACTIVE', label: 'Active (Production Access)' },
                  { value: 'INACTIVE', label: 'Inactive' },
                  { value: 'SUSPENDED', label: 'Suspended' },
                ]}
              />
            </div>
          </div>
        )}

        {/* STEP 2: ADDRESS DETAILS */}
        {currentStep === 2 && (
          <div className="space-y-4 animate-fade-in">
            <div className="border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2 text-indigo-600">
                <MapPin className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900">Step 2 — Address Details</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Physical headquarters address, regional timezone, and default invoicing currency.
              </p>
            </div>

            <TextInput
              label="1. Address Line 1"
              required
              value={formData.addressLine1}
              onChange={(e) => setFormData({ ...formData, addressLine1: e.target.value })}
              placeholder="Building No, Plot / Sector, Industrial Area"
              error={errors.addressLine1}
            />

            <TextInput
              label="2. Address Line 2"
              value={formData.addressLine2}
              onChange={(e) => setFormData({ ...formData, addressLine2: e.target.value })}
              placeholder="Street Name, Landmark, Main Road"
            />

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="3. City"
                required
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                placeholder="e.g. Bengaluru"
                error={errors.city}
              />
              <TextInput
                label="4. State"
                required
                value={formData.state}
                onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                placeholder="e.g. Karnataka"
                error={errors.state}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="5. Country"
                required
                value={formData.country}
                onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                placeholder="India"
              />
              <TextInput
                label="6. Pincode / Postal Code"
                required
                value={formData.pincode}
                onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
                placeholder="e.g. 560100"
                error={errors.pincode}
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <SelectInput
                label="7. Timezone"
                required
                value={formData.timezone}
                onChange={(e) => setFormData({ ...formData, timezone: e.target.value })}
                options={[
                  { value: 'Asia/Kolkata (IST)', label: 'Asia/Kolkata (IST, UTC+05:30)' },
                  { value: 'UTC', label: 'Coordinated Universal Time (UTC)' },
                  { value: 'America/New_York (EST)', label: 'America/New_York (EST, UTC-05:00)' },
                  { value: 'Europe/London (GMT)', label: 'Europe/London (GMT, UTC+00:00)' },
                  { value: 'Asia/Dubai (GST)', label: 'Asia/Dubai (GST, UTC+04:00)' },
                  { value: 'Asia/Singapore (SGT)', label: 'Asia/Singapore (SGT, UTC+08:00)' },
                ]}
              />
              <SelectInput
                label="8. Currency"
                required
                value={formData.currency}
                onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
                options={[
                  { value: 'INR (₹)', label: 'INR (₹) - Indian Rupee' },
                  { value: 'USD ($)', label: 'USD ($) - US Dollar' },
                  { value: 'EUR (€)', label: 'EUR (€) - Euro' },
                  { value: 'GBP (£)', label: 'GBP (£) - British Pound' },
                  { value: 'AED (د.إ)', label: 'AED (د.إ) - UAE Dirham' },
                  { value: 'SGD ($)', label: 'SGD ($) - Singapore Dollar' },
                ]}
              />
            </div>
          </div>
        )}

        {/* STEP 3: INVENTORY SETUP */}
        {currentStep === 3 && (
          <div className="space-y-4 animate-fade-in">
            <div className="border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2 text-indigo-600">
                <Boxes className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900">Step 3 — Inventory Setup</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Configure facility network topology, inventory branches, and operational scope.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                type="number"
                label="1. Number of Branches"
                required
                value={formData.numberOfBranches.toString()}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    numberOfBranches: Math.max(1, parseInt(e.target.value, 10) || 1),
                  })
                }
                min={1}
                max={50}
                placeholder="1"
                helperText="Total branch facilities or testing centers under this tenant"
                error={errors.numberOfBranches}
              />
              <div className="p-4 bg-indigo-50/70 rounded-2xl border border-indigo-100 flex items-start gap-3">
                <Boxes className="w-5 h-5 text-indigo-600 shrink-0 mt-0.5" />
                <div className="text-xs text-indigo-900">
                  <span className="font-bold block mb-1">Multi-Branch Inventory Routing</span>
                  Each branch acts as a physical stock & calibration handling center. Organizations
                  and equipment intake requests can be segregated across these branches.
                </div>
              </div>
            </div>

            <Textarea
              label="Tenant Business Notes / Description"
              value={formData.description || ''}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Primary calibration laboratory network capabilities, accreditation scopes (NABL ISO/IEC 17025), and business specialization..."
            />
          </div>
        )}

        {/* STEP 4: ADMINISTRATION */}
        {currentStep === 4 && (
          <div className="space-y-4 animate-fade-in">
            <div className="border-b border-slate-100 pb-3 mb-4">
              <div className="flex items-center gap-2 text-indigo-600">
                <KeyRound className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900">Step 4 — Administration</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Set up the master administrator credentials for this enterprise tenant account.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="1. Admin Name"
                required
                value={formData.adminName}
                onChange={(e) => setFormData({ ...formData, adminName: e.target.value })}
                placeholder="e.g. Apex Super Admin"
                error={errors.adminName}
              />
              <TextInput
                type="email"
                label="2. Admin Email"
                required
                value={formData.adminEmail}
                onChange={(e) => setFormData({ ...formData, adminEmail: e.target.value })}
                placeholder="admin@apexmetrology.com"
                helperText="Login email for the tenant platform administrator"
                error={errors.adminEmail}
              />
            </div>

            {!isEdit && (
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <TextInput
                  type="password"
                  label="3. Password"
                  required
                  value={formData.adminPassword || ''}
                  onChange={(e) => setFormData({ ...formData, adminPassword: e.target.value })}
                  placeholder="••••••••••••"
                  helperText="Minimum 8 characters with letters, numbers, and symbols"
                  error={errors.adminPassword}
                />
                <div className="p-4 bg-amber-50/80 rounded-2xl border border-amber-200/80 flex items-start gap-3">
                  <Lock className="w-5 h-5 text-amber-600 shrink-0 mt-0.5" />
                  <div className="text-xs text-amber-900">
                    <span className="font-bold block mb-1">Administrative Privileges</span>
                    This user will receive full governance access to provision organizations,
                    manage staff roles, and oversee calibration operations for this tenant.
                  </div>
                </div>
              </div>
            )}
          </div>
        )}

        {/* STEP 5: REVIEW & CONFIRM */}
        {currentStep === 5 && (
          <div className="space-y-6 animate-fade-in">
            <div className="border-b border-slate-100 pb-3">
              <div className="flex items-center gap-2 text-emerald-600">
                <CheckCircle className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900">Step 5 — Review & Confirmation</h3>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                Verify all tenant onboarding details across the 4 sections before provisioning.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Section 1 Review */}
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-slate-200/70">
                  <span className="font-bold text-slate-800 flex items-center gap-1.5">
                    <Building2 className="w-4 h-4 text-indigo-600" />
                    1. Tenant Information
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentStep(1)}
                    className="text-[11px] text-indigo-600 font-semibold hover:underline"
                  >
                    Edit
                  </button>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">TENANT NAME:</span>
                  <span className="font-semibold text-slate-900">{formData.name}</span>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <span className="text-slate-400 block text-[10px]">CODE:</span>
                    <span className="font-mono font-bold text-indigo-700">{formData.code}</span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">TYPE:</span>
                    <span className="text-slate-700">{formData.tenantType}</span>
                  </div>
                </div>
                {formData.registrationNumber && (
                  <div>
                    <span className="text-slate-400 block text-[10px]">REG NO:</span>
                    <span className="font-mono text-slate-700">{formData.registrationNumber}</span>
                  </div>
                )}
                {formData.gstNumber && (
                  <div>
                    <span className="text-slate-400 block text-[10px]">GST NO:</span>
                    <span className="font-mono font-bold text-slate-800">{formData.gstNumber}</span>
                  </div>
                )}
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <span className="text-slate-400 block text-[10px]">EMAIL:</span>
                    <span className="text-slate-700">{formData.contactEmail}</span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">PHONE:</span>
                    <span className="font-mono text-slate-700">{formData.contactPhone}</span>
                  </div>
                </div>
              </div>

              {/* Section 2 Review */}
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-slate-200/70">
                  <span className="font-bold text-slate-800 flex items-center gap-1.5">
                    <MapPin className="w-4 h-4 text-emerald-600" />
                    2. Address Details
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentStep(2)}
                    className="text-[11px] text-indigo-600 font-semibold hover:underline"
                  >
                    Edit
                  </button>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">STREET ADDRESS:</span>
                  <span className="text-slate-800">
                    {formData.addressLine1}
                    {formData.addressLine2 ? `, ${formData.addressLine2}` : ''}
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <span className="text-slate-400 block text-[10px]">CITY / STATE:</span>
                    <span className="text-slate-800">
                      {formData.city}, {formData.state}
                    </span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">PINCODE:</span>
                    <span className="font-mono text-slate-800">{formData.pincode}</span>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div>
                    <span className="text-slate-400 block text-[10px]">TIMEZONE:</span>
                    <span className="text-slate-700">{formData.timezone}</span>
                  </div>
                  <div>
                    <span className="text-slate-400 block text-[10px]">CURRENCY:</span>
                    <span className="font-bold text-slate-800">{formData.currency}</span>
                  </div>
                </div>
              </div>

              {/* Section 3 Review */}
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-slate-200/70">
                  <span className="font-bold text-slate-800 flex items-center gap-1.5">
                    <Boxes className="w-4 h-4 text-cyan-600" />
                    3. Inventory Setup
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentStep(3)}
                    className="text-[11px] text-indigo-600 font-semibold hover:underline"
                  >
                    Edit
                  </button>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">NUMBER OF BRANCHES:</span>
                  <span className="font-mono font-bold text-slate-900 text-sm">
                    {formData.numberOfBranches} Branches
                  </span>
                </div>
                {formData.description && (
                  <div>
                    <span className="text-slate-400 block text-[10px]">BUSINESS NOTES:</span>
                    <p className="text-slate-700 line-clamp-2">{formData.description}</p>
                  </div>
                )}
              </div>

              {/* Section 4 Review */}
              <div className="p-4 rounded-2xl bg-slate-50 border border-slate-200/80 space-y-2 text-xs">
                <div className="flex items-center justify-between pb-2 border-b border-slate-200/70">
                  <span className="font-bold text-slate-800 flex items-center gap-1.5">
                    <KeyRound className="w-4 h-4 text-purple-600" />
                    4. Administration
                  </span>
                  <button
                    type="button"
                    onClick={() => setCurrentStep(4)}
                    className="text-[11px] text-indigo-600 font-semibold hover:underline"
                  >
                    Edit
                  </button>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">ADMIN NAME:</span>
                  <span className="font-semibold text-slate-900">{formData.adminName}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">ADMIN EMAIL:</span>
                  <span className="text-slate-800">{formData.adminEmail}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px]">STATUS:</span>
                  <StatusBadge status={formData.status} size="sm" />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Wizard Navigation Action Footer */}
        <div className="flex items-center justify-between gap-3 pt-6 border-t border-slate-100 mt-8">
          <div>
            {currentStep > 1 && (
              <button
                type="button"
                onClick={handleBack}
                className="inline-flex items-center gap-1.5 px-4 py-2.5 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition cursor-pointer"
              >
                <ArrowLeft className="w-4 h-4" />
                <span>Back</span>
              </button>
            )}
          </div>

          <div className="flex items-center gap-3">
            {currentStep < 5 ? (
              <button
                type="button"
                onClick={handleNext}
                className="inline-flex items-center gap-2 px-6 py-2.5 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-md shadow-indigo-600/20 transition cursor-pointer"
              >
                <span>Next: {stepsList[currentStep]?.title || 'Continue'}</span>
                <ArrowRight className="w-4 h-4" />
              </button>
            ) : (
              <button
                type="button"
                disabled={submitting}
                onClick={handleSubmit}
                className="inline-flex items-center gap-2 px-7 py-2.5 text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl shadow-md shadow-emerald-600/20 transition disabled:opacity-50 cursor-pointer"
              >
                <CheckCircle className="w-4 h-4" />
                <span>{isEdit ? 'Save Changes' : 'Complete Tenant Onboarding'}</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export const TenantDetailPage: React.FC = () => {
  const { tenantId } = useParams<{ tenantId: string }>();
  const [tenant, setTenant] = useState<Tenant | null>(null);
  const [tenantOrgs, setTenantOrgs] = useState<Organization[]>([]);
  const [loadingOrgs, setLoadingOrgs] = useState(true);
  const [addOrgModalOpen, setAddOrgModalOpen] = useState(false);
  const [submittingOrg, setSubmittingOrg] = useState(false);
  const [orgToDelete, setOrgToDelete] = useState<Organization | null>(null);
  const [deleteOrgModalOpen, setDeleteOrgModalOpen] = useState(false);

  const { showToast } = useNotification();
  const navigate = useNavigate();

  const [newOrgForm, setNewOrgForm] = useState({
    companyName: '',
    companyCode: '',
    companyType: 'Private Limited' as const,
    businessType: 'Calibration' as const,
    registrationNumber: '',
    gstNumber: '',
    companyEmail: '',
    companyPhone: '',
    addressLine1: '',
    addressLine2: '',
    city: '',
    state: '',
    country: 'India',
    pincode: '',
    timezone: 'Asia/Kolkata (IST)',
    currency: 'INR (₹)',
    numberOfBranches: 1,
    numberOfWarehouses: 1,
    adminName: '',
    adminEmail: '',
  });

  const loadTenantAndOrgs = async () => {
    if (!tenantId) return;
    setLoadingOrgs(true);
    try {
      const t = await tenantService.getById(tenantId);
      setTenant(t);
      const allOrgs = await organizationService.getAll();
      const orgs = allOrgs.filter((o) => o.tenantId === tenantId || (t && o.tenantId === t.code));
      setTenantOrgs(orgs);
    } catch {
      showToast('Error loading tenant facilities', 'error');
    } finally {
      setLoadingOrgs(false);
    }
  };

  useEffect(() => {
    loadTenantAndOrgs();
  }, [tenantId]);

  const handleCreateOrg = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!tenant) return;
    if (!newOrgForm.companyName.trim() || !newOrgForm.companyCode.trim()) {
      showToast('Facility Name and Code are required', 'warning');
      return;
    }

    setSubmittingOrg(true);
    try {
      await organizationService.create({
        ...newOrgForm,
        tenantId: tenant.id,
      });
      showToast(`Facility ${newOrgForm.companyName} created inside ${tenant.name}!`, 'success');
      setAddOrgModalOpen(false);
      setNewOrgForm({
        companyName: '',
        companyCode: '',
        companyType: 'Private Limited',
        businessType: 'Calibration',
        registrationNumber: '',
        gstNumber: '',
        companyEmail: '',
        companyPhone: '',
        addressLine1: '',
        addressLine2: '',
        city: '',
        state: '',
        country: 'India',
        pincode: '',
        timezone: 'Asia/Kolkata (IST)',
        currency: 'INR (₹)',
        numberOfBranches: 1,
        numberOfWarehouses: 1,
        adminName: '',
        adminEmail: '',
      });
      await loadTenantAndOrgs();
    } catch {
      showToast('Failed to create organization', 'error');
    } finally {
      setSubmittingOrg(false);
    }
  };

  if (!tenant) return null;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => navigate('/admin/tenants')}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-800 transition cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Tenants
        </button>
        <button
          type="button"
          onClick={() => navigate(`/admin/tenants/edit/${tenant.id}`)}
          className="inline-flex items-center gap-1.5 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition cursor-pointer"
        >
          <Edit2 className="w-3.5 h-3.5" />
          Edit Tenant
        </button>
      </div>

      <div className="bg-white rounded-3xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle space-y-6">
        {/* Banner Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-100 pb-5">
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className="text-[10px] font-mono font-bold text-indigo-700 bg-indigo-50 px-2.5 py-0.5 rounded-full border border-indigo-200/60">
                ID: {tenant.code}
              </span>
              <span className="text-xs text-slate-500">
                {tenant.tenantType || 'Enterprise'}
              </span>
            </div>
            <h1 className="text-2xl font-bold text-slate-900">{tenant.name}</h1>
          </div>
          <StatusBadge status={tenant.status} />
        </div>

        {/* 4 Detail Grid Sections */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* 1. Tenant Info */}
          <div className="bg-slate-50/70 rounded-2xl p-5 border border-slate-200/80 space-y-3">
            <h2 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-2 pb-2 border-b border-slate-200/70">
              <Building2 className="w-4 h-4 text-indigo-600" />
              1. Tenant Info
            </h2>
            <div className="grid grid-cols-2 gap-3 text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">TENANT NAME:</span>
                <span className="font-semibold text-slate-900">{tenant.name}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">TENANT ID / CODE:</span>
                <span className="font-mono font-bold text-indigo-700">{tenant.code}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">TENANT TYPE:</span>
                <span className="text-slate-700">{tenant.tenantType || 'Enterprise'}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">REGISTRATION NO:</span>
                <span className="font-mono text-slate-700">{tenant.registrationNumber || 'N/A'}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">GST NUMBER:</span>
                <span className="font-mono font-bold text-slate-800">{tenant.gstNumber || 'N/A'}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">TENANT PHONE:</span>
                <span className="font-mono text-slate-700">{tenant.contactPhone}</span>
              </div>
              <div className="col-span-2">
                <span className="text-slate-400 block text-[10px] font-semibold">TENANT EMAIL:</span>
                <span className="text-slate-800">{tenant.contactEmail}</span>
              </div>
            </div>
          </div>

          {/* 2. Address Details */}
          <div className="bg-slate-50/70 rounded-2xl p-5 border border-slate-200/80 space-y-3">
            <h2 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-2 pb-2 border-b border-slate-200/70">
              <MapPin className="w-4 h-4 text-emerald-600" />
              2. Address Details
            </h2>
            <div className="space-y-2.5 text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">LINE 1:</span>
                <span className="text-slate-800">{tenant.addressLine1 || 'N/A'}</span>
              </div>
              {tenant.addressLine2 && (
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">LINE 2:</span>
                  <span className="text-slate-800">{tenant.addressLine2}</span>
                </div>
              )}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">CITY:</span>
                  <span className="text-slate-800">{tenant.city || 'N/A'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">STATE:</span>
                  <span className="text-slate-800">{tenant.state || 'N/A'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">COUNTRY:</span>
                  <span className="text-slate-800">{tenant.country || 'India'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">PINCODE:</span>
                  <span className="font-mono text-slate-800">{tenant.pincode || 'N/A'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">TIMEZONE:</span>
                  <span className="text-slate-700">{tenant.timezone || 'Asia/Kolkata (IST)'}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">CURRENCY:</span>
                  <span className="font-bold text-slate-800">{tenant.currency || 'INR (₹)'}</span>
                </div>
              </div>
            </div>
          </div>

          {/* 3. Inventory Setup */}
          <div className="bg-slate-50/70 rounded-2xl p-5 border border-slate-200/80 space-y-3">
            <h2 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-2 pb-2 border-b border-slate-200/70">
              <Boxes className="w-4 h-4 text-cyan-600" />
              3. Inventory Setup
            </h2>
            <div className="space-y-3 text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">NUMBER OF BRANCHES:</span>
                <span className="font-mono font-bold text-slate-900 text-sm">
                  {tenant.numberOfBranches || 1} Branches
                </span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">AFFILIATED FACILITIES:</span>
                <span className="text-slate-700">
                  {tenantOrgs.length} Operating Facilities Registered
                </span>
              </div>
              {tenant.description && (
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold mb-1">
                    OVERVIEW & SCOPE:
                  </span>
                  <p className="text-xs text-slate-700 leading-relaxed bg-white p-3 rounded-xl border border-slate-200/60">
                    {tenant.description}
                  </p>
                </div>
              )}
            </div>
          </div>

          {/* 4. Administration */}
          <div className="bg-slate-50/70 rounded-2xl p-5 border border-slate-200/80 space-y-3">
            <h2 className="text-xs font-bold text-slate-900 uppercase tracking-wider flex items-center gap-2 pb-2 border-b border-slate-200/70">
              <KeyRound className="w-4 h-4 text-purple-600" />
              4. Administration
            </h2>
            <div className="space-y-3 text-xs">
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">ADMIN NAME:</span>
                <span className="font-semibold text-slate-900">{tenant.adminName || 'Super Admin'}</span>
              </div>
              <div>
                <span className="text-slate-400 block text-[10px] font-semibold">ADMIN EMAIL:</span>
                <span className="text-slate-800">{tenant.adminEmail || tenant.contactEmail}</span>
              </div>
              <div className="grid grid-cols-2 gap-3 pt-2 border-t border-slate-200/60">
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">ONBOARDED DATE:</span>
                  <span className="font-mono text-slate-600">{tenant.createdDate}</span>
                </div>
                <div>
                  <span className="text-slate-400 block text-[10px] font-semibold">LAST UPDATED:</span>
                  <span className="font-mono text-slate-600">{tenant.updatedDate}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* 5. ORGANIZATIONS INSIDE THIS TENANT (NO SEPARATE PAGE) */}
        <div className="pt-6 border-t border-slate-200/80 space-y-4">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
            <div>
              <div className="flex items-center gap-2">
                <Building className="w-5 h-5 text-indigo-600" />
                <h2 className="text-base font-bold text-slate-900">
                  Organizations & Operating Facilities ({tenantOrgs.length})
                </h2>
              </div>
              <p className="text-xs text-slate-500 mt-0.5">
                All operating facilities, laboratory networks, and regional testing centers managed strictly inside {tenant.name}.
              </p>
            </div>
            <button
              type="button"
              onClick={() => setAddOrgModalOpen(true)}
              className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition cursor-pointer"
            >
              <Plus className="w-4 h-4" />
              <span>Add Organization to Tenant</span>
            </button>
          </div>

          {loadingOrgs ? (
            <div className="text-center py-8 text-xs text-slate-400">Loading tenant organizations...</div>
          ) : tenantOrgs.length === 0 ? (
            <div className="text-center py-10 px-4 bg-slate-50 rounded-2xl border border-dashed border-slate-300 text-xs space-y-3">
              <div className="w-10 h-10 rounded-full bg-indigo-50 text-indigo-600 flex items-center justify-center mx-auto">
                <Building className="w-5 h-5" />
              </div>
              <div>
                <p className="font-semibold text-slate-700">No Organizations Registered Under This Tenant</p>
                <p className="text-slate-400 mt-1 max-w-sm mx-auto">
                  Organizations exist strictly inside enterprise tenants. Click below to provision the first laboratory or operating facility for {tenant.name}.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setAddOrgModalOpen(true)}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition inline-flex items-center gap-2 cursor-pointer"
              >
                <Plus className="w-4 h-4" />
                <span>Add First Organization</span>
              </button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {tenantOrgs.map((org) => (
                <div
                  key={org.id}
                  className="bg-slate-50/80 rounded-2xl p-5 border border-slate-200/90 space-y-3 hover:border-indigo-200 transition"
                >
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <div className="flex items-center gap-1.5 mb-1">
                        <span className="font-mono text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded border border-emerald-200/60">
                          {org.companyCode}
                        </span>
                        <span className="text-[11px] text-slate-500 font-medium">
                          {org.businessType || 'Laboratory'}
                        </span>
                      </div>
                      <h3 className="text-sm font-bold text-slate-900">{org.companyName}</h3>
                    </div>
                    <StatusBadge status={org.status} size="sm" />
                  </div>

                  <div className="grid grid-cols-2 gap-2 text-xs pt-2 border-t border-slate-200/60">
                    <div>
                      <span className="text-slate-400 block text-[10px] font-semibold">LOCATION:</span>
                      <span className="text-slate-700">{org.city ? `${org.city}, ${org.state}` : 'Headquarters'}</span>
                    </div>
                    <div>
                      <span className="text-slate-400 block text-[10px] font-semibold">SCALE:</span>
                      <span className="font-mono font-bold text-slate-800">
                        {org.numberOfBranches || 1} Branches • {org.numberOfWarehouses || 1} Warehouses
                      </span>
                    </div>
                    <div>
                      <span className="text-slate-400 block text-[10px] font-semibold">EMAIL:</span>
                      <span className="text-slate-700 truncate block">{org.companyEmail || 'N/A'}</span>
                    </div>
                    <div>
                      <span className="text-slate-400 block text-[10px] font-semibold">PHONE:</span>
                      <span className="font-mono text-slate-700">{org.companyPhone || 'N/A'}</span>
                    </div>
                    {org.gstNumber && (
                      <div className="col-span-2">
                        <span className="text-slate-400 block text-[10px] font-semibold">GST NUMBER:</span>
                        <span className="font-mono text-slate-800 font-semibold">{org.gstNumber}</span>
                      </div>
                    )}
                  </div>

                  <div className="flex items-center justify-between pt-2 border-t border-slate-200/60 text-xs">
                    <span className="text-[11px] text-slate-400">
                      Admin: <strong className="text-slate-700">{org.adminName || 'Facility Admin'}</strong>
                    </span>
                    <div className="flex items-center gap-1">
                      <button
                        type="button"
                        onClick={async () => {
                          await organizationService.toggleStatus(org.id);
                          showToast(`Organization set to ${org.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}`, 'info');
                          loadTenantAndOrgs();
                        }}
                        className="p-1.5 text-slate-400 hover:text-slate-700 rounded-lg hover:bg-slate-200/70 transition cursor-pointer"
                        title="Toggle Active Status"
                      >
                        <Power className="w-3.5 h-3.5" />
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          setOrgToDelete(org);
                          setDeleteOrgModalOpen(true);
                        }}
                        className="p-1.5 text-slate-400 hover:text-rose-600 rounded-lg hover:bg-rose-50 transition cursor-pointer"
                        title="Delete Organization"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* ADD ORGANIZATION MODAL (Directly Inside Tenant) */}
      <Modal
        isOpen={addOrgModalOpen}
        onClose={() => setAddOrgModalOpen(false)}
        title={`Add Organization to ${tenant.name}`}
        subtitle={`Provision a new operating facility directly inside tenant (${tenant.code})`}
        maxWidth="max-w-2xl"
        fullPage={false}
      >
        <form onSubmit={handleCreateOrg} className="space-y-4 p-1">
          <div className="p-3 bg-indigo-50/70 border border-indigo-100 rounded-xl text-xs text-indigo-900 leading-relaxed">
            <span className="font-bold">Architectural Boundary:</span> This organization will be provisioned directly under parent tenant <strong>{tenant.name} ({tenant.code})</strong>.
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Organization / Facility Name"
              required
              value={newOrgForm.companyName}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, companyName: e.target.value })}
              placeholder="e.g. Apex Bangalore Calibration Facility"
            />
            <TextInput
              label="Facility Code"
              required
              value={newOrgForm.companyCode}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, companyCode: e.target.value.toUpperCase() })}
              placeholder="e.g. APEX-BLR-01"
            />
            <SelectInput
              label="Company Legal Type"
              required
              value={newOrgForm.companyType}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, companyType: e.target.value as any })}
              options={[
                { value: 'Private Limited', label: 'Private Limited' },
                { value: 'Public Limited', label: 'Public Limited' },
                { value: 'Partnership', label: 'Partnership' },
                { value: 'Proprietorship', label: 'Proprietorship' },
                { value: 'LLP', label: 'LLP' },
              ]}
            />
            <SelectInput
              label="Business Type"
              required
              value={newOrgForm.businessType}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, businessType: e.target.value as any })}
              options={[
                { value: 'Calibration', label: 'Calibration & Metrology' },
                { value: 'Laboratory', label: 'Testing Laboratory' },
                { value: 'Manufacturing', label: 'Manufacturing' },
                { value: 'Service', label: 'Field Services' },
              ]}
            />
            <TextInput
              label="Facility Email"
              type="email"
              required
              value={newOrgForm.companyEmail}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, companyEmail: e.target.value })}
              placeholder="blr-lab@apexmetrology.com"
            />
            <TextInput
              label="Facility Phone"
              required
              value={newOrgForm.companyPhone}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, companyPhone: e.target.value })}
              placeholder="+91 80 2839 0001"
            />
            <TextInput
              label="GST Number"
              value={newOrgForm.gstNumber}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, gstNumber: e.target.value.toUpperCase() })}
              placeholder="29ABCDE1234F1Z5"
            />
            <TextInput
              label="Registration Number"
              value={newOrgForm.registrationNumber}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, registrationNumber: e.target.value })}
              placeholder="U74999KA2020PTC139888"
            />
            <TextInput
              label="Address Line 1"
              required
              value={newOrgForm.addressLine1}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, addressLine1: e.target.value })}
              placeholder="Plot 42, Industrial Suburb"
            />
            <TextInput
              label="City"
              required
              value={newOrgForm.city}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, city: e.target.value })}
              placeholder="Bangalore"
            />
            <TextInput
              label="State"
              required
              value={newOrgForm.state}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, state: e.target.value })}
              placeholder="Karnataka"
            />
            <TextInput
              label="Pincode"
              required
              value={newOrgForm.pincode}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, pincode: e.target.value })}
              placeholder="560058"
            />
            <TextInput
              type="number"
              label="Number of Branches"
              min={1}
              value={String(newOrgForm.numberOfBranches)}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, numberOfBranches: Number(e.target.value) || 1 })}
            />
            <TextInput
              type="number"
              label="Number of Warehouses"
              min={1}
              value={String(newOrgForm.numberOfWarehouses)}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, numberOfWarehouses: Number(e.target.value) || 1 })}
            />
            <TextInput
              label="Facility Admin Name"
              required
              value={newOrgForm.adminName}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, adminName: e.target.value })}
              placeholder="Facility General Manager"
            />
            <TextInput
              label="Facility Admin Email"
              type="email"
              required
              value={newOrgForm.adminEmail}
              onChange={(e) => setNewOrgForm({ ...newOrgForm, adminEmail: e.target.value })}
              placeholder="gm-blr@apexmetrology.com"
            />
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => setAddOrgModalOpen(false)}
              className="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-100 rounded-xl transition cursor-pointer"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submittingOrg}
              className="px-5 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs transition disabled:opacity-50 cursor-pointer"
            >
              {submittingOrg ? 'Provisioning...' : 'Provision Organization'}
            </button>
          </div>
        </form>
      </Modal>

      {/* DELETE ORGANIZATION CONFIRMATION MODAL */}
      <DeleteModal
        isOpen={deleteOrgModalOpen}
        onClose={() => setDeleteOrgModalOpen(false)}
        onConfirm={async () => {
          if (!orgToDelete) return;
          await organizationService.delete(orgToDelete.id);
          showToast('Organization deleted', 'info');
          setDeleteOrgModalOpen(false);
          setOrgToDelete(null);
          loadTenantAndOrgs();
        }}
        title="Delete Organization"
        itemName={orgToDelete?.companyName}
        message="Are you sure you want to remove this organization from the tenant? All linked laboratory operations will be affected."
      />
    </div>
  );
};
