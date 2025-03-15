import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/features/home/widgets/action_card.dart';
import 'package:kikilt/features/home/widgets/recent_device_list.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/services/device_service.dart';
import 'package:kikilt/widgets/animated_button.dart';
import 'package:lottie/lottie.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 应用主页
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isServerRunning = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 检查服务器状态
    _checkServerStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 检查服务器状态
  Future<void> _checkServerStatus() async {
    final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
    final isRunning = deviceService.serverRunning;

    setState(() {
      _isServerRunning = isRunning;
    });

    if (_isServerRunning) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.reset();
    }
  }

  /// 切换服务器状态
  Future<void> _toggleServerStatus() async {
    final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
    final currentStatus = deviceService.serverRunning;

    // 更新服务器状态
    await deviceService.setServerRunning(!currentStatus);

    // 更新UI状态
    setState(() {
      _isServerRunning = !currentStatus;
    });

    // 控制动画
    if (_isServerRunning) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.reset();
    }
  }

  /// 导航到设备发现页面
  void _navigateToDeviceDiscovery() {
    context.push('/device-discovery');
  }

  /// 导航到传输历史页面
  void _navigateToTransferHistory() {
    context.push('/transfer-history');
  }

  /// 导航到设置页面
  void _navigateToSettings() {
    context.push('/settings');
  }

  /// 处理设备选择
  void _onDeviceSelected(DeviceModel device) {
    context.push('/file-selection?deviceId=${device.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'KikiLt',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToSettings,
            icon: const Icon(Icons.settings),
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 服务器状态卡片
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 6,
              shadowColor: isDarkMode
                  ? AppColors.shadowDark
                  : AppColors.primaryPink.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    // 服务图标
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (_isServerRunning ? AppColors.primaryPink : Colors.grey).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isServerRunning
                                ? 0.8 + (_animationController.value * 0.2)
                                : 1.0,
                            child: child,
                          );
                        },
                        child: Icon(
                          Icons.wifi_tethering,
                          color: _isServerRunning ? AppColors.primaryPink : Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // 服务状态信息
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '接收服务',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isServerRunning
                                ? '服务已启动，可以接收文件'
                                : '服务已停止，无法接收文件',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 开关按钮
                    Switch(
                      value: _isServerRunning,
                      onChanged: (value) => _toggleServerStatus(),
                      activeColor: AppColors.primaryPink,
                      activeTrackColor: AppColors.primaryPink.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 主要操作区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 操作卡片
                  Row(
                    children: [
                      // 发送文件卡片
                      Expanded(
                        child: ActionCard(
                          title: '发送文件',
                          description: '发现设备并发送文件',
                          icon: Icons.upload_file,
                          iconColor: AppColors.primaryPink,
                          backgroundColor: isDarkMode
                              ? AppColors.cardDark
                              : Colors.white,
                          onTap: _navigateToDeviceDiscovery,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // 传输历史卡片
                      Expanded(
                        child: ActionCard(
                          title: '传输历史',
                          description: '查看历史记录',
                          icon: Icons.history,
                          iconColor: AppColors.secondaryPurple,
                          backgroundColor: isDarkMode
                              ? AppColors.cardDark
                              : Colors.white,
                          onTap: _navigateToTransferHistory,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 最近设备标题
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '最近设备',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: _navigateToDeviceDiscovery,
                        child: Text(
                          '查看所有',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 最近设备列表
                  RefenaConsumer<DevicesNotifier, List<DeviceModel>>(
                    listenableSelector: (notifier) => notifier,
                    builder: (context, devices) {
                      // 筛选最近设备（最多显示5个）
                      final recentDevices = devices
                          .where((d) => d.isFavorite || d.status == DeviceStatus.online)
                          .toList()
                        ..sort((a, b) {
                          // 优先显示收藏设备
                          if (a.isFavorite && !b.isFavorite) return -1;
                          if (!a.isFavorite && b.isFavorite) return 1;
                          // 然后按最后见到时间排序
                          return b.lastSeen.compareTo(a.lastSeen);
                        });

                      final displayDevices = recentDevices.take(5).toList();

                      if (displayDevices.isEmpty) {
                        return _buildEmptyDevicesView();
                      }

                      return RecentDeviceList(
                        devices: displayDevices,
                        onDeviceTap: _onDeviceSelected,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空设备视图
  Widget _buildEmptyDevicesView() {
    final theme = Theme.of(context);

    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/empty_devices.json',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '没有发现设备',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击下方按钮搜索设备',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedButton(
              text: '搜索设备',
              icon: Icons.search,
              onPressed: _navigateToDeviceDiscovery,
              type: ButtonType.primary,
              height: 44,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}