import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Contact2,
  Plus,
  ArrowRight,
  ArrowLeft,
  CheckCircle2,
  Building,
  Mail,
  Phone,
  MapPin,
  FileText,
  Clock,
  Eye,
  Trash2,
  Edit2,
  Save,
} from 'lucide-react';
import { Client, ClientFormData, ClientAccountStatus } from '../../types/client';
import { clientService } from '../../services/clientService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { TextInput, SelectInput, NumberInput } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { DeleteModal } from '../../components/modals/AppModals';
import { mockStore } from '../../mock/initialStore';

export const ClientListPage: React.FC = () => {
  const [clients, setClients] = useState<Client[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [clientToDelete, setClientToDelete] = useState<Client | null>(null);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadClients = async () => {
    setLoading(true);
    try {
      const data = await clientService.getAll();
      setClients(data);
    } catch {
      showToast('Unable to load clients', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadClients();
  }, []);

  const handleDelete = async () => {
    if (!clientToDelete) return;
    try {
      await clientService.delete(clientToDelete.id);
      showToast('Client removed', 'info');
      setDeleteModalOpen(false);
      setClientToDelete(null);
      loadClients();
    } catch {
      showToast('Error deleting client', 'error');
    }
  };

  const columns: Column<Client>[] = [
    {
      key: 'clientCode',
      header: 'Code / ID',
      sortable: true,
      render: (c) => (
        <span className="font-mono font-bold text-teal-700 bg-teal-50 px-2 py-0.5 rounded text-xs">
          {c.clientCode}
        </span>
      ),
    },
    {
      key: 'clientName',
      header: 'Client Corporate Name',
      sortable: true,
      render: (c) => (
        <div>
          <span className="font-semibold text-slate-900 block">{c.clientName}</span>
          <span className="text-[11px] text-slate-400">{c.businessType}</span>
        </div>
      ),
    },
    {
      key: 'contactPersonName',
      header: 'Primary Contact',
      render: (c) => (
        <div>
          <span className="font-medium text-slate-800 block text-xs">{c.contactPersonName}</span>
          <span className="text-[11px] text-slate-400">{c.contactPersonContactNumber}</span>
        </div>
      ),
    },
    {
      key: 'city',
      header: 'Location',
      render: (c) => (
        <span className="text-xs text-slate-600">
          {c.city}, {c.state}
        </span>
      ),
    },
    {
      key: 'accountStatus',
      header: 'Status',
      render: (c) => <StatusBadge status={c.accountStatus} size="sm" />,
    },
    {
      key: 'activeRequestsCount',
      header: 'Active Jobs',
      render: (c) => (
        <span className="font-mono font-bold text-xs text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
          {c.activeRequestsCount || 0}
        </span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (c) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={() => navigate(`/clients/${c.id}`)}
            className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition"
            title="View Details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => {
              setClientToDelete(c);
              setDeleteModalOpen(true);
            }}
            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition"
            title="Delete"
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Client Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Maintain industrial customer accounts, site locations, GST profiles, and commercial agreements.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/clients/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Onboard New Client
        </button>
      </div>

      <DataTable
        data={clients}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search clients by name, code, contact, GST..."
        onRowClick={(c) => navigate(`/clients/${c.id}`)}
      />

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete Client Account"
        itemName={clientToDelete?.clientName}
        message="Deleting this client will archive historical records and disable incoming requests."
      />
    </div>
  );
};

export const ClientOnboardingWizard: React.FC = () => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState<ClientFormData>({
    clientName: '',
    clientCode: '',
    businessType: 'Automotive Manufacturing',
    gstNumber: '',
    contactPersonName: '',
    contactPersonContactNumber: '',
    email: '',
    phoneNumber: '',
    address: '',
    city: '',
    state: 'Maharashtra',
    country: 'India',
    pincode: '',
    currency: 'INR',
    numberOfBranches: 1,
    numberOfWarehouses: 1,
    onboardingDate: new Date().toISOString().split('T')[0],
    accountStatus: 'Active',
    msmeNumber: '',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const validate = (curStep: number): boolean => {
    const errs: Record<string, string> = {};
    if (curStep === 1) {
      if (!formData.clientName.trim()) errs.clientName = 'Client name is required';
      if (!formData.clientCode.trim()) errs.clientCode = 'Client code is required';
      if (!formData.businessType.trim()) errs.businessType = 'Business type is required';
      if (!formData.contactPersonName.trim()) errs.contactPersonName = 'Contact person name is required';
    } else if (curStep === 2) {
      if (!formData.email.trim()) errs.email = 'Email address is required';
      if (!formData.phoneNumber.trim()) errs.phoneNumber = 'Phone number is required';
      if (!formData.address.trim()) errs.address = 'Address is required';
      if (!formData.city.trim()) errs.city = 'City is required';
      if (!formData.pincode.trim()) errs.pincode = 'Pincode is required';
    }
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleNext = () => {
    if (validate(step)) setStep((prev) => Math.min(prev + 1, 4));
  };

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      const created = await clientService.create(formData);
      showToast(`Client ${created.clientName} created successfully!`, 'success');
      navigate(`/clients/${created.id}`);
    } catch {
      showToast('Failed to onboard client', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const stepsList = [
    { num: 1, title: 'Client Information' },
    { num: 2, title: 'Contact Address' },
    { num: 3, title: 'Business Setup' },
    { num: 4, title: 'Review & Submit' },
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs font-mono font-bold text-teal-700 bg-teal-50 px-2.5 py-0.5 rounded-full uppercase tracking-wider">
            Customer Intake
          </span>
          <h1 className="text-xl font-bold text-slate-900 mt-1">Client Onboarding Wizard</h1>
          <p className="text-xs text-slate-500">
            Register industrial customer entity, contact point, and commercial dispatch address.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/clients')}
          className="px-3 py-2 text-xs font-semibold text-slate-600 hover:text-slate-900 transition"
        >
          Cancel
        </button>
      </div>

      {/* Stepper Header */}
      <div className="bg-white rounded-2xl border border-slate-200/90 p-4 shadow-subtle overflow-x-auto">
        <div className="flex items-center justify-between min-w-[500px]">
          {stepsList.map((s, idx) => {
            const isCompleted = step > s.num;
            const isCurrent = step === s.num;
            return (
              <React.Fragment key={s.num}>
                <div className="flex items-center gap-2.5">
                  <div
                    className={`w-7 h-7 rounded-full flex items-center justify-center text-xs font-bold transition ${
                      isCompleted
                        ? 'bg-teal-600 text-white'
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
                        ? 'font-semibold text-teal-700'
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

      {/* Content Form */}
      <div className="bg-white rounded-3xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle">
        {step === 1 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 1: Client Information
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Client Corporate Name"
                required
                value={formData.clientName}
                onChange={(e) => setFormData({ ...formData, clientName: e.target.value })}
                placeholder="e.g. Tata Motors Limited"
                error={errors.clientName}
              />
              <TextInput
                label="Client Code"
                required
                value={formData.clientCode}
                onChange={(e) => setFormData({ ...formData, clientCode: e.target.value.toUpperCase() })}
                placeholder="e.g. CLI-TATA-01"
                error={errors.clientCode}
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Business Type"
                required
                value={formData.businessType}
                onChange={(e) => setFormData({ ...formData, businessType: e.target.value })}
                placeholder="e.g. Automotive Manufacturing"
                error={errors.businessType}
              />
              <TextInput
                label="GST Number"
                value={formData.gstNumber || ''}
                onChange={(e) => setFormData({ ...formData, gstNumber: e.target.value.toUpperCase() })}
                placeholder="e.g. 27AAACT2727Q1ZW"
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Contact Person Name"
                required
                value={formData.contactPersonName}
                onChange={(e) => setFormData({ ...formData, contactPersonName: e.target.value })}
                placeholder="e.g. Anand Kulkarni"
                error={errors.contactPersonName}
              />
              <TextInput
                label="Contact Person Contact Number"
                value={formData.contactPersonContactNumber}
                onChange={(e) => setFormData({ ...formData, contactPersonContactNumber: e.target.value })}
                placeholder="+91 98201 44550"
              />
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 2: Contact Address
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Corporate Email Address"
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder="quality@client.com"
                error={errors.email}
              />
              <TextInput
                label="Office Phone Number"
                required
                value={formData.phoneNumber}
                onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                placeholder="+91 20 6613 2000"
                error={errors.phoneNumber}
              />
            </div>
            <TextInput
              label="Physical Plant / Billing Address"
              required
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              placeholder="e.g. Pimpri Works, Mumbai-Pune Highway"
              error={errors.address}
            />
            <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
              <TextInput
                label="City"
                required
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                placeholder="Pune"
                error={errors.city}
              />
              <TextInput
                label="State"
                required
                value={formData.state}
                onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                placeholder="Maharashtra"
              />
              <TextInput
                label="Country"
                required
                value={formData.country}
                onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                placeholder="India"
              />
              <TextInput
                label="Pincode"
                required
                value={formData.pincode}
                onChange={(e) => setFormData({ ...formData, pincode: e.target.value })}
                placeholder="411018"
                error={errors.pincode}
              />
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 3: Business Setup & MSME
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <TextInput
                label="Currency"
                required
                value={formData.currency}
                onChange={(e) => setFormData({ ...formData, currency: e.target.value })}
                placeholder="INR"
              />
              <TextInput
                type="number"
                label="Number of Branches"
                value={String(formData.numberOfBranches)}
                onChange={(e) => setFormData({ ...formData, numberOfBranches: Number(e.target.value) || 1 })}
              />
              <TextInput
                type="number"
                label="Number of Warehouses"
                value={String(formData.numberOfWarehouses)}
                onChange={(e) => setFormData({ ...formData, numberOfWarehouses: Number(e.target.value) || 1 })}
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <TextInput
                type="date"
                label="Onboarding Date"
                value={formData.onboardingDate}
                onChange={(e) => setFormData({ ...formData, onboardingDate: e.target.value })}
              />
              <SelectInput
                label="Account Status"
                value={formData.accountStatus}
                onChange={(e) => setFormData({ ...formData, accountStatus: e.target.value as ClientAccountStatus })}
                options={[
                  { value: 'Active', label: 'Active' },
                  { value: 'Inactive', label: 'Inactive' },
                  { value: 'Pending', label: 'Pending' },
                  { value: 'Suspended', label: 'Suspended' },
                ]}
              />
              <TextInput
                label="MSME Number (Optional)"
                value={formData.msmeNumber || ''}
                onChange={(e) => setFormData({ ...formData, msmeNumber: e.target.value })}
                placeholder="UDYAM-MH-26-0001429"
              />
            </div>
          </div>
        )}

        {step === 4 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 4: Review Client Details
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 space-y-1.5">
                <span className="font-bold text-slate-500 uppercase text-[10px] block mb-1">Company Profile</span>
                <div>Name: <span className="font-semibold text-slate-900">{formData.clientName}</span></div>
                <div>Code: <span className="font-mono font-bold text-teal-700">{formData.clientCode}</span></div>
                <div>Domain: <span className="text-slate-700">{formData.businessType}</span></div>
                <div>GST: <span className="font-mono text-slate-700">{formData.gstNumber || 'None'}</span></div>
                <div>Contact: <span className="text-slate-900 font-medium">{formData.contactPersonName} ({formData.contactPersonContactNumber})</span></div>
              </div>
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 space-y-1.5">
                <span className="font-bold text-slate-500 uppercase text-[10px] block mb-1">Contact & Address</span>
                <div>Email: <span className="text-slate-800">{formData.email}</span></div>
                <div>Phone: <span className="text-slate-800">{formData.phoneNumber}</span></div>
                <div>Address: <span className="text-slate-800">{formData.address}, {formData.city}, {formData.state} - {formData.pincode}</span></div>
                <div>Currency: <span className="font-semibold">{formData.currency}</span> • Status: <span className="text-teal-700 font-bold">{formData.accountStatus}</span></div>
              </div>
            </div>
          </div>
        )}

        {/* Footer Actions */}
        <div className="flex items-center justify-between pt-6 mt-6 border-t border-slate-100">
          {step > 1 ? (
            <button
              type="button"
              onClick={() => setStep((p) => p - 1)}
              className="inline-flex items-center gap-1.5 px-4 py-2.5 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition"
            >
              <ArrowLeft className="w-4 h-4" />
              Previous
            </button>
          ) : <div />}

          {step < 4 ? (
            <button
              type="button"
              onClick={handleNext}
              className="inline-flex items-center gap-1.5 px-5 py-2.5 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs transition"
            >
              Next Step
              <ArrowRight className="w-4 h-4" />
            </button>
          ) : (
            <button
              type="button"
              onClick={handleSubmit}
              disabled={submitting}
              className="inline-flex items-center gap-2 px-6 py-2.5 text-xs font-semibold text-white bg-teal-600 hover:bg-teal-700 rounded-xl shadow-md transition"
            >
              {submitting ? 'Registering...' : 'Create Client Account'}
              <CheckCircle2 className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export const ClientDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [client, setClient] = useState<Client | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    if (id) {
      clientService.getById(id).then((c) => setClient(c));
    }
  }, [id]);

  if (!client) {
    return <div className="text-center py-12 text-xs text-slate-400">Loading client profile...</div>;
  }

  const clientRequests = mockStore.data.requests.filter((r) => r.clientId === client.id);

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-teal-50 border border-teal-100 text-teal-700 flex items-center justify-center font-mono font-bold text-xl">
            {client.clientCode.split('-')[1] || 'CLI'}
          </div>
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-xl font-bold text-slate-900">{client.clientName}</h1>
              <StatusBadge status={client.accountStatus} size="sm" />
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              Code: <span className="font-mono">{client.clientCode}</span> • GST: {client.gstNumber || 'N/A'}
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={() => navigate('/clients')}
          className="px-3.5 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition"
        >
          Back to Clients
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3 text-xs">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Contact Person
          </h3>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Name:</span>
            <span className="font-semibold text-slate-900">{client.contactPersonName}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Phone:</span>
            <span className="text-slate-800">{client.contactPersonContactNumber}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Corporate Email:</span>
            <span className="text-slate-800">{client.email}</span>
          </div>
          <div className="flex justify-between py-1">
            <span className="text-slate-500">Main Office Phone:</span>
            <span className="text-slate-800">{client.phoneNumber}</span>
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3 text-xs">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Address & Setup
          </h3>
          <div className="py-1 text-slate-700 leading-relaxed border-b border-slate-50">
            {client.address}
            <br />
            {client.city}, {client.state} - {client.pincode}, {client.country}
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Branches:</span>
            <span className="font-mono font-bold text-slate-800">{client.numberOfBranches}</span>
          </div>
          <div className="flex justify-between py-1">
            <span className="text-slate-500">Warehouses:</span>
            <span className="font-mono font-bold text-slate-800">{client.numberOfWarehouses}</span>
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3 text-xs">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Calibration Orders ({clientRequests.length})
          </h3>
          <div className="divide-y divide-slate-100">
            {clientRequests.map((r) => (
              <div
                key={r.id}
                onClick={() => navigate(`/requests/${r.id}`)}
                className="py-2 flex items-center justify-between hover:bg-slate-50 cursor-pointer rounded p-1"
              >
                <div>
                  <span className="font-mono font-bold text-indigo-700 block">{r.requestNumber}</span>
                  <span className="text-[10px] text-slate-400">{r.items.length} items</span>
                </div>
                <StatusBadge status={r.status} size="sm" />
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};
