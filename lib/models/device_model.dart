import 'package:common/model/device.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'device_model.mapper.dart';

/// 表示一个可用于文件传输的设备
@MappableClass()
class DeviceModel with DeviceModelMappable {
  /// 设备的唯一标识符（使用指纹作为ID）
  final String id;

  /// 设备的IP地址
  final String ip;

  /// 设备的端口
  final int port;

  /// 设备是否使用HTTPS
  final bool https;

  /// 设备的指纹
  final String fingerprint;

  /// 设备的别名（用户可读名称）
  final String alias;

  /// 设备的型号
  final String? deviceModel;

  /// 设备的类型（移动设备、桌面设备等）
  final DeviceType deviceType;

  /// 设备是否支持下载功能
  final bool download;

  /// 设备的协议版本
  final String version;

  /// 设备是否是收藏设备
  final bool isFavorite;

  /// 设备的状态
  final DeviceStatus status;

  /// 最后一次发现时间
  final DateTime lastSeen;

  const DeviceModel({
    required this.id,
    required this.ip,
    required this.port,
    required this.https,
    required this.fingerprint,
    required this.alias,
    required this.deviceModel,
    required this.deviceType,
    required this.download,
    required this.version,
    this.isFavorite = false,
    this.status = DeviceStatus.online,
    required this.lastSeen,
  });

  /// 从common库的Device创建DeviceModel
  factory DeviceModel.fromDevice(Device device) {
    return DeviceModel(
      id: device.fingerprint,
      ip: device.ip,
      port: device.port,
      https: device.https,
      fingerprint: device.fingerprint,
      alias: device.alias,
      deviceModel: device.deviceModel,
      deviceType: device.deviceType,
      download: device.download,
      version: device.version,
      lastSeen: DateTime.now(),
    );
  }

  /// 转换为common库的Device
  Device toDevice() {
    return Device(
      ip: ip,
      version: version,
      port: port,
      https: https,
      fingerprint: fingerprint,
      alias: alias,
      deviceModel: deviceModel,
      deviceType: deviceType,
      download: download,
    );
  }

  /// 获取完整的设备名称
  String get fullName {
    if (deviceModel != null && deviceModel!.isNotEmpty) {
      return '$alias ($deviceModel)';
    }
    return alias;
  }

  /// 获取设备的地址
  String get address => '$ip:$port';

  /// 获取设备类型的显示名称
  String get deviceTypeString {
    switch (deviceType) {
      case DeviceType.mobile:
        return '移动设备';
      case DeviceType.desktop:
        return '桌面设备';
      case DeviceType.web:
        return '网页';
      case DeviceType.headless:
        return '无界面设备';
      case DeviceType.server:
        return '服务器';
      default:
        return '未知';
    }
  }
}

/// 设备状态
enum DeviceStatus {
  /// 在线
  online,

  /// 离线
  offline,

  /// 忙碌（当前有活动传输）
  busy,

  /// 未知状态
  unknown,
}