import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  FileCheck,
  CalendarClock,
  Clock,
  ArrowRight,
  AlertTriangle,
  FileText,
  Printer,
  Download,
  Building,
  CheckCircle2,
  Share2,
} from 'lucide-react';
import { CalibrationEntryFormData, CalibrationDueItem, CalibrationOutcome } from '../../types/calibration';
import { CalibrationCertificate } from '../../types/certificate';
import { CalibrationRequest, RequestItem } from '../../types/request';
import { calibrationService } from '../../services/calibrationService';
import { requestService } from '../../services/requestService';
import { DataTable, Column } from '../../components/common/DataTable';
import { StatusBadge } from '../../components/common/StatusBadge';
import { Modal } from '../../components/modals/AppModals';
import { TextInput, SelectInput, Textarea } from '../../components/forms/FormControls';
import { useNotification } from '../../context/NotificationContext';
import { mockStore } from '../../mock/initialStore';

export const CalibrationQueuePage: React.FC = () => {
  const [requests, setRequests] = useState<CalibrationRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedReqItem, setSelectedReqItem] = useState<{ req: CalibrationRequest; item: RequestItem } | null>(null);
  const [certModalOpen, setCertModalOpen] = useState(false);
  const [activeCert, setActiveCert] = useState<CalibrationCertificate | null>(null);

  const navigate = useNavigate();
  const { showToast } = useNotification();

  // Calibration Form Data
  const [calibrationResult, setCalibrationResult] = useState<CalibrationOutcome>('CALIBRATED');
  const [measurementData, setMeasurementData] = useState('');
  const [calibrationFrequencyMonths, setCalibrationFrequencyMonths] = useState(12);
  const [remarks, setRemarks] = useState('');

  // Faulty fields
  const [faultDescription, setFaultDescription] = useState('');
  const [serviceRequired, setServiceRequired] = useState('');
  const [estimatedCost, setEstimatedCost] = useState(0);

  // Outsource fields
  const [vendorId, setVendorId] = useState(mockStore.data.vendors[0]?.id || '');
  const [outsourcingReason, setOutsourcingReason] = useState('');

  const loadData = async () => {
    setLoading(true);
    try {
      const data = await requestService.getAll();
      setRequests(data);
    } catch {
      showToast('Unable to load calibration queue', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const handleOpenTest = (req: CalibrationRequest, item: RequestItem) => {
    setSelectedReqItem({ req, item });
    setCalibrationResult('CALIBRATED');
    setMeasurementData(item.measurementData || 'Measured standard error within ±0.01mm tolerance across 5 test points. Passed.');
    setCalibrationFrequencyMonths(item.calibrationFrequencyMonths || 12);
    setRemarks('');
    setFaultDescription('');
    setServiceRequired('');
    setEstimatedCost(0);
    setOutsourcingReason('');
  };

  const handleSubmitCalibration = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedReqItem) return;

    try {
      const vendorObj = mockStore.data.vendors.find((v) => v.id === vendorId);
      await calibrationService.submitCalibration({
        requestId: selectedReqItem.req.id,
        requestItemId: selectedReqItem.item.id,
        measurementData,
        calibrationResult,
        calibrationDate: new Date().toISOString().split('T')[0],
        calibrationFrequencyMonths,
        nextDueDate: new Date(Date.now() + calibrationFrequencyMonths * 30 * 86400000)
          .toISOString()
          .split('T')[0],
        remarks,
        faultDescription,
        serviceRequired,
        estimatedCost,
        vendorId,
        vendorName: vendorObj?.vendorName,
        outsourcingReason,
      });

      showToast(`Calibration outcome recorded: ${calibrationResult}`, 'success');
      setSelectedReqItem(null);
      loadData();
    } catch (err: any) {
      showToast(err.message || 'Error recording calibration', 'error');
    }
  };

  const handleViewCert = async (certNum: string) => {
    const cert = await calibrationService.getCertificate(certNum);
    if (cert) {
      setActiveCert(cert);
      setCertModalOpen(true);
    } else {
      showToast('Certificate not found', 'warning');
    }
  };

  // Flatten items awaiting calibration
  const queueItems: { req: CalibrationRequest; item: RequestItem }[] = [];
  requests.forEach((r) => {
    r.items.forEach((it) => {
      queueItems.push({ req: r, item: it });
    });
  });

  const columns: Column<{ req: CalibrationRequest; item: RequestItem }>[] = [
    {
      key: 'item',
      header: 'Equipment Specification',
      sortable: true,
      render: ({ item }) => (
        <div>
          <span className="font-semibold text-slate-900 block text-xs">{item.itemName}</span>
          <span className="text-[11px] text-slate-400 font-mono">
            {item.manufacturer} • {item.model}
          </span>
        </div>
      ),
    },
    {
      key: 'serialNumber',
      header: 'Serial Tag',
      sortable: true,
      render: ({ item }) => (
        <span className="font-mono font-bold text-xs text-slate-800">{item.serialNumber}</span>
      ),
    },
    {
      key: 'client',
      header: 'Client & Request',
      render: ({ req }) => (
        <div>
          <span className="font-medium text-slate-800 text-xs block">{req.clientName}</span>
          <span className="text-[10px] text-indigo-600 font-mono font-semibold">{req.requestNumber}</span>
        </div>
      ),
    },
    {
      key: 'status',
      header: 'Calibration Status',
      render: ({ item }) => <StatusBadge status={item.calibrationStatus || 'PENDING'} size="sm" />,
    },
    {
      key: 'certificate',
      header: 'Certificate No',
      render: ({ item }) =>
        item.certificateNumber ? (
          <button
            type="button"
            onClick={() => handleViewCert(item.certificateNumber!)}
            className="font-mono text-xs font-bold text-emerald-700 hover:underline flex items-center gap-1"
          >
            <FileText className="w-3.5 h-3.5" />
            {item.certificateNumber}
          </button>
        ) : (
          <span className="text-slate-400 text-xs">—</span>
        ),
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: ({ req, item }) => (
        <div className="flex items-center justify-end gap-1.5" onClick={(e) => e.stopPropagation()}>
          <button
            type="button"
            onClick={() => handleOpenTest(req, item)}
            className="px-3 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-2xs transition flex items-center gap-1"
          >
            <FileCheck className="w-3.5 h-3.5" />
            Test Instrument
          </button>
        </div>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Calibration Testing Workspace</h1>
          <p className="text-xs text-slate-500 mt-1">
            Record physical measurement readings, pass/fail calibration outcomes, maintenance defects, and generate NABL certificates.
          </p>
        </div>
        <button
          type="button"
          onClick={() => navigate('/calibration/due-list')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-800 rounded-xl text-xs font-semibold transition"
        >
          <CalendarClock className="w-4 h-4 text-indigo-600" />
          View Due List
        </button>
      </div>

      <DataTable
        data={queueItems}
        columns={columns}
        loading={loading}
        searchPlaceholder="Search calibration queue by item name, serial number, client..."
      />

      {/* Calibration Execution Modal */}
      {selectedReqItem && (
        <Modal
          isOpen={!!selectedReqItem}
          onClose={() => setSelectedReqItem(null)}
          title={`Calibration Testing: ${selectedReqItem.item.itemName}`}
          maxWidth="max-w-xl"
        >
          <form onSubmit={handleSubmitCalibration} className="space-y-4 text-xs">
            <div className="p-3 bg-slate-50 border border-slate-200 rounded-xl flex items-center justify-between">
              <div>
                <span className="font-semibold text-slate-800">{selectedReqItem.item.itemName}</span>
                <div className="text-slate-500 text-[11px] font-mono">
                  SN: {selectedReqItem.item.serialNumber} • Client: {selectedReqItem.req.clientName}
                </div>
              </div>
              <span className="font-mono text-xs font-bold text-indigo-600">
                {selectedReqItem.req.requestNumber}
              </span>
            </div>

            <div>
              <label className="text-xs font-semibold text-slate-700 block mb-1">
                Calibration Outcome <span className="text-rose-500">*</span>
              </label>
              <div className="grid grid-cols-3 gap-2">
                {[
                  { val: 'CALIBRATED', label: 'Calibrated (Passed)' },
                  { val: 'FAULTY', label: 'Faulty (Requires Service)' },
                  { val: 'OUTSOURCE', label: 'Outsource to Vendor' },
                ].map((opt) => (
                  <button
                    key={opt.val}
                    type="button"
                    onClick={() => setCalibrationResult(opt.val as any)}
                    className={`py-2 px-3 rounded-xl border text-xs font-semibold transition ${
                      calibrationResult === opt.val
                        ? 'bg-indigo-600 text-white border-indigo-600 shadow-xs'
                        : 'bg-white border-slate-200 text-slate-700 hover:bg-slate-50'
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
            </div>

            {/* If Calibrated */}
            {calibrationResult === 'CALIBRATED' && (
              <div className="space-y-3 pt-1">
                <Textarea
                  label="Measurement Data & Observations"
                  required
                  value={measurementData}
                  onChange={(e) => setMeasurementData(e.target.value)}
                  placeholder="Enter test points, observed readings, repeatability, and uncertainty..."
                />

                <div className="grid grid-cols-2 gap-3">
                  <TextInput
                    type="number"
                    label="Calibration Cycle Frequency (Months)"
                    required
                    value={String(calibrationFrequencyMonths)}
                    onChange={(e) => setCalibrationFrequencyMonths(Number(e.target.value) || 12)}
                  />
                  <TextInput
                    label="Auto-Calculated Next Due Date"
                    disabled
                    value={
                      new Date(Date.now() + calibrationFrequencyMonths * 30 * 86400000)
                        .toISOString()
                        .split('T')[0]
                    }
                  />
                </div>
              </div>
            )}

            {/* If Faulty */}
            {calibrationResult === 'FAULTY' && (
              <div className="space-y-3 p-4 bg-rose-50/60 border border-rose-200 rounded-xl">
                <span className="font-bold text-rose-800 text-xs block">
                  Fault Diagnostics & Service Repair Request
                </span>
                <TextInput
                  label="Fault Description"
                  required
                  value={faultDescription}
                  onChange={(e) => setFaultDescription(e.target.value)}
                  placeholder="e.g. Internal ratchet binding; fails repeatability test"
                />
                <TextInput
                  label="Service Required"
                  required
                  value={serviceRequired}
                  onChange={(e) => setServiceRequired(e.target.value)}
                  placeholder="e.g. Replace spring assembly and realign spindle"
                />
                <TextInput
                  type="number"
                  label="Estimated Service / Repair Cost (₹)"
                  value={String(estimatedCost)}
                  onChange={(e) => setEstimatedCost(Number(e.target.value) || 0)}
                  helperText="Estimate will be routed to client QA for approval before repair"
                />
              </div>
            )}

            {/* If Outsource */}
            {calibrationResult === 'OUTSOURCE' && (
              <div className="space-y-3 p-4 bg-purple-50/60 border border-purple-200 rounded-xl">
                <span className="font-bold text-purple-800 text-xs block">
                  Outsource to Accredited External Laboratory
                </span>
                <SelectInput
                  label="Target Accreditation Vendor"
                  required
                  value={vendorId}
                  onChange={(e) => setVendorId(e.target.value)}
                  options={mockStore.data.vendors.map((v) => ({
                    value: v.id,
                    label: `${v.vendorName} (${v.businessType})`,
                  }))}
                />
                <TextInput
                  label="Outsourcing Justification"
                  required
                  value={outsourcingReason}
                  onChange={(e) => setOutsourcingReason(e.target.value)}
                  placeholder="e.g. Requires cryogenic primary standard bath (-196°C)"
                />
              </div>
            )}

            <div className="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setSelectedReqItem(null)}
                className="px-3 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl"
              >
                Cancel
              </button>
              <button
                type="submit"
                className="px-5 py-2 text-xs font-semibold text-white bg-indigo-600 hover:bg-indigo-700 rounded-xl shadow-xs"
              >
                Commit Calibration
              </button>
            </div>
          </form>
        </Modal>
      )}

      {/* Certificate Viewer Modal */}
      {activeCert && (
        <Modal
          isOpen={certModalOpen}
          onClose={() => setCertModalOpen(false)}
          title={`Calibration Certificate: ${activeCert.certificateNumber}`}
          maxWidth="max-w-2xl"
        >
          <div className="space-y-4 text-xs">
            {/* Printed Certificate Mock Layout */}
            <div className="border-2 border-slate-800 p-6 rounded-xl bg-white space-y-4">
              <div className="text-center border-b-2 border-slate-800 pb-3">
                <h2 className="text-base font-bold tracking-tight text-slate-900 uppercase">
                  Apex Precision Calibration Laboratory
                </h2>
                <span className="text-[10px] text-slate-500 font-mono">
                  NABL ISO/IEC 17025 ACCREDITED METROLOGY FACILITY
                </span>
                <div className="text-xs font-mono font-bold mt-2 text-indigo-700">
                  CERTIFICATE NO: {activeCert.certificateNumber}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-4 text-[11px]">
                <div>
                  <span className="text-slate-400 block font-semibold">CUSTOMER:</span>
                  <strong className="text-slate-900">{activeCert.clientName}</strong>
                </div>
                <div>
                  <span className="text-slate-400 block font-semibold">DATE OF CALIBRATION:</span>
                  <strong className="text-slate-900 font-mono">{activeCert.calibrationDate}</strong>
                </div>
                <div>
                  <span className="text-slate-400 block font-semibold">INSTRUMENT DESCRIPTION:</span>
                  <strong className="text-slate-900">{activeCert.itemName}</strong>
                </div>
                <div>
                  <span className="text-slate-400 block font-semibold">SERIAL NUMBER:</span>
                  <strong className="text-slate-900 font-mono">{activeCert.serialNumber}</strong>
                </div>
                <div>
                  <span className="text-slate-400 block font-semibold">NEXT DUE DATE:</span>
                  <strong className="text-emerald-700 font-mono font-bold">{activeCert.nextDueDate}</strong>
                </div>
                <div>
                  <span className="text-slate-400 block font-semibold">OVERALL RESULT:</span>
                  <strong className="text-emerald-600 font-bold">PASS (COMPLIANT)</strong>
                </div>
              </div>

              <div className="border-t border-slate-200 pt-2 text-[10px] text-slate-500">
                <span>Environmental Conditions: Temp: {activeCert.environmentalConditions.temperature}, Humidity: {activeCert.environmentalConditions.humidity}</span>
              </div>

              <div className="pt-4 border-t-2 border-slate-800 flex justify-between items-end text-[11px]">
                <div>
                  <span className="text-slate-400 block text-[10px]">CALIBRATED BY:</span>
                  <strong className="text-slate-800">{activeCert.calibratedBy}</strong>
                </div>
                <div className="text-right">
                  <span className="text-slate-400 block text-[10px]">AUTHORIZED SIGNATORY:</span>
                  <strong className="text-slate-800">{activeCert.authorizedSignatory}</strong>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-end gap-2 pt-2">
              <button
                type="button"
                onClick={() => window.print()}
                className="px-4 py-2 text-xs font-semibold text-slate-700 bg-slate-100 hover:bg-slate-200 rounded-xl transition flex items-center gap-1.5"
              >
                <Printer className="w-3.5 h-3.5" />
                Print Certificate
              </button>
              <button
                type="button"
                onClick={() => {
                  showToast('Certificate PDF downloaded', 'success');
                  setCertModalOpen(false);
                }}
                className="px-4 py-2 text-xs font-semibold text-white bg-emerald-600 hover:bg-emerald-700 rounded-xl shadow-xs transition flex items-center gap-1.5"
              >
                <Download className="w-3.5 h-3.5" />
                Download Official PDF
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
};

export const CalibrationDueListPage: React.FC = () => {
  const [filter, setFilter] = useState<'ALL' | 'DUE_TODAY' | 'DUE_THIS_WEEK' | 'DUE_THIS_MONTH' | 'OVERDUE'>('ALL');
  const [dueItems, setDueItems] = useState<CalibrationDueItem[]>([]);
  const [loading, setLoading] = useState(true);

  const navigate = useNavigate();

  useEffect(() => {
    setLoading(true);
    calibrationService.getDueList(filter).then((data) => {
      setDueItems(data);
      setLoading(false);
    });
  }, [filter]);

  const columns: Column<CalibrationDueItem>[] = [
    {
      key: 'certificateNumber',
      header: 'Certificate No',
      sortable: true,
      render: (d) => <span className="font-mono font-bold text-indigo-700 text-xs">{d.certificateNumber}</span>,
    },
    {
      key: 'clientName',
      header: 'Client',
      sortable: true,
      render: (d) => <span className="font-semibold text-slate-900 text-xs">{d.clientName}</span>,
    },
    {
      key: 'itemName',
      header: 'Equipment',
      render: (d) => (
        <div>
          <span className="font-medium text-slate-800 text-xs block">{d.itemName}</span>
          <span className="font-mono text-[11px] text-slate-400">SN: {d.serialNumber}</span>
        </div>
      ),
    },
    {
      key: 'calibrationDate',
      header: 'Calibration Date',
      render: (d) => <span className="font-mono text-xs text-slate-500">{d.calibrationDate}</span>,
    },
    {
      key: 'nextDueDate',
      header: 'Next Due Date',
      sortable: true,
      render: (d) => (
        <span
          className={`font-mono text-xs font-bold ${
            d.status === 'OVERDUE'
              ? 'text-rose-600'
              : d.status === 'DUE_TODAY'
              ? 'text-amber-600'
              : 'text-slate-800'
          }`}
        >
          {d.nextDueDate}
        </span>
      ),
    },
    {
      key: 'status',
      header: 'Alert Status',
      render: (d) => <StatusBadge status={d.status} size="sm" />,
    },
    {
      key: 'actions',
      header: 'Actions',
      align: 'right',
      render: () => (
        <button
          type="button"
          onClick={() => navigate('/collection')}
          className="px-3 py-1 bg-indigo-50 text-indigo-700 hover:bg-indigo-100 rounded-lg text-xs font-semibold"
        >
          Initiate Pickup
        </button>
      ),
    },
  ];

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl font-bold text-slate-900 tracking-tight">Calibration Due List</h1>
          <p className="text-xs text-slate-500 mt-1">
            Predictive calibration expiration alerts for client equipment due for periodic NABL recalibration.
          </p>
        </div>
        <div className="flex items-center gap-1.5 bg-white border border-slate-200 p-1 rounded-xl shadow-2xs">
          {(['ALL', 'DUE_TODAY', 'DUE_THIS_WEEK', 'DUE_THIS_MONTH', 'OVERDUE'] as const).map((btn) => (
            <button
              key={btn}
              type="button"
              onClick={() => setFilter(btn)}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition ${
                filter === btn
                  ? 'bg-indigo-600 text-white shadow-2xs'
                  : 'text-slate-600 hover:bg-slate-100'
              }`}
            >
              {btn.replace(/_/g, ' ')}
            </button>
          ))}
        </div>
      </div>

      <DataTable data={dueItems} columns={columns} loading={loading} />
    </div>
  );
};
