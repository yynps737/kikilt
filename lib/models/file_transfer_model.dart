import 'package:common/model/file_status.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:kikilt/models/device_model.dart';

part 'file_transfer_model.mapper.dart';

/// 文件传输信息模型
@MappableClass()
class FileTransferModel with FileTransferModelMappable {
  /// 传输会话ID
  final String sessionId;

  /// 文件ID
  final String fileId;

  /// 文件名
  final String fileName;

  /// 文件大小（字节）
  final int fileSize;

  /// 已传输大小（字节）
  final int transferredSize;

  /// 文件MIME类型
  final String mimeType;

  /// 文件路径（如果是本地文件）
  final String? filePath;

  /// 远程设备
  final DeviceModel device;

  /// 传输方向
  final TransferDirection direction;

  /// 传输状态
  final FileTransferStatus status;

  /// 传输开始时间
  final DateTime startTime;

  /// 传输完成时间
  final DateTime? endTime;

  /// 传输速度（字节/秒）
  final double? speed;

  /// 传输错误（如果有）
  final String? error;

  const FileTransferModel({
    required this.sessionId,
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    required this.transferredSize,
    required this.mimeType,
    this.filePath,
    required this.device,
    required this.direction,
    required this.status,
    required this.startTime,
    this.endTime,
    this.speed,
    this.error,
  });

  /// 获取传输进度（0-1）
  double get progress {
    if (fileSize == 0) return 0;
    return transferredSize / fileSize;
  }

  /// 获取传输进度百分比文本
  String get progressText {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  /// 获取传输状态文本
  String get statusText {
    switch (status) {
      case FileTransferStatus.queued:
        return '队列中';
      case FileTransferStatus.connecting:
        return '连接中';
      case FileTransferStatus.transferring:
        return '传输中';
      case FileTransferStatus.completed:
        return '已完成';
      case FileTransferStatus.failed:
        return '失败';
      case FileTransferStatus.cancelled:
        return '已取消';
      case FileTransferStatus.rejected:
        return '已拒绝';
      default:
        return '未知';
    }
  }

  /// 获取格式化的文件大小文本
  String get fileSizeText {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = fileSize.toDouble();

    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// 从文件状态创建
  factory FileTransferModel.fromFileStatus(
      String sessionId,
      String fileId,
      String fileName,
      int fileSize,
      String mimeType,
      String? filePath,
      DeviceModel device,
      TransferDirection direction,
      FileStatus fileStatus,
      ) {
    FileTransferStatus status;
    switch (fileStatus) {
      case FileStatus.queue:
        status = FileTransferStatus.queued;
        break;
      case FileStatus.sending:
        status = FileTransferStatus.transferring;
        break;
      case FileStatus.skipped:
        status = FileTransferStatus.rejected;
        break;
      case FileStatus.failed:
        status = FileTransferStatus.failed;
        break;
      case FileStatus.finished:
        status = FileTransferStatus.completed;
        break;
    }

    return FileTransferModel(
      sessionId: sessionId,
      fileId: fileId,
      fileName: fileName,
      fileSize: fileSize,
      transferredSize: fileStatus == FileStatus.finished ? fileSize : 0,
      mimeType: mimeType,
      filePath: filePath,
      device: device,
      direction: direction,
      status: status,
      startTime: DateTime.now(),
    );
  }

  /// 复制对象并修改属性
  FileTransferModel copyWith({
    String? sessionId,
    String? fileId,
    String? fileName,
    int? fileSize,
    int? transferredSize,
    String? mimeType,
    String? filePath,
    DeviceModel? device,
    TransferDirection? direction,
    FileTransferStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    double? speed,
    String? error,
  }) {
    return FileTransferModel(
      sessionId: sessionId ?? this.sessionId,
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      transferredSize: transferredSize ?? this.transferredSize,
      mimeType: mimeType ?? this.mimeType,
      filePath: filePath ?? this.filePath,
      device: device ?? this.device,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      speed: speed ?? this.speed,
      error: error ?? this.error,
    );
  }
}

/// 文件传输状态
enum FileTransferStatus {
  /// 已加入队列，等待传输
  queued,

  /// 正在连接
  connecting,

  /// 正在传输
  transferring,

  /// 传输完成
  completed,

  /// 传输失败
  failed,

  /// 传输取消
  cancelled,

  /// 传输被拒绝
  rejected,
}

/// 传输方向
enum TransferDirection {
  /// 发送文件
  send,

  /// 接收文件
  receive,
}