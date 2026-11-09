// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organizer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Events tab: totals and one line per event.

@ProviderFor(organizerSales)
final organizerSalesProvider = OrganizerSalesProvider._();

/// The Events tab: totals and one line per event.

final class OrganizerSalesProvider
    extends $FunctionalProvider<AsyncValue<Sales>, Sales, FutureOr<Sales>>
    with $FutureModifier<Sales>, $FutureProvider<Sales> {
  /// The Events tab: totals and one line per event.
  OrganizerSalesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'organizerSalesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$organizerSalesHash();

  @$internal
  @override
  $FutureProviderElement<Sales> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Sales> create(Ref ref) {
    return organizerSales(ref);
  }
}

String _$organizerSalesHash() => r'c7b41c6101ef3cecc54bd965731ab98e59482800';

@ProviderFor(organizerEventStats)
final organizerEventStatsProvider = OrganizerEventStatsFamily._();

final class OrganizerEventStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventStats>,
          EventStats,
          FutureOr<EventStats>
        >
    with $FutureModifier<EventStats>, $FutureProvider<EventStats> {
  OrganizerEventStatsProvider._({
    required OrganizerEventStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'organizerEventStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$organizerEventStatsHash();

  @override
  String toString() {
    return r'organizerEventStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<EventStats> create(Ref ref) {
    final argument = this.argument as String;
    return organizerEventStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrganizerEventStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizerEventStatsHash() =>
    r'6b361f24f1d90f22595d26f6106dbaa17adf1978';

final class OrganizerEventStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventStats>, String> {
  OrganizerEventStatsFamily._()
    : super(
        retry: null,
        name: r'organizerEventStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrganizerEventStatsProvider call(String eventId) =>
      OrganizerEventStatsProvider._(argument: eventId, from: this);

  @override
  String toString() => r'organizerEventStatsProvider';
}

/// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
/// everyone; [search] matches the guest's name, email or ticket code.

@ProviderFor(EventAttendees)
final eventAttendeesProvider = EventAttendeesFamily._();

/// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
/// everyone; [search] matches the guest's name, email or ticket code.
final class EventAttendeesProvider
    extends $AsyncNotifierProvider<EventAttendees, PagedState<EventAdmission>> {
  /// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
  /// everyone; [search] matches the guest's name, email or ticket code.
  EventAttendeesProvider._({
    required EventAttendeesFamily super.from,
    required (String, bool?, String) super.argument,
  }) : super(
         retry: null,
         name: r'eventAttendeesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventAttendeesHash();

  @override
  String toString() {
    return r'eventAttendeesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EventAttendees create() => EventAttendees();

  @override
  bool operator ==(Object other) {
    return other is EventAttendeesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventAttendeesHash() => r'b06ee24367a1d2a1ace270654c7d3f25e57a6170';

/// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
/// everyone; [search] matches the guest's name, email or ticket code.

final class EventAttendeesFamily extends $Family
    with
        $ClassFamilyOverride<
          EventAttendees,
          AsyncValue<PagedState<EventAdmission>>,
          PagedState<EventAdmission>,
          FutureOr<PagedState<EventAdmission>>,
          (String, bool?, String)
        > {
  EventAttendeesFamily._()
    : super(
        retry: null,
        name: r'eventAttendeesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
  /// everyone; [search] matches the guest's name, email or ticket code.

  EventAttendeesProvider call(String eventId, bool? checkedIn, String search) =>
      EventAttendeesProvider._(
        argument: (eventId, checkedIn, search),
        from: this,
      );

  @override
  String toString() => r'eventAttendeesProvider';
}

/// Who holds a ticket to [eventId], one page at a time. [checkedIn] null means
/// everyone; [search] matches the guest's name, email or ticket code.

abstract class _$EventAttendees
    extends $AsyncNotifier<PagedState<EventAdmission>> {
  late final _$args = ref.$arg as (String, bool?, String);
  String get eventId => _$args.$1;
  bool? get checkedIn => _$args.$2;
  String get search => _$args.$3;

  FutureOr<PagedState<EventAdmission>> build(
    String eventId,
    bool? checkedIn,
    String search,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedState<EventAdmission>>,
              PagedState<EventAdmission>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedState<EventAdmission>>,
                PagedState<EventAdmission>
              >,
              AsyncValue<PagedState<EventAdmission>>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}

/// Bookings on the organizer's events, newest first, one page at a time.
/// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.

@ProviderFor(OrganizerBookings)
final organizerBookingsProvider = OrganizerBookingsFamily._();

/// Bookings on the organizer's events, newest first, one page at a time.
/// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.
final class OrganizerBookingsProvider
    extends
        $AsyncNotifierProvider<OrganizerBookings, PagedState<ManagedBooking>> {
  /// Bookings on the organizer's events, newest first, one page at a time.
  /// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.
  OrganizerBookingsProvider._({
    required OrganizerBookingsFamily super.from,
    required (String?, String?) super.argument,
  }) : super(
         retry: null,
         name: r'organizerBookingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$organizerBookingsHash();

  @override
  String toString() {
    return r'organizerBookingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  OrganizerBookings create() => OrganizerBookings();

  @override
  bool operator ==(Object other) {
    return other is OrganizerBookingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$organizerBookingsHash() => r'cbce973f20ed0c45602ef98a314a7a5cad4a7550';

/// Bookings on the organizer's events, newest first, one page at a time.
/// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.

final class OrganizerBookingsFamily extends $Family
    with
        $ClassFamilyOverride<
          OrganizerBookings,
          AsyncValue<PagedState<ManagedBooking>>,
          PagedState<ManagedBooking>,
          FutureOr<PagedState<ManagedBooking>>,
          (String?, String?)
        > {
  OrganizerBookingsFamily._()
    : super(
        retry: null,
        name: r'organizerBookingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Bookings on the organizer's events, newest first, one page at a time.
  /// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.

  OrganizerBookingsProvider call(String? eventId, String? status) =>
      OrganizerBookingsProvider._(argument: (eventId, status), from: this);

  @override
  String toString() => r'organizerBookingsProvider';
}

/// Bookings on the organizer's events, newest first, one page at a time.
/// [eventId] null means all of them; [status] is Pending, Confirmed or Cancelled.

abstract class _$OrganizerBookings
    extends $AsyncNotifier<PagedState<ManagedBooking>> {
  late final _$args = ref.$arg as (String?, String?);
  String? get eventId => _$args.$1;
  String? get status => _$args.$2;

  FutureOr<PagedState<ManagedBooking>> build(String? eventId, String? status);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PagedState<ManagedBooking>>,
              PagedState<ManagedBooking>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PagedState<ManagedBooking>>,
                PagedState<ManagedBooking>
              >,
              AsyncValue<PagedState<ManagedBooking>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
