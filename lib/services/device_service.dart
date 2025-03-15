import 'dart:async';
import 'dart:io';

import 'package:common/constants.dart';
import 'package:common/isolate.dart';
import 'package:common/model/device.dart';
import 'package:common/model/device_info_result.dart';
import 'package:common/model/dto/multicast_dto.dart';
import 'package:common/model/stored_security_context.dart';
import 'package:flutter/foundation.dart';
import 'package:kikilt/services/security_service.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 设备服务，管理设备信息和隔离操作
class DeviceService {
  final Logger _logger = Logger('DeviceService');
  String _alias = '';
  int _port = defaultPort;
  ProtocolType _protocol = ProtocolType.https;
  bool _serverRunning = false;
  bool _download = true;

  ParentIsolateActions? _isolateActions;

  DeviceService();

  /// 获取隔离操作实例
  Future<IsolateActions> getIsolateActions() async {
    if (_isolateActions == null) {
      await _initializeIsolateActions();
    }
    return _isolateActions!;
  }

  /// 获取当前设备别名
  Future<String> getAlias() async {
    if (_alias.isEmpty) {
      await _loadSettings();
    }
    return _alias;
  }

  /// 设置设备别名
  Future<void> setAlias(String alias) async {
    _alias = alias;
    await _saveSettings();
    await _syncServerState();
  }

  /// 获取服务器端口
  int get port => _port;

  /// 设置服务器端口
  Future<void> setPort(int port) async {
    _port = port;
    await _saveSettings();
    await _syncServerState();
  }

  /// 获取当前协议类型
  ProtocolType get protocol => _protocol;

  /// 设置协议类型
  Future<void> setProtocol(ProtocolType protocol) async {
    _protocol = protocol;
    await _saveSettings();
    await _syncServerState();
  }

  /// 获取服务器状态
  bool get serverRunning => _serverRunning;

  /// 设置服务器状态
  Future<void> setServerRunning(bool running) async {
    _serverRunning = running;
    await _saveSettings();
    await _syncServerState();
  }

  /// 获取是否允许下载
  bool get download => _download;

  /// 设置是否允许下载
  Future<void> setDownload(bool enabled) async {
    _download = enabled;
    await _saveSettings();
    await _syncServerState();
  }

  /// 初始化隔离操作
  Future<void> _initializeIsolateActions() async {
    _logger.info('初始化隔离操作');

    // 加载设置
    await _loadSettings();

    // 获取安全上下文
    final securityContext = await SecurityService.getSecurityContext();

    // 获取设备信息
    final deviceInfo = await _getDeviceInfo();

    // 创建隔离操作
    _isolateActions = await ParentIsolateActions.initialize(
      httpClientFactory: _createHttpClient,
      securityContext: securityContext,
      deviceInfo: deviceInfo,
      alias: _alias,
      port: _port,
      protocol: _protocol,
      serverRunning: _serverRunning,
      download: _download,
      multicastGroup: defaultMulticastGroup,
      discoveryTimeout: defaultDiscoveryTimeout,
      uriContentStreamResolver: null,
    );

    _logger.info('隔离操作初始化完成');
  }

  /// 创建HTTP客户端
  CustomHttpClient _createHttpClient(Duration timeout, StoredSecurityContext context) {
    // 根据平台返回不同的HTTP客户端实现
    if (kIsWeb) {
      // Web平台实现
      return WebHttpClient(timeout: timeout, securityContext: context);
    } else {
      // 原生平台实现
      return NativeHttpClient(timeout: timeout, securityContext: context);
    }
  }

  /// 获取设备信息
  Future<DeviceInfoResult> _getDeviceInfo() async {
    DeviceType deviceType;
    String? deviceModel;

    if (kIsWeb) {
      deviceType = DeviceType.web;
      deviceModel = 'Web Browser';
    } else if (Platform.isAndroid) {
      deviceType = DeviceType.mobile;
      deviceModel = 'Android';
    } else if (Platform.isIOS) {
      deviceType = DeviceType.mobile;
      deviceModel = 'iOS';
    } else if (Platform.isWindows) {
      deviceType = DeviceType.desktop;
      deviceModel = 'Windows';
    } else if (Platform.isMacOS) {
      deviceType = DeviceType.desktop;
      deviceModel = 'macOS';
    } else if (Platform.isLinux) {
      deviceType = DeviceType.desktop;
      deviceModel = 'Linux';
    } else {
      deviceType = DeviceType.desktop;
      deviceModel = 'Unknown';
    }

    return DeviceInfoResult(
      deviceType: deviceType,
      deviceModel: deviceModel,
      androidSdkInt: null, // 实际应用中可以使用插件获取
    );
  }

  /// 同步服务器状态到隔离
  Future<void> _syncServerState() async {
    if (_isolateActions != null) {
      await _isolateActions!.syncServerState(
        alias: _alias,
        port: _port,
        protocol: _protocol,
        serverRunning: _serverRunning,
        download: _download,
      );
    }
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _alias = prefs.getString('device_alias') ?? _generateDefaultAlias();
      _port = prefs.getInt('server_port') ?? defaultPort;
      _protocol = prefs.getBool('use_https') ?? true
          ? ProtocolType.https
          : ProtocolType.http;
      _serverRunning = prefs.getBool('server_running') ?? false;
      _download = prefs.getBool('allow_download') ?? true;

      _logger.info('加载设置: alias=$_alias, port=$_port, protocol=$_protocol, serverRunning=$_serverRunning, download=$_download');
    } catch (e) {
      _logger.severe('加载设置失败: $e');

      // 使用默认设置
      _alias = _generateDefaultAlias();
      _port = defaultPort;
      _protocol = ProtocolType.https;
      _serverRunning = false;
      _download = true;
    }
  }

  /// 保存设置
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('device_alias', _alias);
      await prefs.setInt('server_port', _port);
      await prefs.setBool('use_https', _protocol == ProtocolType.https);
      await prefs.setBool('server_running', _serverRunning);
      await prefs.setBool('allow_download', _download);

      _logger.info('保存设置: alias=$_alias, port=$_port, protocol=$_protocol, serverRunning=$_serverRunning, download=$_download');
    } catch (e) {
      _logger.severe('保存设置失败: $e');
    }
  }

  /// 生成默认设备别名
  String _generateDefaultAlias() {
    String deviceType = 'Unknown';

    if (kIsWeb) {
      deviceType = 'Web';
    } else if (Platform.isAndroid) {
      deviceType = 'Android';
    } else if (Platform.isIOS) {
      deviceType = 'iOS';
    } else if (Platform.isWindows) {
      deviceType = 'Windows';
    } else if (Platform.isMacOS) {
      deviceType = 'Mac';
    } else if (Platform.isLinux) {
      deviceType = 'Linux';
    }

    // 生成短UUID
    final shortId = const Uuid().v4().substring(0, 6);

    return 'KikiLt-$deviceType-$shortId';
  }
}

/// HTTP客户端接口
abstract class HttpClient implements CustomHttpClient {
  final Duration timeout;
  final StoredSecurityContext securityContext;

  HttpClient({
    required this.timeout,
    required this.securityContext,
  });
}

/// Web平台HTTP客户端实现
class WebHttpClient extends HttpClient {
  WebHttpClient({
    required super.timeout,
    required super.securityContext,
  });

  @override
  Future<String> get({
    required String uri,
    required Map<String, String> query,
  }) async {
    // Web平台实现
    throw UnimplementedError();
  }

  @override
  Future<String> post({
    required String uri,
    Map<String, String> query = const {},
    required Map<String, dynamic> json,
  }) async {
    // Web平台实现
    throw UnimplementedError();
  }

  @override
  Future<void> postStream({
    required String uri,
    required Map<String, String> query,
    required Map<String, String> headers,
    required Stream<List<int>> stream,
    required void Function(double) onSendProgress,
    required CustomCancelToken cancelToken,
  }) async {
    // Web平台实现
    throw UnimplementedError();
  }
}

/// 原生平台HTTP客户端实现
class NativeHttpClient extends HttpClient {
  NativeHttpClient({
    required super.timeout,
    required super.securityContext,
  });

  @override
  Future<String> get({
    required String uri,
    required Map<String, String> query,
  }) async {
    // 原生平台实现
    throw UnimplementedError();
  }

  @override
  Future<String> post({
    required String uri,
    Map<String, String> query = const {},
    required Map<String, dynamic> json,
  }) async {
    // 原生平台实现
    throw UnimplementedError();
  }

  @override
  Future<void> postStream({
    required String uri,
    required Map<String, String> query,
    required Map<String, String> headers,
    required Stream<List<int>> stream,
    required void Function(double) onSendProgress,
    required CustomCancelToken cancelToken,
  }) async {
    // 原生平台实现
    throw UnimplementedError();
  }
}