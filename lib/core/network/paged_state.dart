import 'package:event_hub_mobile/core/network/paginated_response.dart';

/// What a list that loads page by page has so far: everything fetched up to
/// now, plus what is needed to ask for the next page.
class PagedState<T> {
  const PagedState({
    required this.items,
    required this.page,
    required this.totalCount,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  /// The state after the first page arrives.
  factory PagedState.first(PaginatedResponse<T> response) {
    return PagedState(
      items: response.items,
      page: response.page,
      totalCount: response.totalCount,
      hasMore: response.hasMore,
    );
  }

  final List<T> items;

  /// The last page that was loaded.
  final int page;

  /// How many items exist in total, not just how many are loaded.
  final int totalCount;

  final bool hasMore;
  final bool isLoadingMore;

  /// Set when fetching the next page failed. The items already loaded stay,
  /// so the screen can show a retry row under them instead of an error page.
  final Object? loadMoreError;

  int get nextPage => page + 1;

  PagedState<T> loading() => PagedState(
    items: items,
    page: page,
    totalCount: totalCount,
    hasMore: hasMore,
    isLoadingMore: true,
  );

  PagedState<T> failed(Object error) => PagedState(
    items: items,
    page: page,
    totalCount: totalCount,
    hasMore: hasMore,
    loadMoreError: error,
  );

  /// Adds the next [response] after the current items. [idOf] drops items that
  /// were already loaded: if the list changes on the server between two
  /// requests, an item can slide over a page border and show up twice.
  PagedState<T> appended(
    PaginatedResponse<T> response, {
    required Object Function(T item) idOf,
  }) {
    final known = {for (final item in items) idOf(item)};
    return PagedState(
      items: [
        ...items,
        for (final item in response.items)
          if (known.add(idOf(item))) item,
      ],
      page: response.page,
      totalCount: response.totalCount,
      hasMore: response.hasMore,
    );
  }
}
