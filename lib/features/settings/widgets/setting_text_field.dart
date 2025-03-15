import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kikilt/constants/colors.dart';

/// 文本输入框设置项
class SettingTextField extends StatelessWidget {
  /// 标题
  final String title;

  /// 副标题
  final String? subtitle;

  /// 图标
  final IconData? icon;

  /// 文本控制器
  final TextEditingController controller;

  /// 提示文本
  final String? hintText;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 输入格式化
  final List<TextInputFormatter>? inputFormatters;

  /// 文本提交回调
  final ValueChanged<String>? onSubmitted;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 是否禁用
  final bool isDisabled;

  /// 最大输入长度
  final int? maxLength;

  /// 尾部组件
  final Widget? suffix;

  /// 边框样式
  final InputBorder? border;

  /// 内边距
  final EdgeInsetsGeometry? contentPadding;

  /// 是否显示计数器
  final bool showCounter;

  /// 是否展开（默认为紧凑型）
  final bool isExpanded;

  const SettingTextField({
    Key? key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
    this.onChanged,
    this.isDisabled = false,
    this.maxLength,
    this.suffix,
    this.border,
    this.contentPadding,
    this.showCounter = false,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和副标题
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 图标
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 18,
                        color: isDisabled
                            ? Colors.grey
                            : isDarkMode
                            ? AppColors.iconDark
                            : AppColors.iconLight,
                      ),
                      const SizedBox(width: 8),
                    ],

                    // 标题
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDisabled
                            ? Colors.grey
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                  ],
                ),

                // 副标题
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.only(left: icon != null ? 26 : 0),
                    child: Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDisabled
                            ? Colors.grey.withOpacity(0.7)
                            : theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 输入框
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                suffixIcon: suffix,
                border: border,
                contentPadding: contentPadding,
                counterText: showCounter ? null : '',
                filled: true,
                fillColor: isDisabled
                    ? (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100)
                    : null,
                enabled: !isDisabled,
              ),
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              maxLength: maxLength,
              textInputAction: TextInputAction.done,
              style: TextStyle(
                color: isDisabled
                    ? Colors.grey
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}