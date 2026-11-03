import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// The last row of a list that loads page by page: a small spinner while the
/// next page is on its way, or a short message with a retry button when that
/// request failed. Shows nothing when there is nothing to say.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Text(
              'Couldn’t load more',
              style: context.meta.copyWith(color: context.muted),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Try again',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.small,
              onPressed: onRetry,
            ),
          ],
        ),
      );
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
