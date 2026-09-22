class AppUpdateInfo {
  final String platform;

  final String currentVersion;
  final int currentBuildNumber;

  final String latestVersion;
  final int latestBuildNumber;

  final String minimumVersion;
  final int minimumBuildNumber;

  final String updateTitle;
  final String updateMessage;

  /// APK URL selected for this specific device architecture.
  final String? updateUrl;

  /// Android ABI detected on this device.
  ///
  /// Examples:
  /// arm64-v8a
  /// armeabi-v7a
  /// x86_64
  final String? deviceAbi;

  final bool updateEnabled;

  const AppUpdateInfo({
    required this.platform,
    required this.currentVersion,
    required this.currentBuildNumber,
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minimumVersion,
    required this.minimumBuildNumber,
    required this.updateTitle,
    required this.updateMessage,
    required this.updateUrl,
    required this.deviceAbi,
    required this.updateEnabled,
  });

  // ============================================================
  // UPDATE STATE
  // ============================================================

  bool get hasUpdate {
    if (!updateEnabled) {
      return false;
    }

    return currentBuildNumber < latestBuildNumber;
  }

  bool get isRequired {
    if (!updateEnabled) {
      return false;
    }

    return currentBuildNumber < minimumBuildNumber;
  }

  bool get isOptional {
    return hasUpdate && !isRequired;
  }

  bool get isLatest {
    return !hasUpdate;
  }

  bool get hasUpdateUrl {
    return updateUrl != null &&
        updateUrl!.trim().isNotEmpty;
  }

  // ============================================================
  // DEBUG
  // ============================================================

  @override
  String toString() {
    return 'AppUpdateInfo('
        'currentVersion: $currentVersion, '
        'currentBuildNumber: $currentBuildNumber, '
        'latestVersion: $latestVersion, '
        'latestBuildNumber: $latestBuildNumber, '
        'minimumVersion: $minimumVersion, '
        'minimumBuildNumber: $minimumBuildNumber, '
        'deviceAbi: $deviceAbi, '
        'hasUpdate: $hasUpdate, '
        'isRequired: $isRequired, '
        'hasUpdateUrl: $hasUpdateUrl'
        ')';
  }
}