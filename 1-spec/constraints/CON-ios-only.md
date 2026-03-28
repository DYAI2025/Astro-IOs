# CON-ios-only: iOS-Only MVP

**Category**: Technical

**Status**: Active

**Source stakeholder**: [STK-product-owner](../stakeholders.md)

## Description

The MVP targets iOS exclusively (iOS 26.2+, SwiftUI). No Android, web, or desktop parity is required for the initial App Store launch.

## Rationale

Solo founder with limited resources. Focusing on one platform enables faster iteration and higher design quality. iOS users tend to have higher willingness to pay for premium apps.

## Impact

- All UI is built in SwiftUI with iOS-specific APIs (Liquid Glass, SF Symbols, MapKit)
- No cross-platform framework (Flutter, React Native) — native only
- Android port is a future consideration, not a launch blocker
- Design decisions can leverage iOS-exclusive features without abstraction cost
