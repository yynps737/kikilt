import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/services/file_service.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:kikilt/utils/ui_utils.dart';
import 'package:kikilt/widgets/animated_button.dart';
import 'package:kikilt/widgets/file_item.dart';
import 'package:refena_flutter/refena_flutter.dart';
import 'package:uuid/uuid.dart';

/// 文件选择页面
class FileSelectionScreen extends StatefulWidget {
  /// 目标设备ID
  final String deviceId;

  const FileSelectionScreen({
    Key? key,
    required this.deviceId,
  }) : super(key: key);

  @override
  State<FileSelectionScreen> createState() => _FileSelectionScreenState();
}

class _FileSelectionScreenState extends State<FileSelectionScreen> {
  final List<FileInfo> _selectedFiles = [];
  DeviceModel? _device;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 获取设备信息
    _getDeviceInfo();
  }

  /// 获取设备信息
  void _getDeviceInfo() {
    // 从设备列表中获取设备信息
    final devices = RefenaScope.of(context).read(devicesProvider).state;
    final device = devices.firstWhere(
          (d) => d.id == widget.deviceId,
      orElse: () => throw Exception('设备未找到'),
    );

    setState(() {
      _device = device;
    });
  }

  /// 选择文件
  Future<void> _pickFiles() async {
    try {
      final fileService = RefenaScope.of(context).read(fileServiceProvider);
      final files = await fileService.pickFiles(
        allowMultiple: true,
      );

      if (files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(files);
        });
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, '选择文件失败: $e');
      }
    }
  }

  /// 移除选定的文件
  void _removeFile(FileInfo file) {
    setState(() {
      _selectedFiles.removeWhere((f) => f.id == file.id);
    });
  }

  /// 清除所有选定的文件
  void _clearFiles() {
    if (_selectedFiles.isEmpty) return;

    UiUtils.showConfirmDialog(
      context: context,
      title: '清除所有文件',
      content: '确定要清除所有已选文件吗？',
      confirmText: '清除',
      cancelText: '取消',
      confirmColor: AppColors.error,
    ).then((confirmed) {
      if (confirmed) {
        setState(() {
          _selectedFiles.clear();
        });
      }
    });
  }

  /// 开始传输
  Future<void> _startTransfer() async {
    if (_selectedFiles.isEmpty || _device == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 获取文件路径列表
      final filePaths = _selectedFiles
          .where((file) => file.path != null)
          .map((file) => file.path!)
          .toList();

      // 开始传输
      final transfersNotifier = RefenaScope.of(context).read(transfersProvider);
      final sessionId = await transfersNotifier.sendFiles(widget.deviceId, filePaths);

      if (mounted) {
        // 跳转到传输页面
        context.push('/file-transfer?deviceId=${widget.deviceId}&sessionId=$sessionId');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, '开始传输失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _device != null ? '发送到: ${_device!.alias}' : '选择文件',
        ),
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              onPressed: _clearFiles,
              icon: const Icon(Icons.clear_all),
              tooltip: '清除所有',
            ),
        ],
      ),
      body: Column(
        children: [
          // 设备信息卡片
          if (_device != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shadowColor: theme.brightness == Brightness.dark
                    ? AppColors.shadowDark
                    : AppColors.shadowLight,
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

                      // 连接状态
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _device!.status == DeviceStatus.online
                              ? AppColors.success
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 已选文件标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已选文件 (${_selectedFiles.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedFiles.isNotEmpty)
                  Text(
                    '总大小: ${_calculateTotalSize()}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),

          // 文件列表
          Expanded(
            child: _selectedFiles.isEmpty
                ? _buildEmptyFilesView()
                : FileItemList(
              files: _selectedFiles,
              selectedFileIds: const [],
              onItemDelete: _removeFile,
              isDeletable: true,
              showFileSize: true,
              padding: const EdgeInsets.all(16),
              itemSpacing: 8,
            ),
          ),

          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // 选择文件按钮
                Expanded(
                  child: AnimatedButton(
                    text: '选择文件',
                    icon: Icons.attach_file,
                    onPressed: _pickFiles,
                    type: ButtonType.outlined,
                    height: 50,
                    isDisabled: _isLoading,
                  ),
                ),
                const SizedBox(width: 16),

                // 发送按钮
                Expanded(
                  child: AnimatedButton(
                    text: '发送',
                    icon: Icons.send,
                    onPressed: _selectedFiles.isNotEmpty ? _startTransfer : null,
                    type: ButtonType.primary,
                    height: 50,
                    isDisabled: _selectedFiles.isEmpty || _isLoading,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空文件视图
  Widget _buildEmptyFilesView() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/empty_files.png',
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 24),
          Text(
            '还没有选择文件',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮选择要传输的文件',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedButton(
            text: '选择文件',
            icon: Icons.add,
            onPressed: _pickFiles,
            type: ButtonType.primary,
            width: 150,
            height: 48,
          ),
        ],
      ),
    );
  }

  /// 计算所有文件的总大小
  String _calculateTotalSize() {
    final totalSize = _selectedFiles.fold<int>(
      0,
          (total, file) => total + file.size,
    );

    return formatFileSize(totalSize);
  }
}