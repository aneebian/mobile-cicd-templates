# Mobile CI/CD Templates

Copy-paste **GitHub Actions** workflows for Android (Kotlin) and Flutter apps:
lint, test, build signed APK/AAB, distribute to testers via **Firebase App Distribution**, and publish GitHub Releases.

![Android CI](https://github.com/aneebian/mobile-cicd-templates/actions/workflows/android-ci.yml/badge.svg)
![Flutter CI](https://github.com/aneebian/mobile-cicd-templates/actions/workflows/flutter-ci.yml/badge.svg)

## What's inside

| Workflow | Trigger | What it does |
|---|---|---|
| `android-ci.yml` | PR / push to `main` | Gradle cache, lint, unit tests, uploads reports |
| `android-release.yml` | tag `v*` | Signed APK + AAB, Firebase distribution, GitHub Release |
| `flutter-ci.yml` | PR / push to `main` | Format check, `flutter analyze`, tests with coverage |
| `flutter-release.yml` | tag `v*` | Signed APK + AAB, Firebase distribution, GitHub Release |

## Features
- Concurrency control: stale runs on the same branch are cancelled
- Dependency caching (Gradle, Flutter)
- Secrets-based signing; nothing sensitive is ever committed
- Version name from the git tag, version code from the run number
- Test and lint artifacts uploaded on every run

## Quick start
1. Copy the workflows you need into your app's `.github/workflows/`.
2. Follow [docs/SETUP.md](docs/SETUP.md) to create the keystore, Firebase service account and secrets.
3. Push a tag: `git tag v1.0.0 && git push origin v1.0.0`.

## Pipeline overview
```
PR opened ──► lint ─► tests ─► reports
tag v* ─────► decode keystore ─► build APK/AAB ─► Firebase testers ─► GitHub Release
```

## Roadmap
- [ ] Play Store internal-track upload
- [ ] Detekt / ktlint step
- [ ] Instrumented tests on an emulator
- [ ] iOS (Fastlane + TestFlight) workflow

## License
MIT
