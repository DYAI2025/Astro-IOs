// Type definitions for the CelestialOrrery 3D visualization

export interface PlanetData {
  name: string;
  a: number;       // Semi-major axis (AU)
  e: number;       // Eccentricity
  i: number;       // Inclination (degrees)
  omega: number;   // Longitude of ascending node (degrees)
  w: number;       // Argument of perihelion (degrees)
  M0: number;      // Mean anomaly at epoch (degrees)
  period: number;  // Orbital period (days)
  radius: number;  // Visual radius for rendering
  color: string;   // Color hex code
  symbol: string;  // Unicode symbol
  rings?: boolean; // Has rings (Saturn)
}

export interface StarData {
  name: string;
  ra: number;   // Right Ascension (hours)
  dec: number;  // Declination (degrees)
  mag: number;  // Apparent magnitude
  con: string;  // Constellation abbreviation
}

export interface CityData {
  name: string;
  lat: number;
  lon: number;
}

export interface Position3D {
  x: number;
  y: number;
  z: number;
}

export interface EquatorialCoordinates {
  ra: number;
  dec: number;
}

export interface HorizontalCoordinates {
  altitude: number;
  azimuth: number;
}

export type ViewMode = "orrery" | "transition" | "planetarium";

export interface ConstellationLines {
  [constellation: string]: [string, string][];
}

export interface ConstellationNames {
  [constellation: string]: string;
}
