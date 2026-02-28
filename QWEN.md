# Astro-Noctum (Bazodiac) — Project Context

## Project Overview

**Astro-Noctum** is a fusion astrology web application that combines Western astrology, Chinese BaZi (Four Pillars of Destiny), and Wu-Xing (Five Elements) philosophy. Users input birth data to receive AI-generated horoscope interpretations via Google Gemini, visualize their natal chart through a 3D orrery, and interact with "Levi Bazi" — an ElevenLabs voice agent.

**Tech Stack:**
- **Frontend:** React 19 + TypeScript + Vite + Tailwind CSS v4
- **Backend:** Express.js (production server), Vite proxy (development)
- **Database:** Supabase (PostgreSQL with Row Level Security)
- **External APIs:** BAFE (astrology calculations), Gemini (text generation), ElevenLabs (voice agent)
- **Deployment:** Railway (nixpacks-based build)

**UI Language:** German  
**Aesthetic:** Dark luxury (obsidian/gold palette)

---

## Directory Structure

```
Astro-Noctum/
├── src/
│   ├── components/       # React components (BirthForm, Dashboard, Orrery, etc.)
│   ├── contexts/         # React Context providers (AuthContext)
│   ├── hooks/            # Custom React hooks
│   ├── lib/              # Utilities (astronomy calculations, 3D materials)
│   ├── services/         # API clients (api.ts, gemini.ts, supabase.ts)
│   ├── App.tsx           # Main application component
│   ├── main.tsx          # Entry point
│   └── index.css         # Global styles + Tailwind config
├── media/                # Static assets (served as publicDir)
├── dist/                 # Production build output
├── server.mjs            # Express production server
├── vite.config.ts        # Vite configuration + dev proxy
├── tsconfig.json         # TypeScript configuration
├── package.json          # Dependencies + scripts
├── railway.json          # Railway deployment config
├── nixpacks.toml         # Nixpacks build configuration
├── supabase-schema.sql   # Database schema + RLS policies
└── .env.example          # Environment variable template
```

---

## Building and Running

### Prerequisites
- Node.js **20.19+** (pinned in `.nvmrc` and `package.json`)
- npm 10+

### Development

```bash
# Install dependencies
npm install

# Copy environment template and fill values
cp .env.example .env.local

# Start Vite dev server (port 3000)
npm run dev

# Optional: Run Express server separately for /api/auth, /api/profile, /api/agent routes
PORT=3001 node server.mjs
```

### Production

```bash
# Build for production
npm run build        # Outputs to dist/

# Start production server
npm run start        # Express serves dist/ on PORT (default 3000)
```

### Other Commands

```bash
npm run lint         # TypeScript type-check (tsc --noEmit)
npm run clean        # Remove dist/
```

---

## Environment Variables

Create `.env.local` from `.env.example`. Variables prefixed with `VITE_` are exposed to the browser; unprefixed are server-only.

| Variable | Scope | Description |
|----------|-------|-------------|
| `VITE_GEMINI_API_KEY` | Client | Google Gemini API key for horoscope generation |
| `VITE_BAFE_BASE_URL` | Client | BAFE API base URL (default: `https://bafe.vercel.app`) |
| `VITE_SUPABASE_URL` | Client | Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Client | Supabase anon/public key |
| `SUPABASE_URL` | Server | Supabase project URL (server-side) |
| `SUPABASE_SERVICE_ROLE_KEY` | Server | Supabase service role key (bypasses RLS) |
| `VITE_ELEVENLABS_AGENT_ID` | Client | ElevenLabs voice agent ID |
| `ELEVENLABS_TOOL_SECRET` | Server | Secret token for ElevenLabs tool auth |

---

## Architecture

### Application Flow

```
Splash → AuthGate → BirthForm → Dashboard
```

State-driven single-page app (no router).

### Data Flow

1. **BirthForm** collects birth date/time/location/timezone
2. **services/api.ts** → `calculateAll()` fires 5 parallel requests to BAFE:
   - `/calculate/bazi` — Chinese Four Pillars
   - `/calculate/western` — Western astrology
   - `/calculate/fusion` — Combined interpretation
   - `/calculate/wuxing` — Five Elements analysis
   - `/calculate/tst` — Time Space Theory
3. **services/gemini.ts** → Sends combined results to Gemini for AI interpretation
4. **services/supabase.ts** → Persists data to Supabase (non-blocking)
5. **Dashboard** renders results + 3D orrery + ElevenLabs widget

### Server Contexts

| Context | Purpose |
|---------|---------|
| **Vite dev server** (`npm run dev`) | Proxies `/api/calculate/*` to BAFE; `/api/auth`, `/api/profile`, `/api/agent` to local Express (port 3001) |
| **Express production server** (`server.mjs`) | Serves `dist/`, proxies BAFE with fallback chain, handles server-side auth, ElevenLabs endpoints |

---

## Key Modules

| File | Purpose |
|------|---------|
| `src/contexts/AuthContext.tsx` | Supabase auth provider (signIn/signUp/signOut) |
| `src/services/api.ts` | BAFE API client with response normalization and fallback handling |
| `src/services/gemini.ts` | Gemini Flash integration for horoscope text generation |
| `src/services/supabase.ts` | Database operations (birth_data, astro_profiles, natal_charts) |
| `src/components/BirthChartOrrery.tsx` | Three.js 3D solar system visualization |
| `src/lib/astronomy/` | Keplerian orbital mechanics, star catalog, constellation data |
| `src/lib/3d/materials.ts` | Custom GLSL shaders (sun corona, atmospheric glow, Saturn rings) |
| `server.mjs` | Production Express server with BAFE proxy, Supabase admin auth, ElevenLabs endpoints |

---

## Database Schema (Supabase)

Tables (all with Row Level Security enabled):

| Table | Description |
|-------|-------------|
| `profiles` | User profile (auto-created on signup via trigger) |
| `birth_data` | User-submitted birth information |
| `astro_profiles` | Computed astrological data (upsert per user) |
| `natal_charts` | History of chart calculations |
| `agent_conversations` | ElevenLabs Levi Bazi session summaries |

See `supabase-schema.sql` for full DDL and RLS policies.

---

## External Dependencies

| Service | Purpose |
|---------|---------|
| **BAFE API** | Astrology calculation backend (German field names for BaZi pillars) |
| **Supabase** | Auth + PostgreSQL database |
| **Gemini API** | Text generation (`gemini-3-flash-preview`) |
| **ElevenLabs** | Voice agent widget (Levi Bazi) |

---

## Styling Conventions

**Tailwind v4** with custom theme tokens in `src/index.css`:

```css
--color-obsidian: #00050A;   /* Deep black background */
--color-gold: #D4AF37;       /* Luxury accent */
--color-ash: #1A1C1E;        /* Secondary dark */
```

**Fonts:**
- Sans-serif: Sora
- Serif: Cormorant Garamond

**Custom CSS Classes:**
- `.glass-card` — Frosted glass effect
- `.stele-card` — Decorative card style
- `.skeleton-dust` — Animated particle background
- `.grain-overlay` — Film grain texture

---

## Development Conventions

- **TypeScript:** Strict mode, no emit (type-check only via `npm run lint`)
- **Path Alias:** `@/*` maps to project root (configured in `tsconfig.json` and `vite.config.ts`)
- **React:** Functional components with hooks, React 19
- **Testing:** No test suite currently configured
- **Code Style:** Inferred from existing code — semicolons, double quotes, trailing commas in objects

---

## Deployment (Railway)

### Configuration Files

- `nixpacks.toml` — Pins Node.js 20 runtime via Nixpacks
- `railway.json` — Build/deploy commands

### Build Process

```toml
# nixpacks.toml
[phases.install]
cmds = ["npm ci"]

[phases.build]
cmds = ["npm run build"]

[start]
cmd = "npm run start"
```

### Required Railway Variables

- `VITE_GEMINI_API_KEY`
- `VITE_BAFE_BASE_URL`
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VITE_ELEVENLABS_AGENT_ID`
- `SUPABASE_SERVICE_ROLE_KEY`
- `ELEVENLABS_TOOL_SECRET`

---

## Known Issues

See `BUGS.md` for current limitations:
- Live verification of BAFE endpoint schema not possible in isolated environments due to network restrictions (`ENETUNREACH`)
- Recommended: Add CI contract tests against staging BAFE instance

---

## Additional Documentation

- `README.md` — User-facing setup and deployment guide
- `CLAUDE.md` — Developer guidance for Claude Code
- `SETUP-ELEVENLABS.txt` — ElevenLabs agent configuration
- `elevenlabs-tool.json` — ElevenLabs tool definition
- `elevenlabs-tool-save-conversation.json` — Conversation save tool config
