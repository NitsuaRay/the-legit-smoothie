import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_update_info.dart';

class AppUpdateService {
  final SupabaseClient _supabase;

  AppUpdateService({
    SupabaseClient? supabase,
  }) : _supabase =
            supabase ?? Supabase.instance.client;

  // ============================================================
  // CHECK FOR UPDATE
  // ============================================================

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      // ----------------------------------------------------------
      // PLATFORM
      // ----------------------------------------------------------

      if (kIsWeb) {
        return null;
      }

      String platform;

      if (Platform.isAndroid) {
        platform = 'android';
      } else if (Platform.isIOS) {
        platform = 'ios';
      } else {
        return null;
      }

      // ----------------------------------------------------------
      // CURRENT INSTALLED APP
      // ----------------------------------------------------------

      final PackageInfo packageInfo =
          await PackageInfo.fromPlatform();

      final String currentVersion =
          packageInfo.version.trim();

      final int currentBuildNumber =
          int.tryParse(
                packageInfo.buildNumber.trim(),
              ) ??
              0;

      // ----------------------------------------------------------
      // SERVER VERSION
      // ----------------------------------------------------------

      final Map<String, dynamic>? data =
          await _supabase
              .from('app_versions')
              .select(
                'platform, '
                'latest_version, '
                'latest_build_number, '
                'minimum_version, '
                'minimum_build_number, '
                'update_title, '
                'update_message, '
                'update_url, '
                'is_update_enabled',
              )
              .eq('platform', platform)
              .maybeSingle();

      if (data == null) {
        debugPrint(
          'App update: no version configuration '
          'found for $platform.',
        );

        return null;
      }

      // ----------------------------------------------------------
      // SERVER VALUES
      // ----------------------------------------------------------

      final String latestVersion =
          (data['latest_version'] ?? '')
              .toString()
              .trim();

      final int latestBuildNumber =
          _toInt(
        data['latest_build_number'],
      );

      final String minimumVersion =
          (data['minimum_version'] ?? '')
              .toString()
              .trim();

      final int minimumBuildNumber =
          _toInt(
        data['minimum_build_number'],
      );

      final String updateTitle =
          (data['update_title'] ??
                  'Update available')
              .toString()
              .trim();

      final String updateMessage =
          (data['update_message'] ??
                  'A new version is available.')
              .toString()
              .trim();

      final String? updateUrl =
          _nullableString(
        data['update_url'],
      );

      final bool updateEnabled =
          data['is_update_enabled'] == true;

      // ----------------------------------------------------------
      // VALIDATE CONFIGURATION
      // ----------------------------------------------------------

      if (latestBuildNumber <= 0 ||
          minimumBuildNumber <= 0) {
        debugPrint(
          'App update: invalid build numbers '
          'received from Supabase.',
        );

        return null;
      }

      // ----------------------------------------------------------
      // RESULT
      // ----------------------------------------------------------

      final AppUpdateInfo result =
          AppUpdateInfo(
        platform: platform,

        currentVersion: currentVersion,
        currentBuildNumber:
            currentBuildNumber,

        latestVersion: latestVersion,
        latestBuildNumber:
            latestBuildNumber,

        minimumVersion: minimumVersion,
        minimumBuildNumber:
            minimumBuildNumber,

        updateTitle: updateTitle,
        updateMessage: updateMessage,
        updateUrl: updateUrl,

        updateEnabled: updateEnabled,
      );

      debugPrint(
        'App update check: $result',
      );

      return result;
    } on PostgrestException catch (error) {
      debugPrint(
        'App update Supabase error: '
        '${error.message}',
      );

      return null;
    } catch (error) {
      debugPrint(
        'App update check failed: $error',
      );

      return null;
    }
  }

  // ============================================================
  // INT
  // ============================================================

  int _toInt(
    dynamic value,
  ) {
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