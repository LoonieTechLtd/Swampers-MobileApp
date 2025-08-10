import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LightweightUpgrader {
  static const String _lastVersionCheckKey = 'last_version_check';
  static const String _ignoredVersionKey = 'ignored_version';

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final prefs = await SharedPreferences.getInstance();

      // Check if we should skip this version
      final ignoredVersion = prefs.getString(_ignoredVersionKey);
      final currentVersion = packageInfo.version;

      // Only check once per day
      final lastCheck = prefs.getInt(_lastVersionCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheck < 86400000) return; // 24 hours

      // Check app store for updates (simplified)
      final latestVersion = await _getLatestVersion(packageInfo.packageName);

      if (latestVersion != null &&
          latestVersion != currentVersion &&
          latestVersion != ignoredVersion) {
        await prefs.setInt(_lastVersionCheckKey, now);
        _showUpdateDialog(context, latestVersion, packageInfo.packageName);
      }
    } catch (e) {
      // Silently fail - don't annoy users with errors
      debugPrint('Update check failed: $e');
    }
  }

  static Future<String?> _getLatestVersion(String packageName) async {
    try {
      // For Android - Google Play Store API
      final response = await http.get(
        Uri.parse('https://play.google.com/store/apps/details?id=$packageName'),
        headers: {'User-Agent': 'Mozilla/5.0'},
      );

      if (response.statusCode == 200) {
        // Simple regex to extract version from Play Store page
        final regex = RegExp(r'Current Version.*?>(.*?)<');
        final match = regex.firstMatch(response.body);
        return match?.group(1)?.trim();
      }
    } catch (e) {
      debugPrint('Failed to get latest version: $e');
    }
    return null;
  }

  static void _showUpdateDialog(
    BuildContext context,
    String latestVersion,
    String packageName,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Text(
              'A new version ($latestVersion) is available. Would you like to update?',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(_ignoredVersionKey, latestVersion);
                  Navigator.pop(context);
                },
                child: const Text('Ignore'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final url =
                      'https://play.google.com/store/apps/details?id=$packageName';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }
}
