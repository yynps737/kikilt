import 'package:flutter/material.dart';
import 'package:kikilt/constants/colors.dart';
import 'package:kikilt/utils/file_utils.dart';
import 'package:kikilt/utils/ui_utils.dart';

/// 文件项组件
class FileItem extends StatelessWidget {
  /// 文件信息
  final FileInfo file;

  /// 选择状态
  final bool isSelected;

  /// 点击回调
  final VoidCallback? onTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 是否可删除
  final bool isDeletable;

  /// 自定义尾部组件
  final Widget? trailing;

  /// 自定义前置组件
  final Widget? leading;

  /// 是否显示文件大小
  final bool showFileSize;

  const FileItem({
    Key? key,
    required this.file,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.isDeletable = false,
    this.trailing,
    this.leading,
    this.showFileSize = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 获取文件类型颜色
    final Color typeColor = UiUtils.getFileTypeColor(file.mimeType);

    // 获取文件类型图标
    IconData typeIcon;
    if (file.isImage) {
      typeIcon = Icons.image;
    } else if (file.isVideo) {
      typeIcon = Icons.videocam;
    } else if (file.isPdf) {
      typeIcon = Icons.picture_as_pdf;
    } else if (file.isText) {
      typeIcon = Icons.text_snippet;
    } else if (file.isApk) {
      typeIcon = Icons.android;
    } else {
      typeIcon = Icons.insert_drive_file;
    }

    return Card(
      color: isSelected
          ? (isDarkMode ? AppColors.primaryPinkDark.withOpacity(0.2) : AppColors.primaryPink.withOpacity(0.1))
          : (isDarkMode ? AppColors.cardDark : Colors.white),
      elevation: 2,
      shadowColor: isDarkMode ? AppColors.shadowDark : AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: isDarkMode ? AppColors.primaryPinkDark : AppColors.primaryPink, width: 1.5)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // 前置组件或文件类型图标
              leading ?? Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  typeIcon,
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // 文件信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showFileSize) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            file.sizeFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            file.typeText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 尾部组件或删除按钮
              trailing ?? (isDeletable ? IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close),
                color: theme.iconTheme.color?.withOpacity(0.7),
                visualDensity: VisualDensity.compact,
                iconSize: 20,
              ) : isSelected ? const Icon(
                Icons.check_circle,
                color: AppColors.primaryPink,
                size: 22,
              ) : const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

/// 文件项列表
class FileItemList extends StatelessWidget {
  /// 文件列表
  final List<FileInfo> files;

  /// 选择的文件ID列表
  final List<String> selectedFileIds;

  /// 点击回调
  final ValueChanged<FileInfo>? onItemTap;

  /// 长按回调
  final ValueChanged<FileInfo>? onItemLongPress;

  /// 删除回调
  final ValueChanged<FileInfo>? onItemDelete;

  /// 是否可删除
  final bool isDeletable;

  /// 是否显示文件大小
  final bool showFileSize;

  /// 列表填充
  final EdgeInsetsGeometry padding;

  /// 列表间距
  final double itemSpacing;

  /// 空列表提示
  final Widget? emptyWidget;

  const FileItemList({
    Key? key,
    required this.files,
    this.selectedFileIds = const [],
    this.onItemTap,
    this.onItemLongPress,
    this.onItemDelete,
    this.isDeletable = false,
    this.showFileSize = true,
    this.padding = const EdgeInsets.all(16),
    this.itemSpacing = 8,
    this.emptyWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return emptyWidget ?? const Center(
        child: Text('没有文件'),
      );
    }

    return ListView.separated(
      padding: padding,
      itemCount: files.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) {
        final file = files[index];
        final isSelected = selectedFileIds.contains(file.id);

        return FileItem(
          file: file,
          isSelected: isSelected,
          onTap: onItemTap != null ? () => onItemTap!(file) : null,
          onLongPress: onItemLongPress != null ? () => onItemLongPress!(file) : null,
          onDelete: onItemDelete != null ? () => onItemDelete!(file) : null,
          isDeletable: isDeletable,
          showFileSize: showFileSize,
        );
      },
    );
  }
}

/// 空文件列表提示组件
class EmptyFileList extends StatelessWidget {
  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 按钮文本
  final String? buttonText;

  /// 按钮点击回调
  final VoidCallback? onButtonPressed;

  /// 是否显示图片
  final bool showImage;

  /// 图片资源路径
  final String? imagePath;

  const EmptyFileList({
    Key? key,
    this.title = '没有文件',
    this.description = '点击下方按钮选择文件',
    this.buttonText,
    this.onButtonPressed,
    this.showImage = true,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Image.asset(
                  imagePath ?? 'assets/images/empty_files.png',
                  width: 180,
                  height: 180,
                ),
              ),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}