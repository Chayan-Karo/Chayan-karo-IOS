import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateService {
  /// 🔥 Enable this for local testing (NO Play upload needed)
  static bool debugForceUpdate = false;

  static bool _isShowing = false; // prevent duplicate dialogs

  static Future<void> checkForUpdate(BuildContext context) async {
  if (_isShowing) return;

  try {
    if (Platform.isAndroid) {
      await _handleAndroidUpdate(context); // 👈 SAME LOGIC
    } else if (Platform.isIOS) {
      await _handleIosUpdate(context); // 👈 NEW
    }
  } catch (e) {
    debugPrint("Update error: $e");
  }
}
static Future<void> _handleAndroidUpdate(BuildContext context) async {
  AppUpdateInfo? updateInfo;

  if (!debugForceUpdate) {
    updateInfo = await InAppUpdate.checkForUpdate();

    if (updateInfo.updateAvailability !=
        UpdateAvailability.updateAvailable) {
      return;
    }
  }

  _isShowing = true;
  await _forceUpdateLoop(context, updateInfo);
  _isShowing = false;
}
static Future<void> _handleIosUpdate(BuildContext context) async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final response = await http.get(
      Uri.parse(
        "https://itunes.apple.com/lookup?id=6761263096&country=IN",
      ),
    );

    if (response.statusCode != 200) return;

    final data = json.decode(response.body);

    if (data['resultCount'] == 0) return;

    final result = data['results'][0];

    final storeVersion = result['version'];
    final storeUrl = result['trackViewUrl'];

    debugPrint("📱 iOS Current: $currentVersion");
    debugPrint("🏪 iOS Store: $storeVersion");

    if (_isNewerVersion(storeVersion, currentVersion)) {
      _isShowing = true;
await _forceUpdateLoop(
  context,
  null,
  storeUrl: storeUrl,
);      _isShowing = false;
    }
  } catch (e) {
    debugPrint("iOS update error: $e");
  }
}

static Future<void> _forceUpdateLoop(
  BuildContext context,
  AppUpdateInfo? updateInfo, {
  String? storeUrl,
}) async {
  AppUpdateInfo? currentInfo = updateInfo;

  while (true) {
 await _showForceDialog(
      context,
      currentInfo,
      storeUrl: storeUrl, // ✅ FIXED
    );
    try {
      if (!debugForceUpdate && Platform.isAndroid) {
        currentInfo = await InAppUpdate.checkForUpdate();
      }
    } catch (e) {
      debugPrint("Loop refresh error: $e");
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }
}
  /// 🔴 COMPACT FORCE UI
static Future<void> _showForceDialog(
  BuildContext context,
  AppUpdateInfo? updateInfo, {
  String? storeUrl, // ✅ FIXED (was [])
}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔴 Smaller Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_rounded,
                      size: 38, // Reduced from 48
                      color: Color(0xFFE47830),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Update Required',
                    style: TextStyle(
                      fontSize: 18, // Reduced from 22
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Please update the app to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14, // Reduced from 15
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔴 COMPACT UPDATE BUTTON
                  GestureDetector(
                   onTap: () async {
  try {
    if (Platform.isAndroid && !debugForceUpdate && updateInfo != null) {
      if (updateInfo.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      } else if (updateInfo.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      } else {
        await _openPlayStore();
      }
    } else {
      // 🍏 iOS OR fallback
      if (storeUrl != null) {
        await launchUrl(
          Uri.parse(storeUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await _openPlayStore();
      }
    }
  } catch (e) {
    debugPrint("Update failed: $e");
  }

  if (context.mounted) Navigator.pop(context);
},
                      
                    
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12), // Slimmer
                      decoration: BoxDecoration(
                        color: const Color(0xFFE47830),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Update Now',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ❌ COMPACT EXIT BUTTON
                  GestureDetector(
                    onTap: () => exit(0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Exit App',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  static bool _isNewerVersion(String store, String current) {
  List<int> s = store.split('.').map(int.parse).toList();
  List<int> c = current.split('.').map(int.parse).toList();

  for (int i = 0; i < s.length; i++) {
    if (s[i] > c[i]) return true;
    if (s[i] < c[i]) return false;
  }
  return false;
}

  /// 🔥 Play Store fallback
  static Future<void> _openPlayStore() async {
    final url = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.chayankaroindia.app",
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}