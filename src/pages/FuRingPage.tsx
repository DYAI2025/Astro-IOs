import { Link, useSearchParams } from 'react-router-dom';
import { ArrowLeft } from 'lucide-react';
import { useFusionRingContext } from '../contexts/FusionRingContext';
import { useLanguage } from '../contexts/LanguageContext';
import FusionRing from '../components/FusionRing';
import FusionRingTimeline from '../components/FusionRingTimeline';

const RING = {
  bg: '#020509',
  surface: '#0A1628',
  border: 'rgba(70,130,220,0.18)',
  gold: '#D4AF37',
  goldDim: 'rgba(212,175,55,0.45)',
  text: 'rgba(215,230,255,0.85)',
  muted: 'rgba(215,230,255,0.40)',
  glow: 'rgba(212,175,55,0.08)',
};

export default function FuRingPage() {
  const { signal } = useFusionRingContext();
  const { lang } = useLanguage();
  const [searchParams] = useSearchParams();

  const initialDay = Number(searchParams.get('day')) || 0;

  if (!signal) {
    return (
      <div className="min-h-screen flex items-center justify-center" style={{ background: RING.bg, color: RING.muted }}>
        <p className="text-sm">{lang === 'de' ? 'Kein Signalprofil vorhanden.' : 'No signal profile available.'}</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen font-sans" style={{ background: RING.bg, color: RING.text }}>
      {/* Header — 56px, solid bg */}
      <header
        className="fixed top-0 w-full h-14 flex items-center justify-between px-4 md:px-8 z-50"
        style={{ background: RING.surface, borderBottom: `1px solid ${RING.border}` }}
      >
        <Link to="/" className="flex items-center gap-2 text-sm transition-colors" style={{ color: RING.muted }}>
          <ArrowLeft className="w-4 h-4" />
          <span className="hidden sm:inline">Dashboard</span>
        </Link>
        <span className="text-[10px] uppercase tracking-[0.3em]" style={{ color: RING.muted }}>
          Fu-Ring
        </span>
        <span className="text-xs" style={{ color: RING.muted }}>
          {lang.toUpperCase()}
        </span>
      </header>

      {/* Ring center */}
      <main className="pt-14">
        <section className="flex items-center justify-center" style={{ minHeight: '60vh' }}>
          <div className="relative">
            <div
              className="absolute inset-0 -m-16 rounded-full pointer-events-none"
              style={{ background: `radial-gradient(circle, ${RING.glow} 0%, transparent 70%)` }}
            />
            <FusionRing
              signal={signal}
              size={typeof window !== 'undefined' && window.innerWidth < 640 ? 300 : 520}
              showLabels
              showKorona
              showTension
              animated
              withBackground={false}
            />
          </div>
        </section>

        {/* Timeline */}
        <section className="max-w-3xl mx-auto px-4 pb-12">
          <FusionRingTimeline signal={signal} size={typeof window !== 'undefined' && window.innerWidth < 640 ? 340 : 520} />
        </section>
      </main>
    </div>
  );
}
