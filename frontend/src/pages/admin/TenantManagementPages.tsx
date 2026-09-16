import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Building2,
  Plus,
  Edit2,
  Trash2,
  Power,
  Eye,
  Building,
  Users,
  Shield,
  Activity,
  History,
  CheckCircle,
  ArrowLeft,
  Save,
} from 'lucide-react';
import { Tenant, TenantFormData } from '../../types/tenant';
import { tenantService } from '../../services/tenantService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { DeleteModal } from '../../components/modals/AppModals';
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
      showToast('Tenant deleted', 'info');
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
      header: 'Tenant Group',
      sortable: true,
      render: (t) => (
        <div>
          <span className="font-semibold text-slate-900 block text-xs">{t.name}</span>
          <span className="text-[11px] text-slate-400 font-mono">Code: {t.code}</span>
        </div>
      ),
    },
    {
      key: 'organizationsCount',
      header: 'Facilities',
      render: (t) => (
        <span className="font-mono text-xs font-semibold text-slate-700 bg-slate-100 px-2 py-0.5 rounded">
          {t.organizationsCount} Org Labs
        </span>
      ),
    },
    {
      key: 'contactEmail',
      header: 'Contact',
      render: (t) => (
        <div className="text-xs text-slate-600">
          <div>{t.contactEmail}</div>
          <span className="text-[10px] text-slate-400 font-mono">{t.contactPhone}</span>
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
            className="p-1.5 text-slate-400 hover:text-indigo-600 rounded-lg transition"
            title="View Details"
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
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
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
        message="Are you sure you want to permanently remove this enterprise tenant?"
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

  const [formData, setFormData] = useState<TenantFormData>({
    name: '',
    code: '',
    contactEmail: '',
    contactPhone: '',
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
            contactEmail: t.contactEmail,
            contactPhone: t.contactPhone,
            status: t.status,
            description: t.description || '',
          });
        }
      });
    }
  }, [id, isEdit]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.code.trim()) {
      showToast('Tenant name and code are required', 'warning');
      return;
    }

    setSubmitting(true);
    try {
      if (isEdit && id) {
        await tenantService.update(id, formData);
        showToast('Tenant profile updated successfully', 'success');
      } else {
        await tenantService.create(formData);
        showToast('New enterprise tenant onboarded', 'success');
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
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => navigate('/admin/tenants')}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-800 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Tenants
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle space-y-6">
        <div className="border-b border-slate-100 pb-4">
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">
            {isEdit ? 'Edit Tenant Profile' : 'Onboard New Enterprise Tenant'}
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Provision a top-level enterprise tenant group for multi-facility calibration management.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Tenant Name"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g. Apex Metrology Group"
            />
            <TextInput
              label="Tenant Identifier Code"
              required
              value={formData.code}
              onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
              placeholder="e.g. APEX"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              type="email"
              label="Corporate Contact Email"
              value={formData.contactEmail}
              onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
              placeholder="contact@company.com"
            />
            <TextInput
              label="Contact Phone"
              value={formData.contactPhone}
              onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
              placeholder="+91 80 2845 0001"
            />
          </div>

          <SelectInput
            label="Tenant Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
            options={[
              { value: 'ACTIVE', label: 'Active' },
              { value: 'INACTIVE', label: 'Inactive' },
              { value: 'SUSPENDED', label: 'Suspended' },
            ]}
          />

          <Textarea
            label="Tenant Overview & Business Notes"
            value={formData.description || ''}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Primary NABL calibration laboratory network description..."
          />

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => navigate('/admin/tenants')}
              className="px-4 py-2.5 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="inline-flex items-center gap-2 px-6 py-2.5 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs transition disabled:opacity-50"
            >
              <Save className="w-4 h-4" />
              <span>{isEdit ? 'Save Changes' : 'Onboard Tenant'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export const TenantDetailPage: React.FC = () => {
  const { tenantId } = useParams<{ tenantId: string }>();
  const [tenant, setTenant] = useState<Tenant | null>(null);

  const navigate = useNavigate();

  useEffect(() => {
    if (tenantId) {
      tenantService.getById(tenantId).then(setTenant);
    }
  }, [tenantId]);

  if (!tenant) return null;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => navigate('/admin/tenants')}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-800 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Tenants
        </button>
        <button
          type="button"
          onClick={() => navigate(`/admin/tenants/edit/${tenant.id}`)}
          className="inline-flex items-center gap-1.5 px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Edit2 className="w-3.5 h-3.5" />
          Edit Tenant
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle space-y-6">
        <div className="flex items-center justify-between border-b border-slate-100 pb-4">
          <div>
            <h1 className="text-xl font-bold text-slate-900">{tenant.name}</h1>
            <span className="font-mono text-xs text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded font-bold mt-1 inline-block">
              {tenant.code}
            </span>
          </div>
          <StatusBadge status={tenant.status} />
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
          <div>
            <span className="text-slate-400 block font-semibold text-[10px]">CONTACT EMAIL:</span>
            <span className="text-slate-800 font-medium">{tenant.contactEmail}</span>
          </div>
          <div>
            <span className="text-slate-400 block font-semibold text-[10px]">CONTACT PHONE:</span>
            <span className="text-slate-800 font-mono">{tenant.contactPhone}</span>
          </div>
          <div>
            <span className="text-slate-400 block font-semibold text-[10px]">ORGANIZATIONS:</span>
            <span className="text-slate-800 font-bold">{tenant.organizationsCount} Facilities</span>
          </div>
          <div>
            <span className="text-slate-400 block font-semibold text-[10px]">CREATED DATE:</span>
            <span className="text-slate-800 font-mono">{tenant.createdDate}</span>
          </div>
        </div>

        {tenant.description && (
          <div className="pt-4 border-t border-slate-100">
            <span className="text-slate-400 block font-semibold text-[10px] mb-1">DESCRIPTION:</span>
            <p className="text-xs text-slate-700">{tenant.description}</p>
          </div>
        )}
      </div>
    </div>
  );
};
