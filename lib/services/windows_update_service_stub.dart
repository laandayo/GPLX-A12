class WindowsUpdateInfo {
  final bool isUpdateAvailable;
  final String currentVersion;
  final String? latestVersion;
  final String? message;

  const WindowsUpdateInfo({
    required this.isUpdateAvailable,
    required this.currentVersion,
    this.latestVersion,
    this.message,
  });
}

class WindowsUpdateService {
  Future<WindowsUpdateInfo> checkForUpdate() async => const WindowsUpdateInfo(
    isUpdateAvailable: false,
    currentVersion: '',
    message: 'Tính năng này chỉ dành cho ứng dụng Windows.',
  );

  Future<void> downloadAndInstall() {
    throw UnsupportedError('Windows updates are only available on Windows.');
  }
}
