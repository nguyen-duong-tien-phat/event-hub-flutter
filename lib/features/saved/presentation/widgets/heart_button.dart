import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/features/saved/presentation/providers/saved_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The heart that saves or unsaves an event.
class HeartButton extends ConsumerWidget {
  /// A bare heart, for lists.
  const HeartButton({super.key, required this.eventId})
    : onPhoto = false,
      size = 0;

  /// A white circle with the heart, for placing over a photo.
  const HeartButton.onPhoto({super.key, required this.eventId, this.size = 36})
    : onPhoto = true;

  final String eventId;
  final bool onPhoto;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(savedIdsProvider).value?.contains(eventId) ?? false;

    Future<void> toggle() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(savedIdsProvider.notifier).toggle(eventId);
      } on ApiException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      }
    }

    final tooltip = saved ? 'Remove from saved' : 'Save';

    if (onPhoto) {
      return Material(
        color: context.surface.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: toggle,
          child: Tooltip(
            message: tooltip,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                saved ? Icons.favorite : LucideIcons.heart,
                size: 18,
                color: saved ? context.accent : context.ink,
              ),
            ),
          ),
        ),
      );
    }

    return InkResponse(
      onTap: toggle,
      radius: 22,
      child: Tooltip(
        message: tooltip,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            saved ? Icons.favorite : LucideIcons.heart,
            size: 20,
            color: saved ? context.accent : context.muted,
          ),
        ),
      ),
    );
  }
}
