import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/memo_model.dart';
import '../../../l10n/app_localizations.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? memoName;
  final String? initialContent;
  final List<AttachmentModel>? initialAttachments;

  const EditorScreen({
    super.key,
    this.memoName,
    this.initialContent,
    this.initialAttachments,
  });

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _saving = false;
  bool _showSlashMenu = false;
  bool _uploading = false;
  String _visibility = 'PRIVATE';
  List<AttachmentModel> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  final List<_MarkdownHelper> _helpersEn = const [
    _MarkdownHelper('h1', 'Heading 1', Icons.title_rounded, '# '),
    _MarkdownHelper('h2', 'Heading 2', Icons.text_fields_rounded, '## '),
    _MarkdownHelper('h3', 'Heading 3', Icons.text_fields_rounded, '### '),
    _MarkdownHelper('bold', 'Bold', Icons.format_bold_rounded, '**text**'),
    _MarkdownHelper('italic', 'Italic', Icons.format_italic_rounded, '_text_'),
    _MarkdownHelper('code', 'Inline Code', Icons.code_rounded, '`code`'),
    _MarkdownHelper(
        'codeblock', 'Code Block', Icons.code_rounded, '```\ncode\n```'),
    _MarkdownHelper('quote', 'Blockquote', Icons.format_quote_rounded, '> '),
    _MarkdownHelper(
        'ul', 'Bullet List', Icons.format_list_bulleted_rounded, '- '),
    _MarkdownHelper(
        'ol', 'Numbered List', Icons.format_list_numbered_rounded, '1. '),
    _MarkdownHelper(
        'task', 'Task', Icons.check_box_outline_blank_rounded, '- [ ] '),
    _MarkdownHelper('link', 'Link', Icons.link_rounded, '[text](url)'),
    _MarkdownHelper('hr', 'Divider', Icons.horizontal_rule_rounded, '\n---\n'),
    _MarkdownHelper('tag', 'Tag', Icons.tag_rounded, '#tag'),
    _MarkdownHelper('file', 'File', Icons.attach_file_rounded, ''),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
    _attachments = widget.initialAttachments ?? [];
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    if (cursor <= 0) {
      if (_showSlashMenu) setState(() => _showSlashMenu = false);
      return;
    }
    final lastChar = text.substring(cursor - 1, cursor);
    if (lastChar == '/') {
      setState(() => _showSlashMenu = true);
    } else if (_showSlashMenu) {
      final textBeforeCursor = text.substring(0, cursor);
      final lastSlash = textBeforeCursor.lastIndexOf('/');
      if (lastSlash == -1) {
        setState(() => _showSlashMenu = false);
      }
    }
  }

  void _insertMarkdown(_MarkdownHelper helper) {
    if (helper.id == 'file') {
      setState(() => _showSlashMenu = false);
      _pickFile();
      return;
    }

    setState(() => _showSlashMenu = false);
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;

    final lastSlash = text.lastIndexOf('/', cursor - 1);
    final before = lastSlash >= 0
        ? text.substring(0, lastSlash)
        : text.substring(0, cursor);
    final after = text.substring(cursor);
    final insertion = helper.markdown;
    final newText = '$before$insertion$after';

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: before.length + insertion.length,
      ),
    );
  }

  void _insertToolbarMarkdown(String prefix, String suffix) {
    final sel = _controller.selection;
    final text = _controller.text;
    if (!sel.isValid) return;
    final selectedText = sel.textInside(text);
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);
    final inserted = '$prefix$selectedText$suffix';
    _controller.value = TextEditingValue(
      text: '$before$inserted$after',
      selection:
          TextSelection.collapsed(offset: before.length + inserted.length),
    );
  }

  Future<void> _pickFile() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: null, // Don't compress - keep original
      );
      if (file != null) {
        await _uploadAttachment(File(file.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _uploadAttachment(File file) async {
    final online = await Connectivity().checkConnectivity();
    final isOffline =
        online.isEmpty || online.contains(ConnectivityResult.none);

    if (isOffline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot upload attachments while offline'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _uploading = true);

    try {
      final attachment =
          await ref.read(memosRepositoryProvider).uploadAttachment(file.path);

      setState(() {
        _attachments.add(attachment);
        _uploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attachment uploaded'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context)!;
    final content = _controller.text.trim();
    if (content.isEmpty) {
      context.pop();
      return;
    }
    setState(() => _saving = true);

    final connectivity = await Connectivity().checkConnectivity();
    final isOffline =
        connectivity.isEmpty || connectivity.contains(ConnectivityResult.none);

    try {
      String? memoName;
      if (widget.memoName != null) {
        await ref
            .read(memosProvider.notifier)
            .updateMemo(widget.memoName!, content);
        memoName = widget.memoName;
      } else {
        final memo = await ref
            .read(memosProvider.notifier)
            .createMemo(content, visibility: _visibility);
        memoName = memo.name;
      }

      // Handle attachments
      if (memoName != null) {
        final existingNames =
            widget.initialAttachments?.map((a) => a.name).toSet() ?? <String>{};
        final currentNames = _attachments.map((a) => a.name).toSet();

        // Only call setMemoAttachments if attachments changed
        if (existingNames != currentNames && _attachments.isNotEmpty) {
          await ref.read(memosRepositoryProvider).setMemoAttachments(
                memoName,
                _attachments.map((a) => a.name).toList(),
              );
        }

        // Always refresh memo to get latest from server
        await ref.read(memosRepositoryProvider).getMemo(memoName);
        // Invalidate providers to force refresh
        ref.invalidate(memosProvider);
        ref.invalidate(memoDetailProvider(memoName));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOffline ? loc.savedOffline : loc.saved),
            duration: const Duration(seconds: 2),
            backgroundColor:
                isOffline ? AppColors.textSecondary : AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(loc.failedToSave(e.toString())),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isEdit = widget.memoName != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.surface;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBg;
    final textColor = isDark ? AppColors.darkText : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? loc.editMemo : loc.newMemo),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _visibility,
            onSelected: (v) => setState(() => _visibility = v),
            icon: Icon(
              _visibility == 'PUBLIC'
                  ? Icons.public_rounded
                  : _visibility == 'PROTECTED'
                      ? Icons.people_rounded
                      : Icons.lock_rounded,
              color: textSecondary,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'PRIVATE', child: Text(loc.private)),
              PopupMenuItem(value: 'PROTECTED', child: Text(loc.protected)),
              PopupMenuItem(value: 'PUBLIC', child: Text(loc.public)),
            ],
          ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  )
                : Text(loc.save,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 44,
            color: surfaceColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _ToolbarButton(
                    icon: Icons.format_bold_rounded,
                    onTap: () => _insertToolbarMarkdown('**', '**'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_italic_rounded,
                    onTap: () => _insertToolbarMarkdown('_', '_'),
                  ),
                  _ToolbarButton(
                    icon: Icons.code_rounded,
                    onTap: () => _insertToolbarMarkdown('`', '`'),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_bulleted_rounded,
                    onTap: () => _insertToolbarMarkdown('- ', ''),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_list_numbered_rounded,
                    onTap: () => _insertToolbarMarkdown('1. ', ''),
                  ),
                  _ToolbarButton(
                    icon: Icons.check_box_outline_blank_rounded,
                    onTap: () => _insertToolbarMarkdown('- [ ] ', ''),
                  ),
                  _ToolbarButton(
                    icon: Icons.format_quote_rounded,
                    onTap: () => _insertToolbarMarkdown('> ', ''),
                  ),
                  _ToolbarButton(
                    icon: Icons.link_rounded,
                    onTap: () => _insertToolbarMarkdown('[', '](url)'),
                  ),
                  _ToolbarButton(
                    icon: Icons.tag_rounded,
                    onTap: () => _insertToolbarMarkdown('#', ''),
                  ),
                  _ToolbarButton(
                    icon: Icons.attach_file_rounded,
                    onTap: _pickFile,
                  ),
                ],
              ),
            ),
          ),
          if (_attachments.isNotEmpty)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final att = _attachments[index];
                  final instanceUrl =
                      StorageService.getString(AppConstants.memosInstanceKey) ??
                          '';
                  final attachmentId = att.name.split('/').last;
                  // Correct URL pattern: /file/attachments/{uid}/{filename}
                  final imageUrl =
                      '$instanceUrl/file/attachments/$attachmentId/${Uri.encodeComponent(att.filename ?? 'file')}';
                  final isImage = att.type?.startsWith('image/') == true;

                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: isImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  httpHeaders: {
                                    'Authorization':
                                        'Bearer ${StorageService.getString(AppConstants.accessTokenKey) ?? ''}',
                                  },
                                  placeholder: (ctx, url) => const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  errorWidget: (ctx, url, error) => Icon(
                                    Icons.broken_image_rounded,
                                    color: textSecondary,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.attach_file_rounded,
                                  color: textSecondary,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 4,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => _removeAttachment(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (_uploading)
            const LinearProgressIndicator(color: AppColors.primary),
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.writeMemo,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                if (_showSlashMenu)
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    left: 16,
                    right: 16,
                    child: _SlashMenu(
                      helpers: _helpersEn,
                      onSelect: _insertMarkdown,
                      onDismiss: () => setState(() => _showSlashMenu = false),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkdownHelper {
  final String id;
  final String label;
  final IconData icon;
  final String markdown;

  const _MarkdownHelper(this.id, this.label, this.icon, this.markdown);
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return IconButton(
      icon: Icon(icon, size: 20),
      color: iconColor,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(6),
    );
  }
}

class _SlashMenu extends StatelessWidget {
  final List<_MarkdownHelper> helpers;
  final ValueChanged<_MarkdownHelper> onSelect;
  final VoidCallback onDismiss;

  const _SlashMenu({
    required this.helpers,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final dividerColor = isDark ? Colors.white24 : AppColors.divider;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textHint = isDark ? AppColors.darkTextSecondary : AppColors.textHint;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Format',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: helpers.length,
                itemBuilder: (context, i) {
                  final h = helpers[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(h.icon, size: 18, color: AppColors.primary),
                    title: Text(h.label, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      h.markdown.length > 20
                          ? '${h.markdown.substring(0, 20)}...'
                          : h.markdown,
                      style: TextStyle(
                        fontSize: 11,
                        color: textHint,
                        fontFamily: 'monospace',
                      ),
                    ),
                    onTap: () => onSelect(h),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
