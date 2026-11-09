import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:event_hub_mobile/core/router/app_routes.dart';
import 'package:event_hub_mobile/core/theme/text_styles.dart';
import 'package:event_hub_mobile/core/widgets/app_button.dart';
import 'package:event_hub_mobile/core/widgets/page_title.dart';
import 'package:event_hub_mobile/features/organizer/data/organizer_repository.dart';
import 'package:event_hub_mobile/features/organizer/presentation/providers/organizer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Check-in: scan the QR code on a guest's ticket, or type its short code.
/// The camera only runs while this tab is on screen.
class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _scanner = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    autoStart: false,
  );

  /// True while a code is being checked or its answer is on screen, so one
  /// QR in view is not sent over and over.
  bool _busy = false;
  bool _active = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The tabs are kept alive side by side; a tab that is not shown has its
    // tickers off. Use that to switch the camera on and off with the tab.
    final active = TickerMode.valuesOf(context).enabled;
    if (active == _active) return;
    _active = active;
    if (active && !_busy) {
      _startCamera();
    } else {
      _scanner.stop().catchError((_) {});
    }
  }

  Future<void> _startCamera() async {
    try {
      await _scanner.start();
    } catch (_) {
      // No permission or no camera: the preview shows the reason.
    }
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty || _busy) return;
    await _submit(value);
  }

  Future<void> _submit(String code) async {
    if (_busy) return;
    _busy = true;
    await _scanner.stop().catchError((_) {});
    try {
      final result = await ref
          .read(organizerRepositoryProvider)
          .checkIn(code.trim());
      HapticFeedback.mediumImpact();
      // Numbers on the other screens changed.
      ref.invalidate(organizerSalesProvider);
      ref.invalidate(organizerEventStatsProvider);
      ref.invalidate(eventAttendeesProvider);
      if (!mounted) return;
      await context.push(AppRoutes.orgCheckInResult, extra: result);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      _busy = false;
      if (mounted && _active) _startCamera();
    }
  }

  Future<void> _typeCode() async {
    await _scanner.stop().catchError((_) {});
    if (!mounted) return;
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.surface,
      builder: (_) => const _TypeCodeSheet(),
    );
    if (code != null && code.trim().isNotEmpty) {
      await _submit(code);
    } else if (mounted && _active) {
      _startCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitle('Check in'),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Text(
              'Scan the QR code on a guest’s ticket.',
              style: context.bodySmall.copyWith(color: context.muted),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: context.ink,
                      child: MobileScanner(
                        controller: _scanner,
                        onDetect: _onDetect,
                        errorBuilder: (context, error) =>
                            _CameraError(onType: _typeCode),
                      ),
                    ),
                    const Center(child: _ScanFrame()),
                    Positioned(
                      top: 14,
                      right: 14,
                      child: IconButton.filled(
                        tooltip: 'Torch',
                        onPressed: () => _scanner.toggleTorch(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.18),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(LucideIcons.zap, size: 18),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 16,
                      child: Text(
                        'Hold the phone steady, the code is read by itself',
                        textAlign: TextAlign.center,
                        style: context.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: AppButton(
              label: 'Type the code instead',
              icon: LucideIcons.keyboard,
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.large,
              expand: true,
              onPressed: _typeCode,
            ),
          ),
        ],
      ),
    );
  }
}

/// Four white corners that show where to hold the QR code.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Colors.white, width: 4);
    Widget corner(Alignment alignment, Border border, BorderRadius radius) =>
        Align(
          alignment: alignment,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(border: border, borderRadius: radius),
          ),
        );
    const r = Radius.circular(14);
    return IgnorePointer(
      child: SizedBox(
        width: 240,
        height: 240,
        child: Stack(
          children: [
            corner(
              Alignment.topLeft,
              const Border(top: side, left: side),
              const BorderRadius.only(topLeft: r),
            ),
            corner(
              Alignment.topRight,
              const Border(top: side, right: side),
              const BorderRadius.only(topRight: r),
            ),
            corner(
              Alignment.bottomLeft,
              const Border(bottom: side, left: side),
              const BorderRadius.only(bottomLeft: r),
            ),
            corner(
              Alignment.bottomRight,
              const Border(bottom: side, right: side),
              const BorderRadius.only(bottomRight: r),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.onType});

  final VoidCallback onType;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const Icon(LucideIcons.cameraOff, color: Colors.white, size: 32),
              Text(
                'The camera isn’t available',
                style: context.headline.copyWith(color: Colors.white),
              ),
              Text(
                'Allow camera access in Settings, or type the ticket code.',
                textAlign: TextAlign.center,
                style: context.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              AppButton(
                label: 'Type the code',
                variant: AppButtonVariant.secondary,
                onPressed: onType,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeCodeSheet extends StatefulWidget {
  const _TypeCodeSheet();

  @override
  State<_TypeCodeSheet> createState() => _TypeCodeSheetState();
}

class _TypeCodeSheetState extends State<_TypeCodeSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text('Type the ticket code', style: context.title),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.pop(context, value),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9 -]')),
              LengthLimitingTextInputFormatter(12),
            ],
            style: const TextStyle(
              fontFamily: 'Menlo',
              fontSize: 22,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'K7Q4 9XMD',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Text(
            '8 characters, printed under the QR code. Capitals and spaces do not matter.',
            style: context.caption.copyWith(color: context.muted),
          ),
          AppButton(
            label: 'Check in',
            variant: AppButtonVariant.dark,
            size: AppButtonSize.large,
            expand: true,
            onPressed: () => Navigator.pop(context, _controller.text),
          ),
        ],
      ),
    );
  }
}
