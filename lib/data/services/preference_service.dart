import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/domain/extensions/subdivisions.dart';
import 'package:tempus/domain/models/sample_pair.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';

enum Preference {
  appVolume(1.0),
  bpm(120),
  beatVolume(1.0),
  downbeatVolume(1.0),
  isPremium(false),
  samplePair(SamplePair("sine", false)),
  subdivisions(<Key, SubdivisionData>{}),
  themeMode(ThemeMode.system);

  final dynamic defaultValue;
  const Preference(this.defaultValue);
}

class PreferenceService {
  final AssetService _assetService;

  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  PreferenceService(this._assetService);

  Future<double> getAppVolume() async {
    try {
      double? volume =
          await _sharedPreferencesAsync.getDouble(Preference.appVolume.name);
      return volume ?? Preference.appVolume.defaultValue;
    } catch (exception) {
      print("Exception while getting app volume: $exception");
      return Preference.appVolume.defaultValue;
    }
  }

  Future<int> getBpm() async {
    try {
      int? bpm = await _sharedPreferencesAsync.getInt(Preference.bpm.name);
      return bpm ?? Preference.bpm.defaultValue;
    } catch (exception) {
      print("Exception while getting BPM: $exception");
      await setBpm(Preference.bpm.defaultValue);
      return Preference.bpm.defaultValue;
    }
  }

  Future<double> getBeatVolume() async {
    try {
      double? volume =
          await _sharedPreferencesAsync.getDouble(Preference.beatVolume.name);
      return volume ?? Preference.beatVolume.defaultValue;
    } catch (exception) {
      print("Exception while getting beat volume: $exception");
      return Preference.beatVolume.defaultValue;
    }
  }

  Future<double> getDownbeatVolume() async {
    try {
      double? volume = await _sharedPreferencesAsync
          .getDouble(Preference.downbeatVolume.name);
      return volume ?? Preference.downbeatVolume.defaultValue;
    } catch (exception) {
      print("Exception while getting downbeat volume: $exception");
      return Preference.downbeatVolume.defaultValue;
    }
  }

  Future<bool> getIsPremium() async {
    try {
      bool? isPremium =
          await _sharedPreferencesAsync.getBool(Preference.isPremium.name);
      return isPremium ?? Preference.isPremium.defaultValue;
    } catch (exception) {
      print("Exception while getting premium status: $exception");
      await setIsPremium(Preference.isPremium.defaultValue);
      return Preference.isPremium.defaultValue;
    }
  }

  Future<SamplePair> getSamplePair() async {
    try {
      String? samplePairAsJsonString =
          await _sharedPreferencesAsync.getString(Preference.samplePair.name);

      if (samplePairAsJsonString != null) {
        return _assetService.samplePairs.firstWhere((samplePair) =>
            samplePair == SamplePair.fromJsonString(samplePairAsJsonString));
      } else {
        return Preference.samplePair.defaultValue;
      }
    } catch (exception) {
      print("Exception while getting sample pair: $exception");
      await setSamplePair(Preference.samplePair.defaultValue);
      return Preference.samplePair.defaultValue;
    }
  }

  Future<Map<Key, SubdivisionData>> getSubdivisions() async {
    try {
      String? subdivisionsAsJsonString =
          await _sharedPreferencesAsync.getString(Preference.subdivisions.name);

      if (subdivisionsAsJsonString != null) {
        Map<String, dynamic> subdivisionsAsJson =
            jsonDecode(subdivisionsAsJsonString);
        return subdivisionsAsJson.map((key, value) =>
            MapEntry(Key(key), SubdivisionData.fromJson(value)));
      } else {
        return Preference.subdivisions.defaultValue;
      }
    } catch (exception) {
      print("Exception while getting subdivisions: $exception");
      await setSubdivisions(Preference.subdivisions.defaultValue);
      return Preference.subdivisions.defaultValue;
    }
  }

  Future<ThemeMode> getThemeMode() async {
    try {
      String? themeModeAsString =
          await _sharedPreferencesAsync.getString(Preference.themeMode.name);

      if (themeModeAsString != null) {
        return ThemeMode.values
            .firstWhere((themeMode) => themeMode.name == themeModeAsString);
      } else {
        return Preference.themeMode.defaultValue;
      }
    } catch (exception) {
      print("Exception while getting theme mode: $exception");
      await setThemeMode(Preference.themeMode.defaultValue);
      return Preference.themeMode.defaultValue;
    }
  }

  Future<void> setAppVolume(double volume) async =>
      await _sharedPreferencesAsync.setDouble(
          Preference.appVolume.name, volume);

  Future<void> setBpm(int bpm) async =>
      await _sharedPreferencesAsync.setInt(Preference.bpm.name, bpm);

  Future<void> setBeatVolume(double volume) async =>
      await _sharedPreferencesAsync.setDouble(
          Preference.beatVolume.name, volume);

  Future<void> setDownbeatVolume(double volume) async =>
      await _sharedPreferencesAsync.setDouble(
          Preference.downbeatVolume.name, volume);

  Future<void> setIsPremium(bool value) async =>
      await _sharedPreferencesAsync.setBool(Preference.isPremium.name, value);

  Future<void> setSamplePair(SamplePair samplePair) async =>
      await _sharedPreferencesAsync.setString(
          Preference.samplePair.name, samplePair.toJsonString());

  Future<void> setSubdivisions(Map<Key, SubdivisionData> subdivisions) async =>
      await _sharedPreferencesAsync.setString(
          Preference.subdivisions.name, subdivisions.toJsonString());

  Future<void> setThemeMode(ThemeMode themeMode) async =>
      await _sharedPreferencesAsync.setString(
          Preference.themeMode.name, themeMode.name);
}
