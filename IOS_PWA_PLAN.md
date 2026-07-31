# iOS PWA delivery plan

## Scope and decisions

- Deliver a Flutter web app that works in iPhone and iPad Safari and can be added to the Home Screen as a standalone web app. This is not an App Store native iOS app.
- Keep the current local-only model: no account, backend, or cloud sync. Progress is intentionally local to the browser/Home Screen installation and can be lost if the user clears website data or deletes it.
- Google Mobile Ads is **not available for browser PWAs**. Keep the Google Mobile Ads SDK mobile-native only; do not initialize, import, or render it in the PWA. If web advertising is later required, choose and implement a separate web-ad solution after confirming its policy and privacy implications.
- The PWA must work without ads and must never block an exam result on an ad callback.

## Current starting point

- The repository already includes `web/`, a manifest with `display: standalone`, and iOS Home Screen metadata in `web/index.html`.
- `flutter build web` currently succeeds, including the WebAssembly compatibility dry run.
- The manifest and HTML still use generic `gplx_app` branding and generic descriptions.
- The app currently requests portrait orientation in `lib/main.dart` and the web manifest declares `portrait-primary`; this needs a deliberate iPad/landscape policy.

## Implementation order

### 1. Make shared code safe for the web

- [x] Create a platform-safe ad abstraction: Android may use Google Mobile Ads; the PWA uses a no-op implementation. Avoid unguarded `dart:io` / `Platform.is...` imports in code compiled for the web.
- [x] Change orientation handling so mobile native can remain portrait if desired, while web/PWA can resize and support iPad landscape.
- [x] Ensure every exam completion path proceeds directly when ads are absent.
- [x] Run `flutter build web --wasm` after each platform-boundary change.

### 2. Deliver a responsive iPhone and iPad experience

- [ ] Test iPhone portrait, iPhone landscape, iPad portrait, and iPad landscape at minimum.
- [x] Use central breakpoints and maximum content widths; prevent long question/answer lines and overly wide cards.
- [ ] Keep touch targets comfortably sized and make scrolling, dialogs, bottom navigation, and text scaling work with iOS safe areas.
- [ ] On wider iPad layouts, use a navigation rail or other wide layout only if it improves the flow; retain the phone bottom navigation on compact widths.
- [ ] Validate Vietnamese text, image loading, dark mode, large text, and long question content on real Safari rather than Chrome alone.

### 3. Finish PWA metadata and installation behavior

- [x] Replace generic name, short name, description, title, theme color, and icon assets with the final GPLX branding in `web/manifest.json` and `web/index.html`.
- [ ] Supply appropriate Apple touch icons, including iPhone and iPad sizes, and verify the icon/title after Add to Home Screen.
- [x] Decide whether landscape should be supported. Recommended: remove the portrait-only manifest restriction and support both orientations, especially on iPad.
- [ ] Deploy only over HTTPS (required for production service-worker/PWA behavior) with the correct base path and SPA rewrite/fallback for direct routes.
- [ ] Test first visit, repeat visit, Home Screen launch, update after a new deployment, and clearing website data. Document these user-visible behaviors.

### 4. Automate Cloudflare production deployments

- [x] Connect the Cloudflare static-assets Worker to the GitHub repository and use `main` as its production branch.
- [x] Configure Cloudflare Workers Builds to fetch Flutter 3.38.1, build `build/web` with WebAssembly, then run `npx wrangler deploy`.
- [x] Add `wrangler.jsonc` so Wrangler deploys `build/web` as the `cnnqt-gplx` static-assets Worker, including SPA fallback routing.
- [ ] Push these changes to `main`, confirm the first Cloudflare build succeeds, then verify the production URL displays the new version.
- [ ] Do not also enable a GitHub Actions Cloudflare deployment workflow; Workers Builds is the single production deployment path.

### 5. Storage, privacy, and release checks

- [ ] Verify `shared_preferences` persistence for settings, question state, and exam history in Safari and after Home Screen installation.
- [x] Add a short in-app or landing-page note: data is stored on this device/browser only and may disappear when website data is cleared or the app is deleted.
- [ ] Publish a simple privacy notice appropriate to the final hosting/analytics choices; with no accounts, no analytics, and no web ads, this can be very short.
- [ ] Run `flutter analyze`, `flutter build web`, and manual Safari tests on a physical iPhone and iPad before release.

## Acceptance checklist

- [ ] Opens and completes the full study/exam flow in supported iOS Safari versions and as a Home Screen app.
- [ ] Can be installed from Safari using Add to Home Screen, launches in standalone mode, and has correct GPLX name/icon.
- [ ] Uses no Google Mobile Ads API and has no ad-related failures or blocked result flow.
- [ ] Works in iPhone portrait and in chosen iPad orientations without clipped, overlapping, or unreachable UI.
- [ ] Progress is explicitly local-only and no account/cloud-sync behavior is implied.
- [ ] Production deployment is HTTPS and survives refresh/direct navigation at its final URL.

## Handoff reminder

If the Windows work is completed first, begin here at **Implementation order, step 1**. Shared work should be limited to responsive layout and platform-safe startup/ads. PWA hosting, Safari verification, and Home Screen installation remain mandatory even if the Windows app is already complete.
