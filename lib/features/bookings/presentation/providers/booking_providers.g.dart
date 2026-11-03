// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(booking)
final bookingProvider = BookingFamily._();

final class BookingProvider
    extends $FunctionalProvider<AsyncValue<Booking>, Booking, FutureOr<Booking>>
    with $FutureModifier<Booking>, $FutureProvider<Booking> {
  BookingProvider._({
    required BookingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookingHash();

  @override
  String toString() {
    return r'bookingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Booking> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Booking> create(Ref ref) {
    final argument = this.argument as String;
    return booking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookingHash() => r'e99a9ca8c0def85fd5c6472a3db0fe5da8d0a7c1';

final class BookingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Booking>, String> {
  BookingFamily._()
    : super(
        retry: null,
        name: r'bookingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookingProvider call(String id) =>
      BookingProvider._(argument: id, from: this);

  @override
  String toString() => r'bookingProvider';
}

/// The signed-in user's bookings (the Tickets tab), one page at a time.
///
/// The backend does not promise an order for this list, and the Tickets screen
/// sorts by event date itself, so the order here does not matter.

@ProviderFor(MyBookings)
final myBookingsProvider = MyBookingsProvider._();

/// The signed-in user's bookings (the Tickets tab), one page at a time.
///
/// The backend does not promise an order for this list, and the Tickets screen
/// sorts by event date itself, so the order here does not matter.
final class MyBookingsProvider
    extends $AsyncNotifierProvider<MyBookings, PagedState<Booking>> {
  /// The signed-in user's bookings (the Tickets tab), one page at a time.
  ///
  /// The backend does not promise an order for this list, and the Tickets screen
  /// sorts by event date itself, so the order here does not matter.
  MyBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBookingsHash();

  @$internal
  @override
  MyBookings create() => MyBookings();
}

String _$myBookingsHash() => r'72d1d64b3a5899d7cdbd1d2ee6fd3cbaf506bd92';

/// The signed-in user's bookings (the Tickets tab), one page at a time.
///
/// The backend does not promise an order for this list, and the Tickets screen
/// sorts by event date itself, so the order here does not matter.

abstract class _$MyBookings extends $AsyncNotifier<PagedState<Booking>> {
  FutureOr<PagedState<Booking>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PagedState<Booking>>, PagedState<Booking>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedState<Booking>>, PagedState<Booking>>,
              AsyncValue<PagedState<Booking>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Stripe client secrets by booking id. The backend only sends a secret when a
/// booking is created, so it is kept here until the payment is done.

@ProviderFor(PaymentSecrets)
final paymentSecretsProvider = PaymentSecretsProvider._();

/// Stripe client secrets by booking id. The backend only sends a secret when a
/// booking is created, so it is kept here until the payment is done.
final class PaymentSecretsProvider
    extends $NotifierProvider<PaymentSecrets, Map<String, String>> {
  /// Stripe client secrets by booking id. The backend only sends a secret when a
  /// booking is created, so it is kept here until the payment is done.
  PaymentSecretsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentSecretsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentSecretsHash();

  @$internal
  @override
  PaymentSecrets create() => PaymentSecrets();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$paymentSecretsHash() => r'd9e22f93740f52771bccd387fbf8ac8149019d12';

/// Stripe client secrets by booking id. The backend only sends a secret when a
/// booking is created, so it is kept here until the payment is done.

abstract class _$PaymentSecrets extends $Notifier<Map<String, String>> {
  Map<String, String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Map<String, String>, Map<String, String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, String>, Map<String, String>>,
              Map<String, String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Bookings whose Stripe payment sheet is open right now. While a booking is
/// in here nothing may cancel it, or the customer could pay for tickets that
/// were already given back.

@ProviderFor(PaymentsInProgress)
final paymentsInProgressProvider = PaymentsInProgressProvider._();

/// Bookings whose Stripe payment sheet is open right now. While a booking is
/// in here nothing may cancel it, or the customer could pay for tickets that
/// were already given back.
final class PaymentsInProgressProvider
    extends $NotifierProvider<PaymentsInProgress, Set<String>> {
  /// Bookings whose Stripe payment sheet is open right now. While a booking is
  /// in here nothing may cancel it, or the customer could pay for tickets that
  /// were already given back.
  PaymentsInProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentsInProgressProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentsInProgressHash();

  @$internal
  @override
  PaymentsInProgress create() => PaymentsInProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$paymentsInProgressHash() =>
    r'56443dd5821af2cfc3199f46d59803623634e7ab';

/// Bookings whose Stripe payment sheet is open right now. While a booking is
/// in here nothing may cancel it, or the customer could pay for tickets that
/// were already given back.

abstract class _$PaymentsInProgress extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
