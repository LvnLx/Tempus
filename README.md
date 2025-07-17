# Tempus

An iOS metronome app developed with [Flutter](https://flutter.dev/), supporting real-time adjustments to timing and sound settings without producing any audio artifacts (clicks and pops) during playback. The main focus of the app is to have robust and highly flexible features that ensure a seamless experience. It is available to [download on the App Store](https://apps.apple.com/us/app/tempus-metronome/id6738511466?platform=iphone)

This document is split into a [Nontechnical](#nontechnical) and [Technical](#technical) section. The former doesn't require any previous programming experience to follow along, and covers high level design and features. The latter is targeted towards those with a programming background and provides a deeper look at implementations, considerations, and iterations of this app

## Terminology

- **Audio Artifact**: An unintended and typically unpleasant click or pop that occurs during audio playback
- **Beat**: Any counted note in a measure. In `4/4` for example there are beats `1`, `2`, `3`, and `4`
- **Clip**: A short bit of audio such as a tambourine, clave, or drumstick click
- **Downbeat**: The first beat of a measure
- **Sample**: A single point of audio data, typically in the `-1.0` - `1.0` range. Audio files typically have `44,100` or `48,000` samples per second
- **Subdivision/Inner Beat**: Any note that falls between beats. For example an eighth note subdivision in `4/4` would be the `and` between each beat

## Index

- [Nontechnical](#nontechnical)
  - [User Interface](#user-interface)
  - [Features](#features)
    - [Multiple Subdivisions](#multiple-subdivisions)
    - [Complex Time Signatures](#complex-time-signatures)
    - [Flexible Beat Units](#flexible-beat-units)
    - [Tempo Adjustment](#tempo-adjustment)
    - [Accessibility](#accessibility)
    - [Sample Selection](#sample-selection)
    - [Volume Adjustment](#volume-adjustment)
- [Technical](#technical)
  - [Audio Engine](#audio-engine)
    - [Audio Artifacts](#audio-artifacts)
    - [Iterations](#iterations)
      - [Queueing](#queueing)
      - [Audio Buffering](#audio-buffering)
      - [Fading](#fading)
      - [Ensuring Completion](#ensuring-completion)
  - [Metronome](#timing)
    - [System](#system)
    - [Events](#events)
  - [Architecture](#architecture)
  - [Limitations](#limitations)



## Nontechnical

### User Interface

The design for the UI is intended to take cues from the native iOS look, remain consistent across iPhones and iPads, adapt to the light/dark mode preference of the user's device, and remain intuitive to use. The settings page in particular leans very closely on the native settings look

| Light Mode | Dark Mode | Settings |
| ---------- | --------- | -------- |
| <img src="https://github.com/user-attachments/assets/e18bc486-af25-4dbc-8b2e-56960d27a3a2" width="300"> | <img src="https://github.com/user-attachments/assets/ca999eed-354c-467c-bf49-f90ef9ca5d65" width="300"> | <img src="https://github.com/user-attachments/assets/d9b9db98-8768-42d9-8f7d-e68e6a2f8588" width="300"> |

### Features

#### Multiple Subdivisions
One of the main technical motivations for creating this app was having a metronome app that supports multiple subdivisions at once, similar to a [Boss DB-90](https://www.boss.info/us/products/db-90/), but even more flexbile in terms of subdivision choice. Users can select subdivisions ranging from 2 to 9, which correspond to eighth notes (2), eighth note triplets (3), quarter notes (4), and so on, while controlling the volume of them independently

The UI implementation for subdivision control (and beat/accent volume control) was also heavily inspired by the [Boss DB-90](https://www.boss.info/us/products/db-90/), as well as the faders found in DAWs/mixing consoles — an inspiration stemming from my hobbyist background in audio engineering and creating drum covers:

<img src="https://github.com/user-attachments/assets/544e0546-6a9a-4978-9081-610d92ca6219" height="200"> <img src="https://github.com/user-attachments/assets/0994d73a-f5fe-4cf4-b9ac-1e460ae59232" height="200">

#### Complex Time Signatures
Many metronome apps only support a small set of predefined time signatures, so it seemed like a good technical challenge and feature to be able to support any time signature a user would like. Users can select subdivisions with numerators and denominators ranging from 1 - 99 each, which also enables irrational time signatures, something most metronome apps can not do:

<img src="https://github.com/user-attachments/assets/5ea1387f-c8c6-43df-93a6-a885d1532a7f" height="200">

#### Flexible Beat Units
Similar to time signatures, the beat unit is typically only selectable from a small set of predefined options. Since musical notation is necessary to display the beat unit, the approach taken for this app is to have partially pre-defined, but also a large set of generated beat unit options, with support from whole notes to 99-lets, including a small set of dotted notes commonly used:

<img src="https://github.com/user-attachments/assets/02dfd2c5-ab6f-4833-868d-f63a2e050ba7" height="200">

#### Tempo Adjustment

There are a variety of tempo adjustment behaviors that can be found across metronome apps. Having used many of them, immediate tempo adjustment capabilities, as opposed to gradual tempo ramping or only allowing updates while paused, appears to be the best user experience. The app allows real-time tempo adjustments, and importantly without any audio artifacts (regardless of the tempo and quantity of subdivisions being played back)

> [!NOTE]  
> Some of the most popular metronome apps exhibit audio artifacts when making adjustments during playback, demonstrating how challenging of a problem it can be to eliminate them

The BPM range users can select from is 1 - 999, which is among the most flexible for metronome apps, as many set the lower limit to ~30 and the upper limit to ~300. For most use cases, users need to be able to make BPM adjustments both quickly and accurately. To enable this precision single digit incrementing/decrementing, a scroll wheel, and numeric input is supported:
  
<img src="https://github.com/user-attachments/assets/2c20b56c-7672-47a1-ad30-76a244e2e132" height="200"> <img src="https://github.com/user-attachments/assets/515950b9-0f5f-4ede-aa40-a3226cb290bd" height="200">

#### Accessibility

Since audio is not always feasible, both haptics and flashlight usage are supported. Some apps have flashlight support, however haptics are rarely supported, especially for the different types of notes being played back. The app supports different haptic strengths for accents, beats, and subdivisions, essentially giving the user a full haptic equivalent for the audio that is currently being played back:

<img src="https://github.com/user-attachments/assets/074de9eb-7cbb-4efe-8c05-7511fedc93fe" height="200"> <img src="https://github.com/user-attachments/assets/9b4d198a-3f13-492f-bfee-c8b7b520999b" height="200">

#### Sample Selection

Although not unique to this app, sample selection is also supported (again, in real-time) with a sample being a set of sounds for the accent, beat, and subdivision:

<img src="https://github.com/user-attachments/assets/1bf2feef-ff2d-4a66-b68a-5caab9e1805e" height="200">

#### Volume Adjustment

Volume adjustment is somewhat supported by different metronome apps, but to enable full flexibility for this app the volume for the beat, accent (note at the beginning of the measures), subdivisions, and app as a whole can be independently set, with the last one inspired by [Gap Click](https://gapclick.app/) developed by [Derek Lee](https://github.com/theextremeprogrammer):

<img src="https://github.com/user-attachments/assets/b7b10095-6c51-4c0e-9f29-2a764eb398f9" height="200"> <img src="https://github.com/user-attachments/assets/6cad9249-aa6a-487e-9ac7-dc0835ee19d0" height="200">

## Technical

### Audio Engine

#### Audio Artifacts

In the context of metronome apps, audio artifacting has the potential to present itself anytime a change is made to the metronome that affects the content being played back. This could be a volume change, a timing change (time signature, tempo, etc.), additions/subtractions of a subdivision, or changing the clips being used from a clave to a tambourine, for example.

During initial prototyping this wasn't an issue I was aware of, and I thought that I could simply make any changes to the audio as soon as the user requested that change. Regardless of if you pause, change the upcoming audio queue, then resume, or just change the queue while still playing back, audio artifacts will occur. This is becuase the playback head (the audio currently being played to the user) may be in the middle of a clip, and not in a silent section. An example of this can be seen below, where the line represents the playback head, i.e. the audio the user is currently hearing:

<img src="https://github.com/user-attachments/assets/b228f74b-00f8-4ac7-bb20-22f76a383faf" height="400">

#### Iterations

##### Queueing

The initial attempts of implementing this were done using the [Audio Queue Services](https://developer.apple.com/documentation/audiotoolbox/audio-queue-services) interface, as it aligned with my idea of being able to queue my clips, followed by the necessary amount of silence before the next clip, which would effectively give the auditory experience of a metronome at a given tempo

> [!IMPORTANT]
> Time signatures and beat units were not considered at this point yet due to the added timing complexities. Only simple tempo control was considered, for example 120 BPM

This being the first approach, audio artifacts were an issue due to the potential for clips being changed while being played back, as well as timing consistency. The latter was an issue due to the lack of control over delays in dequeueing and the aforemention playing/pausing approaches

##### Audio Buffering

With the realization that high level interfaces such as [Audio Queue Services](https://developer.apple.com/documentation/audiotoolbox/audio-queue-services) wouldn't be sufficient for the intricate and precise audio/timing controls needed for a metronome, I began looking for better options. After doing quite a bit of research it appeared that a buffered interface such as the Audio Unit components of the [Audio Toolbox](https://developer.apple.com/documentation/audiotoolbox) would be the right option. The Android equivalent is [Oboe](https://github.com/google/oboe), and was used for the C++ implementation of the app (see the [Limitations](#limitations) section for details)

At a high level, a buffered audio interface works by periodically asking the program to load audio data into a buffer of audio data, which the interface provides: "Give me 512 samples of audio data into this buffer, please". This appears to be very simple on the surface, and it is! The caveat is that as soon as the interface asks for data, the data **must** be provided. Any "blocking" operations such as allocating new memory, making external calls, or waiting for other functions to complete, should be avoided, as the audio buffer may otherwise be starved of data

Usage of a buffered audio interface like this doesn't inherintly help us solve the problem of audio artifacts, however it gives us sample level control of audio that is being played back. This guarantees sample accurate timing (crucial for a metronome), and removes any abstractions that hide potential latency or delays to changes in audio we might want to make

##### Fading

Even armed with an audio buffer interface that improved timing properties of the metronome, the problem of audio artifacts still remained. There were a few iterations that I worked through at this stage, however the prevalent theme was trying to make any changes to the metronome that might introduce audio artifacts *gradually*. An example of this is taking a short window from the time the change was requested (say 50 milliseconds), and gradually fading from the current audio buffer to the next one. This is essentially crossfading, for which a visual example can be found [here](https://manual.audacityteam.org/man/fade_and_crossfade.html#dj)

While helping reduce audio artifacts (primarily by making them quieter and more gradual), they were still celarly audible. An extreme example of this is a sample with a value of 1.0 followed by a sample with a value of -1.0. If the adjustment requested by the user is delayed to be made halfway through the crossfade, we might be able to avoid the abrupt jump between the two adjacent samples, however the shift in sounds samples can still incur audio artifacts, the the clips may be starting/stopping at completely different points within the clip. Alas, the fading option was not viable

##### Ensuring Completion

A working solution to this problem took a few weeks and tons of brain racking to arrive at, and as with most things it took some reconsideration to realize what actually addressed the problem. One of the main concerns was enabling real-time user changes. I had associated that with changing what was in the audio buffer **immediately**, and while that assessment was correct, one of the key details wasn't obvious

> Once a clip has started playing back, it must complete without being directly altered

This doesn't seem that revolutionary on the surface, however all of the previous solutions effectively changed any clips that were in progress of being played. Instead of cutting off a clip, a much cleaner approach would be to just let any clips that are currently being played back complete. And vice versa, if the user requested change would cause the playback head to be placed in the middle of a clip that was never properly started at it's first sample, it isn't played back

With this approach, all areas of potential audio artifacting are directly addressed. Any given audio sample will always be started from it's first sample and always be guaranteed playback it's last sample.

> [!IMPORTANT]
> This approach still allows multiple clips to overlap. For example, in instances of higher tempos with intricate subdivisions

### Timing

#### System

One of the big functional challenges in metronomes is the support for time signatures and beat units. Many metronome apps support a list of pre-canned time signatures (such as 4/4, 3/4, 6/8. 5/4, 12/8, ...) and beat units (such as quarter notes, dotted quarter notes, eighth notes, ...). Welcoming the challenge of not just hardcoding a bunch of different combinations for timing, I decided on implementing a generalized, sample accurate system, that offers user practically limitless flexibility (see the [Key Features](#key-features) section for the ranges that are supported for each timing element)

To integrate with a dynamic timing system like this, the audio buffer interface would essentially act as the driver for a separate timing buffer. The latter is a sample acurrate representation of a measure of the given metronome settings. For example:

| Tempo (BPM) | Time Signature |   Beat Unit  | Sample Rate | Measure Length (Samples) | Quarter Note Locations (Samples) |
| ----------- | -------------- | ------------ | ----------- | ------------------------ | -------------------------------- |
|     120     |       4/4      | Quarter Note |   44,100Hz  |          88,200          |  22,050, 44,100, 66,150, 88,200  |

Anytime the audio buffer interface would ask for a sample, both it's own [pointer](https://en.wikipedia.org/wiki/Pointer_(computer_programming)) and that of the timing buffer would be incremented. During this increment the following occurs:

1. Any clip that starts on the current timing buffer sample is marked as active
2. For all active clips, copy their current sample value into the audio buffer and increment their pointer
3. For all clips that have reached the end of their sample values, mark them as inactive

This approach implements what was discussed in [Ensuring Completion](#ensuring-completion). In addition to what was just described, any wrapping around to the beginning of buffers is also handled, so that there is only ever one active timing buffer, and clips are reset to a state in which they are ready to be picked up again by the time the next measure is played

The locations and measure length shown in the previous chart for quarter notes are a simple numeric example of where clips are placed within the timing buffer and show values for a given input. For those interested in a more technical look at how all of the locations and measure length are calculated, please feel free to take a look at the implementation [here](https://github.com/LvnLx/Tempus/blob/main/ios/Runner/Metronome.swift#L207)

#### Events

One of the difficulties with having a low-level audio engine like this is notifying any other parts of the application of changes or events in audio. To help alleviate this issue and enable some insight from the outside world a simple tie in was made to the existing clips used in the timing buffers. The clips are already written as a `struct` in code, which allows them to also take a callback function as one of their fields. This callback can technically be repurposed to do anyhting, but since most of the functionality for the rest of the app lives within the [Flutter](https://flutter.dev/) layer of the application, the callback simply sends a method channel invocation with some data about what kind of clip made the call. More details about this communication can be found in the [Architecture](#architecture) section

## Architecture

## Limitations
