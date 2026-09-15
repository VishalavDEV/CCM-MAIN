import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  FileSpreadsheet,
  Plus,
  ShoppingBag,
  Eye,
  FileCheck2,
  CheckCircle2,
  AlertCircle,
  FileText,
  Printer,
  Download,
} from 'lucide-react';
import { Invoice, InvoiceType, PurchaseOrder } from '../../types/invoice';
import { invoiceService, purchaseOrderService } from '../../services/commercialServices';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { Modal } from '../../components/modals/AppModals';
import { SelectInput, TextInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { mockStore } from '../../mock/initialStore';

export const InvoiceListPage: React.FC = () => {
  const [invoices, setInvoices] = useState<Invoice[]>([]);
  const [loading, setLoading] = useState(true);
  const [createModalOpen, setCreateModalOpen] = useState(false);
  const [selectedInvoice, setSelectedInvoice] = useState<Invoice | null>(null);

  // Form states
  const [invoiceType, setInvoiceType] = useState<InvoiceType>('FULL_REQUEST');
  const [clientId, setClientId] = useState(mockStore.data.clients[0]?.id || '');
  const [requestId, setRequestId] = useState(mockStore.data.requests[0]?.id || '');
  const [notes, setNotes] = useState('');

  const { showToast } = useNotification();

  const loadInvoices = async () => {
    setLoading(true);
    try {
      const data = await invoiceService.getAll();
      setInvoices(data);
    } catch {
      showToast('Error loading invoices', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadInvoices();
  }, []);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const created = await invoiceService.create(invoiceType, clientId, requestId, undefined, notes);
      showToast(`Invoice ${created.invoiceNumber} generated successfully!`, 'success');
      setCreateModalOpen(false);
      loadInvoices();
    } catch {
      showToast('Failed to create invoice', 'error');
    }
  };

  const columns: Column<Invoice>[] = [
    {
      key: 'invoiceNumber',
      header: 'Invoice Number',
      sortable: true,
      render: (i) => (
        <div>
          <span className="font-mono font-bold text-teal-700 text-xs block">{i.invoiceNumber}</span>
          <span className="text-[10px] text-slate-400 font-mono">Due: {i.dueDate}</span>
        </div>
      ),
    },
    {
      key: 'invoiceType',
      header: 'Invoice Type',
      render: (i) => (
        <span className="font-mono text-[11px] font-semibold text-indigo-700 bg-indigo-50 px-2 py-0.5 rounded">
          {i.invoiceType.replace(/_/g, ' ')}
        </span>
      ),
    },
    {
      key: 'clientName',
      header: 'Client',
      sortable: true,
      render: (i) => <span className="font-semibold text-slate-900 text-xs">{i.clientName}</span>,
    },
    {
      key: 'requestNumber',
      header: 'Order Reference',
      render: (i) => <span className="font-mono text-xs text-slate-600">{i.requestNumber || 'Standalone'}</span>,
    },
    {
      key: 'totalAmount',
      header: 'Total Value',
      sortable: true,
      render: (i) => (
        <span className="font-mono font-bold text-xs text-slate-900">
          ₹ {i.totalAmount.toLocaleString()}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Status',
      render: (i) => <StatusBadge status={i.status} size="sm" />,
    },
    {
      key: 'isSigned',
      header: 'Client Signature',
      render: (i) => (
        <span
          className={`font-mono text-[10px] font-bold px-2 py-0.5 rounded-full border ${
            i.isSigned
              ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
              : 'bg-amber-50 text-amber-800 border-amber-200'
          }`}
        >
          {i.isSigned ? 'SIGNED' : 'PENDING SIGN'}
        </span>
      ),
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (i) => (
        <button
          type="button"
          onClick={() => setSelectedInvoice(i)}
          className="p-1.5 text-slate-400 hover:text-indigo-600 rounded-lg"
          title="View Invoice"
        >
          <Eye className="w-4 h-4" />
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Commercial Invoices</h1>
          <p className="text-xs text-slate-500 mt-1">
            Supports whole-request billing, partial instruments invoicing, and standalone metrology invoices.
          </p>
        </div>
        <button
          type="button"
          onClick={() => setCreateModalOpen(true)}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs"
        >
          <Plus className="w-4 h-4" />
          Generate Invoice
        </button>
      </div>

      <DataTable data={invoices} columns={columns} loading={loading} />

      {/* Create Invoice Modal */}
      <Modal
        isOpen={createModalOpen}
        onClose={() => setCreateModalOpen(false)}
        title="Generate Commercial Invoice"
        maxWidth="max-w-md"
      >
        <form onSubmit={handleCreate} className="space-y-4">
          <SelectInput
            label="Invoicing Scheme"
            required
            value={invoiceType}
            onChange={(e) => setInvoiceType(e.target.value as InvoiceType)}
            options={[
              { value: 'FULL_REQUEST', label: 'Full Request Invoice (All Items)' },
              { value: 'PARTIAL', label: 'Partial Invoice (Cleared Items Only)' },
              { value: 'INVOICE_ONLY', label: 'Invoice Only (Direct Commercial)' },
            ]}
          />

          <SelectInput
            label="Client Enterprise"
            required
            value={clientId}
            onChange={(e) => setClientId(e.target.value)}
            options={mockStore.data.clients.map((c) => ({ value: c.id, label: c.clientName }))}
          />

          {invoiceType !== 'INVOICE_ONLY' && (
            <SelectInput
              label="Calibration Request"
              required
              value={requestId}
              onChange={(e) => setRequestId(e.target.value)}
              options={mockStore.data.requests.map((r) => ({
                value: r.id,
                label: `${r.requestNumber} (${r.items.length} items)`,
              }))}
            />
          )}

          <Textarea
            label="Invoice Notes / Payment Terms"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Payment due within 30 days via RTGS..."
          />

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setCreateModalOpen(false)}
              className="px-3 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="px-4 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs"
            >
              Generate
            </button>
          </div>
        </form>
      </Modal>

      {/* Invoice Viewer Modal */}
      {selectedInvoice && (
        <Modal
          isOpen={!!selectedInvoice}
          onClose={() => setSelectedInvoice(null)}
          title={`Tax Invoice: ${selectedInvoice.invoiceNumber}`}
          maxWidth="max-w-2xl"
        >
          <div className="space-y-4 text-xs">
            <div className="border border-slate-200 p-6 rounded-xl bg-white space-y-4">
              <div className="flex justify-between items-start border-b border-slate-200 pb-4">
                <div>
                  <h3 className="text-base font-bold text-slate-900">Apex Precision Labs Bangalore</h3>
                  <span className="text-[11px] text-slate-500">GSTIN: 29AAACA1234F1Z5</span>
                </div>
                <div className="text-right">
                  <span className="font-mono text-base font-bold text-indigo-700 block">
                    {selectedInvoice.invoiceNumber}
                  </span>
                  <span className="text-slate-400 font-mono text-[11px]">Date: {selectedInvoice.invoiceDate}</span>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 text-xs">
                <div>
                  <span className="text-slate-400 font-semibold block text-[10px]">BILLED TO:</span>
                  <strong className="text-slate-900">{selectedInvoice.clientName}</strong>
                </div>
                <div>
                  <span className="text-slate-400 font-semibold block text-[10px]">PAYMENT DUE:</span>
                  <strong className="text-slate-900 font-mono">{selectedInvoice.dueDate}</strong>
                </div>
              </div>

              <table className="w-full text-left text-xs border-collapse">
                <thead>
                  <tr className="bg-slate-50 border-y border-slate-200 text-[10px] font-bold text-slate-500 uppercase">
                    <th className="py-2 px-3">Description</th>
                    <th className="py-2 px-3 text-center">Qty</th>
                    <th className="py-2 px-3 text-right">Rate</th>
                    <th className="py-2 px-3 text-right">Total</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 font-mono">
                  {selectedInvoice.items.map((it) => (
                    <tr key={it.id}>
                      <td className="py-2 px-3 font-sans font-medium text-slate-800">{it.description}</td>
                      <td className="py-2 px-3 text-center">{it.quantity}</td>
                      <td className="py-2 px-3 text-right">₹{it.rate}</td>
                      <td className="py-2 px-3 text-right font-bold">₹{it.total}</td>
                    </tr>
                  ))}
                </tbody>
              </table>

              <div className="pt-2 border-t border-slate-200 flex justify-end">
                <div className="w-56 space-y-1 text-xs">
                  <div className="flex justify-between text-slate-500">
                    <span>Subtotal:</span>
                    <span className="font-mono">₹{selectedInvoice.subtotal.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between text-slate-500">
                    <span>Tax (GST 18%):</span>
                    <span className="font-mono">₹{selectedInvoice.taxAmount.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between font-bold text-sm text-slate-900 border-t border-slate-200 pt-1">
                    <span>Grand Total:</span>
                    <span className="font-mono text-indigo-700">
                      ₹{selectedInvoice.totalAmount.toLocaleString()}
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => window.print()}
                className="px-3.5 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl flex items-center gap-1.5"
              >
                <Printer className="w-3.5 h-3.5" />
                Print Invoice
              </button>
              <button
                type="button"
                onClick={() => setSelectedInvoice(null)}
                className="px-4 py-2 text-xs font-semibold text-white bg-indigo-600 rounded-xl"
              >
                Close
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};

export const PurchaseOrderListPage: React.FC = () => {
  const [orders, setOrders] = useState<PurchaseOrder[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    purchaseOrderService.getAll().then((data) => {
      setOrders(data);
      setLoading(false);
    });
  }, []);

  const columns: Column<PurchaseOrder>[] = [
    {
      key: 'poNumber',
      header: 'PO Number',
      sortable: true,
      render: (p) => <span className="font-mono font-bold text-indigo-700 text-xs">{p.poNumber}</span>,
    },
    {
      key: 'vendorName',
      header: 'Accredited Supplier Vendor',
      sortable: true,
      render: (p) => <span className="font-semibold text-slate-900 text-xs">{p.vendorName}</span>,
    },
    {
      key: 'requestNumber',
      header: 'Linked Calibration Request',
      render: (p) => <span className="font-mono text-xs text-slate-600">{p.requestNumber || 'Stock'}</span>,
    },
    {
      key: 'totalAmount',
      header: 'PO Value',
      sortable: true,
      render: (p) => (
        <span className="font-mono font-bold text-xs text-slate-900">
          ₹ {p.totalAmount.toLocaleString()}
        </span>
      ),
    },
    {
      key: 'expectedDate',
      header: 'Expected Delivery',
      render: (p) => <span className="font-mono text-xs text-slate-500">{p.expectedDate}</span>,
    },
    {
      key: 'status',
      header: 'Status',
      render: (p) => <StatusBadge status={p.status} size="sm" />,
    },
  ];

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-xl font-bold text-slate-900 tracking-tight">Purchase Orders</h1>
        <p className="text-xs text-slate-500 mt-1">
          Track outsourcing purchase orders to external accredited laboratories and standard parts vendors.
        </p>
      </div>

      <DataTable data={orders} columns={columns} loading={loading} />
    </div>
  );
};
