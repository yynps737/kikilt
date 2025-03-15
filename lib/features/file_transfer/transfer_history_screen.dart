import 'package:flutter/material.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/models/file_transfer_model.dart';
import 'package:kikilt/utils/ui_utils.dart';
import 'package:kikilt/widgets/animated_button.dart';
import 'package:kikilt/widgets/transfer_progress.dart';
import 'package:lottie/lottie.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 传输历史页面
class TransferHistoryScreen extends StatefulWidget {
  const TransferHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransferHistoryScreen> createState() => _TransferHistoryScreenState();
}

class _TransferHistoryScreenState extends State<TransferHistoryScreen> {
  int _currentTabIndex = 0; // 0: 全部, 1: 发送, 2: 接收
  String? _filterQuery;

  /// 构建标签页
  Tab _buildTab(String text, int index) {
    return Tab(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: _currentTabIndex == index
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  /// 清除完成的传输
  void _clearCompletedTransfers() {
    UiUtils.showConfirmDialog(
      context: context,
      title: '清除完成的传输',
      content: '确定要清除所有已完成的传输记录吗？此操作无法撤销。',
      confirmText: '清除',
      cancelText: '取消',
      confirmColor: AppColors.error,
    ).then((confirmed) {
      if (confirmed) {
        final transfersNotifier = RefenaScope.of(context).read(transfersProvider);
        transfersNotifier.clearCompletedTransfers();

        UiUtils.showSnackBar(
          context,
          '已清除完成的传输记录',
        );
      }
    });
  }

  /// 筛选传输列表
  List<FileTransferModel> _filterTransfers(List<FileTransferModel> transfers) {
    // 应用标签筛选
    List<FileTransferModel> filtered;

    if (_currentTabIndex == 1) {
      // 发送
      filtered = transfers.where((t) => t.direction == TransferDirection.send).toList();
    } else if (_currentTabIndex == 2) {
      // 接收
      filtered = transfers.where((t) => t.direction == TransferDirection.receive).toList();
    } else {
      // 全部
      filtered = transfers;
    }

    // 应用搜索筛选
    if (_filterQuery != null && _filterQuery!.isNotEmpty) {
      final query = _filterQuery!.toLowerCase();
      filtered = filtered.where((t) {
        return t.fileName.toLowerCase().contains(query) ||
            t.device.alias.toLowerCase().contains(query) ||
            t.mimeType.toLowerCase().contains(query);
      }).toList();
    }

    // 按会话ID分组并排序
    filtered.sort((a, b) {
      // 优先按会话ID分组
      final int sessionCompare = a.sessionId.compareTo(b.sessionId);
      if (sessionCompare != 0) return sessionCompare;

      // 同一会话内按开始时间排序
      return a.startTime.compareTo(b.startTime);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _currentTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('传输历史'),
          actions: [
            IconButton(
              onPressed: _clearCompletedTransfers,
              icon: const Icon(Icons.delete_sweep),
              tooltip: '清除已完成',
            ),
          ],
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: [
              _buildTab('全部', 0),
              _buildTab('发送', 1),
              _buildTab('接收', 2),
            ],
            indicatorColor: AppColors.primaryPink,
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: Theme.of(context).textTheme.bodyLarge?.color,
            indicatorSize: TabBarIndicatorSize.label,
          ),
        ),
        body: Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索传输记录...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {
                    _filterQuery = value;
                  });
                },
              ),
            ),

            // 传输列表
            Expanded(
              child: RefenaConsumer<TransfersNotifier, List<FileTransferModel>>(
                listenableSelector: (notifier) => notifier,
                builder: (context, transfers) {
                  final filteredTransfers = _filterTransfers(transfers);

                  if (filteredTransfers.isEmpty) {
                    return _buildEmptyTransfersView();
                  }

                  return TransferProgressList(
                    transfers: filteredTransfers,
                    cancelable: false, // 历史记录不需要取消按钮
                    showDeviceInfo: true,
                    padding: const EdgeInsets.all(16),
                    itemSpacing: 12,
                    groupBySession: true, // 按会话分组
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空传输视图
  Widget _buildEmptyTransfersView() {
    final theme = Theme.of(context);
    String title;
    String description;

    // 根据当前标签设置提示文本
    if (_filterQuery != null && _filterQuery!.isNotEmpty) {
      title = '没有找到匹配的记录';
      description = '尝试使用其他关键词搜索';
    } else {
      switch (_currentTabIndex) {
        case 1:
          title = '没有发送记录';
          description = '您还没有发送过任何文件';
          break;
        case 2:
          title = '没有接收记录';
          description = '您还没有接收过任何文件';
          break;
        default:
          title = '没有传输记录';
          description = '您还没有传输过任何文件';
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/empty_transfers.json',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            AnimatedButton(
              text: '发送文件',
              icon: Icons.upload_file,
              onPressed: () {
                Navigator.of(context).pop(); // 返回上一页
              },
              type: ButtonType.primary,
              width: 150,
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}