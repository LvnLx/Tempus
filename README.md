# Tempus

An iOS metronome app developed with [Flutter](https://flutter.dev/), supporting real-time adjustments to timing and sound settings without producing any audio artifacts (clicks and pops) during playback. The main focus of the app is to have robust and highly flexible features that ensure a seamless experience. It is available to [download on the App Store](https://apps.apple.com/us/app/tempus-metronome/id6738511466?platform=iphone)

## Sections
- [Key Features](#key-features)
- [Techincal Challenges](#technical-challenges)
- [Architecture](#architecture)
- [Limitations](#limitations)
- [Media](#media)

# Key Features
- Multiple subdivisions
  - One of the main technical motivations for creating this app was having a metronome app that supports multiple subdivisions at once, similar to a [Boss DB-90](https://www.boss.info/us/products/db-90/), but even more flexbile. Users can select subdivisions ranging from 2 to 9, which correspond to eighth notes (2), eighth note triplets (3), quarter notes (4), and so on, while controlling the volume of them independently.
  - The UI implementation for subdivision control (and beat/accent volume control) was also heavily inspired by the [Boss DB-90](https://www.boss.info/us/products/db-90/), as well as the faders found in DAWs/mixing consoles — an inspiration stemming from my hobbyist background in audio engineering and creating drum covers:

    <img src="https://github.com/user-attachments/assets/544e0546-6a9a-4978-9081-610d92ca6219" height="200">

- Complex time signatures
  - Many metronome apps only support a small set of time signatures, so it seemed like a great challenge and feature to be able to support any time signature a user would like. Users can select subdivisions with numerators and denominators ranging from 1 - 99 each, which also yields irrational time signatures:
  
    <img src="https://github.com/user-attachments/assets/5ea1387f-c8c6-43df-93a6-a885d1532a7f" width="200">

- Felxibe beat unit
- Tempo adjustment
- Sample selection
- Volume adjustment

# Technical Challenges

# Architecture

# Limitations

# Media
