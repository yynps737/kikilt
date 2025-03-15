import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kikilt/app/providers/app_providers.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/constants/theme.dart';
import 'package:kikilt/features/settings/widgets/section_title.dart';
import 'package:kikilt/features/settings/widgets/setting_item.dart';
import 'package:kikilt/features/settings/widgets/setting_switch.dart';
import 'package:kikilt/features/settings/widgets/setting_text_field.dart';
import 'package:kikilt/services/device_service.dart';
import 'package:kikilt/services/security_service.dart';
import 'package:kikilt/utils/ui_utils.dart';
import 'package:refena_flutter/refena_flutter.dart';

/// 应用设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  bool _isHttps = true;
  bool _allowDownload = true;
  bool _autoStart = false;
  bool _saveReceivedFiles = true;

  late ThemeMode _themeMode;
  String _fingerprint = '';

  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _portController.dispose();
    super.dispose();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 加载设备服务设置
      final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
      final alias = await deviceService.getAlias();
      final port = deviceService.port;
      final protocol = deviceService.protocol;
      final download = deviceService.download;

      // 加载主题设置
      final themeNotifier = RefenaScope.of(context).read(themeProvider);
      final themeMode = themeNotifier.state;

      // 加载安全上下文
      final securityContext = await SecurityService.getSecurityContext();
      final fingerprint = securityContext.certificateHash;

      // 设置控制器和状态
      _aliasController.text = alias;
      _portController.text = port.toString();
      _isHttps = protocol == ProtocolType.https;
      _allowDownload = download;
      _themeMode = themeMode;

      // 设置指纹（只显示前8位 + ... + 后8位）
      if (fingerprint.length > 16) {
        _fingerprint = fingerprint.substring(0, 8) + '...' +
            fingerprint.substring(fingerprint.length - 8);
      } else {
        _fingerprint = fingerprint;
      }

      // 从SharedPreferences加载其他设置
      // 这些仅作为示例，未真正实现持久化
      _autoStart = false;
      _saveReceivedFiles = true;
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, '加载设置失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 保存设备别名
  Future<void> _saveAlias() async {
    if (_isUpdating) return;

    final alias = _aliasController.text.trim();
    if (alias.isEmpty) {
      UiUtils.showErrorSnackBar(context, '设备名称不能为空');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // 保存别名
      final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
      await deviceService.setAlias(alias);

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, '设备名称已更新');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, '保存设备名称失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  /// 保存端口
  Future<void> _savePort() async {
    if (_isUpdating) return;

    final portText = _portController.text.trim();
    final port = int.tryParse(portText);

    if (port == null || port < 1024 || port > 65535) {
      UiUtils.showErrorSnackBar(context, '端口必须是1024-65535之间的数字');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      // 保存端口
      final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
      await deviceService.setPort(port);

      if (mounted) {
        UiUtils.showSuccessSnackBar(context, '端口已更新，需要重启服务生效');
      }
    } catch (e) {
      if (mounted) {
        UiUtils.showErrorSnackBar(context, '保存端口失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  /// 更新协议
  Future<void> _updateProtocol(bool useHttps) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _isHttps = useHttps;
    });

    try {
      // 保存协议设置
      final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
      await deviceService.setProtocol(useHttps ? ProtocolType.https : ProtocolType.http);

      if (mounted) {
        UiUtils.showSuccessSnackBar(
            context,
            '已${useHttps ? '启用' : '禁用'}HTTPS，需要重启服务生效'
        );
      }
    } catch (e) {
      if (mounted) {
        // 恢复状态
        setState(() {
          _isHttps = !useHttps;
        });
        UiUtils.showErrorSnackBar(context, '更新协议设置失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  /// 更新下载设置
  Future<void> _updateDownloadSetting(bool allowDownload) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _allowDownload = allowDownload;
    });

    try {
      // 保存下载设置
      final deviceService = RefenaScope.of(context).read(deviceServiceProvider);
      await deviceService.setDownload(allowDownload);

      if (mounted) {
        UiUtils.showSuccessSnackBar(
            context,
            '已${allowDownload ? '允许' : '禁止'}其他设备从此设备下载文件'
        );
      }
    } catch (e) {
      if (mounted) {
        // 恢复状态
        setState(() {
          _allowDownload = !allowDownload;
        });
        UiUtils.showErrorSnackBar(context, '更新下载设置失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  /// 更新自动启动设置
  void _updateAutoStartSetting(bool autoStart) {
    setState(() {
      _autoStart = autoStart;
    });

    // 这里应该实现真正的持久化，仅作为示例
    UiUtils.showSnackBar(
      context,
      '已${autoStart ? '启用' : '禁用'}应用启动时自动启动服务',
    );
  }

  /// 更新保存接收文件设置
  void _updateSaveReceivedFilesSetting(bool saveFiles) {
    setState(() {
      _saveReceivedFiles = saveFiles;
    });

    // 这里应该实现真正的持久化，仅作为示例
    UiUtils.showSnackBar(
      context,
      '已${saveFiles ? '启用' : '禁用'}自动保存接收的文件',
    );
  }

  /// 重置安全上下文
  Future<void> _resetSecurityContext() async {
    final confirmed = await UiUtils.showConfirmDialog(
      context: context,
      title: '重置安全证书',
      content: '此操作将生成新的安全证书，会导致之前收藏的设备无法连接。确定要继续吗？',
      confirmText: '重置',
      cancelText: '取消',
      confirmColor: AppColors.error,
    );

    if (confirmed) {
      setState(() {
        _isUpdating = true;
      });

      try {
        // 重置安全上下文
        final newContext = await SecurityService.resetSecurityContext();

        setState(() {
          _fingerprint = newContext.certificateHash.substring(0, 8) + '...' +
              newContext.certificateHash.substring(newContext.certificateHash.length - 8);
        });

        if (mounted) {
          UiUtils.showSuccessSnackBar(context, '安全证书已重置');
        }
      } catch (e) {
        if (mounted) {
          UiUtils.showErrorSnackBar(context, '重置安全证书失败: $e');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    }
  }

  /// 切换主题
  void _toggleTheme() {
    final themeNotifier = RefenaScope.of(context).read(themeProvider);

    if (_themeMode == ThemeMode.light) {
      themeNotifier.setThemeMode(ThemeMode.dark);
      setState(() {
        _themeMode = ThemeMode.dark;
      });
    } else {
      themeNotifier.setThemeMode(ThemeMode.light);
      setState(() {
        _themeMode = ThemeMode.light;
      });
    }
  }

  /// 导航到关于页面
  void _navigateToAbout() {
    context.push('/about');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备设置
            const SectionTitle(title: '设备设置'),
            SettingTextField(
              title: '设备名称',
              controller: _aliasController,
              hintText: '输入设备名称',
              icon: Icons.devices,
              onSubmitted: (_) => _saveAlias(),
              suffix: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveAlias,
                tooltip: '保存',
              ),
            ),
            SettingTextField(
              title: '端口',
              controller: _portController,
              hintText: '输入端口号 (1024-65535)',
              icon: Icons.settings_ethernet,
              keyboardType: TextInputType.number,
              onSubmitted: (_) => _savePort(),
              suffix: IconButton(
                icon: const Icon(Icons.save),
                onPressed: _savePort,
                tooltip: '保存',
              ),
            ),
            SettingSwitch(
              title: '使用HTTPS',
              subtitle: '加密传输，提高安全性',
              icon: Icons.https,
              value: _isHttps,
              onChanged: _updateProtocol,
            ),
            SettingSwitch(
              title: '允许下载',
              subtitle: '允许其他设备从此设备下载文件',
              icon: Icons.download,
              value: _allowDownload,
              onChanged: _updateDownloadSetting,
            ),

            const SizedBox(height: 16),

            // 应用设置
            const SectionTitle(title: '应用设置'),
            SettingSwitch(
              title: '自动启动服务',
              subtitle: '应用启动时自动启动接收服务',
              icon: Icons.play_circle_outline,
              value: _autoStart,
              onChanged: _updateAutoStartSetting,
            ),
            SettingSwitch(
              title: '保存接收的文件',
              subtitle: '自动保存接收的文件到下载目录',
              icon: Icons.save,
              value: _saveReceivedFiles,
              onChanged: _updateSaveReceivedFilesSetting,
            ),
            SettingItem(
              title: '主题',
              subtitle: _themeMode == ThemeMode.light ? '浅色模式' : '深色模式',
              icon: _themeMode == ThemeMode.light
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
              trailing: Switch(
                value: _themeMode == ThemeMode.dark,
                onChanged: (_) => _toggleTheme(),
                activeColor: AppColors.primaryPink,
              ),
              onTap: _toggleTheme,
            ),

            const SizedBox(height: 16),

            // 安全设置
            const SectionTitle(title: '安全设置'),
            SettingItem(
              title: '设备指纹',
              subtitle: _fingerprint,
              icon: Icons.fingerprint,
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _resetSecurityContext,
                tooltip: '重置',
              ),
            ),

            const SizedBox(height: 16),

            // 关于
            const SectionTitle(title: '关于'),
            SettingItem(
              title: '关于 KikiLt',
              subtitle: '版本 1.0.0',
              icon: Icons.info_outline,
              trailing: const Icon(Icons.chevron_right),
              onTap: _navigateToAbout,
            ),
          ],
        ),
      ),
    );
  }
}