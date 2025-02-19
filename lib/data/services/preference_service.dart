import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/domain/models/sample_pair.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';
import 'package:tempus/util.dart';

enum Preference {
  bpm(120),
  isPremium(false),
  samplePair(SamplePair("sine", false)),
  subdivisions({}),
  themeMode(ThemeMode.system),
  volume(1.0);

  final dynamic defaultValue;
  const Preference(this.defaultValue);
}

class PreferenceService {
  final AssetService _assetService;

  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  PreferenceService(this._assetService);

  Future<int> getBpm() async =>
      await _sharedPreferencesAsync.getInt(Preference.bpm.name) ??
      Preference.bpm.defaultValue;

  Future<bool> getIsPremium() async =>
      await _sharedPreferencesAsync.getBool(Preference.isPremium.name) ??
      Preference.isPremium.defaultValue;

  Future<SamplePair> getSamplePair() async => await _getOrElse<SamplePair>(
      Preference.samplePair.name,
      _assetService.samplePairs,
      Preference.samplePair.defaultValue.name,
      (samplePair) => samplePair.name);

  Future<Map<Key, SubdivisionData>> getSubdivisions() async =>
      await _getSubdivisions() ?? {};

  Future<ThemeMode> getThemeMode() async => await _getOrElse<ThemeMode>(
      Preference.themeMode.name,
      ThemeMode.values,
      Preference.themeMode.defaultValue.toString(),
      (themeMode) => themeMode.toString());

  Future<double> getVolume() async =>
      await _sharedPreferencesAsync.getDouble(Preference.volume.name) ??
      Preference.volume.defaultValue;

  Future<void> setBpm(int bpm) async =>
      await _sharedPreferencesAsync.setInt(Preference.bpm.name, bpm);

  Future<void> setIsPremium(bool value) async =>
      await _sharedPreferencesAsync.setBool(Preference.isPremium.name, value);

  Future<void> setSamplePair(SamplePair samplePair) async =>
      await _sharedPreferencesAsync.setString(
          Preference.samplePair.name, samplePair.name);

  Future<void> setSubdivisions(Map<Key, SubdivisionData> subdivisions) async =>
      await _sharedPreferencesAsync.setString(
          Preference.subdivisions.name, jsonEncodeSubdivisions(subdivisions));

  Future<void> setThemeMode(ThemeMode themeMode) async =>
      await _sharedPreferencesAsync.setString(
          Preference.themeMode.name, themeMode.toString());

  Future<void> setVolume(double volume) async =>
      await _sharedPreferencesAsync.setDouble(Preference.volume.name, volume);

  Future<T> _getOrElse<T>(
    String key,
    Iterable<T> possibleValues,
    String defaultValue,
    String Function(T) comparator,
  ) async {
    String value = await _sharedPreferencesAsync.getString(key) ?? defaultValue;
    return possibleValues.firstWhere((element) => comparator(element) == value);
  }

  Future<Map<Key, SubdivisionData>?> _getSubdivisions() async {
    String? subdivisionsAsJsonString =
        await _sharedPreferencesAsync.getString(Preference.subdivisions.name);

    if (subdivisionsAsJsonString == null) return null;

    Map<String, dynamic> subdivisionsAsJson =
        jsonDecode(subdivisionsAsJsonString);
    return subdivisionsAsJson.map(
        (key, value) => MapEntry(Key(key), SubdivisionData.fromJson(value)));
  }
}
