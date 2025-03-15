import 'package:common/model/file_type.dart';
import 'package:flutter/foundation.dart';

/// 文件信息数据类
class FileInfo {
  /// 文件唯一标识符
  final String id;

  /// 文件名
  final String name;

  /// 文件路径（本地文件）
  final String? path;

  /// 文件数据（Web平台）
  final Uint8List? bytes;

  /// 文件大小（字节）
  final int size;

  /// 文件MIME类型
  final String mimeType;

  /// 文件类型
  final FileType type;

  FileInfo({
    required this.id,
    required this.name,
    this.path,
    this.bytes,
    required this.size,
    required this.mimeType,
    required this.type,
  });

  /// 获取格式化的文件大小文本
  String get sizeFormatted {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = this.size.toDouble();

    while (size > 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// 获取文件图标
  String get iconAsset {
    switch (type) {
      case FileType.image:
        return 'assets/images/file_image.png';
      case FileType.video:
        return 'assets/images/file_video.png';
      case FileType.pdf:
        return 'assets/images/file_pdf.png';
      case FileType.text:
        return 'assets/images/file_text.png';
      case FileType.apk:
        return 'assets/images/file_apk.png';
      case FileType.other:
      default:
        return 'assets/images/file_other.png';
    }
  }

  /// 获取文件类型的显示文本
  String get typeText {
    switch (type) {
      case FileType.image:
        return '图片文件';
      case FileType.video:
        return '视频文件';
      case FileType.pdf:
        return 'PDF文档';
      case FileType.text:
        return '文本文件';
      case FileType.apk:
        return 'Android应用';
      case FileType.other:
      default:
        return '其他文件';
    }
  }

  /// 获取文件扩展名
  String get extension {
    final parts = name.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// 检查是否为图片文件
  bool get isImage => type == FileType.image;

  /// 检查是否为视频文件
  bool get isVideo => type == FileType.video;

  /// 检查是否为PDF文件
  bool get isPdf => type == FileType.pdf;

  /// 检查是否为文本文件
  bool get isText => type == FileType.text;

  /// 检查是否为APK文件
  bool get isApk => type == FileType.apk;
}

/// 格式化文件大小
String formatFileSize(int bytes) {
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  var i = 0;
  double size = bytes.toDouble();

  while (size > 1024 && i < suffixes.length - 1) {
    size /= 1024;
    i++;
  }

  return '${size.toStringAsFixed(2)} ${suffixes[i]}';
}

/// 根据扩展名获取MIME类型
String getMimeTypeFromExtension(String extension) {
  final Map<String, String> mimeTypeMap = {
    // 图片
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'gif': 'image/gif',
    'webp': 'image/webp',
    'bmp': 'image/bmp',

    // 视频
    'mp4': 'video/mp4',
    'avi': 'video/x-msvideo',
    'mkv': 'video/x-matroska',
    'mov': 'video/quicktime',
    'wmv': 'video/x-ms-wmv',

    // 音频
    'mp3': 'audio/mpeg',
    'wav': 'audio/wav',
    'ogg': 'audio/ogg',
    'flac': 'audio/flac',

    // 文档
    'pdf': 'application/pdf',
    'doc': 'application/msword',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xls': 'application/vnd.ms-excel',
    'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'ppt': 'application/vnd.ms-powerpoint',
    'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',

    // 文本
    'txt': 'text/plain',
    'html': 'text/html',
    'css': 'text/css',
    'js': 'text/javascript',
    'json': 'application/json',
    'xml': 'application/xml',

    // 压缩文件
    'zip': 'application/zip',
    'rar': 'application/x-rar-compressed',
    '7z': 'application/x-7z-compressed',
    'tar': 'application/x-tar',
    'gz': 'application/gzip',

    // 其他
    'apk': 'application/vnd.android.package-archive',
    'exe': 'application/x-msdownload',
    'dll': 'application/x-msdownload',
  };

  return mimeTypeMap[extension.toLowerCase()] ?? 'application/octet-stream';
}

/// 根据MIME类型判断是否为可预览的文件
bool isPreviewableFile(String mimeType) {
  return mimeType.startsWith('image/') ||
      mimeType.startsWith('text/') ||
      mimeType == 'application/pdf';
}

/// 获取文件的简短名称（如果过长则截断）
String getShortFileName(String fileName, {int maxLength = 20}) {
  if (fileName.length <= maxLength) {
    return fileName;
  }

  final extension = fileName.contains('.')
      ? fileName.substring(fileName.lastIndexOf('.'))
      : '';

  final nameWithoutExtension = fileName.substring(
      0,
      fileName.length - extension.length
  );

  if (nameWithoutExtension.length <= maxLength - 3 - extension.length) {
    return nameWithoutExtension + extension;
  }

  return nameWithoutExtension.substring(
      0,
      maxLength - 3 - extension.length
  ) + '...' + extension;
}