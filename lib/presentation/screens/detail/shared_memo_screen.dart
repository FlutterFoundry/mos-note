import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_service.dart';

class SharedMemoScreen extends ConsumerWidget {
  final String shareId;

  const SharedMemoScreen({super.key, required this.shareId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final memoAsync = ref.watch(sharedMemoProvider(shareId));
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
            body: const Center(
                child: Text('Memo not found or share link expired')),
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
                          '$instanceUrl/file/attachments/$attachmentId/${Uri.encodeComponent(att.filename ?? 'file')}';
                      final isImage = att.type?.startsWith('image/') == true;

                      if (isImage) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) => Container(
                              width: 120,
                              height: 120,
                              color: AppColors.cardBg,
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (ctx, url, error) => Container(
                              width: 120,
                              height: 120,
                              color: AppColors.cardBg,
                              child: const Icon(Icons.broken_image_rounded,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.attach_file_rounded,
                                  size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                att.filename ?? 'attachment',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
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
}
