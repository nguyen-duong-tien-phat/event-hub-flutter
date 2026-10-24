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

/// The signed-in user's bookings, newest first (the Tickets tab).

@ProviderFor(myBookings)
final myBookingsProvider = MyBookingsProvider._();

/// The signed-in user's bookings, newest first (the Tickets tab).

final class MyBookingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Booking>>,
          List<Booking>,
          FutureOr<List<Booking>>
        >
    with $FutureModifier<List<Booking>>, $FutureProvider<List<Booking>> {
  /// The signed-in user's bookings, newest first (the Tickets tab).
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
  $FutureProviderElement<List<Booking>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Booking>> create(Ref ref) {
    return myBookings(ref);
  }
}

String _$myBookingsHash() => r'613c07d8413c8ffaac84843896c5ee40b910ceef';

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
