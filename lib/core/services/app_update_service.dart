import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_update_info.dart';

class AppUpdateService {
  final SupabaseClient _supabase;

  AppUpdateService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ============================================================
  // CHECK FOR UPDATE
  // ============================================================

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      if (kIsWeb) {
        return null;
      }

      // ========================================================
      // PLATFORM
      // ========================================================

      String platform;

      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      } else {
        return null;
      }

      // ========================================================
      // INSTALLED APP VERSION
      // ========================================================

      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String currentVersion = packageInfo.version.trim();

      final int rawBuildNumber =
          int.tryParse(packageInfo.buildNumber.trim()) ?? 0;

      // ========================================================
      // DETECT DEVICE ABI
      // ========================================================

      String? deviceAbi;

      if (Platform.isAndroid) {
        deviceAbi = await OtaUpdate().getAbi();
        deviceAbi = deviceAbi?.trim();

      }

      // ========================================================
      // NORMALIZE BUILD NUMBER
      // ========================================================

      final int currentBuildNumber = Platform.isAndroid
          ? _normalizeAndroidBuildNumber(
              rawBuildNumber: rawBuildNumber,
              deviceAbi: deviceAbi,
            )
          : rawBuildNumber;

      // ========================================================
      // GET SERVER CONFIGURATION
      // ========================================================

      final Map<String, dynamic>? data = await _supabase
          .from('app_versions')
          .select(
            'platform, '
            'latest_version, '
            'latest_build_number, '
            'minimum_version, '
            'minimum_build_number, '
            'update_title, '
            'update_message, '
            'is_update_enabled, '
            'arm64_url, '
            'armeabi_v7a_url, '
            'x86_64_url',
          )
          .eq('platform', platform)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      // ========================================================
      // SERVER VERSION VALUES
      // ========================================================

      final String latestVersion =
          (data['latest_version'] ?? '').toString().trim();

      final int latestBuildNumber =
          _toInt(data['latest_build_number']);

      final String minimumVersion =
          (data['minimum_version'] ?? '').toString().trim();

      final int minimumBuildNumber =
          _toInt(data['minimum_build_number']);

      final String updateTitle =
          (data['update_title'] ?? 'Update available')
              .toString()
              .trim();

      final String updateMessage =
          (data['update_message'] ?? 'A new version is available.')
              .toString()
              .trim();

      final bool updateEnabled =
          data['is_update_enabled'] == true;

      // ========================================================
      // SELECT CORRECT APK FOR DEVICE ABI
      // ========================================================

      String? selectedUpdateUrl;

      if (Platform.isAndroid) {
        switch (deviceAbi) {
          case 'arm64-v8a':
            selectedUpdateUrl =
                _nullableString(data['arm64_url']);
            break;

          case 'armeabi-v7a':
            selectedUpdateUrl =
                _nullableString(data['armeabi_v7a_url']);
            break;

          case 'x86_64':
            selectedUpdateUrl =
                _nullableString(data['x86_64_url']);
            break;

          default:
        }
      }

      // ========================================================
      // VALIDATE SERVER CONFIGURATION
      // ========================================================

      if (latestBuildNumber <= 0 ||
          minimumBuildNumber <= 0) {

        return null;
      }

      // ========================================================
      // RESULT
      // ========================================================

      final AppUpdateInfo result = AppUpdateInfo(
        platform: platform,
        currentVersion: currentVersion,
        currentBuildNumber: currentBuildNumber,
        latestVersion: latestVersion,
        latestBuildNumber: latestBuildNumber,
        minimumVersion: minimumVersion,
        minimumBuildNumber: minimumBuildNumber,
        updateTitle: updateTitle,
        updateMessage: updateMessage,
        updateUrl: selectedUpdateUrl,
        deviceAbi: deviceAbi,
        updateEnabled: updateEnabled,
      );

      if (result.hasUpdate &&
          !result.hasUpdateUrl) {
      }

      return result;
    } on PostgrestException {

      return null;
    } catch (error) {
      debugPrint(
        'App update check failed: $error',
      );

      return null;
    }
  }

  // ============================================================
  // DOWNLOAD AND INSTALL UPDATE
  // ============================================================

  Stream<OtaEvent> installUpdate(
    AppUpdateInfo updateInfo,
  ) {
    final String? url = updateInfo.updateUrl;

    if (url == null || url.trim().isEmpty) {
      throw StateError(
        'No compatible APK URL is available '
        'for ${updateInfo.deviceAbi}.',
      );
    }

    return OtaUpdate().execute(
      url.trim(),
      destinationFilename:
          'the-legit-smoothie-update.apk',
    );
  }

  // ============================================================
  // NORMALIZE ANDROID SPLIT APK BUILD NUMBER
  // ============================================================

  int _normalizeAndroidBuildNumber({
    required int rawBuildNumber,
    required String? deviceAbi,
  }) {
    if (rawBuildNumber <= 0) {
      return rawBuildNumber;
    }

    // When running normally with `flutter run`,
    // PackageInfo may already return the original Flutter
    // build number, for example:
    //
    //   2
    //
    // In that case there is nothing to normalize.
    if (rawBuildNumber < 1000) {
      return rawBuildNumber;
    }

    // Flutter --split-per-abi produced the following
    // versionCode prefixes in this project:
    //
    // armeabi-v7a:
    //   build 2 -> 1002
    //
    // arm64-v8a:
    //   build 2 -> 2002
    //
    // x86_64:
    //   build 2 -> 4002
    //
    // Remove the ABI prefix so Supabase only needs
    // to store the normal Flutter build number.

    switch (deviceAbi) {
      case 'armeabi-v7a':
        if (rawBuildNumber >= 1000) {
          return rawBuildNumber - 1000;
        }
        break;

      case 'arm64-v8a':
        if (rawBuildNumber >= 2000) {
          return rawBuildNumber - 2000;
        }
        break;

      case 'x86_64':
        if (rawBuildNumber >= 4000) {
          return rawBuildNumber - 4000;
        }
        break;
    }

    // If the ABI is unknown, do not guess.
    return rawBuildNumber;
  }

  // ============================================================
  // INT
  // ============================================================

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value.toString(),
        ) ??
        0;
  }

  // ============================================================
  // NULLABLE STRING
  // ============================================================

  String? _nullableString(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final String text =
        value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }
}