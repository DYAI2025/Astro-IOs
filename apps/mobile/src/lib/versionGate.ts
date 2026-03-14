import { Platform } from "react-native";
import type { MobileBootstrap } from "@bazodiac/shared";

function normalize(version: string): [number, number, number] {
  const clean = version.trim().replace(/^v/i, "").split("-")[0];
  const parts = clean.split(".");

  const major = Number.parseInt(parts[0] || "0", 10) || 0;
  const minor = Number.parseInt(parts[1] || "0", 10) || 0;
  const patch = Number.parseInt(parts[2] || "0", 10) || 0;

  return [major, minor, patch];
}

export function compareVersions(current: string, minimum: string): number {
  const [cMajor, cMinor, cPatch] = normalize(current);
  const [mMajor, mMinor, mPatch] = normalize(minimum);

  if (cMajor !== mMajor) return cMajor - mMajor;
  if (cMinor !== mMinor) return cMinor - mMinor;
  return cPatch - mPatch;
}

export function isBelowMinVersion(
  appVersion: string,
  bootstrap: MobileBootstrap | null,
  platform: "ios" | "android" = Platform.OS === "ios" ? "ios" : "android",
): boolean {
  if (!bootstrap) return false;

  const minVersion =
    platform === "ios"
      ? bootstrap.min_supported_versions.ios
      : bootstrap.min_supported_versions.android;

  // Explicitly ignore empty / missing minimum version config so bad config
  // does not silently change gating behavior.
  if (!minVersion || !minVersion.trim()) return false;

  return compareVersions(appVersion, minVersion) < 0;
}

export function requiredVersionForPlatform(
  bootstrap: MobileBootstrap | null,
  platform: "ios" | "android" = Platform.OS === "ios" ? "ios" : "android",
): string {
  if (!bootstrap) return "";
  return platform === "ios"
    ? bootstrap.min_supported_versions.ios
    : bootstrap.min_supported_versions.android;
}
