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
} from 'lucide-react';
import { Tenant, TenantFormData } from '../../types/tenant';
import { tenantService } from '../../services/tenantService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { Modal, DeleteModal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { mockStore } from '../../mock/initialStore';

export const TenantListPage: React.FC = () => {
  const [tenants, setTenants] = useState<Tenant[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingTenant, setEditingTenant] = useState<Tenant | null>(null);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [tenantToDelete, setTenantToDelete] = useState<Tenant | null>(null);

  const [formData, setFormData] = useState<TenantFormData>({
    name: '',
    code: '',
    contactEmail: '',
    contactPhone: '',
    status: 'ACTIVE',
    description: '',
  });

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

  const handleOpenCreate = () => {
    setEditingTenant(null);
    setFormData({
      name: '',
      code: '',
      contactEmail: '',
      contactPhone: '',
      status: 'ACTIVE',
      description: '',
    });
    setModalOpen(true);
  };

  const handleOpenEdit = (t: Tenant, e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingTenant(t);
    setFormData({
      name: t.name,
      code: t.code,
      contactEmail: t.contactEmail,
      contactPhone: t.contactPhone,
      status: t.status,
      description: t.description || '',
    });
    setModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingTenant) {
        await tenantService.update(editingTenant.id, formData);
        showToast('Tenant updated successfully', 'success');
      } else {
        await tenantService.create(formData);
        showToast('Tenant created successfully', 'success');
      }
      setModalOpen(false);
      loadTenants();
    } catch (err: any) {
      showToast(err.message || 'Error saving tenant', 'error');
    }
  };

  const handleToggleStatus = async (id: string, e: React.MouseEvent) => {
    e.stopPropagation();
    try {
      const updated = await tenantService.toggleStatus(id);
      showToast(`Tenant status set to ${updated.status}`, 'info');
      loadTenants();
    } catch {
      showToast('Error toggling tenant status', 'error');
    }
  };

  const handleDelete = async () => {
    if (!tenantToDelete) return;
    try {
      await tenantService.delete(tenantToDelete.id);
      showToast('Tenant deleted successfully', 'info');
      setDeleteModalOpen(false);
      setTenantToDelete(null);
      loadTenants();
    } catch {
      showToast('Error deleting tenant', 'error');
    }
  };

  const columns: Column<Tenant>[] = [
    {
      key: 'code',
      header: 'Code / ID',
      sortable: true,
      render: (t) => (
        <div>
          <span className="font-mono font-bold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded text-xs">
            {t.code}
          </span>
          <div className="text-[10px] text-slate-400 font-mono mt-0.5">{t.id}</div>
        </div>
      ),
    },
    {
      key: 'name',
      header: 'Tenant Name',
      sortable: true,
      render: (t) => (
        <div>
          <span className="font-semibold text-slate-900 block">{t.name}</span>
          <span className="text-[11px] text-slate-500">{t.contactEmail}</span>
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (t) => <StatusBadge status={t.status} size="sm" />,
    },
    {
      key: 'organizationsCount',
      header: 'Organizations',
      sortable: true,
      render: (t) => (
        <span className="font-mono text-xs font-semibold text-slate-700">
          {t.organizationsCount} Org{t.organizationsCount !== 1 ? 's' : ''}
        </span>
      ),
    },
    {
      key: 'usersCount',
      header: 'Users',
      sortable: true,
      render: (t) => (
        <span className="font-mono text-xs font-semibold text-slate-700">{t.usersCount} Users</span>
      ),
    },
    {
      key: 'createdDate',
      header: 'Created Date',
      sortable: true,
      render: (t) => <span className="text-xs text-slate-500 font-mono">{t.createdDate}</span>,
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
            className="p-1.5 text-slate-400 hover:text-indigo-600 hover:bg-slate-100 rounded-lg transition"
            title="View Details"
          >
            <Eye className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={(e) => handleOpenEdit(t, e)}
            className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition"
            title="Edit Tenant"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={(e) => handleToggleStatus(t.id, e)}
            className="p-1.5 text-slate-400 hover:text-amber-600 hover:bg-slate-100 rounded-lg transition"
            title={t.status === 'ACTIVE' ? 'Deactivate' : 'Activate'}
          >
            <Power className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Tenant Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Configure multi-tenant commercial platforms, organizational clusters, and licenses.
          </p>
        </div>
        <button
          type="button"
          onClick={handleOpenCreate}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Create New Tenant
        </button>
      </div>

      <DataTable
        data={tenants}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search tenants by name, code, email..."
        onRowClick={(t) => navigate(`/admin/tenants/${t.id}`)}
      />

      {/* Create / Edit Modal */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingTenant ? 'Edit Tenant Details' : 'Create New Tenant'}
        maxWidth="max-w-md"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <TextInput
            label="Tenant Entity Name"
            required
            value={formData.name}
            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
            placeholder="e.g. Apex Metrology Group"
          />
          <TextInput
            label="Tenant Code"
            required
            value={formData.code}
            onChange={(e) => setFormData({ ...formData, code: e.target.value })}
            placeholder="e.g. APEX"
            helperText="Unique uppercase identifier for system isolation"
          />
          <div className="grid grid-cols-2 gap-3">
            <TextInput
              label="Contact Email"
              type="email"
              required
              value={formData.contactEmail}
              onChange={(e) => setFormData({ ...formData, contactEmail: e.target.value })}
              placeholder="contact@domain.com"
            />
            <TextInput
              label="Contact Phone"
              required
              value={formData.contactPhone}
              onChange={(e) => setFormData({ ...formData, contactPhone: e.target.value })}
              placeholder="+91 80 0000 0000"
            />
          </div>
          <SelectInput
            label="Initial Account Status"
            value={formData.status}
            onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
            options={[
              { value: 'ACTIVE', label: 'Active - Full platform privileges' },
              { value: 'INACTIVE', label: 'Inactive - Suspended' },
            ]}
          />
          <Textarea
            label="Description / License Notes"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Enter business scope, geographic license, or notes..."
          />
          <div className="flex items-center justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-3 py-2 text-xs font-medium text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 text-xs font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs"
            >
              {editingTenant ? 'Save Changes' : 'Create Tenant'}
            </button>
          </div>
        </form>
      </Modal>

      {/* Delete Confirmation Modal */}
      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete Tenant Organization"
        itemName={tenantToDelete?.name}
        message="Deleting this tenant will permanently remove access for all associated organizations, laboratories, and users."
      />
    </div>
  );
};

export const TenantDetailPage: React.FC = () => {
  const { tenantId } = useParams<{ tenantId: string }>();
  const [tenant, setTenant] = useState<Tenant | null>(null);
  const [activeTab, setActiveTab] = useState<'overview' | 'orgs' | 'users' | 'roles' | 'activity' | 'audit'>('overview');
  const navigate = useNavigate();

  useEffect(() => {
    if (tenantId) {
      tenantService.getById(tenantId).then((t) => setTenant(t));
    }
  }, [tenantId]);

  if (!tenant) {
    return <div className="text-center py-12 text-xs text-slate-400">Loading tenant details...</div>;
  }

  const tenantOrgs = mockStore.data.organizations.filter((o) => o.tenantId === tenant.id);
  const tenantUsers = mockStore.data.users.filter((u) => u.tenantId === tenant.id);
  const tenantAuditLogs = mockStore.data.auditLogs.filter((a) => a.tenantId === tenant.id);

  return (
    <div className="space-y-6">
      {/* Header Banner */}
      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex items-center gap-4">
          <div className="w-14 h-14 rounded-2xl bg-indigo-50 border border-indigo-100 text-indigo-700 flex items-center justify-center font-mono font-bold text-xl">
            {tenant.code}
          </div>
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-xl font-bold text-slate-900">{tenant.name}</h1>
              <StatusBadge status={tenant.status} size="sm" />
            </div>
            <p className="text-xs text-slate-500 mt-0.5">
              Tenant ID: <span className="font-mono">{tenant.id}</span> • Registered: {tenant.createdDate}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => navigate('/admin/tenants')}
            className="px-3.5 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition"
          >
            Back to Tenants
          </button>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex items-center gap-2 border-b border-slate-200 overflow-x-auto">
        {[
          { id: 'overview', label: 'Overview' },
          { id: 'orgs', label: `Organizations (${tenantOrgs.length})` },
          { id: 'users', label: `Users (${tenantUsers.length})` },
          { id: 'roles', label: 'Roles & Privileges' },
          { id: 'activity', label: 'Activity' },
          { id: 'audit', label: `Audit Logs (${tenantAuditLogs.length})` },
        ].map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id as any)}
            className={`px-4 py-2.5 text-xs font-semibold border-b-2 transition whitespace-nowrap ${
              activeTab === tab.id
                ? 'border-indigo-600 text-indigo-600'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab Content */}
      {activeTab === 'overview' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
            <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
              Tenant Master Profile
            </h3>
            <div className="space-y-2 text-xs">
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-500">Contact Email:</span>
                <span className="font-medium text-slate-900">{tenant.contactEmail}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-500">Contact Phone:</span>
                <span className="font-medium text-slate-900">{tenant.contactPhone}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-500">Total Laboratories / Orgs:</span>
                <span className="font-bold text-indigo-600 font-mono">{tenant.organizationsCount}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-slate-50">
                <span className="text-slate-500">Total User Licenses:</span>
                <span className="font-bold text-slate-900 font-mono">{tenant.usersCount}</span>
              </div>
              <div className="flex justify-between py-1">
                <span className="text-slate-500">Last Configuration Update:</span>
                <span className="text-slate-600 font-mono">{tenant.updatedDate}</span>
              </div>
            </div>
          </div>

          <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle">
            <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2 mb-3">
              Description & Operational Scope
            </h3>
            <p className="text-xs text-slate-600 leading-relaxed">
              {tenant.description || 'No detailed license notes provided for this tenant.'}
            </p>
            <div className="mt-6 p-4 rounded-xl bg-slate-50 border border-slate-200/80 text-xs">
              <span className="font-semibold text-slate-800 block mb-1">Architecture Note:</span>
              <p className="text-slate-500 text-[11px] leading-relaxed">
                Tenant isolation guarantees complete schema separation. The lowest business scope under each tenant is Organization (No sub-organization exists).
              </p>
            </div>
          </div>
        </div>
      )}

      {activeTab === 'orgs' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-semibold text-slate-900">Registered Organizations under {tenant.name}</h3>
            <button
              type="button"
              onClick={() => navigate('/organizations/new')}
              className="px-3 py-1.5 bg-indigo-600 text-white rounded-xl text-xs font-semibold shadow-xs"
            >
              + Onboard Organization
            </button>
          </div>
          <div className="divide-y divide-slate-100">
            {tenantOrgs.map((org) => (
              <div key={org.id} className="py-3 flex items-center justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-slate-900">{org.companyName}</span>
                    <span className="text-[10px] font-mono bg-slate-100 px-1.5 py-0.2 rounded font-semibold text-slate-600">
                      {org.companyCode}
                    </span>
                    <StatusBadge status={org.status} size="sm" />
                  </div>
                  <span className="text-[11px] text-slate-500">
                    {org.city}, {org.state} • {org.companyType} • {org.businessType}
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() => navigate(`/admin/organizations/${org.id}`)}
                  className="text-xs text-indigo-600 hover:underline font-semibold"
                >
                  View Org
                </button>
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'users' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle">
          <h3 className="text-sm font-semibold text-slate-900 mb-4">Assigned Personnel & Staff</h3>
          <div className="divide-y divide-slate-100">
            {tenantUsers.map((u) => (
              <div key={u.id} className="py-3 flex items-center justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs font-bold text-slate-900">{u.fullName}</span>
                    <span className="text-[10px] font-mono bg-indigo-50 text-indigo-700 px-1.5 py-0.2 rounded font-semibold">
                      {u.roleName}
                    </span>
                  </div>
                  <span className="text-[11px] text-slate-500">
                    {u.email} • {u.organizationName}
                  </span>
                </div>
                <StatusBadge status={u.status} size="sm" />
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
