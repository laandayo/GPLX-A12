import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class WindowsUpdateInfo {
  final bool isUpdateAvailable;
  final String currentVersion;
  final String? latestVersion;
  final String? _downloadUrl;
  final String? message;

  const WindowsUpdateInfo({
    required this.isUpdateAvailable,
    required this.currentVersion,
    this.latestVersion,
    String? downloadUrl,
    this.message,
  }) : _downloadUrl = downloadUrl;
}

class WindowsUpdateService {
  static const _repository = String.fromEnvironment(
    'GPLX_UPDATE_REPOSITORY',
    defaultValue: 'laandayo/GPLX-A12',
  );
  static const _installerAssetName = 'GPLX-Windows-x64-Setup.exe';

  WindowsUpdateInfo? _availableUpdate;

  Future<WindowsUpdateInfo> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    if (kIsWeb || !Platform.isWindows) {
      return WindowsUpdateInfo(
        isUpdateAvailable: false,
        currentVersion: currentVersion,
        message: 'Tính năng này chỉ dành cho ứng dụng Windows.',
      );
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$_repository/releases/latest'),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'GPLX-Windows-Updater',
        },
      );
      if (response.statusCode == 404) {
        return WindowsUpdateInfo(
          isUpdateAvailable: false,
          currentVersion: currentVersion,
          message: 'Hiện tại không có cập nhật mới nào.',
        );
      }
      if (response.statusCode != 200) {
        return WindowsUpdateInfo(
          isUpdateAvailable: false,
          currentVersion: currentVersion,
          message: 'Không thể kiểm tra cập nhật (mã ${response.statusCode}).',
        );
      }

      final release = jsonDecode(response.body) as Map<String, dynamic>;
      final latestVersion = (release['tag_name'] as String? ?? '').replaceFirst(
        RegExp(r'^[vV]'),
        '',
      );
      final assets = release['assets'] as List<dynamic>? ?? const [];
      Map<String, dynamic>? asset;
      for (final candidate in assets) {
        if (candidate is Map<String, dynamic> &&
            candidate['name'] == _installerAssetName) {
          asset = candidate;
          break;
        }
      }
      final downloadUrl = asset?['browser_download_url'] as String?;
      if (downloadUrl == null || latestVersion.isEmpty) {
        return WindowsUpdateInfo(
          isUpdateAvailable: false,
          currentVersion: currentVersion,
          latestVersion: latestVersion.isEmpty ? null : latestVersion,
          message: 'Bản phát hành mới chưa có file cài đặt Windows.',
        );
      }

      final info = WindowsUpdateInfo(
        isUpdateAvailable: _isNewer(latestVersion, currentVersion),
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
      );
      _availableUpdate = info.isUpdateAvailable ? info : null;
      return info;
    } on SocketException {
      return WindowsUpdateInfo(
        isUpdateAvailable: false,
        currentVersion: currentVersion,
        message: 'Không có kết nối Internet để kiểm tra cập nhật.',
      );
    } catch (_) {
      return WindowsUpdateInfo(
        isUpdateAvailable: false,
        currentVersion: currentVersion,
        message: 'Không thể đọc thông tin cập nhật. Hãy thử lại sau.',
      );
    }
  }

  Future<void> downloadAndInstall() async {
    final update = _availableUpdate;
    final downloadUrl = update?._downloadUrl;
    if (downloadUrl == null) {
      throw StateError('No update is ready to install.');
    }

    final directory = await getTemporaryDirectory();
    final installer = File(
      '${directory.path}${Platform.pathSeparator}$_installerAssetName',
    );
    final request = http.Request('GET', Uri.parse(downloadUrl));
    request.headers['User-Agent'] = 'GPLX-Windows-Updater';
    final client = http.Client();
    try {
      final response = await client.send(request);
      if (response.statusCode != 200) {
        throw HttpException(
          'Download failed with status ${response.statusCode}.',
        );
      }
      await response.stream.pipe(installer.openWrite());
    } finally {
      client.close();
    }

    final script = File(
      '${directory.path}${Platform.pathSeparator}gplx-update.cmd',
    );
    await script.writeAsString('''@echo off
timeout /t 2 /nobreak > nul
start /wait "" "${installer.path}" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS
start "" "C:\\Program Files\\GPLX\\gplx_app.exe"
''');
    await Process.start('cmd.exe', [
      '/c',
      script.path,
    ], mode: ProcessStartMode.detached);
    exit(0);
  }

  bool _isNewer(String candidate, String current) {
    final candidateParts = _versionParts(candidate);
    final currentParts = _versionParts(current);
    for (var index = 0; index < 3; index++) {
      if (candidateParts[index] != currentParts[index]) {
        return candidateParts[index] > currentParts[index];
      }
    }
    return false;
  }

  List<int> _versionParts(String version) {
    final values = version
        .split('.')
        .map((value) => int.tryParse(value) ?? 0)
        .toList();
    return List<int>.generate(
      3,
      (index) => index < values.length ? values[index] : 0,
    );
  }
}
