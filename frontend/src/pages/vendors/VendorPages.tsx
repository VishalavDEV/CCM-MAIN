import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Briefcase,
  Plus,
  ArrowRight,
  ArrowLeft,
  CheckCircle2,
  Trash2,
  Eye,
  Shield,
  CreditCard,
  Building,
} from 'lucide-react';
import { Vendor, VendorFormData, CreditLevel } from '../../types/vendor';
import { vendorService } from '../../services/vendorService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { TextInput, SelectInput, NumberInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { DeleteModal } from '../../components/modals/AppModals';
import { mockStore } from '../../mock/initialStore';

export const VendorListPage: React.FC = () => {
  const [vendors, setVendors] = useState<Vendor[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [vendorToDelete, setVendorToDelete] = useState<Vendor | null>(null);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadVendors = async () => {
    setLoading(true);
    try {
      const data = await vendorService.getAll();
      setVendors(data);
    } catch {
      showToast('Unable to load vendors', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadVendors();
  }, []);

  const handleDelete = async () => {
    if (!vendorToDelete) return;
    try {
      await vendorService.delete(vendorToDelete.id);
      showToast('Vendor removed', 'info');
      setDeleteModalOpen(false);
      setVendorToDelete(null);
      loadVendors();
    } catch {
      showToast('Error deleting vendor', 'error');
    }
  };

  const columns: Column<Vendor>[] = [
    {
      key: 'vendorCode',
      header: 'Code / ID',
      sortable: true,
      render: (v) => (
        <span className="font-mono font-bold text-purple-700 bg-purple-50 px-2 py-0.5 rounded text-xs">
          {v.vendorCode}
        </span>
      ),
    },
    {
      key: 'vendorName',
      header: 'Vendor Name & Specialization',
      sortable: true,
      render: (v) => (
        <div>
          <span className="font-semibold text-slate-900 block">{v.vendorName}</span>
          <span className="text-[11px] text-slate-400">{v.businessType}</span>
        </div>
      ),
    },
    {
      key: 'contactPersonName',
      header: 'Contact Person',
      render: (v) => (
        <div>
          <span className="font-medium text-slate-800 block text-xs">{v.contactPersonName}</span>
          <span className="text-[11px] text-slate-400">{v.phoneNumber}</span>
        </div>
      ),
    },
    {
      key: 'creditLevel',
      header: 'Credit Level',
      render: (v) => {
        let badgeColor = 'bg-emerald-50 text-emerald-700 border-emerald-200';
        if (v.creditLevel === 'High Risk') badgeColor = 'bg-rose-50 text-rose-700 border-rose-200';
        else if (v.creditLevel === 'Average') badgeColor = 'bg-amber-50 text-amber-800 border-amber-200';

        return (
          <span className={`text-xs font-mono font-semibold px-2 py-0.5 rounded-full border ${badgeColor}`}>
            {v.creditLevel} ({v.creditScore}/100)
          </span>
        );
      },
    },
    {
      key: 'status',
      header: 'Status',
      render: (v) => <StatusBadge status={v.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (v) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={() => navigate(`/vendors/${v.id}`)}
            className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition"
            title="View Details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => {
              setVendorToDelete(v);
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Vendor Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Manage accredited external calibration suppliers, primary laboratories, and commercial terms.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/vendors/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-purple-600 hover:bg-purple-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Onboard New Vendor
        </button>
      </div>

      <DataTable
        data={vendors}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search vendors by name, code, contact, GST..."
        onRowClick={(v) => navigate(`/vendors/${v.id}`)}
      />

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete Vendor Profile"
        itemName={vendorToDelete?.vendorName}
        message="Are you sure you want to remove this vendor? Ongoing outsourced purchase orders may be affected."
      />
    </div>
  );
};

export const VendorOnboardingWizard: React.FC = () => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState<VendorFormData>({
    vendorName: '',
    vendorCode: '',
    businessType: 'Dimensional Metrology & Standards',
    contactPersonName: '',
    gstNumber: '',
    panNumber: '',
    email: '',
    phoneNumber: '',
    address: '',
    city: '',
    state: 'Karnataka',
    country: 'India',
    pincode: '',
    creditScore: 85,
    creditLevel: 'Good',
    paymentDetails: 'Net 30 Days via NEFT/RTGS',
    termsAndConditions: 'All calibration standards traceable to National Physical Laboratory (NPL)',
  });

  const [errors, setErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const validate = (curStep: number): boolean => {
    const errs: Record<string, string> = {};
    if (curStep === 1) {
      if (!formData.vendorName.trim()) errs.vendorName = 'Vendor name is required';
      if (!formData.vendorCode.trim()) errs.vendorCode = 'Vendor code is required';
      if (!formData.contactPersonName.trim()) errs.contactPersonName = 'Contact person name is required';
    } else if (curStep === 2) {
      if (!formData.email.trim()) errs.email = 'Corporate email is required';
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
      const created = await vendorService.create(formData);
      showToast(`Vendor ${created.vendorName} onboarded successfully!`, 'success');
      navigate(`/vendors/${created.id}`);
    } catch {
      showToast('Failed to onboard vendor', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const stepsList = [
    { num: 1, title: 'Vendor Information' },
    { num: 2, title: 'Contact Address' },
    { num: 3, title: 'Commercial Info' },
    { num: 4, title: 'Review & Submit' },
  ];

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <span className="text-xs font-mono font-bold text-purple-700 bg-purple-50 px-2.5 py-0.5 rounded-full uppercase tracking-wider">
            Supplier Intake
          </span>
          <h1 className="text-xl font-bold text-slate-900 mt-1">Vendor Onboarding Wizard</h1>
          <p className="text-xs text-slate-500">
            Register accredited sub-contractor laboratories and reference standards providers.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/vendors')}
          className="px-3 py-2 text-xs font-semibold text-slate-600 hover:text-slate-900 transition"
        >
          Cancel
        </button>
      </div>

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
                        ? 'bg-purple-600 text-white'
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
                        ? 'font-semibold text-purple-700'
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

      <div className="bg-white rounded-3xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle">
        {step === 1 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 1: Vendor Information
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Vendor Enterprise Name"
                required
                value={formData.vendorName}
                onChange={(e) => setFormData({ ...formData, vendorName: e.target.value })}
                placeholder="e.g. Fluke Calibration India Pvt Ltd"
                error={errors.vendorName}
              />
              <TextInput
                label="Vendor Code"
                required
                value={formData.vendorCode}
                onChange={(e) => setFormData({ ...formData, vendorCode: e.target.value.toUpperCase() })}
                placeholder="e.g. VEN-FLK-01"
                error={errors.vendorCode}
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="Business / Metrology Specialization"
                required
                value={formData.businessType}
                onChange={(e) => setFormData({ ...formData, businessType: e.target.value })}
                placeholder="e.g. Primary Electrical & Temp Standards"
              />
              <TextInput
                label="Contact Person Name"
                required
                value={formData.contactPersonName}
                onChange={(e) => setFormData({ ...formData, contactPersonName: e.target.value })}
                placeholder="e.g. Sanjay Deshmukh"
                error={errors.contactPersonName}
              />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                label="GST Number"
                value={formData.gstNumber || ''}
                onChange={(e) => setFormData({ ...formData, gstNumber: e.target.value.toUpperCase() })}
                placeholder="29AAACF3344A1Z9"
              />
              <TextInput
                label="PAN Number"
                value={formData.panNumber || ''}
                onChange={(e) => setFormData({ ...formData, panNumber: e.target.value.toUpperCase() })}
                placeholder="AAACF3344A"
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
                label="Corporate Email"
                type="email"
                required
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                placeholder="vendor@domain.com"
                error={errors.email}
              />
              <TextInput
                label="Phone Number"
                required
                value={formData.phoneNumber}
                onChange={(e) => setFormData({ ...formData, phoneNumber: e.target.value })}
                placeholder="+91 80 0000 0000"
                error={errors.phoneNumber}
              />
            </div>
            <TextInput
              label="Laboratory / Factory Address"
              required
              value={formData.address}
              onChange={(e) => setFormData({ ...formData, address: e.target.value })}
              placeholder="e.g. Outer Ring Road, Marathahalli"
              error={errors.address}
            />
            <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
              <TextInput
                label="City"
                required
                value={formData.city}
                onChange={(e) => setFormData({ ...formData, city: e.target.value })}
                placeholder="Bengaluru"
                error={errors.city}
              />
              <TextInput
                label="State"
                required
                value={formData.state}
                onChange={(e) => setFormData({ ...formData, state: e.target.value })}
                placeholder="Karnataka"
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
                placeholder="560037"
                error={errors.pincode}
              />
            </div>
          </div>
        )}

        {step === 3 && (
          <div className="space-y-4">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 3: Commercial Information & Rating
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <TextInput
                type="number"
                label="Credit Score (0 - 100)"
                min={0}
                max={100}
                value={String(formData.creditScore)}
                onChange={(e) => setFormData({ ...formData, creditScore: Number(e.target.value) || 75 })}
              />
              <SelectInput
                label="Credit Risk Level"
                value={formData.creditLevel}
                onChange={(e) => setFormData({ ...formData, creditLevel: e.target.value as CreditLevel })}
                options={[
                  { value: 'Excellent', label: 'Excellent - Prime Partner' },
                  { value: 'Good', label: 'Good - Standard Terms' },
                  { value: 'Average', label: 'Average - Escrow / Partial Advance' },
                  { value: 'High Risk', label: 'High Risk - 100% On Delivery Inspection' },
                ]}
              />
            </div>
            <TextInput
              label="Bank & Payment Details"
              value={formData.paymentDetails}
              onChange={(e) => setFormData({ ...formData, paymentDetails: e.target.value })}
              placeholder="Bank A/C, IFSC, NEFT details..."
            />
            <Textarea
              label="Standard Terms & Conditions"
              value={formData.termsAndConditions}
              onChange={(e) => setFormData({ ...formData, termsAndConditions: e.target.value })}
              placeholder="Payment terms, delivery TAT, and warranty policy..."
            />
          </div>
        )}

        {step === 4 && (
          <div className="space-y-4 text-xs">
            <h3 className="text-base font-bold text-slate-900 border-b border-slate-100 pb-2">
              Step 4: Review Vendor Profile
            </h3>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 space-y-1.5">
                <span className="font-bold text-slate-500 uppercase text-[10px] block mb-1">Company Profile</span>
                <div>Name: <span className="font-semibold text-slate-900">{formData.vendorName}</span></div>
                <div>Code: <span className="font-mono font-bold text-purple-700">{formData.vendorCode}</span></div>
                <div>Domain: <span className="text-slate-700">{formData.businessType}</span></div>
                <div>GST: <span className="font-mono text-slate-700">{formData.gstNumber || 'None'}</span></div>
                <div>PAN: <span className="font-mono text-slate-700">{formData.panNumber || 'None'}</span></div>
              </div>
              <div className="p-4 rounded-xl bg-slate-50 border border-slate-100 space-y-1.5">
                <span className="font-bold text-slate-500 uppercase text-[10px] block mb-1">Commercial Terms</span>
                <div>Rating: <span className="font-bold text-emerald-700">{formData.creditLevel} ({formData.creditScore})</span></div>
                <div>Payment Terms: <span className="text-slate-800">{formData.paymentDetails}</span></div>
                <div>Address: <span className="text-slate-800">{formData.address}, {formData.city}</span></div>
              </div>
            </div>
          </div>
        )}

        {/* Navigation Buttons */}
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
              className="inline-flex items-center gap-2 px-6 py-2.5 text-xs font-semibold text-white bg-purple-600 hover:bg-purple-700 rounded-xl shadow-md transition"
            >
              {submitting ? 'Registering...' : 'Complete Vendor Onboarding'}
              <CheckCircle2 className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export const VendorDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [vendor, setVendor] = useState<Vendor | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    if (id) {
      vendorService.getById(id).then((v: Vendor | null) => setVendor(v));
    }
  }, [id]);

  if (!vendor) {
    return <div className="text-center py-12 text-xs text-slate-400">Loading vendor details...</div>;
  }

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-purple-50 border border-purple-100 text-purple-700 flex items-center justify-center font-mono font-bold text-xl">
            {vendor.vendorCode.split('-')[1] || 'VEN'}
          </div>
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-xl font-bold text-slate-900">{vendor.vendorName}</h1>
              <StatusBadge status={vendor.status} size="sm" />
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              Code: <span className="font-mono">{vendor.vendorCode}</span> • GST: {vendor.gstNumber || 'N/A'}
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={() => navigate('/vendors')}
          className="px-3.5 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition"
        >
          Back to Vendors
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 text-xs">
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Supplier Commercial Standing
          </h3>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Credit Score:</span>
            <span className="font-mono font-bold text-emerald-700">{vendor.creditScore} / 100</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Credit Rating:</span>
            <span className="font-semibold text-slate-800">{vendor.creditLevel}</span>
          </div>
          <div className="py-1">
            <span className="text-slate-500 block mb-1">Payment Instructions:</span>
            <p className="text-slate-700 bg-slate-50 p-2 rounded-lg font-mono">{vendor.paymentDetails}</p>
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Contact & Address
          </h3>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Person:</span>
            <span className="font-semibold text-slate-800">{vendor.contactPersonName}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Phone:</span>
            <span className="text-slate-800">{vendor.phoneNumber}</span>
          </div>
          <div className="flex justify-between py-1 border-b border-slate-50">
            <span className="text-slate-500">Email:</span>
            <span className="text-slate-800">{vendor.email}</span>
          </div>
          <div className="py-1 text-slate-600 leading-relaxed">
            {vendor.address}, {vendor.city}, {vendor.state} - {vendor.pincode}
          </div>
        </div>

        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3">
          <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
            Purchase Orders
          </h3>
          <p className="text-slate-500">
            Active POs dispatched to this vendor: <span className="font-bold text-slate-800">{vendor.activePOCount || 0}</span>
          </p>
          <div className="mt-4 p-3 bg-purple-50 rounded-xl border border-purple-100 text-purple-900">
            Certified partner for secondary standards and outsourced high-precision calibrations.
          </div>
        </div>
      </div>
    </div>
  );
};
