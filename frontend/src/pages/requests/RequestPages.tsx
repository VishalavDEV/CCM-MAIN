import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  ClipboardList,
  Plus,
  ArrowRight,
  CheckCircle2,
  AlertCircle,
  FileText,
  Clock,
  Send,
  Truck,
  Eye,
  Trash2,
  Calendar,
  Layers,
  FlaskConical,
  Receipt,
  FileSignature,
  History,
  AlertTriangle,
  FileSpreadsheet,
  Download,
} from 'lucide-react';
import { CalibrationRequest, RequestStatus, RequestPriority } from '../../types/request';
import { requestService } from '../../services/requestService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { RequestWorkflowTracker } from '../../components/workflow/RequestWorkflowTracker';
import { DocumentManager } from '../../components/documents/DocumentManager';
import { AuditTimeline } from '../../components/workflow/AuditTimeline';
import { STATUS_UI_ACTIONS } from '../../constants/workflow';
import { useNotification } from '../../context/NotificationContext';
import { mockStore } from '../../mock/initialStore';

export const RequestListPage: React.FC = () => {
  const [requests, setRequests] = useState<CalibrationRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState<string>('ALL');
  const [priorityFilter, setPriorityFilter] = useState<string>('ALL');

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadRequests = async () => {
    setLoading(true);
    try {
      const data = await requestService.getAll();
      setRequests(data);
    } catch {
      showToast('Unable to load calibration requests', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRequests();
  }, []);

  const filteredRequests = requests.filter((r) => {
    if (statusFilter !== 'ALL' && r.status !== statusFilter) return false;
    if (priorityFilter !== 'ALL' && r.priority !== priorityFilter) return false;
    return true;
  });

  const columns: Column<CalibrationRequest>[] = [
    {
      key: 'requestNumber',
      header: 'Request Number',
      sortable: true,
      render: (r) => (
        <div>
          <span className="font-mono font-bold text-indigo-700 block text-xs">{r.requestNumber}</span>
          <span className="text-[10px] text-slate-400 font-mono">{r.createdAt}</span>
        </div>
      ),
    },
    {
      key: 'clientName',
      header: 'Client Enterprise',
      sortable: true,
      render: (r) => (
        <div>
          <span className="font-semibold text-slate-900 block text-xs">{r.clientName}</span>
          <span className="text-[11px] text-slate-400">{r.organizationName}</span>
        </div>
      ),
    },
    {
      key: 'priority',
      header: 'Priority',
      sortable: true,
      render: (r) => (
        <span
          className={`font-mono text-[10px] font-bold px-2 py-0.5 rounded-full border ${
            r.priority === 'URGENT'
              ? 'bg-rose-50 text-rose-700 border-rose-200'
              : 'bg-slate-100 text-slate-700 border-slate-200'
          }`}
        >
          {r.priority}
        </span>
      ),
    },
    {
      key: 'items',
      header: 'Items Logged',
      render: (r) => (
        <span className="font-mono text-xs font-semibold text-slate-700">
          {r.items.length} Instrument{r.items.length !== 1 ? 's' : ''}
        </span>
      ),
    },
    {
      key: 'collectionDate',
      header: 'Intake Date',
      sortable: true,
      render: (r) => <span className="font-mono text-xs text-slate-500">{r.collectionDate}</span>,
    },
    {
      key: 'status',
      header: 'Current Stage',
      render: (r) => <StatusBadge status={r.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: (r) => (
        <button
          type="button"
          onClick={() => navigate(`/requests/${r.id}`)}
          className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-indigo-600 hover:bg-indigo-50 rounded-xl transition"
        >
          <Eye className="w-3.5 h-3.5" />
          Workspace
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Calibration Requests</h1>
          <p className="text-xs text-slate-500 mt-1">
            Central repository of all multi-item calibration orders from field collection to dispatch.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/collection')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <Plus className="w-4 h-4" />
          New Collection Request
        </button>
      </div>

      <DataTable
        data={filteredRequests}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search requests by number, client, organization..."
        onRowClick={(r) => navigate(`/requests/${r.id}`)}
        filters={
          <div className="flex items-center gap-2 flex-wrap">
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="text-xs py-2 px-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-700 focus:outline-none"
            >
              <option value="ALL">All Statuses</option>
              <option value="CREATED">Created</option>
              <option value="COLLECTED">Collected</option>
              <option value="LAB_QUEUE">Lab Queue</option>
              <option value="VERIFICATION">Verification</option>
              <option value="CALIBRATION">Calibration</option>
              <option value="CALIBRATED">Calibrated</option>
              <option value="APPROVAL">Approval</option>
              <option value="READY_TO_DISPATCH">Ready to Dispatch</option>
              <option value="COMPLETED">Completed</option>
              <option value="FAULTY">Faulty (Exception)</option>
              <option value="OUTSOURCED">Outsourced (Exception)</option>
              <option value="PARTIALLY_COMPLETED">Partially Completed</option>
            </select>

            <select
              value={priorityFilter}
              onChange={(e) => setPriorityFilter(e.target.value)}
              className="text-xs py-2 px-3 bg-slate-50 border border-slate-200 rounded-xl text-slate-700 focus:outline-none"
            >
              <option value="ALL">All Priorities</option>
              <option value="NORMAL">Normal SLA</option>
              <option value="URGENT">Urgent SLA</option>
            </select>
          </div>
        }
      />
    </div>
  );
};

// THE CENTRAL COMMAND WORKSPACE
export const RequestDetailPage: React.FC = () => {
  const { requestId } = useParams<{ requestId: string }>();
  const [request, setRequest] = useState<CalibrationRequest | null>(null);
  const [activeTab, setActiveTab] = useState<string>('overview');
  const [loading, setLoading] = useState(true);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  const loadRequest = async () => {
    if (!requestId) return;
    setLoading(true);
    try {
      const data = await requestService.getById(requestId);
      setRequest(data);
    } catch {
      showToast('Unable to load request details', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadRequest();
  }, [requestId]);

  if (loading || !request) {
    return <div className="text-center py-16 text-xs text-slate-400">Loading Request Command Workspace...</div>;
  }

  // Linked entities
  const linkedQuotation = mockStore.data.quotations.find(
    (q) => q.requestId === request.id || q.requestNumber === request.requestNumber
  );
  const linkedInvoice = mockStore.data.invoices.find(
    (i) => i.requestId === request.id || i.requestNumber === request.requestNumber
  );
  const linkedDispatch = mockStore.data.dispatches.find(
    (d) => d.requestId === request.id || d.requestNumber === request.requestNumber
  );
  const linkedSignatures = mockStore.data.signatures.filter(
    (s) => s.referenceNumber === linkedInvoice?.invoiceNumber || s.referenceNumber === linkedDispatch?.dispatchNumber
  );
  const requestAuditLogs = mockStore.data.auditLogs.filter(
    (a) => a.recordId === request.id || a.recordIdentifier === request.requestNumber
  );

  // Status Action Handler
  const handleStatusAction = () => {
    const action = STATUS_UI_ACTIONS[request.status];
    if (action.route) {
      if (action.route === '/verification') {
        navigate(`/verification/${request.id}`);
      } else {
        navigate(action.route);
      }
    } else {
      showToast(`Action: ${action.actionText} executed for ${request.requestNumber}`, 'info');
    }
  };

  const tabs = [
    { id: 'overview', label: 'Overview' },
    { id: 'items', label: `Items (${request.items.length})` },
    { id: 'verification', label: 'Verification' },
    { id: 'calibration', label: 'Calibration' },
    { id: 'documents', label: 'Documents' },
    { id: 'commercial', label: 'Quotation' },
    { id: 'approval', label: 'Approval' },
    { id: 'invoice', label: 'Invoice' },
    { id: 'signatures', label: 'Signatures' },
    { id: 'dispatch', label: 'Dispatch & Delivery' },
    { id: 'audit', label: 'Audit Trail' },
  ];

  return (
    <div className="space-y-6">
      {/* Central Command Header */}
      <div className="bg-white rounded-3xl border border-slate-200/90 p-6 shadow-subtle flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3 mb-1">
            <span className="font-mono text-xl font-bold text-slate-900">{request.requestNumber}</span>
            <StatusBadge status={request.status} size="md" />
            <span
              className={`font-mono text-[10px] font-bold px-2 py-0.5 rounded-full border ${
                request.priority === 'URGENT'
                  ? 'bg-rose-50 text-rose-700 border-rose-200'
                  : 'bg-slate-100 text-slate-700 border-slate-200'
              }`}
            >
              {request.priority} SLA
            </span>
          </div>

          <div className="text-xs text-slate-500 flex items-center gap-2 flex-wrap">
            <span className="font-semibold text-slate-800">{request.clientName}</span>
            <span>•</span>
            <span>{request.organizationName}</span>
            <span>•</span>
            <span>Agent: {request.collectionAgentName}</span>
            <span>•</span>
            <span>Intake: {request.collectionDate}</span>
          </div>
        </div>

        {/* Dynamic Status-Driven Action Button */}
        <div className="flex items-center gap-2.5 shrink-0">
          <button
            type="button"
            onClick={handleStatusAction}
            className="px-5 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-md shadow-indigo-600/20 transition flex items-center gap-2"
          >
            <span>{STATUS_UI_ACTIONS[request.status]?.actionText || 'Proceed Next Step'}</span>
            <ArrowRight className="w-4 h-4" />
          </button>
        </div>
      </div>

      {/* Horizontal 15-Stage Workflow Stepper Component */}
      <RequestWorkflowTracker currentStatus={request.status} />

      {/* Workspace Tabs */}
      <div className="flex items-center gap-2 border-b border-slate-200 overflow-x-auto">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            type="button"
            onClick={() => setActiveTab(tab.id)}
            className={`px-3.5 py-2.5 text-xs font-semibold border-b-2 transition whitespace-nowrap ${
              activeTab === tab.id
                ? 'border-indigo-600 text-indigo-600'
                : 'border-transparent text-slate-500 hover:text-slate-800'
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Tab 1: Overview */}
      {activeTab === 'overview' && (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-3 text-xs">
            <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
              Order Master Properties
            </h3>
            <div className="flex justify-between py-1 border-b border-slate-50">
              <span className="text-slate-500">Client Account:</span>
              <span className="font-semibold text-slate-900">{request.clientName}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-50">
              <span className="text-slate-500">Executing Lab:</span>
              <span className="font-medium text-slate-800">{request.organizationName}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-50">
              <span className="text-slate-500">Collection Agent:</span>
              <span className="text-slate-800">{request.collectionAgentName}</span>
            </div>
            <div className="flex justify-between py-1 border-b border-slate-50">
              <span className="text-slate-500">Intake Collection Date:</span>
              <span className="font-mono text-slate-800">{request.collectionDate}</span>
            </div>
            <div className="flex justify-between py-1">
              <span className="text-slate-500">Created At:</span>
              <span className="font-mono text-slate-600">{request.createdAt}</span>
            </div>
          </div>

          <div className="lg:col-span-2 bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
            <h3 className="text-sm font-semibold text-slate-900 border-b border-slate-100 pb-2">
              Status & Notes
            </h3>
            <div className="p-3 bg-slate-50 rounded-xl text-xs text-slate-700 leading-relaxed font-mono">
              {request.remarks || 'No special collection remarks logged.'}
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-2">
              <div className="p-3 rounded-xl bg-slate-50 border border-slate-100 text-center">
                <span className="text-[10px] text-slate-400 font-bold uppercase block">Total Items</span>
                <span className="text-lg font-mono font-bold text-slate-900">{request.items.length}</span>
              </div>
              <div className="p-3 rounded-xl bg-emerald-50/70 border border-emerald-100 text-center">
                <span className="text-[10px] text-emerald-700 font-bold uppercase block">Calibrated</span>
                <span className="text-lg font-mono font-bold text-emerald-800">
                  {request.items.filter((i) => i.calibrationStatus === 'CALIBRATED').length}
                </span>
              </div>
              <div className="p-3 rounded-xl bg-amber-50/70 border border-amber-100 text-center">
                <span className="text-[10px] text-amber-700 font-bold uppercase block">In Progress</span>
                <span className="text-lg font-mono font-bold text-amber-800">
                  {request.items.filter((i) => i.itemStatus === 'PENDING' || i.calibrationStatus === 'IN_PROGRESS').length}
                </span>
              </div>
              <div className="p-3 rounded-xl bg-indigo-50/70 border border-indigo-100 text-center">
                <span className="text-[10px] text-indigo-700 font-bold uppercase block">Est Commercial</span>
                <span className="text-sm font-mono font-bold text-indigo-900 mt-1 block">
                  ₹{request.items.reduce((a, c) => a + (c.overrideCost || c.standardCost), 0).toLocaleString()}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Tab 2: Items (With Partial Processing Indicators) */}
      {activeTab === 'items' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 shadow-subtle overflow-hidden">
          <div className="p-4 border-b border-slate-100 flex items-center justify-between">
            <h3 className="text-sm font-bold text-slate-900">Items Catalog ({request.items.length})</h3>
            <span className="text-xs text-slate-400">
              One parent request supports multi-item partial lifecycle progression
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="bg-slate-50 border-b border-slate-200/80 text-[11px] font-bold text-slate-500 uppercase">
                  <th className="px-5 py-3">Item Specification</th>
                  <th className="px-4 py-3">Serial No</th>
                  <th className="px-4 py-3 text-center">Qty</th>
                  <th className="px-4 py-3">Verification</th>
                  <th className="px-4 py-3">Calibration Status</th>
                  <th className="px-4 py-3">Certificate / Due Date</th>
                  <th className="px-4 py-3 text-right">Standard Rate</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {request.items.map((it) => (
                  <tr key={it.id} className="hover:bg-slate-50 transition">
                    <td className="px-5 py-3">
                      <span className="font-semibold text-slate-900 block">{it.itemName}</span>
                      <span className="text-[11px] text-slate-400 font-mono">
                        {it.manufacturer} • {it.model}
                      </span>
                    </td>
                    <td className="px-4 py-3 font-mono font-bold text-slate-800">{it.serialNumber}</td>
                    <td className="px-4 py-3 text-center font-mono font-semibold">
                      {it.receivedQuantity || it.requestedQuantity}
                    </td>
                    <td className="px-4 py-3">
                      <StatusBadge status={it.verificationResult || 'PENDING'} size="sm" />
                    </td>
                    <td className="px-4 py-3">
                      <StatusBadge status={it.calibrationStatus || 'PENDING'} size="sm" />
                    </td>
                    <td className="px-4 py-3 font-mono text-[11px]">
                      {it.certificateNumber ? (
                        <div>
                          <span className="text-emerald-700 font-bold block">{it.certificateNumber}</span>
                          <span className="text-slate-400">Due: {it.nextDueDate}</span>
                        </div>
                      ) : (
                        <span className="text-slate-400">—</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-right font-mono font-bold text-slate-800">
                      ₹ {it.standardCost.toLocaleString()}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Tab 3: Verification */}
      {activeTab === 'verification' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Lab Physical Inspection & Intake Verification</h3>
              <p className="text-xs text-slate-500">
                Item matching, serial tag verification, quantity checks, and condition logging.
              </p>
            </div>
            <button
              type="button"
              onClick={() => navigate(`/verification/${request.id}`)}
              className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs"
            >
              Open Full Verification Desk
            </button>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
            {request.items.map((it) => (
              <div key={it.id} className="p-4 rounded-xl bg-slate-50 border border-slate-200 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-slate-900">{it.itemName}</span>
                  <StatusBadge status={it.verificationResult || 'PENDING'} size="sm" />
                </div>
                <div className="text-slate-600 font-mono">SN: {it.serialNumber}</div>
                <div className="grid grid-cols-2 gap-2 text-[11px] pt-1">
                  <div>Serial Match: <strong className="text-slate-800">{it.serialMatchStatus || 'Pending'}</strong></div>
                  <div>Condition: <strong className="text-slate-800">{it.condition || 'Pending'}</strong></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab 4: Calibration */}
      {activeTab === 'calibration' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Metrology Calibration Results & Certificates</h3>
              <p className="text-xs text-slate-500">
                Instrument test data, outcomes (Calibrated, Faulty, Outsource), and calibration certificates.
              </p>
            </div>
            <button
              type="button"
              onClick={() => navigate('/calibration')}
              className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs"
            >
              Open Calibration Workspace
            </button>
          </div>

          <div className="space-y-3">
            {request.items.map((it) => (
              <div key={it.id} className="p-4 rounded-xl bg-slate-50 border border-slate-200 text-xs flex flex-col md:flex-row md:items-center justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-bold text-slate-900">{it.itemName}</span>
                    <span className="font-mono text-slate-500">({it.serialNumber})</span>
                    <StatusBadge status={it.calibrationStatus || 'PENDING'} size="sm" />
                  </div>
                  {it.measurementData && (
                    <p className="text-slate-600 font-mono mt-1 text-[11px]">{it.measurementData}</p>
                  )}
                  {it.faultDetails && (
                    <div className="mt-2 p-2 bg-rose-50 border border-rose-200 rounded text-rose-800 text-[11px]">
                      <strong>Fault:</strong> {it.faultDetails.faultDescription} • Est Repair: ₹{it.faultDetails.estimatedCost}
                    </div>
                  )}
                </div>

                {it.certificateNumber && (
                  <div className="text-right shrink-0">
                    <span className="text-[11px] text-slate-400 block">Certificate:</span>
                    <span className="font-mono font-bold text-indigo-700">{it.certificateNumber}</span>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Tab 5: Documents */}
      {activeTab === 'documents' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle">
          <DocumentManager requestId={request.id} />
        </div>
      )}

      {/* Tab 6: Quotation */}
      {activeTab === 'commercial' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <div>
              <h3 className="text-sm font-bold text-slate-900">Commercial Quotation</h3>
              <p className="text-xs text-slate-500">
                Standard pricing vs overrides with audit tracking.
              </p>
            </div>
            {!linkedQuotation && (
              <button
                type="button"
                onClick={() => navigate('/commercial/quotations/new')}
                className="px-4 py-2 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-xs font-semibold shadow-xs"
              >
                + Generate Quotation
              </button>
            )}
          </div>

          {linkedQuotation ? (
            <div className="p-4 bg-slate-50 rounded-xl border border-slate-200 text-xs space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <span className="font-mono font-bold text-indigo-700 text-sm">
                    {linkedQuotation.quotationNumber}
                  </span>
                  <span className="text-slate-500 block text-[11px]">Date: {linkedQuotation.quotationDate}</span>
                </div>
                <StatusBadge status={linkedQuotation.status} size="sm" />
              </div>

              <div className="pt-2 border-t border-slate-200/60 flex justify-between font-mono text-xs">
                <span>Total Quotation Value:</span>
                <span className="font-bold text-slate-900 text-sm">
                  ₹ {linkedQuotation.totalAmount.toLocaleString()} INR
                </span>
              </div>
            </div>
          ) : (
            <div className="text-center py-8 text-xs text-slate-400">
              No commercial quotation has been generated for this request yet.
            </div>
          )}
        </div>
      )}

      {/* Tab 7: Approval */}
      {activeTab === 'approval' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <h3 className="text-sm font-bold text-slate-900 border-b border-slate-100 pb-2">
            Quality & Commercial Sign-Off
          </h3>
          {linkedQuotation?.approvedBy ? (
            <div className="p-4 bg-emerald-50 border border-emerald-200 rounded-xl text-xs text-emerald-900 space-y-1">
              <div className="font-bold text-sm">Quotation Approved</div>
              <div>Sign-off Authority: <strong>{linkedQuotation.approvedBy}</strong> ({linkedQuotation.approvedAt})</div>
              <div className="text-emerald-700 font-mono mt-1">Remarks: {linkedQuotation.approvalRemarks}</div>
            </div>
          ) : (
            <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl text-xs text-amber-900">
              Pending review by authorized Approver under <code>quotation.approve</code> permission.
            </div>
          )}
        </div>
      )}

      {/* Tab 8: Invoice */}
      {activeTab === 'invoice' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h3 className="text-sm font-bold text-slate-900">Commercial Tax Invoice</h3>
            {!linkedInvoice && (
              <button
                type="button"
                onClick={() => navigate('/commercial/invoices')}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs"
              >
                + Generate Invoice
              </button>
            )}
          </div>

          {linkedInvoice ? (
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs space-y-2">
              <div className="flex justify-between">
                <span className="font-mono font-bold text-slate-900">{linkedInvoice.invoiceNumber}</span>
                <StatusBadge status={linkedInvoice.status} size="sm" />
              </div>
              <div className="text-slate-600">Type: <strong>{linkedInvoice.invoiceType}</strong></div>
              <div className="text-slate-600">Due: {linkedInvoice.dueDate}</div>
              <div className="pt-2 border-t border-slate-200 flex justify-between font-mono font-bold text-sm">
                <span>Invoice Amount:</span>
                <span>₹ {linkedInvoice.totalAmount.toLocaleString()}</span>
              </div>
            </div>
          ) : (
            <div className="text-center py-8 text-xs text-slate-400">
              No invoice generated for this job yet.
            </div>
          )}
        </div>
      )}

      {/* Tab 9: Signatures */}
      {activeTab === 'signatures' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <h3 className="text-sm font-bold text-slate-900 border-b border-slate-100 pb-2">
            Client Digital Signatures (Invoice & Delivery)
          </h3>
          {linkedSignatures.length > 0 ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-xs">
              {linkedSignatures.map((s) => (
                <div key={s.id} className="p-4 bg-slate-50 border border-slate-200 rounded-xl space-y-2">
                  <div className="flex justify-between items-center">
                    <span className="font-mono font-bold text-indigo-700">{s.type} SIGNATURE</span>
                    <StatusBadge status={s.status} size="sm" />
                  </div>
                  <div className="text-slate-800 font-semibold">{s.signatoryName} ({s.signatoryDesignation})</div>
                  <div className="text-slate-400 text-[11px] font-mono">Date: {s.signedDate}</div>
                  <div className="p-3 bg-white border border-slate-200 rounded-lg text-center font-serif italic text-base text-slate-800">
                    {s.signatoryName}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-8 text-xs text-slate-400">
              No digital signatures captured yet.
            </div>
          )}
        </div>
      )}

      {/* Tab 10: Dispatch & Delivery */}
      {activeTab === 'dispatch' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle space-y-4">
          <div className="flex items-center justify-between border-b border-slate-100 pb-3">
            <h3 className="text-sm font-bold text-slate-900">Packaging, Courier & Delivery</h3>
            {!linkedDispatch && (
              <button
                type="button"
                onClick={() => navigate('/dispatch')}
                className="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs"
              >
                + Create Dispatch
              </button>
            )}
          </div>

          {linkedDispatch ? (
            <div className="p-4 bg-slate-50 border border-slate-200 rounded-xl text-xs space-y-2">
              <div className="flex justify-between">
                <span className="font-mono font-bold text-slate-900">{linkedDispatch.dispatchNumber}</span>
                <StatusBadge status={linkedDispatch.status} size="sm" />
              </div>
              <div>Mode: <strong>{linkedDispatch.transportMode}</strong> ({linkedDispatch.courierName})</div>
              <div>AWB / Tracking Number: <strong className="font-mono">{linkedDispatch.trackingNumber}</strong></div>
              <div>Destination: {linkedDispatch.deliveryAddress}</div>
            </div>
          ) : (
            <div className="text-center py-8 text-xs text-slate-400">
              Instruments not yet packed or dispatched.
            </div>
          )}
        </div>
      )}

      {/* Tab 11: Audit Trail */}
      {activeTab === 'audit' && (
        <div className="bg-white rounded-2xl border border-slate-200/90 p-6 shadow-subtle">
          <AuditTimeline logs={requestAuditLogs} />
        </div>
      )}
    </div>
  );
};
