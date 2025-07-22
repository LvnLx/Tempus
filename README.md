# Tempus

An iOS metronome app developed with [Flutter](https://flutter.dev/), supporting real-time adjustments to timing and sound settings without producing any audio artifacts during playback. The main focus of the app is to have robust and highly flexible features that ensure a seamless experience. It is available to [download on the App Store](https://apps.apple.com/us/app/tempus-metronome/id6738511466?platform=iphone)

This document is split into a [Nontechnical](#nontechnical) and [Technical](#technical) section. The former doesn't require any previous programming experience to follow along, and covers high level design and features. The latter is targeted towards those with a programming background and provides a deeper look at implementations, considerations, and iterations of the app

## Terminology

- **Audio Artifact**: An unintended and typically unpleasant click or pop that occurs during audio playback
- **Beat**: Any counted note in a measure. In `4/4` for example there are beats `1`, `2`, `3`, and `4`
- **Clip**: A short bit of audio such as a tambourine, clave, or drumstick click
- **Downbeat**: The first beat of a measure
- **Playback Head**: The sample location of where the audio is currently being played back
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
    - [Settings Persistence]()
- [Technical](#technical)
  - [Audio Engine](#audio-engine)
    - [Audio Artifacts](#audio-artifacts)
    - [Iterations](#iterations)
      - [Queueing](#queueing)
      - [Audio Buffering](#audio-buffering)
      - [Fading](#fading)
      - [Ensuring Completion](#ensuring-completion)
  - [Metronome](#metronome)
    - [System](#system)
    - [Integration](#integration)
    - [Updates](#updates)
    - [Events](#events)
  - [Miscellaneous](#miscellaneous)
    - [Flutter Native Communication](#flutter-native-communication)
    - [Timing Accuracy](#timing-accuracy)
    - [Setting Persistence](#setting-persistence)
- [Limitations](#limitations)
  - [Android](#android)
  - [Multiple Measures](#multiple-measures)
  - [Testing](#testing)
  - [Continuous Integration and Deployment](#continuous-integration-and-deployment)

## Nontechnical

### User Interface

The design for the UI is intended to take cues from the native iOS look, remain consistent across iPhones and iPads, adapt to the light/dark mode preference of the user's device, and remain intuitive to use. The settings page in particular leans very closely on the native settings look

| Light Mode | Dark Mode | Settings |
| ---------- | --------- | -------- |
| <img src="https://github.com/user-attachments/assets/e18bc486-af25-4dbc-8b2e-56960d27a3a2" width="300"> | <img src="https://github.com/user-attachments/assets/ca999eed-354c-467c-bf49-f90ef9ca5d65" width="300"> | <img src="https://github.com/user-attachments/assets/d9b9db98-8768-42d9-8f7d-e68e6a2f8588" width="300"> |

### Features

#### Multiple Subdivisions
One of the main technical motivations for creating the app was having a metronome app that supports multiple subdivisions at once, similar to a [Boss DB-90](https://www.boss.info/us/products/db-90/), but even more flexible in terms of subdivision choice. Users can select subdivisions in the range `2` - `9`, which correspond to eighth notes (`2`), eighth note triplets (`3`), quarter notes (`4`), and so on, while controlling the volume of them independently

The UI implementation for subdivision control (and beat/accent volume control) was also heavily inspired by the [Boss DB-90](https://www.boss.info/us/products/db-90/), as well as the faders found in DAWs/mixing consoles — an inspiration stemming from my hobbyist background in audio engineering and creating drum covers:

<img src="https://github.com/user-attachments/assets/544e0546-6a9a-4978-9081-610d92ca6219" height="200"> <img src="https://github.com/user-attachments/assets/0994d73a-f5fe-4cf4-b9ac-1e460ae59232" height="200">

#### Complex Time Signatures
Many metronome apps only support a small set of predefined time signatures, so it seemed like a good technical challenge and feature to be able to support any time signature a user would like. Users can select subdivisions with numerators and denominators in the range `1` - `99` each, which also enables irrational time signatures, something most metronome apps can not do:

<img src="https://github.com/user-attachments/assets/5ea1387f-c8c6-43df-93a6-a885d1532a7f" height="200">

#### Flexible Beat Units
Similar to time signatures, the beat unit is typically only selectable from a small set of predefined options. Since musical notation is necessary to display the beat unit, the approach taken for the app is to have partially pre-defined, but also a large set of generated beat unit options, with support from whole notes to 99-lets, including a small set of dotted notes commonly used:

<img src="https://github.com/user-attachments/assets/02dfd2c5-ab6f-4833-868d-f63a2e050ba7" height="200">

#### Tempo Adjustment

There are a variety of tempo adjustment behaviors that can be found across metronome apps. Having used many of them, immediate tempo adjustment capabilities, as opposed to gradual tempo ramping or only allowing updates while paused, appears to be the best user experience. The app allows real-time tempo adjustments, and importantly without any audio artifacts (regardless of the tempo and quantity of subdivisions being played back)

> [!NOTE]  
> Some of the most popular metronome apps exhibit audio artifacts when making adjustments during playback, demonstrating how challenging of a problem it can be to eliminate them

The BPM range users can select from is `1` - `999`, which is among the most flexible for metronome apps, as many set the lower limit to `~30` and the upper limit to `~300`. For most use cases, users need to be able to make BPM adjustments both quickly and accurately. To enable this precision single digit incrementing/decrementing, a scroll wheel, and numeric input is supported:
  
<img src="https://github.com/user-attachments/assets/2c20b56c-7672-47a1-ad30-76a244e2e132" height="200"> <img src="https://github.com/user-attachments/assets/515950b9-0f5f-4ede-aa40-a3226cb290bd" height="200">

#### Accessibility

Since audio is not always feasible, both haptics and flashlight usage are supported. Some apps have flashlight support, however haptics are rarely supported, especially for the different types of notes being played back. The app supports different haptic strengths for accents, beats, and subdivisions, essentially giving the user a full haptic equivalent for the audio that is currently being played back:

<img src="https://github.com/user-attachments/assets/074de9eb-7cbb-4efe-8c05-7511fedc93fe" height="200"> <img src="https://github.com/user-attachments/assets/9b4d198a-3f13-492f-bfee-c8b7b520999b" height="200">

#### Sample Selection

Although not unique to the app, sample selection is also supported (again, in real-time) with a sample being a set of sounds for the accent, beat, and subdivision:

<img src="https://github.com/user-attachments/assets/1bf2feef-ff2d-4a66-b68a-5caab9e1805e" height="200">

#### Volume Adjustment

Volume adjustment is somewhat supported by different metronome apps, but to enable full flexibility for the app the volume for the beat, accent (note at the beginning of the measures), subdivisions, and app as a whole can be independently set, with the last one inspired by [Gap Click](https://gapclick.app/) developed by [Derek Lee](https://github.com/theextremeprogrammer):

<img src="https://github.com/user-attachments/assets/b7b10095-6c51-4c0e-9f29-2a764eb398f9" height="200"> <img src="https://github.com/user-attachments/assets/6cad9249-aa6a-487e-9ac7-dc0835ee19d0" height="200">

## Technical

### Audio Engine

#### Audio Artifacts

In the context of metronome apps, audio artifacting has the potential to present itself anytime a change is made to the metronome during playback that affects the audio content. This could be a volume change, a timing change (time signature, tempo, etc.), additions/subtractions of a subdivision, or changing the clips being used from a clave to a tambourine, for example.

During initial prototyping this wasn't an issue I was aware of, and I thought that I could simply make any changes to the audio as soon as the user requested that change. Regardless of if you pause, change the upcoming audio queue, then resume, or just change the queue while still playing back, audio artifacts will occur. This is because the playback head may be in the middle of a clip, and not in a silent section. If a sudden jump occurs in sample value (from `0.5` to -`0.75` for example), then an audio artifact will be audible

#### Iterations

##### Queueing

The initial attempts of implementing this were done using the [Audio Queue Services](https://developer.apple.com/documentation/audiotoolbox/audio-queue-services) interface, as it aligned with my idea of being able to queue my clips, followed by the necessary amount of silence before the next clip, which would effectively give the auditory experience of a metronome at a given tempo:

<img src="https://github.com/user-attachments/assets/e4d1454b-5b97-4d4b-aa0c-9125081c3e03" height="200">

This being the first approach, audio artifacts were an issue due to the potential for clips being changed while being played back. In the below example we are updating the queue from the top state to the bottom state during the middle of the playback of the first clip (this being an example of changing to a clip with a different sound, such as from a tambourine to a clave). The instant transition has a high probability to cause an audio artifact:

<img src="https://github.com/user-attachments/assets/c43bb4d1-a6b3-43ed-8466-76fcaf4cc237" height="200">

Another issue was timing accuracy, due to the lack of control over delays in dequeueing when dealing with the [Audio Queue Services](https://developer.apple.com/documentation/audiotoolbox/audio-queue-services) interface

> [!IMPORTANT]
> Time signatures and beat units were not considered at this point yet due to the added timing complexities. Only simple tempo control was considered, for example `120` BPM

##### Audio Buffering

With the realization that high level interfaces such as [Audio Queue Services](https://developer.apple.com/documentation/audiotoolbox/audio-queue-services) wouldn't be sufficient for the intricate and precise audio/timing controls needed for a metronome, I began looking for better options. After doing quite a bit of research it appeared that a buffered interface such as the Audio Unit components of the [Audio Toolbox](https://developer.apple.com/documentation/audiotoolbox) would be the right option. The Android equivalent is [Oboe](https://github.com/google/oboe), and was used for the C++ implementation of the app (see the [Limitations](#limitations) section for details)

At a high level, a buffered audio interface works by periodically asking the program to load audio data into a buffer of audio data, which the interface provides: "Give me `512` samples of audio data into this buffer, please". the appears to be very simple on the surface, and it is! The caveat is that as soon as the interface asks for data, the data **must** be provided. Any "blocking" operations such as allocating new memory, making external calls, or waiting for other functions to complete, should be avoided, as the audio buffer may otherwise be starved of data

Usage of a buffered audio interface like this doesn't inherently help us solve the problem of audio artifacts, however it gives us sample level control of audio that is being played back. This guarantees sample accurate timing (crucial for a metronome), and removes any abstractions that hide potential latency to changes in metronome content we might want to make:

<img src="https://github.com/user-attachments/assets/1a3e8093-4968-4952-ac6b-4b7edf878a8a" height="200">

##### Fading

Even armed with an audio buffer interface that improved timing properties of the metronome, the problem of audio artifacts still remained. There were a few iterations that I worked through at this stage, however the prevalent theme was trying to make any changes to the metronome that might introduce audio artifacts *gradually*. An example of this is taking a short window from the time the change was requested (say `50` milliseconds), and gradually fading from the current audio buffer to another audio buffer. This is essentially crossfading, for which a visual example can be found [here](https://manual.audacityteam.org/man/fade_and_crossfade.html#dj)

While helping reduce audio artifacts (primarily by making them quieter and more gradual), they were still clearly audible. If the the crossfade is made at the exact halfway point of both clips, we might be able to avoid an abrupt jump between the samples between both clips, however audio artifacts can still occur as the clips may have drastically different sound content. Alas, the fading option doesn't address the underlying problem

##### Ensuring Completion

A working solution to this problem took a few weeks, tons of brain racking, and some major mental reframing of the problem to arrive at. One of the main functional drivers was enabling real-time user changes. I had mentally associated real-time user changes with changing what was in the audio buffer **immediately**, and while that assessment was semantically correct, one of the key details wasn't obvious:

> As soon as a clip has started playing, the remainder of the clip can finish playing back without impacting the correctness of the metronome's subsequent audio

This doesn't seem that revolutionary on the surface, however all of the previous solutions effectively changed any clips that were in progress of being played. Instead of cutting off a clip, a much cleaner approach would be to just let any clips that are currently being played back complete. And vice versa, if the user requested change would cause the playback head to be placed in the middle of a clip that was never started at it's first sample, it isn't played back. Another way to think about this is to consider that the first sample being played back correctly places the clip in time with respect to the metronome.

With the approach, all areas of potential audio artifacting are directly addressed. Any given audio sample will always be started from it's first sample and always be guaranteed playback it's last sample.

> [!IMPORTANT]
> the approach still allows multiple clips to overlap, something that doesn't inherently cause audio artifacts. This can occur in instances of higher tempos with busy subdivisions

### Metronome

#### System

One of the big functional challenges in metronomes is the support for time signatures and beat units, due to the need for the duration of a measure and location for all the notes within the measure to be calculated. Many metronome apps support a list of pre-canned time signatures (such as `4/4`, `3/4`, `6/8`, `5/4`, `12/8`, ...) and beat units (such as quarter notes, dotted quarter notes, eighth notes, ...) which can drastically simplify the necessary duration and location calculations

Given the limited flexibility most metronomes offer with predefined time signatures and beat units, the decision made for the app was to support any given time signature or beat unit. The latter is a combination of predefined dotted beat units, with the remaining beat units generated dynamically (see the [Features](#features) section for supported ranges). The following table shows an example of parameters set by the user and system, and how those evaluate to the measure length and locations of notes in terms of samples:

| Tempo (BPM) | Time Signature |   Beat Unit  | Sample Rate (Hz) | Measure Length (Samples) |    Quarter Note Locations (Samples)    |
| ----------- | -------------- | ------------ | ---------------- | ------------------------ | -------------------------------------- |
|    `120`    |      `4/4`     | Quarter Note |     `44,100`     |         `88,200`         | `22,050`, `44,100`, `66,150`, `88,200` |

For those interested in a more technical look at how all of the locations and measure length are calculated, please feel free to take a look at the implementation [here](https://github.com/LvnLx/Tempus/blob/main/ios/Runner/Metronome.swift#L207)

#### Integration

To integrate a dynamic timing system like this, the audio buffer interface would essentially act as a driver for the timing system. This is achieved by adding a timing buffer which is incremented through at the same time, and to be more precise, **by** the audio buffer. As you may be able to guess, the timing buffer is a sample accurate representation of a measure determined by the given metronome settings. This is what the outputs of the table in the [System](#system) section are used for. As the audio buffer interface iterates through the buffer it provides, it simultaneously iterates through the timing buffer, with the timing buffer wrapping back to the beginning once it reaches the end

> [!NOTE]  
> In most cases the timing buffer is much longer than the audio buffer, so the audio buffer will be iterated through multiple times before the timing buffer is restarted

With regards to actually writing data to the audio buffer, the following process is used:

1. Loop through all clips, and for any clip with a start sample that matches the current timing buffer sample and is `active`, mark it as `playing`
2. Loop through all `playing` clips, and copy their current sample value into the audio buffer, then increment the sample number it's on. If the sample number incremented to is outside of the valid sample range for the clip, mark it as no longer `playing`

the approach implements what was discussed in [Ensuring Completion](#ensuring-completion). In addition to what was just described, any wrapping around to the beginning of buffers is also handled, so that there is only ever one active timing buffer, and clips are reset to a state in which they are ready to be picked up again by the time the next measure is played

> [!IMPORTANT]  
> Whenever the audio buffer asks for data, it must be filled with data immediately while avoiding any costly operations, such as memory allocations, IO operations, or other blocking calls, to prevent buffer underruns (which may yield audio artifacts) sent to the audio hardware. This results in relatively primitive logic (like the one seen above) when writing to audio buffers

The detailed implementation of this cycle can be found [here](https://github.com/LvnLx/Tempus/blob/main/ios/Runner/Metronome.swift#L60)

#### Updates

To enable realtime changes to the metronome's settings while it's being played back a relatively simple pair of locking mechanism are used to ensure changes aren't made while writing data to the audio buffer, and to ensure clips finish playing once started (as discussed in [Ensuring Completion](#ensuring-completion))

To ensure the metronome data isn't changed while the audio buffer is being written to a [DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue) is used. It ensures that the function that writes to the audio buffer and the function that updates metronome settings can't run concurrently

To ensure clips finish playing, any clips currently marked as `playing` are left in the list of clips that is referenced when writing to the audio buffer, and marked as no longer being `active`. This ensures they will never be marked as `playing` again (as described in step 1 outlined in the [Integration](#integration) process). All the newly clips are then added to the leftover `playing` but not `active` clips to be used next time the audio buffer is written to

Any time a change is made to the metronome, such as a new time signature, beat unit, subdivision, or volume, the list of clips is updated while conforming to the above constraints. This ensures a real-time, artifact free experience.

#### Events

One of the difficulties with having a low-level audio engine like this is notifying any other parts of the application of changes or events in audio. To help alleviate this issue and enable some insight from the outside world, a simple tie in was made to the existing clips used in the timing buffers. The clips are already written as a `struct` in code, which allows them to also take a callback function as one of their fields. This callback can technically be repurposed to do anything, but since most of the functionality for the rest of the app lives within the [Flutter](https://flutter.dev/) layer of the application, the callback simply sends a method channel invocation with some data about what kind of clip made the call. Anytime a clip is newly marked as `playing` it's the callback is invoked

### Miscellaneous

#### Flutter Native Communication

The app takes advantage of Flutter's [method channels](https://docs.flutter.dev/platform-integration/platform-channels), which can essentially act as a bridge between the Flutter runtime and the native runtime. Any metronome updates (as well as the flashlight feature) are transmitted via method channel invocations, packaged with relatively simple values such as strings or integers

#### Timing Accuracy

The final sample level calculations for measure length or clip locations is deferred as long as possible within the app. The user is only presented with integers, however when combined with the sample rate of audio (`44100` for the app), many of the values used for timing could end up as floating point values at various points throughout the app due to division operations. To avoid any timing inaccuracies, all calculations are done as close to when they are actually needed as possible, and simply stored as fractions throughout the entirety of the app (both at the Dart and Swift layers) before then

> [!NOTE]  
> Time signatures are inherently fractions, and beat units are best represented that way as well. For example a quarter note is just `1/4` of a whole note

#### Setting Persistence

Most of the app's settings (including metronome state) are stored to the device in a key/value fashion. Since subdivisions and some metadata about the clip sounds available are more easily represented in a structured manner, rather than a custom string format, `JSON` encoders are used to transmit certain types of data between the Flutter and native layers

## Limitations

### Android

The necessary code to interact with [Oboe](https://github.com/google/oboe) (the Android equivalent for the audio buffer interface) already exists and is fully written for an earlier version of the app, however due to poor emulator performance, lack of access to a physical Android device, and overhead/data privacy concerns of publishing on the Google Play store, the decision was made to discontinue the Android version of the app. Importantly however, the UI is written using various platform agnostic widgets to ensure a coherent user experience if cross-platform development were to continue

### Multiple Measures

Support for multiple different measures after another and entire song structures was experimented with, however the interesting audio/metronome technical challenges are much smaller than the UI features needed to make such features worth investing time into, particularly for an app that isn't intended to be long-lived and generate substantial revenue

### Testing

Due to the overhead and relatively low value that tests would bring for a metronome app with the current feature set and one not intended to be a long-lived product and generate substantial revenue, the decision was made to not invest time into automated testing. The level of manual testing for the app was relatively low for the current feature set, however if more features such as full song structure support were added this decision would be reevaluated

### Continuous Integration and Deployment

CI/CD pipelines were omitted for similar reasons outlined in [Testing](#testing), however the addition of Android support would prompt reevaluation on pipelines for both automated testing and deployment
