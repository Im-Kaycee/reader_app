import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/feed_sources.dart';
import '../../../state/feed_provider.dart';
import '../../../ui/theme/app_theme.dart';
import '../../../ui/widgets/brut_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutedSources = ref.watch(mutedSourcesProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Group feeds by category
    final grouped = <String, List<FeedSource>>{};
    for (final source in kFeedSources) {
      grouped.putIfAbsent(source.category, () => []).add(source);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SETTINGS.', style: AppTextStyles.headline),
                  const SizedBox(height: 4),
                  const Text(
                    'Toggle feeds on or off.',
                    style: AppTextStyles.muted,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(height: 2, color: AppColors.ink),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  // Theme selector
                  const Text('APPEARANCE', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  BrutCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Theme',
                          style: Theme.of(context).brightness == Brightness.dark
                              ? AppTextStyles.cardTitle.copyWith(color: AppColors.darkInk)
                              : AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ThemeButton(
                              label: 'LIGHT',
                              icon: Icons.light_mode,
                              selected: themeMode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.light),
                            ),
                            const SizedBox(width: 8),
                            _ThemeButton(
                              label: 'DARK',
                              icon: Icons.dark_mode,
                              selected: themeMode == ThemeMode.dark,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.dark),
                            ),
                            const SizedBox(width: 8),
                            _ThemeButton(
                              label: 'SYSTEM',
                              icon: Icons.phone_android,
                              selected: themeMode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setMode(ThemeMode.system),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...grouped.entries.map((entry) {
                    final category = entry.key;
                    final sources = entry.value;
                    final accent = AppColors.forCategory(category);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category header
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              color: accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.toUpperCase(),
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Sources in this category
                        ...sources.map((source) {
                          final isMuted =
                              mutedSources.contains(source.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: BrutCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              backgroundColor: isMuted
                                  ? AppColors.paper
                                  : AppColors.white,
                              child: Row(
                                children: [
                                  // Source info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          source.displayName,
                                          style: AppTextStyles.cardTitle
                                              .copyWith(
                                            fontSize: 14,
                                            color: isMuted
                                                ? const Color(0xFF999999)
                                                : AppColors.ink,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          source.url,
                                          style:
                                              AppTextStyles.muted.copyWith(
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // Toggle
                                  GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(mutedSourcesProvider
                                              .notifier)
                                          .toggle(source.id);
                                      // Refresh feed to reflect change
                                      ref.invalidate(feedProvider);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isMuted
                                            ? AppColors.cream
                                            : AppColors.ink,
                                        border: Border.all(
                                          color: AppColors.ink, width: 2,
                                        ),
                                        boxShadow: isMuted
                                            ? null
                                            : const [
                                                BoxShadow(
                                                  color: AppColors.ink,
                                                  offset: Offset(2, 2),
                                                  blurRadius: 0,
                                                ),
                                              ],
                                      ),
                                      child: Text(
                                        isMuted ? 'MUTED' : 'ON',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                          color: isMuted
                                              ? AppColors.ink
                                              : AppColors.cream,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),
                      ],
                    );
                  }),

                  // About
                  Container(height: 2, color: AppColors.ink),
                  const SizedBox(height: 24),
                  const Text('ABOUT', style: AppTextStyles.label),
                  const SizedBox(height: 12),
                  BrutCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reader', style: AppTextStyles.cardTitle),
                        const SizedBox(height: 4),
                        const Text(
                          'Your personal corner of the internet.',
                          style: AppTextStyles.muted,
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: AppColors.paper),
                        const SizedBox(height: 12),
                        const Text(
                          'Version 1.0.0',
                          style: AppTextStyles.muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inkColor = isDark ? AppColors.darkInk : AppColors.ink;
    final bgColor = isDark ? AppColors.darkBg : AppColors.cream;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? inkColor : bgColor,
            border: Border.all(color: inkColor, width: 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.tech,
                      offset: const Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? bgColor : inkColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: selected ? bgColor : inkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
