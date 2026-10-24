import 'dart:async';

import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/message_state.dart';
import 'package:event_hub_mobile/features/events/data/models/event_filters.dart';
import 'package:event_hub_mobile/features/events/presentation/providers/discover_providers.dart';
import 'package:event_hub_mobile/features/events/presentation/screens/discover_screen.dart';
import 'package:event_hub_mobile/features/events/presentation/widgets/filter_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Search by text. The filters chosen on Discover still apply.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  static const _popular = ['Concert', 'Comedy', 'Food', 'Festival', 'Jazz'];

  final _controller = TextEditingController();
  Timer? _debounce;

  /// The text the results are for. Follows the field a moment after typing
  /// stops, so every keystroke does not fire a request.
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {}); // the clear button depends on the field being empty
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  void _setQuery(String text) {
    _debounce?.cancel();
    _controller.text = text;
    _controller.selection = TextSelection.collapsed(offset: text.length);
    setState(() => _query = text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(discoverFiltersProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(child: _field(context)),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text('Cancel', style: context.bodyEmphasis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const QuickFilterChips(),
            Expanded(child: _body(context, filters)),
          ],
        ),
      ),
    );
  }

  Widget _field(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.ink, width: 1.5),
      ),
      child: Row(
        spacing: 10,
        children: [
          Icon(LucideIcons.search, size: 18, color: context.muted),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: context.body,
              onChanged: _onChanged,
              onSubmitted: _setQuery,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search events, venues, artists',
                hintStyle: TextStyle(color: Color(0xFF8A8E94)),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            InkResponse(
              onTap: () => _setQuery(''),
              child: Tooltip(
                message: 'Clear',
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE7E6E1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    size: 12,
                    color: Color(0xFF3F434A),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, EventFilters filters) {
    // Nothing typed yet: suggestions.
    if (_query.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
        children: [_popularSearches(context)],
      );
    }

    final results = ref.watch(eventResultsProvider(filters, _query));

    return results.when(
      skipLoadingOnReload: true,
      loading: () => const EventList.loading(),
      error: (error, _) => MessageState(
        icon: LucideIcons.wifiOff,
        title: 'Couldn’t search',
        message: error is ApiException
            ? error.message
            : 'Check your connection and try again.',
        action: AppButton(
          label: 'Try again',
          variant: AppButtonVariant.dark,
          onPressed: () =>
              ref.invalidate(eventResultsProvider(filters, _query)),
        ),
      ),
      data: (page) => page.items.isEmpty
          ? ListView(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
              children: [
                _NoMatches(query: _query, hasFilters: !filters.isEmpty),
                const SizedBox(height: 40),
                _popularSearches(context),
              ],
            )
          : EventList(
              events: page.items,
              total: page.totalCount,
              onRefresh: () =>
                  ref.refresh(eventResultsProvider(filters, _query).future),
            ),
    );
  }

  Widget _popularSearches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'POPULAR SEARCHES',
          style: context.overline.copyWith(color: context.muted),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final term in _popular)
              FilterChipButton(
                label: term,
                selected: false,
                height: 34,
                onTap: () => _setQuery(term),
              ),
          ],
        ),
      ],
    );
  }
}

class _NoMatches extends ConsumerWidget {
  const _NoMatches({required this.query, required this.hasFilters});

  final String query;
  final bool hasFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEFEEEA),
          ),
          child: const Icon(
            LucideIcons.search,
            size: 28,
            color: Color(0xFF3F434A),
          ),
        ),
        const SizedBox(height: 20),
        Text('No matches found', style: context.title),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            hasFilters
                ? 'We couldn’t find events for “$query” with your current '
                      'filters. Try a broader term.'
                : 'We couldn’t find events for “$query”. Try a broader term.',
            textAlign: TextAlign.center,
            style: context.bodySmall.copyWith(color: context.muted),
          ),
        ),
        if (hasFilters) ...[
          const SizedBox(height: 24),
          AppButton(
            label: 'Clear filters',
            variant: AppButtonVariant.secondary,
            onPressed: () => ref.read(discoverFiltersProvider.notifier).reset(),
          ),
        ],
      ],
    );
  }
}
