import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/widgets/animated_button.dart';

/// 添加设备对话框
class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({Key? key}) : super(key: key);

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController(text: '53317'); // 默认端口

  String? _ipError;
  String? _portError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  /// 提交表单
  void _submitForm() {
    if (_isSubmitting) return;

    // 验证表单
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final String ip = _ipController.text.trim();
      final int port = int.tryParse(_portController.text.trim()) ?? 53317;

      // 返回结果
      Navigator.of(context).pop((ip, port));
    }
  }

  /// 验证IP地址
  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入IP地址';
    }

    // 简单验证IP格式
    final RegExp ipRegex = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    );

    if (!ipRegex.hasMatch(value)) {
      return 'IP地址格式无效';
    }

    // 验证IP地址范围
    final parts = value.split('.');
    for (var part in parts) {
      final int? num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'IP地址范围无效';
      }
    }

    return null;
  }

  /// 验证端口
  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入端口';
    }

    final int? port = int.tryParse(value);
    if (port == null) {
      return '端口必须是数字';
    }

    if (port < 1 || port > 65535) {
      return '端口范围无效 (1-65535)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        '添加设备',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明文本
              Text(
                '请输入要连接的设备IP地址和端口',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // IP地址
              Text(
                'IP地址',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  hintText: '192.168.1.100',
                  errorText: _ipError,
                  prefixIcon: Icon(
                    Icons.wifi,
                    color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: _validateIp,
                onChanged: (value) {
                  if (_ipError != null) {
                    setState(() {
                      _ipError = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // 端口
              Text(
                '端口',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  hintText: '53317',
                  errorText: _portError,
                  prefixIcon: Icon(
                    Icons.settings_ethernet,
                    color: isDarkMode ? AppColors.iconDark : AppColors.iconLight,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: _validatePort,
                onChanged: (value) {
                  if (_portError != null) {
                    setState(() {
                      _portError = null;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '取消',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
        ),
        AnimatedButton(
          text: '添加',
          icon: Icons.add,
          onPressed: _submitForm,
          isLoading: _isSubmitting,
          width: 100,
          height: 40,
          borderRadius: 12,
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      clipBehavior: Clip.antiAlias,
    );
  }
}