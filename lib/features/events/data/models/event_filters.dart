enum DateFilter {
  today('Today'),
  tomorrow('Tomorrow'),
  weekend('This weekend'),
  nextWeek('Next week');

  const DateFilter(this.label);
  final String label;
}

enum PriceFilter {
  free('Free', max: 0),
  under25('Under \$25', max: 25),
  from25to50('\$25–\$50', min: 25, max: 50),
  over50('\$50+', min: 50);

  const PriceFilter(this.label, {this.min, this.max});
  final String label;
  final double? min;
  final double? max;
}

/// Event categories the backend knows about, as they are stored.
const eventCategories = [
  'Concert',
  'Food & Drink',
  'Festival',
  'Conference',
  'Market',
  'Sports',
  'Art',
  'Comedy',
];

/// What the user narrowed the event list down to. Immutable, and equal when
/// the choices are equal, so it can key a provider.
class EventFilters {
  const EventFilters({this.date, this.day, this.price, this.category});

  final DateFilter? date;

  /// A single day picked on the calendar. Replaces [date], never used with it.
  final DateTime? day;
  final PriceFilter? price;
  final String? category;

  /// How many filters are on.
  int get count => [date, day, price, category].where((f) => f != null).length;

  bool get isEmpty => count == 0;

  /// Each argument replaces the current choice; pass null to turn it off.
  EventFilters copyWith({
    DateFilter? Function()? date,
    DateTime? Function()? day,
    PriceFilter? Function()? price,
    String? Function()? category,
  }) {
    return EventFilters(
      date: date != null ? date() : this.date,
      day: day != null ? day() : this.day,
      price: price != null ? price() : this.price,
      category: category != null ? category() : this.category,
    );
  }

  /// The time window for [date], in the phone's time zone. With no date
  /// filter, everything from now on, so events that are over never show.
  ({DateTime from, DateTime? to}) dateRange(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    DateTime endOf(DateTime day) =>
        DateTime(day.year, day.month, day.day, 23, 59, 59);

    final picked = day;
    if (picked != null) {
      final start = DateTime(picked.year, picked.month, picked.day);
      // Today is only what is still ahead; other days start at midnight.
      return (from: start.isBefore(now) ? now : start, to: endOf(start));
    }

    switch (date) {
      case null:
        return (from: now, to: null);
      case DateFilter.today:
        return (from: now, to: endOf(today));
      case DateFilter.tomorrow:
        final tomorrow = today.add(const Duration(days: 1));
        return (from: tomorrow, to: endOf(tomorrow));
      case DateFilter.weekend:
        // Saturday and Sunday of this week; on the weekend itself, from now.
        final saturday = today.add(
          Duration(days: (DateTime.saturday - today.weekday) % 7),
        );
        final sunday = saturday.add(const Duration(days: 1));
        final start = today.weekday >= DateTime.saturday ? now : saturday;
        final end = today.weekday == DateTime.sunday ? today : sunday;
        return (from: start, to: endOf(end));
      case DateFilter.nextWeek:
        // The Monday after today, then that whole week.
        final monday = today.add(Duration(days: 8 - today.weekday));
        return (from: monday, to: endOf(monday.add(const Duration(days: 6))));
    }
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilters &&
      other.date == date &&
      other.day == day &&
      other.price == price &&
      other.category == category;

  @override
  int get hashCode => Object.hash(date, day, price, category);
}
