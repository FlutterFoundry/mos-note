import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_service.dart';

class MemoDetailScreen extends ConsumerWidget {
  final String memoName;

  const MemoDetailScreen({super.key, required this.memoName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memoAsync = ref.watch(memoDetailProvider(memoName));

    return memoAsync.when(
      data: (memo) {
        if (memo == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Memo not found')),
          );
        }

        final html = md.markdownToHtml(
          memo.content,
          extensionSet: md.ExtensionSet.gitHubFlavored,
        );

        final dateStr = memo.displayTime != null
            ? timeago
                .format(DateTime.tryParse(memo.displayTime!) ?? DateTime.now())
            : '';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _share(memo.content, memo.name),
              ),
              IconButton(
                icon: const Icon(Icons.comment_rounded),
                onPressed: () => context
                    .push('/memo/${Uri.encodeComponent(memoName)}/comments'),
              ),
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    context.push(
                      '/editor/${Uri.encodeComponent(memoName)}',
                      extra: {'content': memo.content},
                    );
                  } else if (v == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete memo'),
                        content: const Text('This action cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(memosProvider.notifier)
                          .deleteMemo(memoName);
                      if (context.mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_rounded,
                          size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metadata row
                Row(
                  children: [
                    if (memo.pinned == true) ...[
                      const Icon(Icons.push_pin_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        memo.visibility ?? 'PRIVATE',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 16),
                // Rendered HTML
                Html(
                  data: html,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(15),
                      lineHeight: LineHeight(1.7),
                      color: AppColors.textPrimary,
                    ),
                    'h1': Style(
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    'h2': Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    'h3': Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    'code': Style(
                      backgroundColor: AppColors.cardBg,
                      fontSize: FontSize(13),
                      fontFamily: 'monospace',
                      color: AppColors.primaryDark,
                    ),
                    'pre': Style(
                      backgroundColor: AppColors.cardBg,
                      padding: HtmlPaddings.all(12),
                    ),
                    'blockquote': Style(
                      color: AppColors.textSecondary,
                      border: const Border(
                        left: BorderSide(color: AppColors.primary, width: 3),
                      ),
                      padding: HtmlPaddings.only(left: 12),
                      margin: Margins.only(left: 0, top: 8, bottom: 8),
                    ),
                    'a': Style(color: AppColors.primary),
                  },
                ),
                const SizedBox(height: 24),
                // Tags
                if (memo.tags?.isNotEmpty == true)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (memo.tags ?? [])
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '#${t.name}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  void _share(String content, String name) {
    final instanceUrl =
        StorageService.getString(AppConstants.memosInstanceKey) ?? '';
    final memoId = name.split('/').last;
    final deepLink = '$instanceUrl/m/$memoId';
    Share.share('$content\n\n$deepLink');
  }
}
