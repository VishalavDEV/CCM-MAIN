import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldAlert, ArrowLeft } from 'lucide-react';

export const Forbidden403Page: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-[70vh] flex items-center justify-center p-4">
      <div className="bg-white border border-slate-200 rounded-3xl p-8 max-w-md w-full text-center shadow-subtle">
        <div className="w-16 h-16 rounded-2xl bg-rose-50 text-rose-600 flex items-center justify-center mx-auto mb-4">
          <ShieldAlert className="w-8 h-8" />
        </div>
        <span className="text-xs font-mono font-bold text-rose-600 uppercase tracking-widest bg-rose-50 px-3 py-1 rounded-full">
          HTTP 403 Access Denied
        </span>
        <h1 className="text-2xl font-bold text-slate-900 mt-3 mb-2">Insufficient Permissions</h1>
        <p className="text-xs text-slate-500 mb-6 leading-relaxed">
          Your current assigned role does not possess the granular permissions required to access this resource or execute this business operation.
        </p>
        <button
          type="button"
          onClick={() => navigate('/admin/dashboard')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Return to Dashboard
        </button>
      </div>
    </div>
  );
};

export const NotFound404Page: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-[70vh] flex items-center justify-center p-4">
      <div className="bg-white border border-slate-200 rounded-3xl p-8 max-w-md w-full text-center shadow-subtle">
        <span className="text-4xl font-extrabold text-slate-300 font-mono">404</span>
        <h2 className="text-xl font-bold text-slate-900 mt-2 mb-2">Page Not Found</h2>
        <p className="text-xs text-slate-500 mb-6">
          The requested page or route does not exist in the calibration management system.
        </p>
        <button
          type="button"
          onClick={() => navigate('/admin/dashboard')}
          className="inline-flex items-center gap-2 px-4 py-2.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-xl text-xs font-semibold shadow-xs transition"
        >
          <ArrowLeft className="w-4 h-4" />
          Return to Dashboard
        </button>
      </div>
    </div>
  );
};
