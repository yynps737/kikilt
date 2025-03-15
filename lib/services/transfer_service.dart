import 'dart:async';
import 'dart:io';

import 'package:common/api_route_builder.dart';
import 'package:common/model/dto/file_dto.dart';
import 'package:common/model/dto/prepare_upload_request_dto.dart';
import 'package:common/model/dto/prepare_upload_response_dto.dart';
import 'package:common/model/file_status.dart';
import 'package:kikilt/models/device_model.dart';
import 'package:kikilt/models/file_transfer_model.dart';
import 'package:kikilt/services/device_service.dart';
import 'package:kikilt/services/file_service.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// 文件传输服务，负责处理文件的发送和接收
class TransferService {
  final DeviceService _deviceService;
  final FileService _fileService;
  final Logger _logger = Logger('TransferService');

  // 活动传输会话
  final Map<String, StreamController<List<FileTransferModel>>> _activeSessions = {};

  // 上传任务ID管理
  final Map<String, int> _uploadTaskIds = {};

  TransferService({
    required DeviceService deviceService,
    required FileService fileService,
  })  : _deviceService = deviceService,
        _fileService = fileService;

  /// 发送文件到指定设备
  Future<String> sendFiles(String deviceId, List<String> filePaths) async {
    _logger.info('发送文件到设备 $deviceId: ${filePaths.length} 个文件');

    try {
      // 获取设备
      final isolateActions = await _deviceService.getIsolateActions();
      final devices = await isolateActions.getDiscoveredDevices();
      final device = devices.firstWhere((d) => d.fingerprint == deviceId);

      // 生成会话ID
      final sessionId = const Uuid().v4();

      // 准备文件信息
      final files = <String, FileDto>{};
      final List<FileInfo> fileInfos = [];

      for (final filePath in filePaths) {
        final fileName = path.basename(filePath);
        final fileSize = await _fileService.getFileSize(filePath);
        final mimeType = _fileService.getMimeType(filePath);

        final fileId = const Uuid().v4();
        final fileInfo = FileInfo(
          id: fileId,
          name: fileName,
          path: filePath,
          size: fileSize,
          mimeType: mimeType,
          type: _getFileTypeFromMime(mimeType),
        );

        fileInfos.add(fileInfo);

        files[fileId] = FileDto(
          id: fileId,
          fileName: fileName,
          size: fileSize,
          fileType: fileInfo.type,
          hash: null,
          preview: null,
          legacy: false,
          metadata: null,
        );
      }

      // 创建传输会话流
      final streamController = StreamController<List<FileTransferModel>>.broadcast();
      _activeSessions[sessionId] = streamController;

      // 创建初始传输模型
      final initialTransfers = fileInfos.map((fileInfo) {
        return FileTransferModel(
          sessionId: sessionId,
          fileId: fileInfo.id,
          fileName: fileInfo.name,
          fileSize: fileInfo.size,
          transferredSize: 0,
          mimeType: fileInfo.mimeType,
          filePath: fileInfo.path,
          device: DeviceModel.fromDevice(device),
          direction: TransferDirection.send,
          status: FileTransferStatus.connecting,
          startTime: DateTime.now(),
        );
      }).toList();

      // 发送初始状态
      streamController.add(initialTransfers);

      // 准备上传请求
      _logger.info('准备上传请求: sessionId=$sessionId, 文件数=${files.length}');

      // 请求设备准备接收文件
      final deviceModel = DeviceModel.fromDevice(device);
      final prepareResponse = await _prepareUpload(deviceModel, files);

      // 开始上传文件
      for (final fileInfo in fileInfos) {
        final fileToken = prepareResponse.files[fileInfo.id];
        if (fileToken == null) {
          _logger.warning('文件 ${fileInfo.name} 没有获取到Token，跳过上传');
          continue;
        }

        // 更新状态为队列中
        _updateTransferStatus(
          sessionId,
          fileInfo.id,
          FileTransferStatus.queued,
        );

        // 执行上传
        _uploadFile(
          sessionId: sessionId,
          fileInfo: fileInfo,
          device: deviceModel,
          fileToken: fileToken,
        );
      }

      return sessionId;
    } catch (e) {
      _logger.severe('发送文件失败: $e');
      rethrow;
    }
  }

  /// 取消传输
  Future<void> cancelTransfer(String sessionId) async {
    _logger.info('取消传输: sessionId=$sessionId');

    try {
      // 取消上传任务
      final taskId = _uploadTaskIds[sessionId];
      if (taskId != null) {
        final isolateActions = await _deviceService.getIsolateActions();
        await isolateActions.cancelUpload(taskId);
        _uploadTaskIds.remove(sessionId);
      }

      // 更新所有传输状态为已取消
      final controller = _activeSessions[sessionId];
      if (controller != null) {
        final currentTransfers = controller.stream.value ?? [];
        final updatedTransfers = currentTransfers.map((transfer) {
          return transfer.copyWith(
            status: FileTransferStatus.cancelled,
            endTime: DateTime.now(),
          );
        }).toList();

        controller.add(updatedTransfers);
      }
    } catch (e) {
      _logger.severe('取消传输失败: $e');
      rethrow;
    }
  }

  /// 获取传输进度流
  Stream<List<FileTransferModel>> getTransferProgress(String sessionId) {
    final controller = _activeSessions[sessionId];
    if (controller == null) {
      // 如果没有找到会话，返回空流
      return Stream.value([]);
    }

    return controller.stream;
  }

  /// 获取文件传输状态
  Stream<FileTransferStatus> getFileTransferStatus(String sessionId, String fileId) {
    final controller = _activeSessions[sessionId];
    if (controller == null) {
      // 如果没有找到会话，返回错误状态
      return Stream.value(FileTransferStatus.failed);
    }

    return controller.stream.map((transfers) {
      final transfer = transfers.firstWhere(
            (t) => t.fileId == fileId,
        orElse: () => FileTransferModel(
          sessionId: sessionId,
          fileId: fileId,
          fileName: '',
          fileSize: 0,
          transferredSize: 0,
          mimeType: '',
          device: DeviceModel(
            id: '',
            ip: '',
            port: 0,
            https: false,
            fingerprint: '',
            alias: '',
            deviceModel: null,
            deviceType: DeviceType.desktop,
            download: false,
            version: '',
            lastSeen: DateTime.now(),
          ),
          direction: TransferDirection.send,
          status: FileTransferStatus.failed,
          startTime: DateTime.now(),
        ),
      );

      return transfer.status;
    });
  }

  /// 准备上传请求
  Future<PrepareUploadResponseDto> _prepareUpload(
      DeviceModel device,
      Map<String, FileDto> files,
      ) async {
    try {
      final isolateActions = await _deviceService.getIsolateActions();

      // 构建准备上传请求数据
      final requestData = PrepareUploadRequestDto(
        info: await isolateActions.getInfoRegisterDto(),
        files: files,
      );

      // 发送准备上传请求
      final httpClient = await isolateActions.getHttpClient();
      final targetUrl = ApiRoute.prepareUpload.target(device.toDevice());

      final response = await httpClient.post(
        uri: targetUrl,
        json: requestData.toJson(),
      );

      return PrepareUploadResponseDto.fromJson(
        Map<String, dynamic>.from(await jsonDecode(response)),
      );
    } catch (e) {
      _logger.severe('准备上传请求失败: $e');
      rethrow;
    }
  }

  /// 上传文件
  Future<void> _uploadFile({
    required String sessionId,
    required FileInfo fileInfo,
    required DeviceModel device,
    required String fileToken,
  }) async {
    try {
      _logger.info('上传文件: ${fileInfo.name} (${fileInfo.id})');

      // 更新状态为正在传输
      _updateTransferStatus(
        sessionId,
        fileInfo.id,
        FileTransferStatus.transferring,
      );

      final isolateActions = await _deviceService.getIsolateActions();

      // 开始上传
      final taskId = await isolateActions.startUpload(
        fileInfo.path!,
        fileInfo.mimeType,
        fileInfo.size,
        device.toDevice(),
        sessionId,
        fileInfo.id,
        fileToken,
      );

      // 保存任务ID，用于可能的取消操作
      _uploadTaskIds[sessionId] = taskId;

      // 监听上传进度
      final progress = isolateActions.getUploadProgress(taskId);

      // 上次更新时间和大小，用于计算速度
      DateTime lastUpdateTime = DateTime.now();
      int lastTransferredSize = 0;

      await for (final value in progress) {
        // 计算传输大小
        final transferredSize = (value * fileInfo.size).toInt();

        // 计算传输速度（字节/秒）
        final now = DateTime.now();
        final duration = now.difference(lastUpdateTime).inMilliseconds;

        double speed = 0;
        if (duration > 0) {
          speed = (transferredSize - lastTransferredSize) / (duration / 1000);
          lastUpdateTime = now;
          lastTransferredSize = transferredSize;
        }

        // 更新传输状态
        _updateTransferProgress(
          sessionId,
          fileInfo.id,
          transferredSize,
          speed,
        );
      }

      // 完成上传
      _updateTransferStatus(
        sessionId,
        fileInfo.id,
        FileTransferStatus.completed,
        DateTime.now(),
      );

      _logger.info('文件上传完成: ${fileInfo.name}');
    } catch (e) {
      _logger.severe('上传文件失败: ${fileInfo.name}, 错误: $e');

      // 更新状态为失败
      _updateTransferStatus(
        sessionId,
        fileInfo.id,
        FileTransferStatus.failed,
        DateTime.now(),
        error: e.toString(),
      );
    } finally {
      // 移除任务ID
      _uploadTaskIds.remove(sessionId);
    }
  }

  /// 更新传输状态
  void _updateTransferStatus(
      String sessionId,
      String fileId,
      FileTransferStatus status,
      [DateTime? endTime,
        String? error]
      ) {
    final controller = _activeSessions[sessionId];
    if (controller == null) return;

    final currentTransfers = controller.stream.value ?? [];
    final updatedTransfers = currentTransfers.map((transfer) {
      if (transfer.fileId == fileId) {
        return transfer.copyWith(
          status: status,
          endTime: endTime ?? transfer.endTime,
          error: error ?? transfer.error,
        );
      }
      return transfer;
    }).toList();

    controller.add(updatedTransfers);
  }

  /// 更新传输进度
  void _updateTransferProgress(
      String sessionId,
      String fileId,
      int transferredSize,
      double speed,
      ) {
    final controller = _activeSessions[sessionId];
    if (controller == null) return;

    final currentTransfers = controller.stream.value ?? [];
    final updatedTransfers = currentTransfers.map((transfer) {
      if (transfer.fileId == fileId) {
        return transfer.copyWith(
          transferredSize: transferredSize,
          speed: speed,
        );
      }
      return transfer;
    }).toList();

    controller.add(updatedTransfers);
  }

  /// 销毁服务
  void dispose() {
    for (final controller in _activeSessions.values) {
      controller.close();
    }
    _activeSessions.clear();
  }

  /// 根据MIME类型获取文件类型
  FileType _getFileTypeFromMime(String mimeType) {
    if (mimeType.startsWith('image/')) {
      return FileType.image;
    } else if (mimeType.startsWith('video/')) {
      return FileType.video;
    } else if (mimeType == 'application/pdf') {
      return FileType.pdf;
    } else if (mimeType.startsWith('text/')) {
      return FileType.text;
    } else if (mimeType == 'application/vnd.android.package-archive') {
      return FileType.apk;
    } else {
      return FileType.other;
    }
  }
}