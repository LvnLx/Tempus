# Tempus

An iOS metronome app developed with [Flutter](https://flutter.dev/), supporting real-time adjustments to timing and sound settings without producing any audio artifacts (clicks and pops) during playback. The main focus of the app is to have robust and highly flexible features that ensure a seamless experience. It is available to [download on the App Store](https://apps.apple.com/us/app/tempus-metronome/id6738511466?platform=iphone)

## Sections
- [User Interface](#user-interface)
- [Key Features](#key-features)
  - [Multiple Subdivisions](#multiple-subdivisions)
  - [Complex Time Signatures](#complex-time-signatures)
  - [Flexible Beat Units](#flexible-beat-units)
  - [Tempo Adjustment](#tempo-adjustment)
  - [Accessibility](#accessibility)
  - [Sample Selection](#sample-selection)
  - [Volume Adjustment](#volume-adjustment)
- [Techincal Challenges](#technical-challenges)
- [Architecture](#architecture)
- [Limitations](#limitations)
- [Media](#media)

## User Interface

The design for the UI is intended to take cues from the native iOS look, remain consistent across devices (both iPhones and iPads are supported), adapt to the light/dark mode preference of the user's device, and remain intuitive to use. The settings page in particular leans very closely on the native settings look

| Light Mode | Dark Mode | Settings |
| ---------- | --------- | -------- |
| <img src="https://github.com/user-attachments/assets/e18bc486-af25-4dbc-8b2e-56960d27a3a2" width="300"> | <img src="https://github.com/user-attachments/assets/ca999eed-354c-467c-bf49-f90ef9ca5d65" width="300"> | <img src="https://github.com/user-attachments/assets/d9b9db98-8768-42d9-8f7d-e68e6a2f8588" width="300"> |



## Key Features
### Multiple Subdivisions
- One of the main technical motivations for creating this app was having a metronome app that supports multiple subdivisions at once, similar to a [Boss DB-90](https://www.boss.info/us/products/db-90/), but even more flexbile in terms of subdivision choice. Users can select subdivisions ranging from 2 to 9, which correspond to eighth notes (2), eighth note triplets (3), quarter notes (4), and so on, while controlling the volume of them independently
- The UI implementation for subdivision control (and beat/accent volume control) was also heavily inspired by the [Boss DB-90](https://www.boss.info/us/products/db-90/), as well as the faders found in DAWs/mixing consoles — an inspiration stemming from my hobbyist background in audio engineering and creating drum covers:

  <img src="https://github.com/user-attachments/assets/544e0546-6a9a-4978-9081-610d92ca6219" height="200">
  
### Complex Time Signatures
- Many metronome apps only support a small set of time signatures, so it seemed like a good technical challenge and feature to be able to support any time signature a user would like. Users can select subdivisions with numerators and denominators ranging from 1 - 99 each, which also enables irrational time signatures, something most metronome apps can not do:

  <img src="https://github.com/user-attachments/assets/5ea1387f-c8c6-43df-93a6-a885d1532a7f" height="200">

### Flexible Beat Units
- Similar to time signatures, beat unit is typically only selectable from a small set of pre-defined options. Since musical notation is necessary to display the beat unit, the approach taken for this app is to have partially pre-defined, but also a large set of generated beat unit options, with support from whole notes to 99-lets, including a small set of dotted notes commonly used, which integrates well with the aforementioned time signatures:

  <img src="https://github.com/user-attachments/assets/02dfd2c5-ab6f-4833-868d-f63a2e050ba7" height="200">

### Tempo Adjustment

- There are a variety of tempo adjustment behaviors that can be found across metronome apps, and having used many of them, having immediate tempo adjustment capabilities appears to be the best user experience. The app allows real-time tempo adjustments, and importantly without any audio artifacts (regardless of the tempo and quantity of subdivisions being played back)
- The BPM range users can select from is 1 - 999, which is among the most flexible for metronome apps, as many set the lower limit to ~30 and the upper limit to ~300. In most settings, users need to be able to make BPM adjustments both quickly and acurrately. To enable this precision single digit incrementing/decrement, a scroll wheel, and numeric input is supported:
  
  <img src="https://github.com/user-attachments/assets/2c20b56c-7672-47a1-ad30-76a244e2e132" height="200"> <img src="https://github.com/user-attachments/assets/515950b9-0f5f-4ede-aa40-a3226cb290bd" height="200">

### Accessibility

- Since audio is not always feasible, both haptics and flashlight usage are supported. Some apps have flashlight support, however haptics are rarely supported, especially for the different types of notes being played back. The app supports different haptic strengths for accents, beats, and subdivisions, essentially giving the user a full haptic equivalent for the audio that is currently being played back:

  <img src="https://github.com/user-attachments/assets/074de9eb-7cbb-4efe-8c05-7511fedc93fe" height="200"> <img src="https://github.com/user-attachments/assets/9b4d198a-3f13-492f-bfee-c8b7b520999b" height="200">

### Sample Selection

- Although not unique to this app, sample selection is also supported (again, in real-time) with a sample being a set of sounds for the accent, beat, and subdivision:

  <img src="https://github.com/user-attachments/assets/1bf2feef-ff2d-4a66-b68a-5caab9e1805e" height="200">

### Volume Adjustment

- Volume adjustment is somewhat supported by different metronome apps, but to enable full flexibility for this app the volume for the beat, accent (note at the beginning of the measures), subdivisions, and app as a whole can be independently set, with the last one inspired by [Gap Click](https://gapclick.app/) developed by [Derek Lee](https://github.com/theextremeprogrammer):

  <img src="https://github.com/user-attachments/assets/b7b10095-6c51-4c0e-9f29-2a764eb398f9" height="200"> <img src="https://github.com/user-attachments/assets/6cad9249-aa6a-487e-9ac7-dc0835ee19d0" height="200">

# Technical Challenges

# Architecture

# Limitations

# Media
