import 'dart:io';

import 'package:flutter/foundation.dart';

/// 平台工具类，提供平台相关的工具方法
class PlatformUtils {
  /// 当前是否为移动平台（Android/iOS）
  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// 当前是否为桌面平台（Windows/macOS/Linux）
  static bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// 当前是否为网页平台
  static bool get isWeb => kIsWeb;

  /// 当前是否为Android平台
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// 当前是否为iOS平台
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// 当前是否为Windows平台
  static bool get isWindows {
    if (kIsWeb) return false;
    return Platform.isWindows;
  }

  /// 当前是否为macOS平台
  static bool get isMacOS {
    if (kIsWeb) return false;
    return Platform.isMacOS;
  }

  /// 当前是否为Linux平台
  static bool get isLinux {
    if (kIsWeb) return false;
    return Platform.isLinux;
  }

  /// 获取平台名称
  static String get platformName {
    if (kIsWeb) return 'Web';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  /// 获取操作系统版本
  static String get operatingSystemVersion {
    if (kIsWeb) return 'Web';
    return Platform.operatingSystemVersion;
  }

  /// 获取设备型号（简化版）
  static String get deviceModel {
    if (kIsWeb) return 'Web Browser';

    if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isWindows) {
      return 'Windows PC';
    } else if (Platform.isMacOS) {
      return 'Mac';
    } else if (Platform.isLinux) {
      return 'Linux Device';
    }

    return 'Unknown Device';
  }

  /// 检查当前平台是否支持某个功能
  static bool isFeatureSupported(PlatformFeature feature) {
    switch (feature) {
      case PlatformFeature.fileSystem:
        return !kIsWeb;
      case PlatformFeature.notifications:
        return !kIsWeb || kIsWeb; // Web也支持通知，但需要权限
      case PlatformFeature.sharing:
        return isMobile || isWeb;
      case PlatformFeature.backgroundExecution:
        return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
      case PlatformFeature.directoryPicker:
        return isDesktop;
      case PlatformFeature.multiWindow:
        return isDesktop;
    }
  }

  /// 获取合适的平台文本
  static String getPlatformSpecificText(
      String mobileText,
      String desktopText,
      String webText,
      ) {
    if (isWeb) return webText;
    if (isMobile) return mobileText;
    return desktopText;
  }
}

/// 平台支持的功能
enum PlatformFeature {
  /// 文件系统访问
  fileSystem,

  /// 系统通知
  notifications,

  /// 系统分享功能
  sharing,

  /// 后台执行
  backgroundExecution,

  /// 目录选择器
  directoryPicker,

  /// 多窗口支持
  multiWindow,
}