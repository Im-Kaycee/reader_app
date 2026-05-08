import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../core/constants/app_version.dart';

class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool hasUpdate;

  const UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.hasUpdate,
  });
}

class UpdateService {
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(kVersionCheckUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final latest = data['version'] as String;
      final downloadUrl = data['download_url'] as String;
      final notes = data['release_notes'] as String? ?? '';

      final hasUpdate = _isNewer(latest, kAppVersion);

      debugPrint('Current: $kAppVersion | Latest: $latest | Update: $hasUpdate');

      return UpdateInfo(
        latestVersion: latest,
        downloadUrl: downloadUrl,
        releaseNotes: notes,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  bool _isNewer(String latest, String current) {
    final l = latest.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (int i = 0; i < 3; i++) {
      if (l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }
}