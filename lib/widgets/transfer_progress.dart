import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/file_transfer_model.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:kikilt/utils/ui_utils.dart';

/// 传输进度组件
class TransferProgress extends StatelessWidget {
  /// 传输信息
  final FileTransferModel transfer;

  /// 点击回调
  final VoidCallback? onTap;

  /// 取消回调
  final VoidCallback? onCancel;

  /// 是否可取消
  final bool cancelable;

  /// 是否显示设备信息
  final bool showDeviceInfo;

  /// 自定义尾部组件
  final Widget? trailing;

  const TransferProgress({
    Key? key,
    required this.transfer,
    this.onTap,
    this.onCancel,
    this.cancelable = true,
    this.showDeviceInfo = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 获取状态颜色
    Color statusColor;
    switch (transfer.status) {
      case FileTransferStatus.completed:
        statusColor = AppColors.success;
        break;
      case FileTransferStatus.failed:
        statusColor = AppColors.error;
        break;
      case FileTransferStatus.cancelled:
      case FileTransferStatus.rejected:
        statusColor = Colors.grey;
        break;
      case FileTransferStatus.transferring:
        statusColor = AppColors.info;
        break;
      default:
        statusColor = AppColors.primaryPink;
    }

    // 获取进度条颜色
    Color progressColor;
    switch (transfer.status) {
      case FileTransferStatus.completed:
        progressColor = AppColors.success;
        break;
      case FileTransferStatus.failed:
        progressColor = AppColors.error;
        break;
      case FileTransferStatus.cancelled:
      case FileTransferStatus.rejected:
        progressColor = Colors.grey;
        break;
      default:
        progressColor = AppColors.primaryPink;
    }

    // 获取图标
    IconData statusIcon;
    switch (transfer.status) {
      case FileTransferStatus.completed:
        statusIcon = Icons.check_circle;
        break;
      case FileTransferStatus.failed:
        statusIcon = Icons.error;
        break;
      case FileTransferStatus.cancelled:
        statusIcon = Icons.cancel;
        break;
      case FileTransferStatus.rejected:
        statusIcon = Icons.block;
        break;
      case FileTransferStatus.queued:
        statusIcon = Icons.schedule;
        break;
      case FileTransferStatus.connecting:
        statusIcon = Icons.sync;
        break;
      case FileTransferStatus.transferring:
        statusIcon = transfer.direction == TransferDirection.send
            ? Icons.upload
            : Icons.download;
        break;
    }

    // 文件类型颜色
    final typeColor = UiUtils.getFileTypeColor(transfer.mimeType);

    // 获取文件类型图标
    IconData typeIcon;
    if (transfer.mimeType.startsWith('image/')) {
      typeIcon = Icons.image;
    } else if (transfer.mimeType.startsWith('video/')) {
      typeIcon = Icons.videocam;
    } else if (transfer.mimeType == 'application/pdf') {
      typeIcon = Icons.picture_as_pdf;
    } else if (transfer.mimeType.startsWith('text/')) {
      typeIcon = Icons.text_snippet;
    } else if (transfer.mimeType == 'application/vnd.android.package-archive') {
      typeIcon = Icons.android;
    } else {
      typeIcon = Icons.insert_drive_file;
    }

    return Card(
      color: isDarkMode ? AppColors.cardDark : Colors.white,
      elevation: 2,
      shadowColor: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 文件信息行
              Row(
                children: [
                  // 文件类型图标
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 文件名和大小
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transfer.fileName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatFileSize(transfer.transferredSize)} / ${transfer.fileSizeText}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 状态图标或取消按钮
                  trailing ?? (cancelable && (transfer.status == FileTransferStatus.queued ||
                      transfer.status == FileTransferStatus.connecting ||
                      transfer.status == FileTransferStatus.transferring)
                      ? IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    color: theme.iconTheme.color?.withOpacity(0.7),
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                  )
                      : Icon(
                    statusIcon,
                    color: statusColor,
                    size: 22,
                  )),
                ],
              ),

              const SizedBox(height: 12),

              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: [
                    FileTransferStatus.completed,
                    FileTransferStatus.failed,
                    FileTransferStatus.cancelled,
                    FileTransferStatus.rejected,
                  ].contains(transfer.status) ? 1.0 : transfer.progress,
                  minHeight: 8,
                  backgroundColor: isDarkMode
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),

              const SizedBox(height: 8),

              // 状态信息行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 状态文本
                  Text(
                    transfer.statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // 传输速度或进度百分比
                  Text(
                    transfer.status == FileTransferStatus.transferring && transfer.speed != null
                        ? '${formatFileSize(transfer.speed!.toInt())}/s'
                        : transfer.progressText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // 设备信息
              if (showDeviceInfo) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 传输方向
                    Row(
                      children: [
                        Icon(
                          transfer.direction == TransferDirection.send
                              ? Icons.upload
                              : Icons.download,
                          size: 14,
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transfer.direction == TransferDirection.send
                              ? '发送到'
                              : '接收自',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),

                    // 设备名称
                    Text(
                      transfer.device.alias,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 传输进度列表
class TransferProgressList extends StatelessWidget {
  /// 传输列表
  final List<FileTransferModel> transfers;

  /// 点击回调
  final ValueChanged<FileTransferModel>? onItemTap;

  /// 取消回调
  final ValueChanged<FileTransferModel>? onItemCancel;

  /// 是否可取消
  final bool cancelable;

  /// 是否显示设备信息
  final bool showDeviceInfo;

  /// 列表填充
  final EdgeInsetsGeometry padding;

  /// 列表间距
  final double itemSpacing;

  /// 空列表提示
  final Widget? emptyWidget;

  /// 是否按会话分组
  final bool groupBySession;

  const TransferProgressList({
    Key? key,
    required this.transfers,
    this.onItemTap,
    this.onItemCancel,
    this.cancelable = true,
    this.showDeviceInfo = true,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 12,
    this.emptyWidget,
    this.groupBySession = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (transfers.isEmpty) {
      return emptyWidget ?? const Center(
        child: Text('没有传输记录'),
      );
    }

    if (!groupBySession) {
      return ListView.separated(
        padding: padding,
        itemCount: transfers.length,
        separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
        itemBuilder: (context, index) {
          final transfer = transfers[index];
          return TransferProgress(
            transfer: transfer,
            onTap: onItemTap != null ? () => onItemTap!(transfer) : null,
            onCancel: onItemCancel != null ? () => onItemCancel!(transfer) : null,
            cancelable: cancelable,
            showDeviceInfo: showDeviceInfo,
          );
        },
      );
    } else {
      // 按会话分组
      final Map<String, List<FileTransferModel>> sessionGroups = {};

      // 分组
      for (final transfer in transfers) {
        if (!sessionGroups.containsKey(transfer.sessionId)) {
          sessionGroups[transfer.sessionId] = [];
        }

        sessionGroups[transfer.sessionId]!.add(transfer);
      }

      // 构建分组列表
      final List<Widget> groupWidgets = [];

      sessionGroups.forEach((sessionId, sessionTransfers) {
        // 排序：按开始时间排序
        sessionTransfers.sort((a, b) => a.startTime.compareTo(b.startTime));

        // 获取第一个传输的设备信息作为组标题
        final deviceName = sessionTransfers.first.device.alias;
        final transferDirection = sessionTransfers.first.direction;

        // 添加组标题
        groupWidgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  transferDirection == TransferDirection.send
                      ? Icons.upload
                      : Icons.download,
                  size: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                const SizedBox(width: 8),
                Text(
                  transferDirection == TransferDirection.send
                      ? '发送到 $deviceName'
                      : '接收自 $deviceName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${sessionTransfers.length} 个文件',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );

        // 添加传输项
        for (int i = 0; i < sessionTransfers.length; i++) {
          final transfer = sessionTransfers[i];

          groupWidgets.add(
            TransferProgress(
              transfer: transfer,
              onTap: onItemTap != null ? () => onItemTap!(transfer) : null,
              onCancel: onItemCancel != null ? () => onItemCancel!(transfer) : null,
              cancelable: cancelable,
              showDeviceInfo: false, // 组内不显示设备信息，避免重复
            ),
          );

          // 添加间距（除了最后一项）
          if (i < sessionTransfers.length - 1) {
            groupWidgets.add(SizedBox(height: itemSpacing));
          }
        }

        // 组之间的分隔线
        groupWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              height: 1,
            ),
          ),
        );
      });

      return ListView(
        padding: padding,
        children: groupWidgets,
      );
    }
  }
}

/// 传输统计组件
class TransferStats extends StatelessWidget {
  /// 传输列表
  final List<FileTransferModel> transfers;

  const TransferStats({
    Key? key,
    required this.transfers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 计算统计数据
    int totalFiles = transfers.length;
    int completedFiles = transfers.where((t) => t.status == FileTransferStatus.completed).length;
    int failedFiles = transfers.where((t) => t.status == FileTransferStatus.failed).length;
    int cancelledFiles = transfers.where((t) =>
    t.status == FileTransferStatus.cancelled ||
        t.status == FileTransferStatus.rejected
    ).length;
    int inProgressFiles = transfers.where((t) =>
    t.status == FileTransferStatus.queued ||
        t.status == FileTransferStatus.connecting ||
        t.status == FileTransferStatus.transferring
    ).length;

    // 计算总大小和已传输大小
    int totalSize = transfers.fold(0, (sum, item) => sum + item.fileSize);
    int transferredSize = transfers.fold(0, (sum, item) => sum + item.transferredSize);

    // 计算总进度
    double totalProgress = totalSize > 0 ? transferredSize / totalSize : 0;

    // 构建进度条
    return Card(
      elevation: 0,
      color: theme.colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '传输统计',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),

            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: totalProgress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(height: 12),

            // 统计信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '总进度: ${(totalProgress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${formatFileSize(transferredSize)} / ${formatFileSize(totalSize)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 文件计数
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  '总计',
                  totalFiles.toString(),
                  Icons.folder,
                  theme.colorScheme.primary,
                ),
                _buildStatItem(
                  context,
                  '完成',
                  completedFiles.toString(),
                  Icons.check_circle,
                  AppColors.success,
                ),
                _buildStatItem(
                  context,
                  '失败',
                  failedFiles.toString(),
                  Icons.error,
                  AppColors.error,
                ),
                _buildStatItem(
                  context,
                  '取消',
                  cancelledFiles.toString(),
                  Icons.cancel,
                  Colors.grey,
                ),
                _buildStatItem(
                  context,
                  '进行中',
                  inProgressFiles.toString(),
                  Icons.sync,
                  AppColors.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}