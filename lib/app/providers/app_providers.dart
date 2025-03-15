import 'package:flutter/material.dart';
import 'package:kikilt/constants/theme.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/models/file_transfer_model.dart';
import 'package:kikilt/services/device_service.dart';
import 'package:kikilt/services/discovery_service.dart';
import 'package:kikilt/services/file_service.dart';
import 'package:kikilt/services/transfer_service.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 全局服务提供者
final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService();
});

final discoveryServiceProvider = Provider<DiscoveryService>((ref) {
  final deviceService = ref.read(deviceServiceProvider);
  return DiscoveryService(deviceService: deviceService);
});

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

final transferServiceProvider = Provider<TransferService>((ref) {
  final deviceService = ref.read(deviceServiceProvider);
  final fileService = ref.read(fileServiceProvider);
  return TransferService(
    deviceService: deviceService,
    fileService: fileService,
  );
});

/// 主题提供者
final themeProvider = ReduxProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// 设备状态提供者
final devicesProvider = ReduxProvider<DevicesNotifier, List<DeviceModel>>((ref) {
  final discoveryService = ref.read(discoveryServiceProvider);
  return DevicesNotifier(discoveryService: discoveryService);
});

/// 文件传输状态提供者
final transfersProvider = ReduxProvider<TransfersNotifier, List<FileTransferModel>>((ref) {
  final transferService = ref.read(transferServiceProvider);
  return TransfersNotifier(transferService: transferService);
});

/// 所有提供者列表
final providers = [
  // 服务提供者
  deviceServiceProvider,
  discoveryServiceProvider,
  fileServiceProvider,
  transferServiceProvider,

  // 状态提供者
  themeProvider,
  devicesProvider,
  transfersProvider,
];

class AppProviderScope extends StatelessWidget {
  final Widget child;

  const AppProviderScope({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefenaProviderScope(
      overrides: providers,
      child: child,
    );
  }
}

/// 设备状态管理器
class DevicesNotifier extends ReduxNotifier<List<DeviceModel>> {
  final DiscoveryService discoveryService;

  DevicesNotifier({required this.discoveryService});

  @override
  List<DeviceModel> init() {
    // 启动设备发现
    _startDiscovery();
    return [];
  }

  Future<void> _startDiscovery() async {
    await discoveryService.initialize();
    discoveryService.startDiscovery().listen((devices) {
      state = devices;
    });
  }

  void refreshDevices() {
    discoveryService.refreshDevices();
  }

  void addFavoriteDevice(String ip, int port) {
    discoveryService.addFavoriteDevice(ip, port);
  }

  void removeFavoriteDevice(String deviceId) {
    discoveryService.removeFavoriteDevice(deviceId);
  }
}

/// 文件传输状态管理器
class TransfersNotifier extends ReduxNotifier<List<FileTransferModel>> {
  final TransferService transferService;

  TransfersNotifier({required this.transferService});

  @override
  List<FileTransferModel> init() {
    return [];
  }

  Future<String> sendFiles(String deviceId, List<String> filePaths) async {
    final sessionId = await transferService.sendFiles(deviceId, filePaths);

    // 监听传输进度
    transferService.getTransferProgress(sessionId).listen((transfers) {
      // 更新当前传输列表
      state = [
        ...state.where((t) => t.sessionId != sessionId),
        ...transfers,
      ];
    });

    return sessionId;
  }

  Future<void> cancelTransfer(String sessionId) async {
    await transferService.cancelTransfer(sessionId);

    // 更新当前传输列表
    state = state.map((transfer) {
      if (transfer.sessionId == sessionId) {
        return transfer.copyWith(status: FileTransferStatus.cancelled);
      }
      return transfer;
    }).toList();
  }

  void clearCompletedTransfers() {
    state = state.where((transfer) {
      return transfer.status != FileTransferStatus.completed &&
          transfer.status != FileTransferStatus.failed &&
          transfer.status != FileTransferStatus.cancelled;
    }).toList();
  }
}