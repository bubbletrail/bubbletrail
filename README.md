<img src="assets/icon-1024.png" alt="Bubbletrail" width="128" height="128">

# Bubbletrail

> A dive log application for scuba divers

## Rationale & goals

Bubbletrail is a personal project to create a dive log that *works for me*.
Goals and aspirations include:

- Stable and well maintained. Bugs are fixed before features are added.
  Values, measurements and results must be correct and technically sound.

- Open exchange of data. Supports import and export in open and common
  formats to prevent any lock-in. You can migrate your existing log to
  Bubbletrail, and then migrate to something better again the future.

- Technically transparent and supports modern best practices. Shows all
  values actually recorded by the dive computer. Computes decompression
  status using Buhlmann ZHL-16C with configurable gradient factors for
  post-dive analysis.

- Cross platform. The same app needs to run on mobile and desktop, on all
  common operating systems. (But for me personally that means iOS and macOS;
  Android and Windows seems to work but isn't tested.)

- Data syncing with privacy. Can use a standard S3 object store for data
  sync between devices, without exposing your personal data to the storage
  operator.

- Organic development. Bubbletrail is not vibe coded.

## Building

```bash
cd app
flutter pub get
flutter run
```

## License

EUPL-1.2
