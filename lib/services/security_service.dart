import 'dart:convert';
import 'package:common/model/stored_security_context.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 安全服务，管理加密相关的功能
class SecurityService {
  static final Logger _logger = Logger('SecurityService');
  static StoredSecurityContext? _securityContext;

  /// 初始化安全服务
  static Future<void> initialize() async {
    _logger.info('初始化安全服务');

    // 尝试从存储中加载证书
    await _loadSecurityContext();

    // 如果没有证书，生成一个新的
    if (_securityContext == null) {
      await _generateSecurityContext();
    }
  }

  /// 获取安全上下文
  static Future<StoredSecurityContext> getSecurityContext() async {
    if (_securityContext == null) {
      await initialize();
    }
    return _securityContext!;
  }

  /// 重置安全上下文（生成新的证书）
  static Future<StoredSecurityContext> resetSecurityContext() async {
    await _generateSecurityContext();
    return _securityContext!;
  }

  /// 生成安全上下文（证书和密钥）
  static Future<void> _generateSecurityContext() async {
    _logger.info('生成新的安全上下文');

    try {
      // 在实际应用中，这里应该使用适当的加密库生成适当的证书和密钥
      // 这里简化为使用UUID生成替代值

      final uuid = const Uuid();
      final privateKey = uuid.v4();
      final publicKey = uuid.v4();
      final certificate = '${privateKey}_${publicKey}';
      final certificateHash = sha256.convert(utf8.encode(certificate)).toString();

      _securityContext = StoredSecurityContext(
        privateKey: privateKey,
        publicKey: publicKey,
        certificate: certificate,
        certificateHash: certificateHash,
      );

      await _saveSecurityContext();
    } catch (e) {
      _logger.severe('生成安全上下文失败: $e');
      rethrow;
    }
  }

  /// 加载安全上下文
  static Future<void> _loadSecurityContext() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final securityContextJson = prefs.getString('security_context');

      if (securityContextJson != null) {
        final json = jsonDecode(securityContextJson);
        _securityContext = StoredSecurityContext.fromJson(json);
        _logger.info('已加载安全上下文，指纹: ${_securityContext!.certificateHash.substring(0, 8)}...');
      } else {
        _logger.info('未找到保存的安全上下文');
      }
    } catch (e) {
      _logger.severe('加载安全上下文失败: $e');
      _securityContext = null;
    }
  }

  /// 保存安全上下文
  static Future<void> _saveSecurityContext() async {
    if (_securityContext == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final json = _securityContext!.toJson();
      await prefs.setString('security_context', jsonEncode(json));
      _logger.info('已保存安全上下文，指纹: ${_securityContext!.certificateHash.substring(0, 8)}...');
    } catch (e) {
      _logger.severe('保存安全上下文失败: $e');
    }
  }
}