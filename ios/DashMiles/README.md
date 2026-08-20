# DashMiles

A small iOS app for logging the miles you drive on a delivery shift, so you
have a defensible mileage log at tax time.

One dash = one shift: tap **Start Dash** when you go online, tap **End Dash**
when you stop. Everything in between is recorded as one trip.

## What it does

- **Live odometer** — miles, elapsed time, current speed, and GPS accuracy
  while a dash is running.
- **Keeps counting in the background** — with location set to *Always*, miles
  accumulate with the screen off and while you are in the DoorDash app.
- **Survives a crash or restart** — an in-progress dash is written to disk, and
  the app picks it back up on relaunch.
- **History** grouped by month, with per-month and year-to-date totals.
- **Edit or add a dash by hand** for the days GPS drops out or you forget to
  start it.
- **Estimated deduction** using a mileage rate you set in Settings.
- **CSV export** to Mail, Files, or a spreadsheet.

Everything is stored in a JSON file in the app's Documents folder. Nothing
leaves the phone, and there are no accounts or dependencies.

## Running it on your phone

1. Open `ios/DashMiles/DashMiles.xcodeproj` in Xcode (16 or newer).
2. Select the **DashMiles** target → **Signing & Capabilities**:
   - Set **Team** to your Apple ID.
   - Change the **Bundle Identifier** from `com.example.DashMiles` to something
     unique, e.g. `com.yourname.DashMiles`.
3. Plug in your iPhone, pick it as the run destination, and press ⌘R.
4. On the phone: **Settings → General → VPN & Device Management** → trust your
   developer certificate (only needed for a free Apple ID).
5. First launch: allow location. When iOS later offers **Always**, accept it —
   *While Using* stops counting once the screen locks for a while.

A free Apple ID signs the app for 7 days before it needs a re-install. A paid
developer account gets you a year, plus TestFlight.

### Background location

The target sets `INFOPLIST_KEY_UIBackgroundModes = location`. If Xcode ever
drops it, add it back under **Signing & Capabilities → + Capability →
Background Modes → Location updates**. The app checks for the capability at
runtime and shows a warning in Settings instead of crashing if it is missing.

## How the miles are counted

Raw GPS wanders a few meters while you sit at a light; adding up every wobble
would inflate a shift by miles you never drove. `LocationTracker` therefore
drops fixes with accuracy worse than 50 m, ignores movement below the noise
floor of the two fixes involved (while keeping the old anchor point, so
stop-and-go traffic still adds up), and discards jumps faster than ~140 mph.

The result reads slightly *under* a car odometer rather than over it, which is
the right direction to be wrong in for a deduction.

## Taxes

The mileage rate in Settings defaults to `0.70`. The IRS publishes a new
standard rate every year — look up the current one and set it. The totals in
this app are estimates to hand to whoever does your taxes, not tax advice.

## Layout

```
ios/DashMiles/
├── DashMiles.xcodeproj
└── DashMiles/
    ├── DashMilesApp.swift        # entry point
    ├── Model/
    │   ├── Shift.swift           # one dash: start, end, meters, notes
    │   ├── Formatting.swift      # miles / clock / date helpers
    │   └── Settings.swift        # UserDefaults keys and defaults
    ├── Services/
    │   ├── LocationTracker.swift # GPS fixes -> meters, with filtering
    │   └── ShiftStore.swift      # shift list, JSON persistence, CSV
    └── Views/
        ├── RootView.swift        # tabs
        ├── DashView.swift        # start/stop + live odometer
        ├── HistoryView.swift     # months, totals, export
        ├── ShiftEditView.swift   # edit or add a dash by hand
        ├── SettingsView.swift
        └── ShareSheet.swift
```
