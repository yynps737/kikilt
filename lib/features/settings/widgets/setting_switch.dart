import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/features/settings/widgets/setting_item.dart';

/// 开关设置项
class SettingSwitch extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 图标
  final IconData? icon;

  /// 当前值
  final bool value;

  /// 值变化回调
  final ValueChanged<bool>? onChanged;

  /// 点击回调（可以不使用开关回调）
  final VoidCallback? onTap;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否禁用
  final bool isDisabled;

  /// 图标颜色
  final Color? iconColor;

  /// 开关激活颜色
  final Color? activeColor;

  /// 开关激活轨道颜色
  final Color? activeTrackColor;

  /// 是否显示分割线
  final bool showDivider;

  const SettingSwitch({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    this.onChanged,
    this.onTap,
    this.padding,
    this.isDisabled = false,
    this.iconColor,
    this.activeColor,
    this.activeTrackColor,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 构建设置项
    return SettingItem(
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: Switch(
        value: value,
        onChanged: isDisabled ? null : onChanged,
        activeColor: activeColor ?? AppColors.primaryPink,
        activeTrackColor: activeTrackColor ?? AppColors.primaryPink.withOpacity(0.3),
      ),
      onTap: isDisabled
          ? null
          : (onTap ?? (onChanged != null ? () => onChanged!(!value) : null)),
      padding: padding,
      isDisabled: isDisabled,
      iconColor: iconColor,
      showDivider: showDivider,
    );
  }
}