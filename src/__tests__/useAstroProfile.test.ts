import { describe, it, expect, vi, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useAstroProfile } from '../hooks/useAstroProfile';

// Mock all external services
vi.mock('../services/api', () => ({
  calculateAll: vi.fn().mockResolvedValue({
    bazi: { day_master: 'Jia', zodiac_sign: 'Rat', pillars: undefined },
    western: { zodiac_sign: 'Aries', moon_sign: 'Taurus', ascendant_sign: 'Gemini', houses: {} },
    wuxing: { dominant_element: 'Wood', elements: { Wood: 3, Fire: 2, Earth: 1, Metal: 1, Water: 1 } },
    fusion: {},
    tst: {},
    issues: [],
  }),
}));
vi.mock('../services/gemini', () => ({
  generateInterpretation: vi.fn().mockResolvedValue({
    interpretation: 'Test interpretation',
    tiles: { sun: 'Sun tile' },
    houses: {},
  }),
}));
vi.mock('../services/supabase', () => ({
  fetchAstroProfile: vi.fn().mockResolvedValue(null),
  upsertAstroProfile: vi.fn().mockResolvedValue(undefined),
  insertBirthData: vi.fn().mockResolvedValue(undefined),
  insertNatalChart: vi.fn().mockResolvedValue(undefined),
}));
vi.mock('../lib/analytics', () => ({ trackEvent: vi.fn() }));

const mockUser = { id: 'user-123' } as any;

beforeEach(() => {
  vi.clearAllMocks();
});

describe('useAstroProfile', () => {
  it('starts in idle state when no user', () => {
    const { result } = renderHook(() => useAstroProfile(null, 'de'));
    expect(result.current.profileState).toBe('idle');
    expect(result.current.apiData).toBeNull();
  });

  it('transitions to not-found when user has no profile', async () => {
    const { result } = renderHook(() => useAstroProfile(mockUser, 'de'));
    await act(async () => { await new Promise(r => setTimeout(r, 50)); });
    expect(result.current.profileState).toBe('not-found');
  });

  it('handleReset clears data in not-found state', async () => {
    const { result } = renderHook(() => useAstroProfile(mockUser, 'de'));
    await act(async () => { await new Promise(r => setTimeout(r, 50)); });
    act(() => { result.current.handleReset(); });
    expect(result.current.apiData).toBeNull();
    expect(result.current.error).toBeNull();
  });

  it('handleSubmit sets profileState to found after success', async () => {
    const { result } = renderHook(() => useAstroProfile(mockUser, 'de'));
    await act(async () => { await new Promise(r => setTimeout(r, 50)); });
    await act(async () => {
      await result.current.handleSubmit({
        date: '2000-01-01T12:00:00',
        tz: 'Europe/Berlin',
        lat: 52.5,
        lon: 13.4,
      });
    });
    expect(result.current.profileState).toBe('found');
    expect(result.current.interpretation).toBe('Test interpretation');
    expect(result.current.isFirstReading).toBe(true);
  });
});
