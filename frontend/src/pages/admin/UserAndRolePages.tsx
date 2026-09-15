import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Users,
  Plus,
  ShieldAlert,
  KeyRound,
  History,
  Check,
  Edit2,
  Trash2,
  Power,
  ShieldCheck,
  CheckSquare,
  Square,
  Filter,
} from 'lucide-react';
import { User, UserFormData } from '../../types/user';
import { Role, RoleFormData } from '../../types/role';
import { AuditLogEntry } from '../../types/dispatch';
import { userService, roleService } from '../../services/userService';
import { auditService } from '../../services/executionServices';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { Modal, DeleteModal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, PasswordInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { MODULES_METADATA } from '../../constants/permissions';
import { mockStore } from '../../mock/initialStore';

export const UserListPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<User | null>(null);

  const [formData, setFormData] = useState<UserFormData>({
    fullName: '',
    email: '',
    phone: '',
    tenantId: 'ten-001',
    organizationId: 'org-001',
    roleId: 'role-admin',
    status: 'ACTIVE',
    password: '',
    confirmPassword: '',
  });

  const { showToast } = useNotification();

  const loadUsers = async () => {
    setLoading(true);
    try {
      const data = await userService.getAll();
      setUsers(data);
    } catch {
      showToast('Unable to load users', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadUsers();
  }, []);

  const handleOpenCreate = () => {
    setEditingUser(null);
    setFormData({
      fullName: '',
      email: '',
      phone: '',
      tenantId: 'ten-001',
      organizationId: 'org-001',
      roleId: 'role-admin',
      status: 'ACTIVE',
      password: '',
      confirmPassword: '',
    });
    setModalOpen(true);
  };

  const handleOpenEdit = (u: User) => {
    setEditingUser(u);
    setFormData({
      fullName: u.fullName,
      email: u.email,
      phone: u.phone,
      tenantId: u.tenantId,
      organizationId: u.organizationId,
      roleId: u.roleId,
      status: u.status,
    });
    setModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      if (editingUser) {
        await userService.update(editingUser.id, formData);
        showToast('User profile updated', 'success');
      } else {
        await userService.create(formData);
        showToast('New user registered successfully', 'success');
      }
      setModalOpen(false);
      loadUsers();
    } catch (err: any) {
      showToast(err.message || 'Error saving user', 'error');
    }
  };

  const handleDelete = async () => {
    if (!userToDelete) return;
    try {
      await userService.delete(userToDelete.id);
      showToast('User account deleted', 'info');
      setDeleteModalOpen(false);
      setUserToDelete(null);
      loadUsers();
    } catch {
      showToast('Error deleting user', 'error');
    }
  };

  const columns: Column<User>[] = [
    {
      key: 'fullName',
      header: 'Staff Member',
      sortable: true,
      render: (u) => (
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-indigo-600/10 text-indigo-700 font-bold text-xs flex items-center justify-center">
            {u.fullName[0]}
          </div>
          <div>
            <span className="font-semibold text-slate-900 block">{u.fullName}</span>
            <span className="text-[11px] text-slate-400">{u.email}</span>
          </div>
        </div>
      ),
    },
    {
      key: 'organizationName',
      header: 'Organization',
      sortable: true,
      render: (u) => <span className="text-xs text-slate-700 font-medium">{u.organizationName}</span>,
    },
    {
      key: 'roleName',
      header: 'Role',
      sortable: true,
      render: (u) => (
        <span className="font-mono text-xs font-semibold px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-100">
          {u.roleName}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (u) => <StatusBadge status={u.status} size="sm" />,
    },
    {
      key: 'lastLogin',
      header: 'Last Session',
      render: (u) => <span className="text-xs text-slate-400 font-mono">{u.lastLogin || 'Never'}</span>,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (u) => (
        <div className="flex items-center justify-end gap-1.5">
          <button
            type="button"
            onClick={() => handleOpenEdit(u)}
            className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition"
            title="Edit User"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={() => {
              setUserToDelete(u);
              setDeleteModalOpen(true);
            }}
            className="p-1.5 text-slate-400 hover:text-rose-600 hover:bg-rose-50 rounded-lg transition"
            title="Delete User"
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">User Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Manage laboratory staff, technicians, collection agents, and administrative accounts.
          </p>
        </div>
        <button
          type="button"
          onClick={handleOpenCreate}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Add User
        </button>
      </div>

      <DataTable
        data={users}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search users by name, email, role, organization..."
      />

      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingUser ? 'Edit User Profile' : 'Register New User'}
        maxWidth="max-w-md"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <TextInput
            label="Full Name"
            required
            value={formData.fullName}
            onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
            placeholder="e.g. Anand Sharma"
          />
          <div className="grid grid-cols-2 gap-3">
            <TextInput
              label="Corporate Email"
              type="email"
              required
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              placeholder="user@domain.com"
            />
            <TextInput
              label="Phone Number"
              required
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              placeholder="+91 98000 00000"
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <SelectInput
              label="Tenant Assignment"
              required
              value={formData.tenantId}
              onChange={(e) => setFormData({ ...formData, tenantId: e.target.value })}
              options={mockStore.data.tenants.map((t) => ({ value: t.id, label: t.name }))}
            />
            <SelectInput
              label="Organization"
              required
              value={formData.organizationId}
              onChange={(e) => setFormData({ ...formData, organizationId: e.target.value })}
              options={mockStore.data.organizations.map((o) => ({ value: o.id, label: o.companyName }))}
            />
          </div>
          <div className="grid grid-cols-2 gap-3">
            <SelectInput
              label="Role Assignment"
              required
              value={formData.roleId}
              onChange={(e) => setFormData({ ...formData, roleId: e.target.value })}
              options={mockStore.data.roles.map((r) => ({ value: r.id, label: r.name }))}
            />
            <SelectInput
              label="Account Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
              options={[
                { value: 'ACTIVE', label: 'Active' },
                { value: 'INACTIVE', label: 'Inactive' },
                { value: 'SUSPENDED', label: 'Suspended' },
              ]}
            />
          </div>
          {!editingUser && (
            <div className="grid grid-cols-2 gap-3 pt-1">
              <PasswordInput
                label="Set Initial Password"
                required
                value={formData.password || ''}
                onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                placeholder="••••••••••••"
              />
              <PasswordInput
                label="Confirm Password"
                required
                value={formData.confirmPassword || ''}
                onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                placeholder="••••••••••••"
              />
            </div>
          )}
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
              {editingUser ? 'Save Changes' : 'Create User'}
            </button>
          </div>
        </form>
      </Modal>

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete User"
        itemName={userToDelete?.fullName}
        message="Are you sure you want to delete this user? They will immediately lose access to the platform."
      />
    </div>
  );
};

export const RoleListPage: React.FC = () => {
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadRoles = async () => {
    setLoading(true);
    try {
      const data = await roleService.getAll();
      setRoles(data);
    } catch {
      showToast('Unable to load roles', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRoles();
  }, []);

  const columns: Column<Role>[] = [
    {
      key: 'name',
      header: 'Role Name',
      sortable: true,
      render: (r) => (
        <div>
          <span className="font-bold text-slate-900 block">{r.name}</span>
          <span className="text-[11px] text-slate-500">{r.description}</span>
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (r) => <StatusBadge status={r.status} size="sm" />,
    },
    {
      key: 'permissions',
      header: 'Permissions',
      render: (r) => (
        <span className="font-mono text-xs font-semibold text-indigo-700 bg-indigo-50 px-2.5 py-1 rounded-lg">
          {r.permissions.length} Grants
        </span>
      ),
    },
    {
      key: 'userCount',
      header: 'Assigned Users',
      sortable: true,
      render: (r) => (
        <span className="font-mono text-xs font-semibold text-slate-700">{r.userCount} Users</span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (r) => (
        <button
          type="button"
          onClick={() => navigate(`/admin/roles/${r.id}/edit`)}
          className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-indigo-600 hover:bg-indigo-50 rounded-xl transition"
        >
          <Edit2 className="w-3.5 h-3.5" />
          Edit Matrix
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Role Management</h1>
          <p className="text-xs text-slate-500 mt-1">
            Configure permission matrices across Tenants, Organizations, Clients, Calibration, and Invoices.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/roles/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Create New Role
        </button>
      </div>

      <DataTable data={roles} columns={columns} loading={loading} />
    </div>
  );
};

// Dynamic Permission Matrix Editor Page
export const RoleFormPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id && id !== 'new';
  const navigate = useNavigate();
  const { showToast } = useNotification();

  const [formData, setFormData] = useState<RoleFormData>({
    name: '',
    description: '',
    status: 'ACTIVE',
    permissions: [],
  });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isEdit) {
      roleService.getById(id).then((r) => {
        if (r) {
          setFormData({
            name: r.name,
            description: r.description,
            status: r.status,
            permissions: r.permissions || [],
          });
        }
      });
    }
  }, [id, isEdit]);

  const togglePermission = (permCode: string) => {
    setFormData((prev) => {
      const exists = prev.permissions.includes(permCode);
      return {
        ...prev,
        permissions: exists
          ? prev.permissions.filter((p) => p !== permCode)
          : [...prev.permissions, permCode],
      };
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name.trim()) {
      showToast('Role name is mandatory', 'warning');
      return;
    }

    setLoading(true);
    try {
      if (isEdit) {
        await roleService.update(id, formData);
        showToast('Role permissions updated successfully', 'success');
      } else {
        await roleService.create(formData);
        showToast('New role created successfully', 'success');
      }
      navigate('/admin/roles');
    } catch {
      showToast('Error saving role permissions', 'error');
    } finally {
      setLoading(false);
    }
  };

  const actionColumns = ['view', 'create', 'edit', 'delete', 'approve'] as const;

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900">
            {isEdit ? `Edit Role: ${formData.name}` : 'Create New System Role'}
          </h1>
          <p className="text-xs text-slate-500 mt-0.5">
            Configure dynamic granular permission matrix across all business modules.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/roles')}
          className="px-3.5 py-2 text-xs font-semibold text-slate-600 hover:text-slate-900 bg-white border border-slate-200 rounded-xl"
        >
          Cancel
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Role Name"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="e.g. Lead Metrologist"
            />
            <SelectInput
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value as any })}
              options={[
                { value: 'ACTIVE', label: 'Active' },
                { value: 'INACTIVE', label: 'Inactive' },
              ]}
            />
          </div>
          <Textarea
            label="Role Purpose / Description"
            value={formData.description}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Describe who this role applies to and operational responsibilities..."
          />
        </div>

        {/* Dynamic Permission Matrix Table */}
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-subtle overflow-hidden">
          <div className="px-6 py-4 border-b border-slate-100 flex items-center justify-between bg-slate-50/50">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Granular Permission Matrix</h3>
              <p className="text-xs text-slate-500">
                Grant or revoke capabilities per business module.
              </p>
            </div>
            <span className="text-xs font-mono font-bold text-indigo-700 bg-indigo-50 px-2.5 py-1 rounded-lg">
              {formData.permissions.length} Selected Grants
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-bold tracking-wider text-slate-500 uppercase">
                  <th className="px-6 py-3.5">Module</th>
                  {actionColumns.map((act) => (
                    <th key={act} className="px-4 py-3.5 text-center capitalize">
                      {act}
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-xs text-slate-700">
                {MODULES_METADATA.map((mod) => (
                  <tr key={mod.id} className="hover:bg-slate-50/70 transition">
                    <td className="px-6 py-3 font-semibold text-slate-900">
                      {mod.name}
                    </td>
                    {actionColumns.map((act) => {
                      const isSupported = (mod.actions as readonly string[]).includes(act);
                      const permCode = `${mod.id.replace(/s$/, '')}.${act}`;
                      const isChecked = formData.permissions.includes(permCode);

                      return (
                        <td key={act} className="px-4 py-3 text-center">
                          {isSupported ? (
                            <button
                              type="button"
                              onClick={() => togglePermission(permCode)}
                              className={`w-6 h-6 rounded-lg inline-flex items-center justify-center transition ${
                                isChecked
                                  ? 'bg-indigo-600 text-white shadow-2xs'
                                  : 'border border-slate-300 hover:border-indigo-400 bg-white'
                              }`}
                            >
                              {isChecked && <Check className="w-3.5 h-3.5 stroke-[3]" />}
                            </button>
                          ) : (
                            <span className="text-slate-300 select-none">—</span>
                          )}
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="p-4 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-2">
            <button
              type="button"
              onClick={() => navigate('/admin/roles')}
              className="px-4 py-2 text-xs font-semibold text-slate-600 hover:bg-slate-200 bg-slate-100 rounded-xl"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-5 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs"
            >
              {loading ? 'Saving...' : 'Save Permissions'}
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export const PermissionListPage: React.FC = () => {
  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">Permission Management</h1>
        <p className="text-xs text-slate-500 mt-1">
          Catalog of system authorization codes formatted as MODULE.ACTION for granular frontend and API guard evaluation.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {MODULES_METADATA.map((mod) => (
          <div key={mod.id} className="bg-white rounded-2xl border border-slate-200/90 p-5 shadow-subtle">
            <div className="flex items-center justify-between mb-3 border-b border-slate-100 pb-2">
              <span className="text-sm font-bold text-slate-900">{mod.name} Module</span>
              <span className="font-mono text-[10px] text-slate-400 uppercase font-semibold">
                {mod.id}
              </span>
            </div>
            <div className="space-y-2">
              {mod.actions.map((act) => {
                const code = `${mod.id.replace(/s$/, '')}.${act}`;
                return (
                  <div key={act} className="flex items-center justify-between text-xs py-1 border-b border-slate-50">
                    <span className="text-slate-600 capitalize">{act} records</span>
                    <span className="font-mono text-[11px] font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
                      {code}
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export const AuditLogsPage: React.FC = () => {
  const [logs, setLogs] = useState<AuditLogEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    auditService.getAll().then((data) => {
      setLogs(data);
      setLoading(false);
    });
  }, []);

  const columns: Column<AuditLogEntry>[] = [
    {
      key: 'timestamp',
      header: 'Timestamp',
      sortable: true,
      render: (l) => <span className="font-mono text-xs text-slate-500">{l.timestamp}</span>,
    },
    {
      key: 'userName',
      header: 'User & Role',
      sortable: true,
      render: (l) => (
        <div>
          <span className="font-semibold text-slate-900 block">{l.userName}</span>
          <span className="text-[10px] text-indigo-600 font-mono font-semibold">{l.role}</span>
        </div>
      ),
    },
    {
      key: 'module',
      header: 'Module / Action',
      sortable: true,
      render: (l) => (
        <div>
          <span className="font-mono text-xs font-bold text-slate-800 uppercase">
            {l.module}.{l.action}
          </span>
          <div className="text-[10px] text-slate-400 font-mono mt-0.5">{l.recordIdentifier}</div>
        </div>
      ),
    },
    {
      key: 'newValue',
      header: 'Audit Trail Detail',
      render: (l) => (
        <div className="text-xs text-slate-600 max-w-md font-mono">
          {l.newValue || l.oldValue}
        </div>
      ),
    },
    {
      key: 'ipAddress',
      header: 'IP Address',
      render: (l) => <span className="font-mono text-xs text-slate-400">{l.ipAddress || 'Internal'}</span>,
    },
    {
      key: 'result',
      header: 'Result',
      render: (l) => (
        <span className="font-mono text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded">
          {l.result}
        </span>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">Enterprise Audit Logs</h1>
        <p className="text-xs text-slate-500 mt-1">
          Immutable event stream capturing all status changes, approvals, overrides, and security events.
        </p>
      </div>

      <DataTable
        data={logs}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search audit logs by user, action, module, record..."
      />
    </div>
  );
};
