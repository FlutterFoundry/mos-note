import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final instanceUrl =
        StorageService.getString(AppConstants.memosInstanceKey) ?? '';
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(loc.profile)),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text(loc.notLoggedIn));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.15),
                      backgroundImage: user.avatarUrl?.isNotEmpty == true
                          ? NetworkImage('$instanceUrl${user.avatarUrl}')
                          : null,
                      child: user.avatarUrl?.isNotEmpty != true
                          ? Text(
                              user.displayNameValue[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayNameValue,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (user.email?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        user.email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role ?? 'USER',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Instance info
              _SectionHeader(title: loc.instance),
              _InfoTile(
                icon: Icons.link_rounded,
                label: loc.instanceUrl,
                value: instanceUrl,
              ),
              const SizedBox(height: 24),

              // Account info
              _SectionHeader(title: loc.account),
              _InfoTile(
                icon: Icons.person_outline_rounded,
                label: loc.username,
                value: user.username,
              ),
              if (user.description?.isNotEmpty == true)
                _InfoTile(
                  icon: Icons.info_outline_rounded,
                  label: loc.description,
                  value: user.description!,
                ),
              const SizedBox(height: 24),

              // Actions
              _SectionHeader(title: loc.settings),

              // Language selector
              ListTile(
                leading: Icon(Icons.language_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
                title: Text(loc.language),
                subtitle: Text(currentLocale.languageCode == 'id'
                    ? loc.indonesian
                    : loc.english),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final newLocale = await showDialog<Locale>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(loc.languageSettings),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('English'),
                            leading: Radio<String>(
                              value: 'en',
                              groupValue: currentLocale.languageCode,
                              onChanged: (v) =>
                                  Navigator.pop(context, const Locale('en')),
                            ),
                            onTap: () =>
                                Navigator.pop(context, const Locale('en')),
                          ),
                          ListTile(
                            title: const Text('Indonesia'),
                            leading: Radio<String>(
                              value: 'id',
                              groupValue: currentLocale.languageCode,
                              onChanged: (v) =>
                                  Navigator.pop(context, const Locale('id')),
                            ),
                            onTap: () =>
                                Navigator.pop(context, const Locale('id')),
                          ),
                        ],
                      ),
                    ),
                  );
                  if (newLocale != null) {
                    ref.read(localeProvider.notifier).setLocale(newLocale);
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),

              // Change Instance
              ListTile(
                leading: const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.textSecondary),
                title: Text(loc.changeInstance),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await StorageService.remove(AppConstants.memosInstanceKey);
                  await ref.read(authStateProvider.notifier).signOut();
                  if (context.mounted) context.go('/instance-setup');
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),

              // Sign out
              ListTile(
                leading:
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text(
                  loc.signOut,
                  style: const TextStyle(color: AppColors.error),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(loc.signOutConfirm),
                      content: Text(loc.signOutMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(loc.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            loc.signOut,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ref.read(authStateProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.cardBg;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
