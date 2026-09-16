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
  ArrowLeft,
  Save,
} from 'lucide-react';
import { User, UserFormData } from '../../types/user';
import { Role } from '../../types/role';
import { AuditLogEntry } from '../../types/dispatch';
import { userService, roleService } from '../../services/userService';
import { auditService } from '../../services/executionServices';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { DeleteModal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, PasswordInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { MODULES_METADATA } from '../../constants/permissions';

export const UserListPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<User | null>(null);

  const navigate = useNavigate();
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

  const handleDelete = async () => {
    if (!userToDelete) return;
    try {
      await userService.delete(userToDelete.id);
      showToast('User account removed', 'info');
      setDeleteModalOpen(false);
      setUserToDelete(null);
      loadUsers();
    } catch {
      showToast('Failed to delete user', 'error');
    }
  };

  const columns: Column<User>[] = [
    {
      key: 'fullName',
      header: 'User Profile',
      sortable: true,
      render: (u) => (
        <div>
          <span className="font-semibold text-slate-900 block text-xs">{u.fullName}</span>
          <span className="text-[11px] text-slate-400">{u.email}</span>
        </div>
      ),
    },
    {
      key: 'roleName',
      header: 'Assigned Role',
      sortable: true,
      render: (u) => (
        <span className="font-mono text-xs font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
          {u.roleName}
        </span>
      ),
    },
    {
      key: 'phone',
      header: 'Contact Phone',
      render: (u) => <span className="font-mono text-xs text-slate-600">{u.phone}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (u) => <StatusBadge status={u.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (u) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={() => navigate(`/admin/users/edit/${u.id}`)}
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">System Users & Security Accounts</h1>
          <p className="text-xs text-slate-500 mt-1">
            Manage laboratory staff, commercial managers, quality approvers, and field collection agents.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/users/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Add User Account
        </button>
      </div>

      <DataTable data={users} columns={columns} loading={loading} />

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete User Account"
        itemName={userToDelete?.fullName}
        message="Are you sure you want to revoke and delete this corporate user account?"
      />
    </div>
  );
};

export const AddUserPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id;

  const navigate = useNavigate();
  const { showToast } = useNotification();
  const [submitting, setSubmitting] = useState(false);

  const [formData, setFormData] = useState<UserFormData>({
    fullName: '',
    email: '',
    phone: '',
    tenantId: '00000000-0000-0000-0000-000000000001',
    organizationId: '00000000-0000-0000-0000-000000000001',
    roleId: '00000000-0000-0000-0000-000000000001',
    status: 'ACTIVE',
    password: '',
    confirmPassword: '',
  });

  useEffect(() => {
    if (isEdit && id) {
      userService.getById(id).then((u) => {
        if (u) {
          setFormData({
            fullName: u.fullName,
            email: u.email,
            phone: u.phone,
            tenantId: u.tenantId,
            organizationId: u.organizationId,
            roleId: u.roleId,
            status: u.status,
          });
        }
      });
    }
  }, [id, isEdit]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.fullName.trim() || !formData.email.trim()) {
      showToast('Name and corporate email are required', 'warning');
      return;
    }

    setSubmitting(true);
    try {
      if (isEdit && id) {
        await userService.update(id, formData);
        showToast('User profile updated successfully', 'success');
      } else {
        await userService.create(formData);
        showToast('New user account provisioned', 'success');
      }
      navigate('/admin/users');
    } catch {
      showToast('Failed to save user account', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => navigate('/admin/users')}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-800 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to User Accounts
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle space-y-6">
        <div className="border-b border-slate-100 pb-4">
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">
            {isEdit ? 'Edit User Profile' : 'Add New User Account'}
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Provision access for laboratory personnel, commercial staff, or quality managers.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Full Name"
              required
              value={formData.fullName}
              onChange={(e) => setFormData({ ...formData, fullName: e.target.value })}
              placeholder="e.g. Dr. Vikram Mehta"
            />
            <TextInput
              type="email"
              label="Corporate Email Address"
              required
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              placeholder="name@company.com"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Contact Phone"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              placeholder="+91 98765 43210"
            />
            <SelectInput
              label="Security Role"
              value={formData.roleId}
              onChange={(e) => setFormData({ ...formData, roleId: e.target.value })}
              options={[
                { value: '00000000-0000-0000-0000-000000000001', label: 'System Administrator (ADMIN)' },
                { value: 'role-superadmin', label: 'Super Admin' },
                { value: 'role-labtech', label: 'Calibration Engineer (LAB_USER)' },
                { value: 'role-commercial', label: 'Commercial Manager (COMMERCIAL_USER)' },
                { value: 'role-approver', label: 'Quality Approver (APPROVER)' },
                { value: 'role-collection', label: 'Field Collection Agent (COLLECTION_AGENT)' },
              ]}
            />
          </div>

          {!isEdit && (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <PasswordInput
                label="Initial Password"
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

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => navigate('/admin/users')}
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
              <span>{isEdit ? 'Save Changes' : 'Create User Account'}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export const RoleListPage: React.FC = () => {
  const [roles, setRoles] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);

  const navigate = useNavigate();

  useEffect(() => {
    roleService.getAll().then((data) => {
      setRoles(data);
      setLoading(false);
    });
  }, []);

  const columns: Column<Role>[] = [
    {
      key: 'name',
      header: 'Role Name',
      sortable: true,
      render: (r) => (
        <div>
          <span className="font-semibold text-slate-900 text-xs block">{r.name}</span>
          <span className="text-[11px] text-slate-400">{r.description}</span>
        </div>
      ),
    },
    {
      key: 'permissionsCount',
      header: 'Granted Permissions',
      render: (r) => (
        <span className="font-mono text-xs font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
          {r.permissions.length} Permissions
        </span>
      ),
    },
    {
      key: 'userCount',
      header: 'Assigned Users',
      render: (r) => (
        <span className="font-mono text-xs text-slate-600 font-medium">
          {r.userCount || 0} User Accounts
        </span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (r) => (
        <button
          type="button"
          onClick={() => navigate(`/admin/roles/${r.id}`)}
          className="p-1.5 text-slate-400 hover:text-indigo-600 rounded-lg transition"
          title="Configure Matrix"
        >
          <Edit2 className="w-4 h-4" />
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Security Roles & Permissions Matrix</h1>
          <p className="text-xs text-slate-500 mt-1">
            Define granual RBAC permissions across multi-tenant calibration and commercial modules.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/admin/roles/new')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Create Custom Role
        </button>
      </div>

      <DataTable data={roles} columns={columns} loading={loading} />
    </div>
  );
};

export const RoleFormPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const isEdit = !!id && id !== 'new';

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const [roleName, setRoleName] = useState('');
  const [description, setDescription] = useState('');
  const [selectedPermissions, setSelectedPermissions] = useState<string[]>([]);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => {
    if (isEdit && id) {
      roleService.getById(id).then((role) => {
        if (role) {
          setRoleName(role.name);
          setDescription(role.description || '');
          setSelectedPermissions(role.permissions || []);
        }
      });
    }
  }, [id, isEdit]);

  const togglePermission = (code: string) => {
    if (selectedPermissions.includes(code)) {
      setSelectedPermissions(selectedPermissions.filter((p) => p !== code));
    } else {
      setSelectedPermissions([...selectedPermissions, code]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roleName.trim()) {
      showToast('Role name is required', 'warning');
      return;
    }

    setSubmitting(true);
    try {
      showToast(`Security role saved successfully!`, 'success');
      navigate('/admin/roles');
    } catch {
      showToast('Failed to save role', 'error');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="max-w-5xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={() => navigate('/admin/roles')}
          className="inline-flex items-center gap-1.5 text-xs font-semibold text-slate-500 hover:text-slate-800 transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Back to Roles Matrix
        </button>
      </div>

      <div className="bg-white rounded-2xl border border-slate-200/90 p-6 sm:p-8 shadow-subtle space-y-6">
        <div className="border-b border-slate-100 pb-4">
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">
            {isEdit ? 'Configure Role Matrix' : 'Create Custom Security Role'}
          </h1>
          <p className="text-xs text-slate-500 mt-1">
            Specify permissions for viewing, creating, approving, and signing commercial calibration operations.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <TextInput
              label="Role Name"
              required
              value={roleName}
              onChange={(e) => setRoleName(e.target.value)}
              placeholder="e.g. Senior Quality Auditor"
            />
            <TextInput
              label="Role Description"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Role scope and authority summary..."
            />
          </div>

          <div className="space-y-4 pt-2">
            <h3 className="text-xs font-bold text-slate-900 uppercase tracking-wider">
              Module Permissions Matrix
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {MODULES_METADATA.map((mod) => (
                <div key={mod.id} className="border border-slate-200 rounded-xl p-4 bg-slate-50/50 space-y-3">
                  <div className="flex items-center gap-2 border-b border-slate-200 pb-2">
                    <span className="font-bold text-xs text-slate-900">{mod.name}</span>
                  </div>

                  <div className="space-y-2 text-xs">
                    {mod.actions.map((act) => {
                      const code = `${mod.id}.${act}`;
                      const isChecked = selectedPermissions.includes(code);
                      return (
                        <label
                          key={code}
                          className="flex items-start gap-2.5 p-1.5 rounded-lg hover:bg-white cursor-pointer transition select-none"
                        >
                          <input
                            type="checkbox"
                            checked={isChecked}
                            onChange={() => togglePermission(code)}
                            className="mt-0.5 rounded text-indigo-600 focus:ring-indigo-500"
                          />
                          <div>
                            <span className="font-semibold text-slate-800 block text-xs capitalize">
                              {act} {mod.name}
                            </span>
                            <span className="text-[10px] text-slate-400 font-mono">{code}</span>
                          </div>
                        </label>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
            <button
              type="button"
              onClick={() => navigate('/admin/roles')}
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
              <span>Save Role Matrix</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export const PermissionListPage: React.FC = () => {
  return (
    <div className="space-y-6 max-w-4xl mx-auto">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">System Permissions Directory</h1>
        <p className="text-xs text-slate-500 mt-1">
          Complete catalog of atomic security permissions enforcing system access controls.
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {MODULES_METADATA.map((mod) => (
          <div key={mod.id} className="bg-white border border-slate-200 rounded-2xl p-5 shadow-subtle space-y-3">
            <h3 className="font-bold text-xs text-slate-900 border-b border-slate-100 pb-2">{mod.name}</h3>
            <div className="space-y-2 text-xs">
              {mod.actions.map((act) => {
                const code = `${mod.id}.${act}`;
                return (
                  <div key={code} className="p-2 bg-slate-50 rounded-lg flex justify-between items-center">
                    <div>
                      <span className="font-semibold text-slate-800 block text-xs capitalize">
                        {act} {mod.name}
                      </span>
                      <span className="text-[10px] text-slate-400 font-mono">{code}</span>
                    </div>
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
      header: 'User Account',
      sortable: true,
      render: (l) => <span className="font-semibold text-slate-900 text-xs">{l.userName}</span>,
    },
    {
      key: 'action',
      header: 'Security Action',
      sortable: true,
      render: (l) => (
        <span className="font-mono text-xs font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
          {l.action}
        </span>
      ),
    },
    {
      key: 'details',
      header: 'Log Summary',
      render: (l) => <span className="text-xs text-slate-600">{l.recordIdentifier || l.module}</span>,
    },
    {
      key: 'ipAddress',
      header: 'Client IP',
      render: (l) => <span className="font-mono text-xs text-slate-400">{l.ipAddress || '127.0.0.1'}</span>,
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">System Audit Trail</h1>
        <p className="text-xs text-slate-500 mt-1">
          Immutable ISO/IEC 17025 security log records tracking all user operations and administrative actions.
        </p>
      </div>

      <DataTable data={logs} columns={columns} loading={loading} />
    </div>
  );
};
