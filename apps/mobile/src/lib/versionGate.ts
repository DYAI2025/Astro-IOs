import { Platform } from "react-native";
import type { MobileBootstrap } from "@bazodiac/shared";

function normalize(version: string): [number, number, number, number] | null {
  const trimmed = version.trim().replace(/^v/i, "");
  if (!trimmed) {
    return null;
  }

  const hasPrereleaseOrBuild = trimmed.includes("-");
  const core = trimmed.split("-")[0];
  const parts = core.split(".");

  // Expect up to "major.minor.patch"; missing minor/patch default to 0,
  // but all present parts must be purely numeric.
  if (parts.length < 1 || parts.length > 3) {
    return null;
  }

  const numericParts: number[] = [];
  for (let i = 0; i < 3; i++) {
    const part = parts[i] ?? "0";
    if (!/^\d+$/.test(part)) {
      return null;
    }
    numericParts.push(Number.parseInt(part, 10));
  }

  const [major, minor, patch] = numericParts;
  // stability: 0 = pre-release/build, 1 = stable
  const stability = hasPrereleaseOrBuild ? 0 : 1;

  return [major, minor, patch, stability];
}

export function compareVersions(current: string, minimum: string): number {
  const cNorm = normalize(current);
  const mNorm = normalize(minimum);

  // Handle invalid version formats explicitly.
  if (!cNorm && !mNorm) {
    // Both versions invalid: treat as equal.
    return 0;
  }
  if (!cNorm && mNorm) {
    // Current invalid, minimum valid: treat current as below minimum.
    return -1;
  }
  if (cNorm && !mNorm) {
    // Current valid, minimum invalid: avoid silently treating minimum as 0.0.0.
    // Treat as equal so gating does not unexpectedly tighten or loosen.
    return 0;
  }

  const [cMajor, cMinor, cPatch, cStability] = cNorm!;
  const [mMajor, mMinor, mPatch, mStability] = mNorm!;

  if (cMajor !== mMajor) return cMajor - mMajor;
  if (cMinor !== mMinor) return cMinor - mMinor;
  if (cPatch !== mPatch) return cPatch - mPatch;
  // For identical major/minor/patch, stable (1) is greater than pre-release (0).
  return cStability - mStability;
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
