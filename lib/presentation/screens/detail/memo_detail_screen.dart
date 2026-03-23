import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class MemoDetailScreen extends ConsumerWidget {
  final String memoName;

  const MemoDetailScreen({super.key, required this.memoName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final memoAsync = ref.watch(memoDetailProvider(memoName));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBg;
    final textColor = isDark ? AppColors.darkText : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return memoAsync.when(
      data: (memo) {
        if (memo == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(loc.memoNotFound)),
          );
        }

        final html = md.markdownToHtml(
          memo.content,
          extensionSet: md.ExtensionSet.gitHubFlavored,
        );

        final dateStr = memo.displayTime != null
            ? timeago.format(
                DateTime.tryParse(memo.displayTime!) ?? DateTime.now(),
                locale: locale.languageCode)
            : '';

        return Scaffold(
          appBar: AppBar(
            title: Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () =>
                    _showShareOptions(context, memo.content, memo.name),
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
                        title: Text(loc.deleteMemo),
                        content: Text(loc.deleteMemoConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              loc.delete,
                              style: const TextStyle(color: AppColors.error),
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
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      const Icon(Icons.edit_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(loc.edit),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      const Icon(Icons.delete_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text(loc.delete,
                          style: const TextStyle(color: AppColors.error)),
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
                if (memo.attachments?.isNotEmpty == true) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: memo.attachments!.map((att) {
                      final instanceUrl = StorageService.getString(
                              AppConstants.memosInstanceKey) ??
                          '';
                      final attachmentId = att.name.split('/').last;
                      final imageUrl =
                          '$instanceUrl/file/$attachmentId/${Uri.encodeComponent(att.filename ?? 'file')}';
                      final isImage = att.type?.startsWith('image/') == true;

                      if (isImage) {
                        return GestureDetector(
                          onTap: () => _showFullScreenImage(
                              context, imageUrl, att.filename ?? 'image'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              httpHeaders: {
                                'Authorization':
                                    'Bearer ${StorageService.getString(AppConstants.accessTokenKey) ?? ''}',
                              },
                              placeholder: (ctx, url) => Container(
                                width: 120,
                                height: 120,
                                color: cardBg,
                                child: const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (ctx, url, error) => Container(
                                width: 120,
                                height: 120,
                                color: cardBg,
                                child: Icon(Icons.broken_image_rounded,
                                    color: textSecondary),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white24
                                    : AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.attach_file_rounded,
                                  size: 16, color: textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                att.filename ?? 'attachment',
                                style: TextStyle(
                                    fontSize: 12, color: textSecondary),
                              ),
                            ],
                          ),
                        );
                      }
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
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
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        memo.visibility ?? 'PRIVATE',
                        style: TextStyle(fontSize: 11, color: textSecondary),
                      ),
                    ),
                    const Spacer(),
                    Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 16),
                Html(
                  data: html,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(15),
                      lineHeight: LineHeight(1.7),
                      color: textColor,
                    ),
                    'h1': Style(
                      fontSize: FontSize(22),
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    'h2': Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    'h3': Style(
                      fontSize: FontSize(16),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    'code': Style(
                      backgroundColor: cardBg,
                      fontSize: FontSize(13),
                      fontFamily: 'monospace',
                      color: isDark
                          ? const Color(0xFFFF8C6B)
                          : AppColors.primaryDark,
                    ),
                    'pre': Style(
                      backgroundColor: cardBg,
                      padding: HtmlPaddings.all(12),
                    ),
                    'blockquote': Style(
                      color: textSecondary,
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

  void _showShareOptions(BuildContext context, String content, String name) {
    final instanceUrl =
        StorageService.getString(AppConstants.memosInstanceKey) ?? '';
    final memoId = name.split('/').last;
    final deepLink = '$instanceUrl/m/$memoId';

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.content_copy_rounded),
              title: Text(AppLocalizations.of(context).shareContentAndLink),
              onTap: () {
                Navigator.pop(ctx);
                Share.share('$content\n\n$deepLink');
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_rounded),
              title: Text(AppLocalizations.of(context).shareLinkOnly),
              onTap: () {
                Navigator.pop(ctx);
                Share.share(deepLink);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(
      BuildContext context, String imageUrl, String filename) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              filename,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Center(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              httpHeaders: {
                'Authorization':
                    'Bearer ${StorageService.getString(AppConstants.accessTokenKey) ?? ''}',
              },
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.broken_image_rounded,
                    color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
