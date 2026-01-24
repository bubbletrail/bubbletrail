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

## Rationale & goals

Bubbletrail takes inspiration from existing apps and wouldn't exist without
them. Nonetheless, the existing alternatives have flaws that were serious
enough to motivate me to create this app. I mention the forebears here not
with scorn but with the utmost respect for their creators:

- **MacDive**, which has been my primary dive log for a log time and would
  continue to be so had it been maintained or, at least, open source so I
  could attempt to maintain it myself.

- **Subsurface**, which provides excellent tools for technical analysis of
  dives and a fantastic dive planner, but unfortunately falls flat as a user
  interface I want to use on my phone. Had I been more enamoured with C and
  Qt I'd have made a serious attempt to contribute a better mobile
  experience; alas, that's not me.

Hence, Bubbletrail. Bubbletrail should be:

- Well maintained, and work on the latest version of all popular platforms
  (Windows, macOS, Linux, Android, and iOS);

- Free, open, and technically excellent like Subsurface; and

- Full-featured and with an attractive user interface, like MacDive.

It isn't full-featured, yet. But it _is_ open source, written in a fashion
that should have a fairly low threshold to contribution for other people,
and I'm also building out functionality as we speak. We'll see if we get
there!

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
