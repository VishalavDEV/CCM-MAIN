import React, { useState, useEffect } from 'react';
import { Package, Plus, Edit2, Trash2, Eye, CheckCircle2 } from 'lucide-react';
import { Item, ItemFormData, ItemStatus } from '../../types/item';
import { itemService } from '../../services/itemService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { Modal, DeleteModal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';

export const ItemMasterListPage: React.FC = () => {
  const [items, setItems] = useState<Item[]>([]);
  const [loading, setLoading] = useState(true);
  const [modalOpen, setModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<Item | null>(null);
  const [deleteModalOpen, setDeleteModalOpen] = useState(false);
  const [itemToDelete, setItemToDelete] = useState<Item | null>(null);

  const [formData, setFormData] = useState<ItemFormData>({
    itemCode: '',
    itemName: '',
    itemType: 'Dimensional',
    manufacturer: '',
    model: '',
    serialNumber: '',
    measurementRange: '',
    leastCount: '',
    standardCost: 1000,
    calibrationFrequencyMonths: 12,
    status: 'ACTIVE',
    description: '',
  });

  const { showToast } = useNotification();

  const loadItems = async () => {
    setLoading(true);
    try {
      const data = await itemService.getAll();
      setItems(data);
    } catch {
      showToast('Unable to load item master catalog', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadItems();
  }, []);

  const handleOpenCreate = () => {
    setEditingItem(null);
    setFormData({
      itemCode: '',
      itemName: '',
      itemType: 'Dimensional',
      manufacturer: '',
      model: '',
      serialNumber: '',
      measurementRange: '',
      leastCount: '',
      standardCost: 1000,
      calibrationFrequencyMonths: 12,
      status: 'ACTIVE',
      description: '',
    });
    setModalOpen(true);
  };

  const handleOpenEdit = (item: Item, e: React.MouseEvent) => {
    e.stopPropagation();
    setEditingItem(item);
    setFormData({
      itemCode: item.itemCode,
      itemName: item.itemName,
      itemType: item.itemType,
      manufacturer: item.manufacturer,
      model: item.model,
      serialNumber: item.serialNumber || '',
      measurementRange: item.measurementRange,
      leastCount: item.leastCount,
      standardCost: item.standardCost,
      calibrationFrequencyMonths: item.calibrationFrequencyMonths,
      status: item.status,
      description: item.description || '',
    });
    setModalOpen(true);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.itemName.trim() || !formData.itemCode.trim()) {
      showToast('Name and code are required', 'warning');
      return;
    }

    try {
      if (editingItem) {
        await itemService.update(editingItem.id, formData);
        showToast('Item specification updated', 'success');
      } else {
        await itemService.create(formData);
        showToast('New item registered in catalog', 'success');
      }
      setModalOpen(false);
      loadItems();
    } catch {
      showToast('Failed to save item', 'error');
    }
  };

  const handleDelete = async () => {
    if (!itemToDelete) return;
    try {
      await itemService.delete(itemToDelete.id);
      showToast('Item deleted from master', 'info');
      setDeleteModalOpen(false);
      setItemToDelete(null);
      loadItems();
    } catch {
      showToast('Failed to delete item', 'error');
    }
  };

  const columns: Column<Item>[] = [
    {
      key: 'itemCode',
      header: 'Item Code',
      sortable: true,
      render: (i) => (
        <span className="font-mono font-bold text-blue-700 bg-blue-50 px-2 py-0.5 rounded text-xs">
          {i.itemCode}
        </span>
      ),
    },
    {
      key: 'itemName',
      header: 'Equipment / Gauge Name',
      sortable: true,
      render: (i) => (
        <div>
          <span className="font-semibold text-slate-900 block">{i.itemName}</span>
          <span className="text-[11px] text-slate-400">
            {i.manufacturer} • {i.model}
          </span>
        </div>
      ),
    },
    {
      key: 'measurementRange',
      header: 'Range & Least Count',
      render: (i) => (
        <div className="text-xs text-slate-700 font-mono">
          <div>{i.measurementRange}</div>
          <span className="text-[10px] text-slate-400">LC: {i.leastCount}</span>
        </div>
      ),
    },
    {
      key: 'standardCost',
      header: 'Standard Rate',
      sortable: true,
      render: (i) => (
        <span className="font-mono font-bold text-xs text-slate-900">
          ₹ {i.standardCost.toLocaleString()}
        </span>
      ),
    },
    {
      key: 'calibrationFrequencyMonths',
      header: 'Frequency',
      render: (i) => (
        <span className="font-mono text-xs text-slate-600 font-medium">
          {i.calibrationFrequencyMonths} Months
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (i) => <StatusBadge status={i.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (i) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={(e) => handleOpenEdit(i, e)}
            className="p-1.5 text-slate-400 hover:text-slate-700 hover:bg-slate-100 rounded-lg transition"
            title="Edit Specification"
          >
            <Edit2 className="w-4 h-4" />
          </button>
          <button
            type="button"
            onClick={(e) => {
              e.stopPropagation();
              setItemToDelete(i);
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
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Item Master Catalog</h1>
          <p className="text-xs text-slate-500 mt-1">
            Standard metrology specifications, manufacturers, measurement ranges, default calibration fees, and cycle frequencies.
          </p>
        </div>
        <button
          type="button"
          onClick={handleOpenCreate}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          Add Master Item
        </button>
      </div>

      <DataTable
        data={items}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search by item code, equipment name, manufacturer..."
      />

      {/* Item Modal */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editingItem ? 'Edit Master Item Specification' : 'Register New Master Item'}
        maxWidth="max-w-lg"
      >
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-3">
            <TextInput
              label="Item Code"
              required
              value={formData.itemCode}
              onChange={(e) => setFormData({ ...formData, itemCode: e.target.value.toUpperCase() })}
              placeholder="e.g. ITM-DIM-01"
            />
            <SelectInput
              label="Domain / Type"
              value={formData.itemType}
              onChange={(e) => setFormData({ ...formData, itemType: e.target.value })}
              options={[
                { value: 'Dimensional', label: 'Dimensional' },
                { value: 'Electro-Technical', label: 'Electro-Technical' },
                { value: 'Pressure', label: 'Pressure & Vacuum' },
                { value: 'Thermal', label: 'Thermal / Temperature' },
                { value: 'Torque & Force', label: 'Torque & Force' },
                { value: 'Mass & Volume', label: 'Mass & Volume' },
              ]}
            />
          </div>

          <TextInput
            label="Equipment / Gauge Name"
            required
            value={formData.itemName}
            onChange={(e) => setFormData({ ...formData, itemName: e.target.value })}
            placeholder="e.g. Digital Vernier Caliper 150mm"
          />

          <div className="grid grid-cols-2 gap-3">
            <TextInput
              label="Manufacturer"
              value={formData.manufacturer}
              onChange={(e) => setFormData({ ...formData, manufacturer: e.target.value })}
              placeholder="e.g. Mitutoyo"
            />
            <TextInput
              label="Model Number"
              value={formData.model}
              onChange={(e) => setFormData({ ...formData, model: e.target.value })}
              placeholder="e.g. 500-196-30 AOS"
            />
          </div>

          <div className="grid grid-cols-2 gap-3">
            <TextInput
              label="Measurement Range"
              value={formData.measurementRange}
              onChange={(e) => setFormData({ ...formData, measurementRange: e.target.value })}
              placeholder="e.g. 0 - 150 mm"
            />
            <TextInput
              label="Least Count"
              value={formData.leastCount}
              onChange={(e) => setFormData({ ...formData, leastCount: e.target.value })}
              placeholder="e.g. 0.01 mm"
            />
          </div>

          <div className="grid grid-cols-3 gap-3">
            <TextInput
              type="number"
              label="Standard Cost (₹)"
              required
              value={String(formData.standardCost)}
              onChange={(e) => setFormData({ ...formData, standardCost: Number(e.target.value) || 0 })}
            />
            <TextInput
              type="number"
              label="Frequency (Months)"
              required
              value={String(formData.calibrationFrequencyMonths)}
              onChange={(e) =>
                setFormData({ ...formData, calibrationFrequencyMonths: Number(e.target.value) || 12 })
              }
            />
            <SelectInput
              label="Status"
              value={formData.status}
              onChange={(e) => setFormData({ ...formData, status: e.target.value as ItemStatus })}
              options={[
                { value: 'ACTIVE', label: 'Active' },
                { value: 'INACTIVE', label: 'Inactive' },
                { value: 'MAINTENANCE', label: 'Under Maintenance' },
              ]}
            />
          </div>

          <Textarea
            label="Technical Description / Standards"
            value={formData.description || ''}
            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
            placeholder="Reference ISO standards or test notes..."
          />

          <div className="flex items-center justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setModalOpen(false)}
              className="px-3 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs"
            >
              {editingItem ? 'Save Updates' : 'Add Item'}
            </button>
          </div>
        </form>
      </Modal>

      <DeleteModal
        isOpen={deleteModalOpen}
        onClose={() => setDeleteModalOpen(false)}
        onConfirm={handleDelete}
        title="Delete Master Item"
        itemName={itemToDelete?.itemName}
        message="Are you sure you want to delete this master equipment specification?"
      />
    </div>
  );
};
