# KTrack 💜

> A calm companion for people living with PTSD and panic attacks.

KTrack is a beautifully animated Flutter app built to help someone track their
emotional disruptions, identify triggers, monitor medication, and — most
importantly — **see their own progress over time.**

Designed with soft gradients, gentle motion, and a low-friction interface,
KTrack aims to feel less like a clinical tracker and more like a quiet friend
that helps you notice patterns without judgement.

---

## ✨ Features

### 🏠 Home
- **Add an Entry** — log symptoms (fast heartbeat, headache, back pain,
  emotional stress, anxiety, tingling, flashbacks, nightmares, dizziness,
  nausea), rate severity 1–5, and add an optional note.
- **"Got Triggered" button** — one tap to log what triggered a panic response
  the moment it happens.
- **Daily motivational quote** — a rotating set of 15 gentle affirmations,
  delivered once per day based on the day of the year.
- **Soft pulsing trigger button** — a subtle visual cue for when things feel
  overwhelming.

### 📈 Graphs & Insights
- **Week / Month toggle** — switch views instantly.
- **Severity trend line chart** — average severity per day, with a glowing
  gradient line and filled area.
- **Panic frequency bar chart** — how many entries per day.
- **Symptom breakdown** — animated horizontal bars showing which symptoms
  appear most often.
- **Automatic trend detection** — KTrack compares the first half of the period
  against the second half and tells you plainly:
  - 🟢 **IMPROVING** — severity is decreasing
  - 🟡 **STABLE** — holding steady
  - 🔴 **NEEDS ATTENTION** — severity is rising
  - ⚪ **NOT ENOUGH DATA** — keep logging

  This is the heart of the app: a clear, non-clinical signal of whether things
  are getting better.

### 💊 Medicines
- Add medicines with **name, dosage, frequency, and notes**.
- Animated glass cards that slide in one by one.
- Swipe-free delete with a confirmation dialog.

### 🎨 Design & Feel
- **Floating gradient blobs** drifting slowly in the background — no static
  screens.
- **Glassmorphism cards** with soft borders and shadows.
- **Touch animations everywhere** — buttons scale down and spring back,
  symptom chips glow when selected, tabs expand into gradient pills.
- **Cinematic loading screen** with a pulsing gradient heart, rotating dashed
  rings, a shimmering KTRACK title, and today's quote — then a smooth fade into
  the app.
- Built with **Poppins** typography for a soft, modern, calming feel.

### 📦 Under the Hood
- **Local-first** — all data stored on-device with `shared_preferences`. No
  accounts, no servers, no network calls.
- **Offline by default** — works completely without internet.
- **Cross-platform** — Android and iOS from a single Flutter codebase.
- **Privacy-conscious by design** — nothing ever leaves the phone.

---

## 🛠️ Tech Stack

| Layer | Tech |
|-------|------|
| Framework | Flutter (Dart 3) |
| Charts | `fl_chart` |
| Local storage | `shared_preferences` |
| Typography | `google_fonts` (Poppins) |
| IDs | `uuid` |
| Dates | `intl` |
| App icon | `flutter_launcher_icons` |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio (for Android) and/or Xcode (for iOS)

### Run locally

```bash
git clone https://github.com/gottabealln/ktrack.git
cd ktrack
flutter pub get
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

### Build for iOS (Mac only)

```bash
flutter build ios
```

---

## 📸 Screenshots

> _Add screenshots here once you've run the app._
>
> Suggested shots:
> - Loading screen
> - Home with quote + buttons
> - Add Entry sheet with symptom chips
> - Graphs (week view) with trend card
> - Medicines list

---

## 🎯 Why This Exists

KTrack was built for a friend navigating PTSD and panic attacks. Existing
symptom trackers felt clinical, cold, or overwhelming. KTrack tries to be the
opposite: **gentle, animated, and honest** — a space to log what's happening
without being judged, and to notice that healing, even when it feels invisible,
shows up in the data.

If it helps even one person feel a little less alone, it did its job.

---

## ⚠️ Disclaimer

KTrack is **not** a medical device and **not** a substitute for professional
care. It is a personal tracking tool. If you or someone you know is in crisis,
please reach out to a mental health professional or a local crisis line.

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

## 💜 Acknowledgements

- Built with [Flutter](https://flutter.dev)
- Charts by [fl_chart](https://pub.dev/packages/fl_chart)
- Icons and typography via [Google Fonts](https://fonts.google.com)
- Inspired by everyone who keeps showing up on the hard days.
