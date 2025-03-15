import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/widgets/animated_button.dart';
import 'package:lottie/lottie.dart';

/// 设备发现空状态组件
class DeviceDiscoveryEmpty extends StatelessWidget {
  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 刷新回调
  final VoidCallback? onRefresh;

  /// 添加设备回调
  final VoidCallback? onAddDevice;

  /// 是否显示添加设备按钮
  final bool showAddButton;

  /// 是否显示刷新按钮
  final bool showRefreshButton;

  /// 是否显示动画
  final bool showAnimation;

  /// 自定义动画资源
  final String? animationAsset;

  const DeviceDiscoveryEmpty({
    Key? key,
    required this.title,
    required this.description,
    this.onRefresh,
    this.onAddDevice,
    this.showAddButton = true,
    this.showRefreshButton = true,
    this.showAnimation = true,
    this.animationAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 动画
            if (showAnimation)
              Lottie.asset(
                animationAsset ?? 'assets/animations/empty_devices.json',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            const SizedBox(height: 16),

            // 标题
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 描述
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 按钮组
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 刷新按钮
                if (showRefreshButton && onRefresh != null)
                  AnimatedButton(
                    text: '刷新',
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    type: ButtonType.secondary,
                    width: 120,
                    height: 48,
                  ),
                if (showRefreshButton && onRefresh != null && showAddButton && onAddDevice != null)
                  const SizedBox(width: 16),

                // 添加设备按钮
                if (showAddButton && onAddDevice != null)
                  AnimatedButton(
                    text: '添加设备',
                    icon: Icons.add,
                    onPressed: onAddDevice,
                    type: ButtonType.primary,
                    width: 120,
                    height: 48,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 网络错误状态
class NetworkErrorState extends StatelessWidget {
  /// 刷新回调
  final VoidCallback? onRefresh;

  /// 检查网络回调
  final VoidCallback? onCheckNetwork;

  /// 标题
  final String title;

  /// 描述
  final String description;

  const NetworkErrorState({
    Key? key,
    this.onRefresh,
    this.onCheckNetwork,
    this.title = '网络连接问题',
    this.description = '无法连接到网络，请检查您的网络连接后重试',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 动画
            Lottie.asset(
              'assets/animations/network_error.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),

            // 标题
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 描述
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 按钮组
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 检查网络按钮
                if (onCheckNetwork != null)
                  AnimatedButton(
                    text: '检查网络',
                    icon: Icons.wifi,
                    onPressed: onCheckNetwork,
                    type: ButtonType.outlined,
                    width: 120,
                    height: 48,
                  ),
                if (onCheckNetwork != null && onRefresh != null)
                  const SizedBox(width: 16),

                // 重试按钮
                if (onRefresh != null)
                  AnimatedButton(
                    text: '重试',
                    icon: Icons.refresh,
                    onPressed: onRefresh,
                    type: ButtonType.primary,
                    width: 120,
                    height: 48,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 权限错误状态
class PermissionErrorState extends StatelessWidget {
  /// 授权回调
  final VoidCallback? onGrant;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 标题
  final String title;

  /// 描述
  final String description;

  const PermissionErrorState({
    Key? key,
    this.onGrant,
    this.onCancel,
    this.title = '需要权限',
    this.description = '我们需要相关权限才能发现设备，请点击下方按钮授予权限',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 动画
            Lottie.asset(
              'assets/animations/permission.json',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              repeat: false,
            ),
            const SizedBox(height: 16),

            // 标题
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 描述
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // 按钮组
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 取消按钮
                if (onCancel != null)
                  AnimatedButton(
                    text: '取消',
                    icon: Icons.close,
                    onPressed: onCancel,
                    type: ButtonType.outlined,
                    width: 120,
                    height: 48,
                  ),
                if (onCancel != null && onGrant != null)
                  const SizedBox(width: 16),

                // 授权按钮
                if (onGrant != null)
                  AnimatedButton(
                    text: '授权',
                    icon: Icons.check_circle,
                    onPressed: onGrant,
                    type: ButtonType.primary,
                    width: 120,
                    height: 48,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}