import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/connectivity_provider.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    return connectivity.when(
      data: (isOnline) => isOnline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8,
              ),
              color: AppColors.ink,
              child: const Row(
                children: [
                  Icon(Icons.wifi_off,
                      color: AppColors.cream, size: 14),
                  SizedBox(width: 8),
                  Text(
                    'YOU\'RE OFFLINE — SHOWING CACHED ARTICLES',
                    style: TextStyle(
                      color: AppColors.cream,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}