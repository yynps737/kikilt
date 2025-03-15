import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:common/model/device.dart';

/// 最近设备列表
class RecentDeviceList extends StatelessWidget {
  /// 设备列表
  final List<DeviceModel> devices;

  /// 设备点击回调
  final ValueChanged<DeviceModel>? onDeviceTap;

  /// 设备长按回调
  final ValueChanged<DeviceModel>? onDeviceLongPress;

  /// 列表内边距
  final EdgeInsetsGeometry padding;

  /// 项目间距
  final double itemSpacing;

  const RecentDeviceList({
    Key? key,
    required this.devices,
    this.onDeviceTap,
    this.onDeviceLongPress,
    this.padding = EdgeInsets.zero,
    this.itemSpacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: padding,
      itemCount: devices.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final device = devices[index];
        return RecentDeviceItem(
          device: device,
          onTap: onDeviceTap != null ? () => onDeviceTap!(device) : null,
          onLongPress: onDeviceLongPress != null ? () => onDeviceLongPress!(device) : null,
        );
      },
    );
  }
}

/// 最近设备项
class RecentDeviceItem extends StatelessWidget {
  /// 设备信息
  final DeviceModel device;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  const RecentDeviceItem({
    Key? key,
    required this.device,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 获取设备类型图标和颜色
    IconData deviceIcon;
    Color deviceIconColor;

    switch (device.deviceType) {
      case DeviceType.mobile:
        deviceIcon = Icons.smartphone;
        deviceIconColor = AppColors.primaryPink;
        break;
      case DeviceType.desktop:
        deviceIcon = Icons.computer;
        deviceIconColor = AppColors.secondaryPurple;
        break;
      case DeviceType.web:
        deviceIcon = Icons.web;
        deviceIconColor = AppColors.info;
        break;
      case DeviceType.headless:
        deviceIcon = Icons.devices_other;
        deviceIconColor = AppColors.warning;
        break;
      case DeviceType.server:
        deviceIcon = Icons.storage;
        deviceIconColor = AppColors.accentYellow;
        break;
      default:
        deviceIcon = Icons.devices;
        deviceIconColor = AppColors.secondaryPurple;
    }

    // 获取状态颜色
    Color statusColor;
    String statusText;

    switch (device.status) {
      case DeviceStatus.online:
        statusColor = AppColors.success;
        statusText = '在线';
        break;
      case DeviceStatus.offline:
        statusColor = Colors.grey;
        statusText = '离线';
        break;
      case DeviceStatus.busy:
        statusColor = AppColors.warning;
        statusText = '忙碌';
        break;
      case DeviceStatus.unknown:
      default:
        statusColor = Colors.grey;
        statusText = '未知';
    }

    return Card(
      elevation: 2,
      shadowColor: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: device.isFavorite
            ? BorderSide(
          color: AppColors.primaryPink.withOpacity(isDarkMode ? 0.5 : 0.3),
          width: 1.5,
        )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 设备图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: deviceIconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  deviceIcon,
                  color: deviceIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // 设备信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 设备名称和收藏图标
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
                        if (device.isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.favorite,
                              color: AppColors.primaryPink,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // 设备类型
                    Text(
                      device.deviceModel ?? device.deviceTypeString,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 设备状态
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 发送按钮
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: AppColors.primaryPink,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}