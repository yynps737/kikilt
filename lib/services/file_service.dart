import 'dart:io';

import 'package:common/model/file_type.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 文件服务，处理文件选择和保存
class FileService {
  final Logger _logger = Logger('FileService');

  /// 选择文件
  Future<List<FileInfo>> pickFiles({
    bool allowMultiple = true,
    List<String>? allowedExtensions,
    FileType? type,
  }) async {
    _logger.info('选择文件: allowMultiple=$allowMultiple, type=$type');

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: type != null ? FilePickerType.custom : FilePickerType.any,
        allowedExtensions: allowedExtensions,
        withData: kIsWeb, // Web平台需要直接获取数据
      );

      if (result == null || result.files.isEmpty) {
        _logger.info('未选择文件');
        return [];
      }

      return result.files.map((file) {
        final String? filePath = file.path;
        final Uint8List? fileBytes = file.bytes;
        final String fileName = file.name;
        final int fileSize = file.size;
        final String mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        final FileType fileType = _getFileTypeFromMime(mimeType);

        return FileInfo(
          id: const Uuid().v4(),
          name: fileName,
          path: filePath,
          bytes: fileBytes,
          size: fileSize,
          mimeType: mimeType,
          type: fileType,
        );
      }).toList();
    } catch (e) {
      _logger.severe('选择文件失败: $e');
      rethrow;
    }
  }

  /// 打开文件
  Future<bool> openFile(String filePath) async {
    _logger.info('打开文件: $filePath');

    try {
      if (kIsWeb) {
        _logger.warning('Web平台不支持直接打开文件');
        return false;
      }

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        _logger.warning('打开文件失败: ${result.message}');
        return false;
      }

      return true;
    } catch (e) {
      _logger.severe('打开文件失败: $e');
      return false;
    }
  }

  /// 获取下载目录
  Future<String> getDownloadDirectory() async {
    try {
      if (kIsWeb) {
        // Web平台没有文件系统概念
        throw UnsupportedError('Web平台不支持获取下载目录');
      }

      if (Platform.isAndroid) {
        // Android平台使用外部存储目录
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          return path.join(externalDir.path, 'KikiLt', 'Downloads');
        }

        // 备选：使用应用文档目录
        final dir = await getApplicationDocumentsDirectory();
        return path.join(dir.path, 'Downloads');
      } else {
        // 其他平台使用下载目录
        final dir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        return path.join(dir.path, 'KikiLt');
      }
    } catch (e) {
      _logger.severe('获取下载目录失败: $e');

      // 备选：使用临时目录
      final tempDir = await getTemporaryDirectory();
      return path.join(tempDir.path, 'KikiLt', 'Downloads');
    }
  }

  /// 确保目录存在
  Future<Directory> ensureDirectoryExists(String dirPath) async {
    final directory = Directory(dirPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// 获取文件大小
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      return await file.length();
    } catch (e) {
      _logger.warning('获取文件大小失败: $e');
      return 0;
    }
  }

  /// 获取文件的MIME类型
  String getMimeType(String filePath) {
    return lookupMimeType(filePath) ?? 'application/octet-stream';
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