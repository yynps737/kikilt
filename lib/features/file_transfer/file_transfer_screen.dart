import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/models/file_transfer_model.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:kikilt/utils/ui_utils.dart';
import 'package:kikilt/widgets/animated_button.dart';
import 'package:kikilt/widgets/transfer_progress.dart';
import 'package:lottie/lottie.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 文件传输页面
class FileTransferScreen extends StatefulWidget {
  /// 设备ID
  final String deviceId;

  /// 会话ID
  final String sessionId;

  const FileTransferScreen({
    Key? key,
    required this.deviceId,
    required this.sessionId,
  }) : super(key: key);

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  DeviceModel? _device;
  bool _isLoading = true;
  bool _isTransferComplete = false;
  bool _showConfetti = false;

  StreamSubscription? _transferSubscription;
  List<FileTransferModel> _currentTransfers = [];

  @override
  void initState() {
    super.initState();

    // 获取设备信息
    _getDeviceInfo();

    // 监听传输进度
    _listenToTransfers();
  }

  @override
  void dispose() {
    _transferSubscription?.cancel();
    super.dispose();
  }

  /// 获取设备信息
  void _getDeviceInfo() {
    // 从设备列表中获取设备信息
    final devices = RefenaScope.of(context).read(devicesProvider).state;

    try {
      final device = devices.firstWhere(
            (d) => d.id == widget.deviceId,
      );

      setState(() {
        _device = device;
      });
    } catch (e) {
      // 设备未找到，使用默认值继续
    }
  }

  /// 监听传输进度
  void _listenToTransfers() {
    final transfersNotifier = RefenaScope.of(context).read(transfersProvider);
    final stream = transfersNotifier.getTransferProgress(widget.sessionId);

    _transferSubscription = stream.listen((transfers) {
      // 更新当前传输列表
      setState(() {
        _currentTransfers = transfers;
        _isLoading = false;
      });

      // 检查传输是否完成
      _checkTransferCompletion();
    });
  }

  /// 检查传输是否完成
  void _checkTransferCompletion() {
    if (_currentTransfers.isEmpty) return;

    final bool allCompleted = _currentTransfers.every((transfer) {
      return transfer.status == FileTransferStatus.completed ||
          transfer.status == FileTransferStatus.failed ||
          transfer.status == FileTransferStatus.cancelled ||
          transfer.status == FileTransferStatus.rejected;
    });

    // 如果所有传输都已完成或失败
    if (allCompleted && !_isTransferComplete) {
      setState(() {
        _isTransferComplete = true;

        // 检查是否所有文件都成功传输，显示庆祝动画
        final bool allSuccess = _currentTransfers.every((transfer) {
          return transfer.status == FileTransferStatus.completed;
        });

        if (allSuccess) {
          _showConfetti = true;
        }
      });
    }
  }

  /// 取消当前传输
  Future<void> _cancelTransfer() async {
    UiUtils.showConfirmDialog(
      context: context,
      title: '取消传输',
      content: '确定要取消当前传输吗？已传输的文件不会被删除。',
      confirmText: '取消传输',
      cancelText: '继续传输',
      confirmColor: AppColors.error,
    ).then((confirmed) async {
      if (confirmed) {
        try {
          final transfersNotifier = RefenaScope.of(context).read(transfersProvider);
          await transfersNotifier.cancelTransfer(widget.sessionId);

          if (mounted) {
            UiUtils.showSnackBar(
              context,
              '传输已取消',
              backgroundColor: AppColors.warning,
            );
          }
        } catch (e) {
          if (mounted) {
            UiUtils.showErrorSnackBar(context, '取消传输失败: $e');
          }
        }
      }
    });
  }

  /// 返回设备选择页面
  void _goBackToDeviceSelection() {
    context.pop();
  }

  /// 返回文件选择页面
  void _goBackToFileSelection() {
    // 如果可以返回两次，返回到设备选择页面
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } else {
      // 否则直接导航到主页
      context.go('/home');
    }
  }

  /// 开始新的传输
  void _startNewTransfer() {
    if (_device == null) {
      _goBackToDeviceSelection();
    } else {
      context.pushReplacement('/file-selection?deviceId=${widget.deviceId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件传输'),
        actions: [
          if (!_isTransferComplete)
            IconButton(
              onPressed: _cancelTransfer,
              icon: const Icon(Icons.cancel),
              tooltip: '取消传输',
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? _buildLoadingView()
              : _currentTransfers.isEmpty
              ? _buildEmptyTransferView()
              : _buildTransferView(),

          // 庆祝动画
          if (_showConfetti)
            IgnorePointer(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
                child: Lottie.asset(
                  'assets/animations/confetti.json',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('准备传输...'),
        ],
      ),
    );
  }

  /// 构建空传输视图
  Widget _buildEmptyTransferView() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/error.json',
              width: 160,
              height: 160,
              repeat: false,
            ),
            const SizedBox(height: 24),
            Text(
              '传输初始化失败',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '无法开始文件传输，请检查设备连接后重试',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AnimatedButton(
              text: '返回',
              icon: Icons.arrow_back,
              onPressed: _goBackToFileSelection,
              type: ButtonType.primary,
              width: 120,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建传输视图
  Widget _buildTransferView() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // 设备信息（如果有）
        if (_device != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // 设备图标
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _device!.deviceType == DeviceType.mobile
                            ? Icons.smartphone
                            : _device!.deviceType == DeviceType.desktop
                            ? Icons.computer
                            : Icons.devices,
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
                          Text(
                            _device!.alias,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _device!.deviceModel ?? _device!.deviceTypeString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // 传输图标
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.info.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: AppColors.info,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // 传输状态和统计
        if (_isTransferComplete)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildCompletionCard(),
          ),

        // 传输进度统计
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TransferStats(transfers: _currentTransfers),
        ),

        // 传输列表
        Expanded(
          child: TransferProgressList(
            transfers: _currentTransfers,
            cancelable: !_isTransferComplete,
            onItemCancel: (transfer) {
              final transfersNotifier = RefenaScope.of(context).read(transfersProvider);
              transfersNotifier.cancelTransfer(widget.sessionId);
            },
            showDeviceInfo: false,
            padding: const EdgeInsets.all(16),
            itemSpacing: 12,
          ),
        ),

        // 底部按钮（当传输完成时）
        if (_isTransferComplete)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 返回按钮
                Expanded(
                  child: AnimatedButton(
                    text: '返回',
                    icon: Icons.arrow_back,
                    onPressed: _goBackToDeviceSelection,
                    type: ButtonType.outlined,
                    height: 50,
                  ),
                ),
                const SizedBox(width: 16),

                // 再次发送按钮
                Expanded(
                  child: AnimatedButton(
                    text: '发送更多',
                    icon: Icons.send,
                    onPressed: _startNewTransfer,
                    type: ButtonType.primary,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建完成卡片
  Widget _buildCompletionCard() {
    final theme = Theme.of(context);

    // 计算完成状态
    final int totalFiles = _currentTransfers.length;
    final int completedFiles = _currentTransfers.where(
            (t) => t.status == FileTransferStatus.completed
    ).length;
    final int failedFiles = _currentTransfers.where(
            (t) => t.status == FileTransferStatus.failed
    ).length;
    final int cancelledFiles = _currentTransfers.where(
            (t) => t.status == FileTransferStatus.cancelled ||
            t.status == FileTransferStatus.rejected
    ).length;

    // 确定状态文本和颜色
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (failedFiles == totalFiles) {
      statusText = '传输失败';
      statusColor = AppColors.error;
      statusIcon = Icons.error;
    } else if (cancelledFiles == totalFiles) {
      statusText = '传输已取消';
      statusColor = AppColors.warning;
      statusIcon = Icons.cancel;
    } else if (completedFiles == totalFiles) {
      statusText = '传输完成';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else if (failedFiles > 0 || cancelledFiles > 0) {
      statusText = '部分完成';
      statusColor = AppColors.warning;
      statusIcon = Icons.warning;
    } else {
      statusText = '传输完成';
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    }

    return Card(
      elevation: 0,
      color: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getCompletionDescription(
                      completedFiles,
                      failedFiles,
                      cancelledFiles,
                      totalFiles,
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取完成描述文本
  String _getCompletionDescription(
      int completed,
      int failed,
      int cancelled,
      int total,
      ) {
    final StringBuffer buffer = StringBuffer();

    if (completed > 0) {
      buffer.write('$completed 个文件成功');
    }

    if (failed > 0) {
      if (buffer.isNotEmpty) buffer.write('，');
      buffer.write('$failed 个文件失败');
    }

    if (cancelled > 0) {
      if (buffer.isNotEmpty) buffer.write('，');
      buffer.write('$cancelled 个文件取消');
    }

    return buffer.toString();
  }
}