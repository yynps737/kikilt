import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';

/// 渐变背景容器组件
class GradientContainer extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 渐变颜色
  final List<Color>? colors;

  /// 渐变开始位置
  final AlignmentGeometry? begin;

  /// 渐变结束位置
  final AlignmentGeometry? end;

  /// 边框圆角
  final BorderRadius? borderRadius;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 阴影
  final List<BoxShadow>? boxShadow;

  /// 边框
  final Border? border;

  /// 子组件对齐方式
  final AlignmentGeometry? alignment;

  /// 形状
  final BoxShape shape;

  const GradientContainer({
    Key? key,
    required this.child,
    this.colors,
    this.begin,
    this.end,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.boxShadow,
    this.border,
    this.alignment,
    this.shape = BoxShape.rectangle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? AppColors.gradientMixed,
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
        ),
        borderRadius: shape == BoxShape.rectangle
            ? borderRadius ?? BorderRadius.circular(16)
            : null,
        shape: shape,
        boxShadow: boxShadow,
        border: border,
      ),
      child: child,
    );
  }

  /// 创建粉色渐变容器
  factory GradientContainer.pink({
    required Widget child,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
    Border? border,
    AlignmentGeometry? alignment,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return GradientContainer(
      child: child,
      colors: AppColors.gradientPink,
      begin: begin,
      end: end,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      boxShadow: boxShadow,
      border: border,
      alignment: alignment,
      shape: shape,
    );
  }

  /// 创建紫色渐变容器
  factory GradientContainer.purple({
    required Widget child,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
    Border? border,
    AlignmentGeometry? alignment,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return GradientContainer(
      child: child,
      colors: AppColors.gradientPurple,
      begin: begin,
      end: end,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      boxShadow: boxShadow,
      border: border,
      alignment: alignment,
      shape: shape,
    );
  }

  /// 创建混合渐变容器
  factory GradientContainer.mixed({
    required Widget child,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
    Border? border,
    AlignmentGeometry? alignment,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return GradientContainer(
      child: child,
      colors: AppColors.gradientMixed,
      begin: begin,
      end: end,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      boxShadow: boxShadow,
      border: border,
      alignment: alignment,
      shape: shape,
    );
  }

  /// 创建自定义渐变容器
  factory GradientContainer.custom({
    required Widget child,
    required List<Color> colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    List<BoxShadow>? boxShadow,
    Border? border,
    AlignmentGeometry? alignment,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return GradientContainer(
      child: child,
      colors: colors,
      begin: begin,
      end: end,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      boxShadow: boxShadow,
      border: border,
      alignment: alignment,
      shape: shape,
    );
  }
}