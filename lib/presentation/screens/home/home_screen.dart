import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/memo_model.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _search = '';
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final memosState = ref.watch(memosProvider);
    final tagsState = ref.watch(tagsProvider);
    final auth = ref.watch(authStateProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final connectivity = ref.watch(connectivityProvider);
    final isOffline = connectivity.when(
      data: (online) => !online,
      loading: () => false,
      error: (_, __) => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          // Sync button with pending-ops badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: syncStatus.isSyncing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.sync_rounded),
                onPressed: syncStatus.isSyncing
                    ? null
                    : () async {
                        // First flush any pending ops, then do a full sync
                        final flushed = await ref
                            .read(memosProvider.notifier)
                            .processPendingOps();
                        await ref.read(memosProvider.notifier).sync();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(flushed > 0
                                  ? loc.syncedPending(flushed)
                                  : loc.synced),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
              ),
              if (syncStatus.pendingCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 14, minHeight: 14),
                      child: Text(
                        '${syncStatus.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: auth.when(
                data: (user) => CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    (user?.displayName.isNotEmpty == true
                        ? user!.displayName[0].toUpperCase()
                        : 'U'),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                loading: () => const SizedBox(width: 36),
                error: (_, __) => const Icon(Icons.person_rounded),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          if (isOffline)
            Container(
              width: double.infinity,
              color: AppColors.textSecondary.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      syncStatus.pendingCount > 0
                          ? '${loc.offline} — ${syncStatus.pendingCount} ${loc.pendingSync}'
                          : '${loc.offline} — ${loc.showingCached}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: loc.searchMemos,
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.textHint),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          // Tags filter
          tagsState.when(
            data: (tags) => tags.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _TagChip(
                          label: loc.all,
                          selected: _selectedTag == null,
                          onTap: () => setState(() => _selectedTag = null),
                        ),
                        ...tags.entries.map((e) => _TagChip(
                              label: '#${e.key} (${e.value})',
                              selected: _selectedTag == e.key,
                              onTap: () => setState(() => _selectedTag = e.key),
                            )),
                      ],
                    ),
                  ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 8),
          // Grid
          Expanded(
            child: memosState.when(
              data: (memos) {
                var filtered = memos;
                if (_search.isNotEmpty) {
                  filtered = memos
                      .where((m) => m.content
                          .toLowerCase()
                          .contains(_search.toLowerCase()))
                      .toList();
                }
                if (_selectedTag != null) {
                  filtered = filtered
                      .where((m) =>
                          m.tags?.any((t) => t.name == _selectedTag) == true ||
                          m.content.contains('#$_selectedTag'))
                      .toList();
                }
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.note_alt_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          _search.isEmpty ? loc.noMemos : loc.noResults,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        if (_search.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            loc.createFirst,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textHint),
                          ),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(memosProvider.notifier).loadMemos(refresh: true),
                  child: MasonryGridView.count(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => MemoCard(
                        memo: filtered[index],
                        loc: loc,
                        localeCode: locale.languageCode),
                  ),
                );
              },
              loading: () => _buildShimmer(),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(loc.failedToLoad,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref
                          .read(memosProvider.notifier)
                          .loadMemos(refresh: true),
                      child: Text(loc.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/editor'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildShimmer() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark ? AppColors.darkCard : AppColors.cardBg;
    final shimmerHighlight = isDark ? AppColors.darkSurface : Colors.white;

    return Shimmer.fromColors(
      baseColor: shimmerBase,
      highlightColor: shimmerHighlight,
      child: MasonryGridView.count(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: 8,
        itemBuilder: (context, index) => Container(
          height: index.isEven ? 140 : 100,
          decoration: BoxDecoration(
            color: shimmerHighlight,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class MemoCard extends StatelessWidget {
  final MemoModel memo;
  final AppLocalizations loc;
  final String localeCode;
  const MemoCard(
      {super.key,
      required this.memo,
      required this.loc,
      required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBg;
    final textColor = isDark ? AppColors.darkText : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final preview = memo.snippet ?? _getPreview(memo.content);
    final tags = _extractTags(memo.content);
    final dateStr = memo.displayTime != null
        ? timeago.format(DateTime.tryParse(memo.displayTime!) ?? DateTime.now(),
            locale: localeCode)
        : '';
    // Detect local-only memos by their temp name prefix
    final isLocalOnly = memo.id.startsWith('local_');

    return GestureDetector(
      onTap: () => context.push('/memo/${Uri.encodeComponent(memo.name)}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: isLocalOnly
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (memo.pinned == true)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Icon(Icons.push_pin_rounded,
                    size: 14, color: AppColors.primary),
              ),
            if (isLocalOnly)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off_rounded,
                        size: 11, color: AppColors.primary),
                    const SizedBox(width: 3),
                    Text(
                      loc.savedOffline,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              preview,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: textColor),
            ),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: tags
                    .take(3)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              dateStr,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _getPreview(String content) {
    return content
        .replaceAll(RegExp(r'#{1,6}\s'), '')
        .replaceAll(RegExp(r'\*+'), '')
        .replaceAll(RegExp(r'`+'), '')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .trim();
  }

  List<String> _extractTags(String content) {
    final matches = RegExp(r'#(\w+)').allMatches(content);
    return matches.map((m) => m.group(1)!).toSet().toList();
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = isDark ? AppColors.darkCard : AppColors.cardBg;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : chipBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
