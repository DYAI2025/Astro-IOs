// Astronomical calculations for planetary positions and sky coordinates

import { PlanetData, Position3D } from "./types";

/**
 * Solves Kepler's equation using Newton-Raphson iteration
 */
export function solveKepler(M: number, e: number, tol: number = 1e-8): number {
  let E = M;
  for (let i = 0; i < 100; i++) {
    const dE = (E - e * Math.sin(E) - M) / (1 - e * Math.cos(E));
    E -= dE;
    if (Math.abs(dE) < tol) break;
  }
  return E;
}

/**
 * Calculates planet position using Keplerian orbital mechanics
 */
export function getPlanetPosition(
  planet: PlanetData,
  daysSinceJ2000: number,
  scale: number = 25,
): Position3D & { distance: number } {
  const { a, e, i, omega, w, M0, period } = planet;

  const n = (2 * Math.PI) / period;
  const M = ((M0 * Math.PI) / 180 + n * daysSinceJ2000) % (2 * Math.PI);
  const E = solveKepler(M, e);

  const nu =
    2 *
    Math.atan2(
      Math.sqrt(1 + e) * Math.sin(E / 2),
      Math.sqrt(1 - e) * Math.cos(E / 2),
    );

  const r = a * (1 - e * Math.cos(E));

  const xOrb = r * Math.cos(nu);
  const yOrb = r * Math.sin(nu);

  const iRad = (i * Math.PI) / 180;
  const omegaRad = (omega * Math.PI) / 180;
  const wRad = (w * Math.PI) / 180;

  const cosO = Math.cos(omegaRad);
  const sinO = Math.sin(omegaRad);
  const cosW = Math.cos(wRad);
  const sinW = Math.sin(wRad);
  const cosI = Math.cos(iRad);
  const sinI = Math.sin(iRad);

  const x =
    (cosO * cosW - sinO * sinW * cosI) * xOrb +
    (-cosO * sinW - sinO * cosW * cosI) * yOrb;
  const y =
    (sinO * cosW + cosO * sinW * cosI) * xOrb +
    (-sinO * sinW + cosO * cosW * cosI) * yOrb;
  const z = sinW * sinI * xOrb + cosW * sinI * yOrb;

  const scaled = Math.log10(r + 1) * scale;
  const factor = scaled / r;

  return {
    x: x * factor,
    y: z * factor,
    z: -y * factor,
    distance: r,
  };
}

/**
 * Converts Date to Julian Date
 */
export function dateToJD(date: Date): number {
  const y = date.getUTCFullYear();
  const m = date.getUTCMonth() + 1;
  const d =
    date.getUTCDate() +
    date.getUTCHours() / 24 +
    date.getUTCMinutes() / 1440 +
    date.getUTCSeconds() / 86400;

  const a = Math.floor((14 - m) / 12);
  const yy = y + 4800 - a;
  const mm = m + 12 * a - 3;

  return (
    d +
    Math.floor((153 * mm + 2) / 5) +
    365 * yy +
    Math.floor(yy / 4) -
    Math.floor(yy / 100) +
    Math.floor(yy / 400) -
    32045
  );
}

/**
 * Calculates days since J2000.0 epoch
 */
export function daysSinceJ2000(date: Date): number {
  return dateToJD(date) - 2451545.0;
}
