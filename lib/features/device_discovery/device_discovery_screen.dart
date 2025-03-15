import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/features/device_discovery/widgets/add_device_dialog.dart';
import 'package:kikilt/features/device_discovery/widgets/device_discovery_empty.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/utils/ui_utils.dart';
import 'package:kikilt/widgets/device_card.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 设备发现页面
class DeviceDiscoveryScreen extends StatefulWidget {
  const DeviceDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<DeviceDiscoveryScreen> createState() => _DeviceDiscoveryScreenState();
}

class _DeviceDiscoveryScreenState extends State<DeviceDiscoveryScreen> {
  bool _isRefreshing = false;
  String? _filterQuery;
  int _filterTab = 0; // 0: 全部, 1: 收藏, 2: 在线

  @override
  void initState() {
    super.initState();
    // 刷新设备列表
    _refreshDevices();
  }

  /// 刷新设备列表
  Future<void> _refreshDevices() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // 刷新设备列表
      final devicesNotifier = RefenaScope.of(context).read(devicesProvider);
      devicesNotifier.refreshDevices();

      // 模拟刷新延迟
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  /// 添加设备
  void _addDevice() async {
    final result = await UiUtils.showCustomDialog<(String, int)?>(
      context: context,
      child: const AddDeviceDialog(),
    );

    if (result != null) {
      final (ip, port) = result;
      final devicesNotifier = RefenaScope.of(context).read(devicesProvider);
      devicesNotifier.addFavoriteDevice(ip, port);

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, '设备已添加到收藏');
      }
    }
  }

  /// 处理设备点击
  void _onDeviceTap(DeviceModel device) {
    // 跳转到文件选择页面
    context.push('/file-selection?deviceId=${device.id}');
  }

  /// 处理收藏切换
  void _onFavoriteToggle(DeviceModel device, bool favorite) {
    final devicesNotifier = RefenaScope.of(context).read(devicesProvider);

    if (favorite) {
      devicesNotifier.addFavoriteDevice(device.ip, device.port);
    } else {
      devicesNotifier.removeFavoriteDevice(device.id);
    }

    UiUtils.showSnackBar(
      context,
      favorite ? '已将设备添加到收藏' : '已将设备从收藏中移除',
    );
  }

  /// 筛选设备列表
  List<DeviceModel> _filterDevices(List<DeviceModel> devices) {
    List<DeviceModel> filtered = List.from(devices);

    // 应用标签筛选
    if (_filterTab == 1) {
      // 收藏
      filtered = filtered.where((d) => d.isFavorite).toList();
    } else if (_filterTab == 2) {
      // 在线
      filtered = filtered.where((d) => d.status == DeviceStatus.online).toList();
    }

    // 应用搜索筛选
    if (_filterQuery != null && _filterQuery!.isNotEmpty) {
      final query = _filterQuery!.toLowerCase();
      filtered = filtered.where((d) {
        return d.alias.toLowerCase().contains(query) ||
            d.ip.contains(query) ||
            (d.deviceModel?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // 排序：收藏 > 在线 > 离线
    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;

      if (a.status == DeviceStatus.online && b.status != DeviceStatus.online) return -1;
      if (a.status != DeviceStatus.online && b.status == DeviceStatus.online) return 1;

      return a.alias.compareTo(b.alias);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备发现'),
        actions: [
          IconButton(
            onPressed: _refreshDevices,
            icon: _isRefreshing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
            )
                : const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
          IconButton(
            onPressed: _addDevice,
            icon: const Icon(Icons.add),
            tooltip: '添加设备',
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: '搜索设备...',
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

          // 筛选标签栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                _buildFilterChip(
                  label: '全部',
                  icon: Icons.devices,
                  index: 0,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: '收藏',
                  icon: Icons.favorite,
                  index: 1,
                ),
                const SizedBox(width: 12),
                _buildFilterChip(
                  label: '在线',
                  icon: Icons.wifi,
                  index: 2,
                ),
              ],
            ),
          ),

          // 设备列表
          Expanded(
            child: RefenaConsumer<DevicesNotifier, List<DeviceModel>>(
              listenableSelector: (notifier) => notifier,
              builder: (context, devices) {
                final filteredDevices = _filterDevices(devices);

                if (filteredDevices.isEmpty) {
                  return DeviceDiscoveryEmpty(
                    title: _getEmptyStateTitle(),
                    description: _getEmptyStateDescription(),
                    onRefresh: _refreshDevices,
                    onAddDevice: _addDevice,
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshDevices,
                  color: AppColors.primaryPink,
                  child: DeviceCardList(
                    devices: filteredDevices,
                    onDeviceTap: _onDeviceTap,
                    onFavoriteToggle: _onFavoriteToggle,
                    showFavoriteButton: true,
                    showDeviceDetails: true,
                    padding: const EdgeInsets.all(16),
                    itemSpacing: 12,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选标签
  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _filterTab == index;
    final theme = Theme.of(context);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppColors.primaryPink,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterTab = selected ? index : 0;
        });
      },
      backgroundColor: theme.scaffoldBackgroundColor,
      selectedColor: AppColors.primaryPink,
      checkmarkColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showCheckmark: false,
      elevation: 0,
      pressElevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.transparent : AppColors.primaryPink,
          width: 1,
        ),
      ),
    );
  }

  /// 获取空状态标题
  String _getEmptyStateTitle() {
    if (_filterQuery != null && _filterQuery!.isNotEmpty) {
      return '没有找到匹配的设备';
    }

    switch (_filterTab) {
      case 1:
        return '没有收藏的设备';
      case 2:
        return '没有在线设备';
      default:
        return '没有发现设备';
    }
  }

  /// 获取空状态描述
  String _getEmptyStateDescription() {
    if (_filterQuery != null && _filterQuery!.isNotEmpty) {
      return '尝试使用其他关键词搜索';
    }

    switch (_filterTab) {
      case 1:
        return '点击添加按钮收藏设备';
      case 2:
        return '请确保设备在同一网络并启用了KikiLt应用';
      default:
        return '请确保设备在同一网络并启用了KikiLt应用';
    }
  }
}