import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';

/// UI工具类，提供UI相关的工具方法
class UiUtils {
  /// 显示普通提示
  static void showSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 2),
        SnackBarAction? action,
        Color? backgroundColor,
        Color? textColor,
      }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        action: action,
      ),
    );
  }

  /// 显示成功提示
  static void showSuccessSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 2),
        SnackBarAction? action,
      }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.success,
      textColor: Colors.white,
      action: action,
    );
  }

  /// 显示错误提示
  static void showErrorSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.error,
      textColor: Colors.white,
      action: action,
    );
  }

  /// 显示警告提示
  static void showWarningSnackBar(
      BuildContext context,
      String message, {
        Duration duration = const Duration(seconds: 3),
        SnackBarAction? action,
      }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: AppColors.warning,
      textColor: Colors.white,
      action: action,
    );
  }

  /// 显示确认对话框
  static Future<bool> showConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        String confirmText = '确认',
        String cancelText = '取消',
        Color? confirmColor,
        bool barrierDismissible = true,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: confirmColor ?? AppColors.primaryPink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// 显示加载对话框
  static Future<T> showLoadingDialog<T>({
    required BuildContext context,
    required Future<T> future,
    String loadingText = '加载中...',
    bool barrierDismissible = false,
  }) async {
    final dialogCompleter = showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              loadingText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );

    try {
      // 等待操作完成
      final result = await future;

      // 关闭对话框
      Navigator.of(context).pop();

      return result;
    } catch (e) {
      // 关闭对话框
      Navigator.of(context).pop();

      // 重新抛出异常
      rethrow;
    } finally {
      // 确保对话框被关闭
      dialogCompleter.ignore();
    }
  }

  /// 显示自定义底部弹出菜单
  static Future<T?> showCustomBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool enableDrag = true,
    bool isDismissible = true,
    bool useSafeArea = true,
    RouteSettings? routeSettings,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Theme.of(context).cardColor,
      elevation: elevation,
      shape: shape ?? const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: clipBehavior ?? Clip.antiAlias,
      barrierColor: barrierColor,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      useSafeArea: useSafeArea,
      routeSettings: routeSettings,
      builder: (context) => child,
    );
  }

  /// 显示自定义对话框
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (context) => child,
    );
  }

  /// 创建渐变装饰
  static BoxDecoration createGradientDecoration({
    List<Color>? colors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Border? border,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors ?? AppColors.gradientMixed,
        begin: begin,
        end: end,
      ),
      borderRadius: shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(16)) : null,
      shape: shape,
      border: border,
    );
  }

  /// 创建带阴影的装饰
  static BoxDecoration createShadowDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? boxShadow,
    Border? border,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: shape == BoxShape.rectangle ? (borderRadius ?? BorderRadius.circular(16)) : null,
      shape: shape,
      border: border,
      boxShadow: boxShadow ?? [
        BoxShadow(
          color: AppColors.shadowLight,
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// 创建虚线装饰
  static BoxDecoration createDashedDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<double>? dashPattern,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: DashedBorder(
        dashPattern: dashPattern ?? [6, 3],
        color: color ?? Colors.grey,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
      ),
    );
  }

  /// 创建文件类型颜色
  static Color getFileTypeColor(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return Colors.blue;
    } else if (mimeType.startsWith('video/')) {
      return Colors.red;
    } else if (mimeType.startsWith('audio/')) {
      return Colors.purple;
    } else if (mimeType == 'application/pdf') {
      return Colors.red;
    } else if (mimeType.startsWith('text/')) {
      return Colors.teal;
    } else if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Colors.green;
    } else if (mimeType.contains('presentation') || mimeType.contains('powerpoint')) {
      return Colors.orange;
    } else if (mimeType.contains('word') || mimeType.contains('document')) {
      return Colors.blue;
    } else if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Colors.amber;
    }

    return Colors.grey;
  }

  /// 根据亮度获取基于主题的颜色
  static Color getThemedColor(BuildContext context, Color lightColor, Color darkColor) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.light ? lightColor : darkColor;
  }
}

/// 虚线边框
class DashedBorder extends BoxBorder {
  final List<double> dashPattern;
  final BorderRadius borderRadius;
  final Color color;
  final double width;

  const DashedBorder({
    required this.dashPattern,
    required this.borderRadius,
    required this.color,
    this.width = 1.0,
  });

  @override
  BorderSide get bottom => BorderSide(color: color, width: width);

  @override
  BorderSide get top => BorderSide(color: color, width: width);

  @override
  BorderSide get left => BorderSide(color: color, width: width);

  @override
  BorderSide get right => BorderSide(color: color, width: width);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
      Canvas canvas,
      Rect rect, {
        TextDirection? textDirection,
        BoxShape shape = BoxShape.rectangle,
        BorderRadius? borderRadius,
      }) {
    if (rect.isEmpty) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    final Path path = Path()..addRRect(borderRadius?.toRRect(rect) ?? RRect.fromRectAndRadius(rect, Radius.zero));

    final Path dashPath = Path();

    double dashLength = dashPattern[0];
    double dashSpace = dashPattern[1];
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }
}