import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/feed_provider.dart';
import '../../data/services/exchange_rate_service.dart';
import '../theme/app_theme.dart';

class ExchangeRateCard extends ConsumerWidget {
  const ExchangeRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratesState = ref.watch(exchangeRateProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.nigeria,
        border: Border.all(color: AppColors.ink, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink,
            offset: Offset(5, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 10,
            ),
            color: AppColors.ink,
            child: Row(
              children: [
                const Text('🇳🇬', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Text(
                  'NAIRA EXCHANGE RATES',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.cream,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                // Refresh button
                GestureDetector(
                  onTap: () =>
                      ref.read(exchangeRateProvider.notifier).refresh(),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.cream,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),

          // Rates content
          Padding(
            padding: const EdgeInsets.all(16),
            child: ratesState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.cream,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Could not load rates. Tap ↻ to retry.',
                  style: AppTextStyles.muted.copyWith(
                    color: AppColors.cream.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ),
              data: (rates) => rates.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No rates available.',
                        style: AppTextStyles.muted.copyWith(
                          color: AppColors.cream.withOpacity(0.6),
                        ),
                      ),
                    )
                  : Row(
                      children: rates
                          .map((rate) => Expanded(
                                child: _RateItem(rate: rate),
                              ))
                          .toList(),
                    ),
            ),
          ),

          // Footer — date
          ratesState.maybeWhen(
            data: (rates) => rates.isNotEmpty
                ? Container(
  width: double.infinity,
  padding: const EdgeInsets.symmetric(
    horizontal: 14, vertical: 8,
  ),
  color: Colors.black26,
  child: Text(
    'Official CBN rate · BDC & parallel market rates may differ',
    style: AppTextStyles.muted.copyWith(
      color: AppColors.cream.withOpacity(0.5),
      fontSize: 10,
    ),
  ),
)
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RateItem extends StatelessWidget {
  final ExchangeRate rate;

  const _RateItem({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Currency symbol + code
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 4,
          ),
          color: Colors.black26,
          child: Text(
            '${rate.symbol} ${rate.currency}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
              letterSpacing: 1,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Rate
        Text(
          '₦${_formatRate(rate.rateToNgn)}',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.cream,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'per ${rate.currency}',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: AppColors.cream.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  String _formatRate(double rate) {
    if (rate >= 1000) {
      return rate.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return rate.toStringAsFixed(2);
  }
}