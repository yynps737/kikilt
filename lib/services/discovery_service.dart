import 'dart:async';
import 'dart:io';

import 'package:common/constants.dart';
import 'package:common/isolate.dart';
import 'package:common/model/device.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/services/device_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 设备发现服务，使用common库查找网络上可用的设备
class DiscoveryService {
  final DeviceService _deviceService;
  final Logger _logger = Logger('DiscoveryService');

  /// 发现的设备流
  final BehaviorSubject<List<DeviceModel>> _devicesSubject = BehaviorSubject.seeded([]);

  /// 收藏的设备列表（IP:端口）
  final Set<String> _favoriteAddresses = {};

  /// 当前发现的设备集合（以指纹为键）
  final Map<String, DeviceModel> _discoveredDevices = {};

  IsolateActions? _isolateActions;
  Timer? _refreshTimer;
  bool _isInitialized = false;

  DiscoveryService({
    required DeviceService deviceService,
  }) : _deviceService = deviceService;

  /// 初始化发现服务
  Future<void> initialize() async {
    if (_isInitialized) return;

    _logger.info('初始化设备发现服务');

    // 加载收藏设备
    await _loadFavoriteDevices();

    // 初始化隔离操作
    _isolateActions = await _deviceService.getIsolateActions();

    _isInitialized = true;

    // 设置定期刷新
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshDevices();
    });
  }

  /// 开始发现设备
  Stream<List<DeviceModel>> startDiscovery() {
    _logger.info('开始设备发现');

    if (!_isInitialized) {
      throw StateError('DiscoveryService 尚未初始化');
    }

    // 启动多播发现
    _startMulticastDiscovery();

    // 启动HTTP发现
    _startHttpDiscovery();

    // 扫描收藏设备
    _scanFavoriteDevices();

    return _devicesSubject.stream;
  }

  /// 刷新设备列表
  void refreshDevices() {
    if (!_isInitialized) return;

    _logger.info('刷新设备列表');

    // 发送多播公告
    _isolateActions?.sendMulticastAnnouncement();

    // 扫描收藏设备
    _scanFavoriteDevices();
  }

  /// 添加收藏设备
  Future<void> addFavoriteDevice(String ip, int port) async {
    final address = '$ip:$port';
    _favoriteAddresses.add(address);
    await _saveFavoriteDevices();

    // 扫描新添加的收藏设备
    if (_isInitialized) {
      _scanFavoriteDevice(ip, port);
    }
  }

  /// 移除收藏设备
  Future<void> removeFavoriteDevice(String deviceId) async {
    // 找到对应的设备
    final device = _discoveredDevices[deviceId];
    if (device != null) {
      final address = '${device.ip}:${device.port}';
      _favoriteAddresses.remove(address);

      // 更新设备的收藏状态
      _updateDevice(device.copyWith(isFavorite: false));

      await _saveFavoriteDevices();
    }
  }

  /// 销毁服务
  void dispose() {
    _refreshTimer?.cancel();
    _devicesSubject.close();
  }

  /// 启动多播发现
  void _startMulticastDiscovery() {
    _isolateActions?.startMulticastListener().listen((device) {
      final deviceModel = DeviceModel.fromDevice(device);

      // 检查是否是收藏设备
      final address = '${deviceModel.ip}:${deviceModel.port}';
      final isFavorite = _favoriteAddresses.contains(address);

      _updateDevice(deviceModel.copyWith(
        isFavorite: isFavorite,
        lastSeen: DateTime.now(),
      ));
    });

    // 发送多播公告
    _isolateActions?.sendMulticastAnnouncement();
  }

  /// 启动HTTP发现（扫描本地网络）
  void _startHttpDiscovery() async {
    for (final interface in await _getNetworkInterfaces()) {
      _isolateActions?.startHttpScanDiscovery(interface, defaultPort, false).listen((device) {
        final deviceModel = DeviceModel.fromDevice(device);

        // 检查是否是收藏设备
        final address = '${deviceModel.ip}:${deviceModel.port}';
        final isFavorite = _favoriteAddresses.contains(address);

        _updateDevice(deviceModel.copyWith(
          isFavorite: isFavorite,
          lastSeen: DateTime.now(),
        ));
      });
    }
  }

  /// 扫描收藏设备
  void _scanFavoriteDevices() {
    for (final address in _favoriteAddresses) {
      final parts = address.split(':');
      if (parts.length == 2) {
        final ip = parts[0];
        final port = int.tryParse(parts[1]) ?? defaultPort;
        _scanFavoriteDevice(ip, port);
      }
    }
  }

  /// 扫描单个收藏设备
  void _scanFavoriteDevice(String ip, int port) {
    _isolateActions?.startHttpTargetDiscovery(ip, port, false).then((device) {
      if (device != null) {
        final deviceModel = DeviceModel.fromDevice(device);
        _updateDevice(deviceModel.copyWith(
          isFavorite: true,
          lastSeen: DateTime.now(),
        ));
      }
    }).catchError((error) {
      _logger.warning('扫描收藏设备失败: $ip:$port, 错误: $error');
    });
  }

  /// 更新设备信息并发送到流
  void _updateDevice(DeviceModel device) {
    _discoveredDevices[device.id] = device;
    _devicesSubject.add(_discoveredDevices.values.toList());
  }

  /// 获取可用的网络接口
  Future<List<String>> _getNetworkInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      return interfaces
          .expand((interface) => interface.addresses)
          .map((addr) => addr.address)
          .where((ip) => ip.startsWith('192.168.') ||
          ip.startsWith('10.') ||
          ip.startsWith('172.'))
          .toList();
    } catch (e) {
      _logger.severe('获取网络接口失败: $e');
      return [];
    }
  }

  /// 加载收藏设备
  Future<void> _loadFavoriteDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favoriteDevices') ?? [];
      _favoriteAddresses.addAll(favorites);
      _logger.info('已加载${_favoriteAddresses.length}个收藏设备');
    } catch (e) {
      _logger.severe('加载收藏设备失败: $e');
    }
  }

  /// 保存收藏设备
  Future<void> _saveFavoriteDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favoriteDevices', _favoriteAddresses.toList());
      _logger.info('已保存${_favoriteAddresses.length}个收藏设备');
    } catch (e) {
      _logger.severe('保存收藏设备失败: $e');
    }
  }
}