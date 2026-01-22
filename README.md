<img src="assets/icon-1024.png" alt="Bubbletrail" width="128" height="128">

# Bubbletrail

> A dive log application for scuba divers

## About

Bubbletrail is a free, open-source dive log for recording and organising
your scuba dives. It connects directly to dive computers over Bluetooth,
imports logs from Subsurface and other programs, and displays dive profiles
including depth, temperature, tank pressure, and calculated deco. Whether
you're a recreational diver or into technical diving with multiple gas
mixes, Bubbletrail keeps your dive history in one place.

The app aims for a modern, intuitive interface and surfaces best-practice
metrics like surface gradient factors (SurfGF) to help you understand your
dives better.

## Features

- Connect to dive computers via Bluetooth LE using libdivecomputer
- Import dives from Subsurface (`.ssrf` format), MacDive (`.xml`) and other
  programs (`.uddf` format).
- View dive profiles with depth, temperature, deco, and tank pressure charts
- Built-in application of Buhlmann ZHL-16c to dive profiles, showing deco
  and end SurfGF even your computer didn't calculate it
- Manage dive sites with GPS coordinates, description, and tags
- Support for technical diving (multiple gases, O2/He percentages)

## Getting started

See <https://bubbletrail.app/getting-started/>.

## Building

```bash
cd app
flutter pub get
flutter run
```

## License

EUPL-1.2
