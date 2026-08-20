# Namaste Nirvana Massage

Website and web application for Namaste Nirvana — a massage therapy studio
opening on Longwood Drive in South Burlington, Vermont, founded by
Nikesh Pokhrel.

## Website (GitHub Pages)

The live marketing site is a single-page static site in [`docs/`](docs/),
deployed automatically to GitHub Pages by the workflow in
`.github/workflows/deploy-pages.yml` on every push to `main` that touches
`docs/`.

To edit the site, change `docs/index.html` and push to `main`.

## DashMiles (iOS)

A standalone SwiftUI app in [`ios/DashMiles/`](ios/DashMiles/) for tracking
delivery-shift mileage. Open `ios/DashMiles/DashMiles.xcodeproj` in Xcode; see
[its README](ios/DashMiles/README.md) for signing and install steps. It shares
no code with the website.

## Legacy Dart web app

An earlier Dart-based web application lives in `lib/` and `web/`.

### Prerequisites

- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository
2. Run `dart pub get` to install dependencies
3. Run `dart run build_runner serve` to start the development server

### Building for Production

```bash
dart run build_runner build --release
```

## Project Structure

```
├── docs/
│   └── index.html        # Static marketing site (GitHub Pages)
├── ios/
│   └── DashMiles/        # SwiftUI mileage tracker (Xcode project)
├── .github/workflows/
│   └── deploy-pages.yml  # Pages deployment workflow
├── lib/
│   └── app.dart          # Main application logic (legacy Dart app)
├── web/
│   ├── index.html        # HTML entry point (legacy Dart app)
│   ├── main.dart         # Dart entry point (legacy Dart app)
│   └── styles.css        # Stylesheet (legacy Dart app)
├── pubspec.yaml          # Project dependencies
└── analysis_options.yaml # Dart analyzer configuration
```
