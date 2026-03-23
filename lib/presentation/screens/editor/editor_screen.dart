import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final String? memoName;
  final String? initialContent;

  const EditorScreen({super.key, this.memoName, this.initialContent});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _saving = false;
  bool _showSlashMenu = false;
  String _visibility = 'PRIVATE';

  final List<_MarkdownHelper> _helpers = const [
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
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialContent ?? '');
    _focusNode = FocusNode();
    _controller.addListener(_onTextChanged);
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
      // Check if the / before cursor is still present
      final textBeforeCursor = text.substring(0, cursor);
      final lastSlash = textBeforeCursor.lastIndexOf('/');
      if (lastSlash == -1) {
        setState(() => _showSlashMenu = false);
      }
    }
  }

  void _insertMarkdown(_MarkdownHelper helper) {
    setState(() => _showSlashMenu = false);
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;

    // Remove the '/' trigger
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

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      context.pop();
      return;
    }
    setState(() => _saving = true);

    // Check connectivity to decide on the snackbar message
    final connectivity = await Connectivity().checkConnectivity();
    final isOffline =
        connectivity.isEmpty || connectivity.contains(ConnectivityResult.none);

    try {
      if (widget.memoName != null) {
        await ref
            .read(memosProvider.notifier)
            .updateMemo(widget.memoName!, content);
      } else {
        await ref
            .read(memosProvider.notifier)
            .createMemo(content, visibility: _visibility);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isOffline ? 'Saved offline' : 'Saved'),
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
              content: Text('Failed to save: $e'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.memoName != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Memo' : 'New Memo'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Visibility toggle
          PopupMenuButton<String>(
            initialValue: _visibility,
            onSelected: (v) => setState(() => _visibility = v),
            icon: Icon(
              _visibility == 'PUBLIC'
                  ? Icons.public_rounded
                  : _visibility == 'PROTECTED'
                      ? Icons.people_rounded
                      : Icons.lock_rounded,
              color: AppColors.textSecondary,
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'PRIVATE', child: Text('Private')),
              const PopupMenuItem(value: 'PROTECTED', child: Text('Protected')),
              const PopupMenuItem(value: 'PUBLIC', child: Text('Public')),
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
                : const Text('Save',
                    style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Markdown toolbar
          Container(
            height: 44,
            color: AppColors.surface,
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
                ],
              ),
            ),
          ),
          // Editor
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
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Write your memo... (type / for formatting)',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ),
                // Slash command menu
                if (_showSlashMenu)
                  Positioned(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                    left: 16,
                    right: 16,
                    child: _SlashMenu(
                      helpers: _helpers,
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
    return IconButton(
      icon: Icon(icon, size: 20),
      color: AppColors.textSecondary,
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
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Format',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textSecondary,
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
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
