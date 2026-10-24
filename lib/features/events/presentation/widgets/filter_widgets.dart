import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/bottom_action_bar.dart';
import 'package:event_hub_mobile/features/events/data/models/event_filters.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/discover_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A rounded chip that is filled dark when [selected].
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 36,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? context.ink : context.surface,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? context.ink : context.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.control.copyWith(
              color: selected ? Colors.white : context.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// The few filters people reach for most, as one-tap chips.
class QuickFilterChips extends ConsumerWidget {
  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(discoverFiltersProvider);
    final notifier = ref.read(discoverFiltersProvider.notifier);

    Widget chip(String label, bool selected, EventFilters Function() toggled) =>
        FilterChipButton(
          label: label,
          selected: selected,
          onTap: () => notifier.set(toggled()),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        spacing: 8,
        children: [
          chip(
            'This weekend',
            filters.date == DateFilter.weekend,
            () => filters.copyWith(
              date: () => filters.date == DateFilter.weekend
                  ? null
                  : DateFilter.weekend,
            ),
          ),
          chip(
            'Under \$25',
            filters.price == PriceFilter.under25,
            () => filters.copyWith(
              price: () => filters.price == PriceFilter.under25
                  ? null
                  : PriceFilter.under25,
            ),
          ),
          chip(
            'Free',
            filters.price == PriceFilter.free,
            () => filters.copyWith(
              price: () =>
                  filters.price == PriceFilter.free ? null : PriceFilter.free,
            ),
          ),
          chip(
            'Concerts',
            filters.category == 'Concert',
            () => filters.copyWith(
              category: () => filters.category == 'Concert' ? null : 'Concert',
            ),
          ),
          chip(
            'Food',
            filters.category == 'Food & Drink',
            () => filters.copyWith(
              category: () =>
                  filters.category == 'Food & Drink' ? null : 'Food & Drink',
            ),
          ),
        ],
      ),
    );
  }
}

/// The square "filters" button with the number of filters on.
class FiltersButton extends ConsumerWidget {
  const FiltersButton({super.key, required this.query});

  /// The text search the sheet's count should include.
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(discoverFiltersProvider).count;

    return Tooltip(
      message: count == 0 ? 'Filters' : 'Filters, $count applied',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: context.ink,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => showFiltersSheet(context, query: query),
              child: const SizedBox.square(
                dimension: 48,
                child: Icon(Icons.tune, size: 20, color: Colors.white),
              ),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: context.background, width: 2),
                ),
                child: Text(
                  '$count',
                  style: context.badge.copyWith(color: Colors.white, height: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens the filters sheet. Choices apply when "Show N events" is tapped.
Future<void> showFiltersSheet(BuildContext context, {String query = ''}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (_) => FiltersSheet(query: query),
  );
}

class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key, this.query = ''});

  final String query;

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late EventFilters _draft = ref.read(discoverFiltersProvider);

  @override
  Widget build(BuildContext context) {
    // How many events the draft would show, so the button can say so.
    final results = ref.watch(eventResultsProvider(_draft, widget.query));
    final count = results.value?.totalCount;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: context.subhead),
                TextButton(
                  onPressed: _draft.isEmpty
                      ? null
                      : () => setState(() => _draft = const EventFilters()),
                  child: Text(
                    'Reset',
                    style: context.bodySmall.copyWith(
                      color: _draft.isEmpty ? context.muted : context.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24,
                children: [
                  _Group('When', [
                    for (final d in DateFilter.values)
                      FilterChipButton(
                        label: d.label,
                        selected: _draft.date == d,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            date: () => _draft.date == d ? null : d,
                          ),
                        ),
                      ),
                  ]),
                  _Group('Price', [
                    for (final p in PriceFilter.values)
                      FilterChipButton(
                        label: p.label,
                        selected: _draft.price == p,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            price: () => _draft.price == p ? null : p,
                          ),
                        ),
                      ),
                  ]),
                  _Group('Category', [
                    for (final c in eventCategories)
                      FilterChipButton(
                        label: c,
                        selected: _draft.category == c,
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            category: () => _draft.category == c ? null : c,
                          ),
                        ),
                      ),
                  ]),
                ],
              ),
            ),
          ),
          BottomActionBar(
            actionLabel: count == null
                ? 'Show events'
                : 'Show $count ${count == 1 ? 'event' : 'events'}',
            onPressed: () {
              ref.read(discoverFiltersProvider.notifier).set(_draft);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.chips);

  final String title;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          title.toUpperCase(),
          style: context.overline.copyWith(color: context.muted),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }
}
