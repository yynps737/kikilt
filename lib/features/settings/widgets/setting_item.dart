import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';

/// 设置项组件
class SettingItem extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 图标
  final IconData? icon;

  /// 尾部组件
  final Widget? trailing;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否禁用
  final bool isDisabled;

  /// 自定义标题样式
  final TextStyle? titleStyle;

  /// 自定义副标题样式
  final TextStyle? subtitleStyle;

  /// 图标颜色
  final Color? iconColor;

  /// 是否显示分割线
  final bool showDivider;

  /// 是否使用墨水效果
  final bool useInkEffect;

  /// 自定义组件（覆盖默认布局）
  final Widget? customWidget;

  const SettingItem({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.isDisabled = false,
    this.titleStyle,
    this.subtitleStyle,
    this.iconColor,
    this.showDivider = false,
    this.useInkEffect = true,
    this.customWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultIconColor = theme.brightness == Brightness.dark
        ? AppColors.iconDark
        : AppColors.iconLight;

    // 自定义组件优先
    if (customWidget != null) {
      return customWidget!;
    }

    // 构建设置项
    Widget content = Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // 图标
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.withOpacity(0.1)
                    : (iconColor ?? defaultIconColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isDisabled
                    ? Colors.grey
                    : iconColor ?? defaultIconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
          ],

          // 标题和副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ?? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDisabled
                        ? Colors.grey
                        : theme.textTheme.titleMedium?.color,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: subtitleStyle ?? theme.textTheme.bodySmall?.copyWith(
                      color: isDisabled
                          ? Colors.grey.withOpacity(0.7)
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 尾部组件
          if (trailing != null)
            trailing!,
        ],
      ),
    );

    // 包装点击效果
    if (onTap != null && !isDisabled && useInkEffect) {
      content = InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    } else if (onTap != null && !isDisabled) {
      content = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: content,
      );
    }

    // 包装分割线
    if (showDivider) {
      content = Column(
        children: [
          content,
          Divider(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1,
            indent: icon != null ? 56 : 16,
            endIndent: 16,
          ),
        ],
      );
    }

    return content;
  }
}