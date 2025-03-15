import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/widgets/gradient_container.dart';

/// 动画按钮组件
class AnimatedButton extends StatefulWidget {
  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 图标
  final IconData? icon;

  /// 按钮类型
  final ButtonType type;

  /// 自定义颜色
  final List<Color>? colors;

  /// 自定义文本样式
  final TextStyle? textStyle;

  /// 图标颜色
  final Color? iconColor;

  /// 按钮宽度
  final double? width;

  /// 按钮高度
  final double? height;

  /// 按钮圆角
  final double borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 是否禁用
  final bool isDisabled;

  /// 是否加载中
  final bool isLoading;

  /// 加载中文本
  final String? loadingText;

  /// 是否使用渐变
  final bool useGradient;

  /// 子组件（覆盖内置的文本和图标）
  final Widget? child;

  /// 边框样式
  final Border? border;

  const AnimatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.type = ButtonType.primary,
    this.colors,
    this.textStyle,
    this.iconColor,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.padding,
    this.isDisabled = false,
    this.isLoading = false,
    this.loadingText,
    this.useGradient = true,
    this.child,
    this.border,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 获取按钮颜色
    List<Color> buttonColors = widget.colors ?? _getButtonColors();
    if (widget.isDisabled) {
      buttonColors = [Colors.grey.shade300, Colors.grey.shade300];
    }

    // 获取文本样式
    final TextStyle textStyle = widget.textStyle ?? theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: _getTextColor(),
    ) ?? const TextStyle();

    // 构建按钮内容
    Widget buttonContent = widget.child ?? Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textStyle.color!),
            ),
          ),
          const SizedBox(width: 8),
          Text(widget.loadingText ?? '加载中...', style: textStyle),
        ] else ...[
          if (widget.icon != null) ...[
            Icon(
              widget.icon,
              color: widget.iconColor ?? textStyle.color,
              size: 20,
            ),
            const SizedBox(width: 8),
          ],
          Text(widget.text, style: textStyle),
        ],
      ],
    );

    // 构建按钮
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: (widget.isDisabled || widget.isLoading) ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.useGradient && widget.type != ButtonType.outlined
            ? GradientContainer(
          width: widget.width,
          height: widget.height ?? 50,
          colors: buttonColors,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          boxShadow: widget.isDisabled || widget.isLoading ? null : [
            BoxShadow(
              color: buttonColors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: widget.border,
          child: buttonContent,
        )
            : Container(
          width: widget.width,
          height: widget.height ?? 50,
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: widget.type == ButtonType.outlined ? Colors.transparent : buttonColors.first,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: widget.border ?? (widget.type == ButtonType.outlined
                ? Border.all(color: widget.isDisabled ? Colors.grey.shade300 : buttonColors.first, width: 2)
                : null),
            boxShadow: widget.isDisabled || widget.isLoading || widget.type == ButtonType.outlined ? null : [
              BoxShadow(
                color: buttonColors.first.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: buttonContent,
        ),
      ),
    );
  }

  List<Color> _getButtonColors() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.gradientPink;
      case ButtonType.secondary:
        return AppColors.gradientPurple;
      case ButtonType.outlined:
        return [AppColors.primaryPink, AppColors.primaryPink];
      case ButtonType.danger:
        return [AppColors.error, AppColors.error.withRed(220)];
      case ButtonType.success:
        return [AppColors.success, AppColors.success.withGreen(220)];
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        return Colors.white;
      case ButtonType.outlined:
        return widget.isDisabled
            ? Colors.grey.shade400
            : AppColors.primaryPink;
    }
  }
}

/// 按钮类型
enum ButtonType {
  /// 主要按钮
  primary,

  /// 次要按钮
  secondary,

  /// 边框按钮
  outlined,

  /// 危险按钮
  danger,

  /// 成功按钮
  success,
}