import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/utils/ui_utils.dart';

/// 设备卡片组件
class DeviceCard extends StatelessWidget {
  /// 设备信息
  final DeviceModel device;

  /// 点击回调
  final VoidCallback? onTap;

  /// 收藏按钮回调
  final ValueChanged<bool>? onFavoriteToggle;

  /// 是否显示收藏按钮
  final bool showFavoriteButton;

  /// 是否显示设备详情
  final bool showDeviceDetails;

  /// 右侧图标
  final IconData? trailingIcon;

  /// 右侧图标颜色
  final Color? trailingIconColor;

  /// 右侧图标点击回调
  final VoidCallback? onTrailingIconTap;

  /// 自定义卡片颜色
  final Color? cardColor;

  /// 自定义阴影颜色
  final Color? shadowColor;

  /// 自定义边框颜色
  final Color? borderColor;

  /// 自定义圆角
  final double borderRadius;

  const DeviceCard({
    Key? key,
    required this.device,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.showDeviceDetails = true,
    this.trailingIcon,
    this.trailingIconColor,
    this.onTrailingIconTap,
    this.cardColor,
    this.shadowColor,
    this.borderColor,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 获取设备类型图标
    IconData deviceTypeIcon;
    switch (device.deviceType) {
      case DeviceType.mobile:
        deviceTypeIcon = Icons.smartphone;
        break;
      case DeviceType.desktop:
        deviceTypeIcon = Icons.computer;
        break;
      case DeviceType.web:
        deviceTypeIcon = Icons.web;
        break;
      case DeviceType.headless:
        deviceTypeIcon = Icons.devices_other;
        break;
      case DeviceType.server:
        deviceTypeIcon = Icons.storage;
        break;
      default:
        deviceTypeIcon = Icons.devices;
    }

    // 获取状态颜色
    Color statusColor;
    switch (device.status) {
      case DeviceStatus.online:
        statusColor = AppColors.success;
        break;
      case DeviceStatus.offline:
        statusColor = Colors.grey;
        break;
      case DeviceStatus.busy:
        statusColor = AppColors.warning;
        break;
      case DeviceStatus.unknown:
      default:
        statusColor = Colors.grey;
    }

    // 构建设备卡片
    return Card(
      color: cardColor ?? (isDarkMode ? AppColors.cardDark : Colors.white),
      elevation: 3,
      shadowColor: shadowColor ?? (isDarkMode ? AppColors.shadowDark : AppColors.shadowLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderColor != null
            ? BorderSide(color: borderColor!, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 设备类型图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  deviceTypeIcon,
                  color: AppColors.primaryPink,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 设备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            device.alias,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 状态指示器
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    if (showDeviceDetails) ...[
                      const SizedBox(height: 4),
                      Text(
                        device.deviceModel ?? device.deviceTypeString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        device.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // 收藏图标或自定义图标
              if (showFavoriteButton)
                IconButton(
                  onPressed: onFavoriteToggle != null
                      ? () => onFavoriteToggle!(!device.isFavorite)
                      : null,
                  icon: Icon(
                    device.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: device.isFavorite ? AppColors.primaryPink : Colors.grey,
                  ),
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                )
              else if (trailingIcon != null)
                IconButton(
                  onPressed: onTrailingIconTap,
                  icon: Icon(
                    trailingIcon,
                    color: trailingIconColor ?? theme.iconTheme.color,
                  ),
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 设备卡片列表
class DeviceCardList extends StatelessWidget {
  /// 设备列表
  final List<DeviceModel> devices;

  /// 设备点击回调
  final ValueChanged<DeviceModel>? onDeviceTap;

  /// 收藏按钮回调
  final Function(DeviceModel, bool)? onFavoriteToggle;

  /// 是否显示收藏按钮
  final bool showFavoriteButton;

  /// 是否显示设备详情
  final bool showDeviceDetails;

  /// 空列表显示的组件
  final Widget? emptyWidget;

  /// 列表填充
  final EdgeInsetsGeometry padding;

  /// 列表间距
  final double itemSpacing;

  const DeviceCardList({
    Key? key,
    required this.devices,
    this.onDeviceTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.showDeviceDetails = true,
    this.emptyWidget,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return emptyWidget ?? const Center(
        child: Text('没有发现设备'),
      );
    }

    return ListView.separated(
      padding: padding,
      itemCount: devices.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceCard(
          device: device,
          onTap: onDeviceTap != null ? () => onDeviceTap!(device) : null,
          onFavoriteToggle: onFavoriteToggle != null
              ? (favorite) => onFavoriteToggle!(device, favorite)
              : null,
          showFavoriteButton: showFavoriteButton,
          showDeviceDetails: showDeviceDetails,
        );
      },
    );
  }
}

/// 空设备列表提示组件
class EmptyDeviceList extends StatelessWidget {
  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 按钮文本
  final String? buttonText;

  /// 按钮点击回调
  final VoidCallback? onButtonPressed;

  /// 是否显示图片
  final bool showImage;

  /// 图片资源路径
  final String? imagePath;

  const EmptyDeviceList({
    Key? key,
    this.title = '没有发现设备',
    this.description = '请确保设备在同一网络并启用了KikiLt应用',
    this.buttonText,
    this.onButtonPressed,
    this.showImage = true,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Image.asset(
                  imagePath ?? 'assets/images/empty_devices.png',
                  width: 180,
                  height: 180,
                ),
              ),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}