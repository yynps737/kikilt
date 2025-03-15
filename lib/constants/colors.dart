import 'package:flutter/material.dart';

/// 应用颜色定义
class AppColors {
  // 品牌颜色
  static final primaryPink = Color(0xFFFF6B9D);
  static final primaryPinkDark = Color(0xFFFF4D89);
  static final secondaryPurple = Color(0xFF9C64FF);
  static final secondaryPurpleDark = Color(0xFF8345FF);
  static final accentYellow = Color(0xFFFFCF4D);
  static final accentYellowDark = Color(0xFFFFBB10);

  // 背景颜色
  static final backgroundLight = Color(0xFFF9F3F8);
  static final backgroundDark = Color(0xFF1E1A2F);

  // 文字颜色
  static final textDark = Color(0xFF2D2A35);
  static final textLight = Color(0xFFF9F9F9);

  // 卡片颜色
  static final cardDark = Color(0xFF2D2740);

  // 边框颜色
  static final borderLight = Color(0xFFE0D7E8);
  static final borderDark = Color(0xFF3A3451);

  // 阴影颜色
  static final shadowLight = Color(0x29C58BDB);
  static final shadowDark = Color(0x40000000);

  // 状态颜色
  static final success = Color(0xFF5CDA8F);
  static final warning = Color(0xFFFFB643);
  static final error = Color(0xFFFA5E5E);
  static final info = Color(0xFF64B5FF);

  // 图标颜色
  static final iconLight = Color(0xFFC7BEDC);
  static final iconDark = Color(0xFF9383B7);

  // 渐变色
  static final gradientPink = [
    Color(0xFFFF6B9D),
    Color(0xFFFF8DC4),
  ];

  static final gradientPurple = [
    Color(0xFF9C64FF),
    Color(0xFFBC9EFF),
  ];

  static final gradientMixed = [
    Color(0xFFFF6B9D),
    Color(0xFF9C64FF),
  ];

  // 透明度颜色
  static Color withAlpha(Color color, int alpha) {
    return color.withAlpha(alpha);
  }
}