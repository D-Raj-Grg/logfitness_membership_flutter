// The camera behind a small interface, so the state machine and the widgets
// can be tested without a camera (simulators and CI have none). The one real
// implementation wraps `mobile_scanner`; tests override
// [doorScannerFactoryProvider] with a fake.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum DoorScannerStatus {
  /// Not started yet, or the permission prompt / camera start is in flight.
  starting,

  /// Frames are flowing.
  running,

  /// Stopped on purpose (tab hidden, app backgrounded, result showing).
  stopped,

  /// The member said no (or the OS restricts the camera).
  permissionDenied,

  /// No usable camera on this device.
  noCamera,

  /// The camera would not start for another reason.
  error,
}

enum DoorTorch { unavailable, off, on }

abstract interface class DoorScanner {
  ValueListenable<DoorScannerStatus> get status;
  ValueListenable<DoorTorch> get torch;

  /// Raw text of every QR in view, per frame batch. Not deduplicated.
  Stream<List<String>> get codes;

  /// Starts the camera. First call asks for permission. Never throws; the
  /// outcome is in [status].
  Future<void> start();

  Future<void> stop();

  Future<void> toggleTorch();

  /// Opens this app's page in the system settings.
  Future<void> openSettings();

  /// The live preview, no overlay.
  Widget buildPreview(BuildContext context);

  void dispose();
}

typedef DoorScannerFactory = DoorScanner Function();

final doorScannerFactoryProvider = Provider<DoorScannerFactory>(
  (ref) =>
      () => MobileDoorScanner(),
);

class MobileDoorScanner implements DoorScanner {
  MobileDoorScanner()
    : _controller = MobileScannerController(
        autoStart: false,
        detectionSpeed: DetectionSpeed.noDuplicates,
        formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      ) {
    _controller.addListener(_onControllerChanged);
    _sub = _controller.barcodes.listen((BarcodeCapture capture) {
      final List<String> raw = <String>[
        for (final Barcode b in capture.barcodes)
          if (b.rawValue != null) b.rawValue!,
      ];
      if (raw.isNotEmpty && !_codes.isClosed) _codes.add(raw);
    });
  }

  final MobileScannerController _controller;
  late final StreamSubscription<BarcodeCapture> _sub;
  final StreamController<List<String>> _codes =
      StreamController<List<String>>.broadcast();
  final ValueNotifier<DoorScannerStatus> _status =
      ValueNotifier<DoorScannerStatus>(DoorScannerStatus.starting);
  final ValueNotifier<DoorTorch> _torch = ValueNotifier<DoorTorch>(
    DoorTorch.unavailable,
  );

  // start/stop calls are chained: the platform side does not like overlap.
  Future<void> _queue = Future<void>.value();
  bool _disposed = false;

  @override
  ValueListenable<DoorScannerStatus> get status => _status;

  @override
  ValueListenable<DoorTorch> get torch => _torch;

  @override
  Stream<List<String>> get codes => _codes.stream;

  void _onControllerChanged() {
    if (_disposed) return;
    final MobileScannerState s = _controller.value;
    _torch.value = switch (s.torchState) {
      TorchState.on => DoorTorch.on,
      TorchState.off || TorchState.auto => DoorTorch.off,
      TorchState.unavailable => DoorTorch.unavailable,
    };
    final MobileScannerException? error = s.error;
    if (error != null) {
      _status.value = switch (error.errorCode) {
        MobileScannerErrorCode.permissionDenied =>
          DoorScannerStatus.permissionDenied,
        MobileScannerErrorCode.unsupported => DoorScannerStatus.noCamera,
        _ => DoorScannerStatus.error,
      };
    } else if (s.isRunning) {
      _status.value = DoorScannerStatus.running;
    }
  }

  Future<void> _enqueue(Future<void> Function() op) {
    _queue = _queue.then((_) async {
      if (_disposed) return;
      try {
        await op();
      } on MobileScannerException catch (e) {
        _status.value = switch (e.errorCode) {
          MobileScannerErrorCode.permissionDenied =>
            DoorScannerStatus.permissionDenied,
          MobileScannerErrorCode.unsupported => DoorScannerStatus.noCamera,
          _ => DoorScannerStatus.error,
        };
      } catch (_) {
        _status.value = DoorScannerStatus.error;
      }
    });
    return _queue;
  }

  @override
  Future<void> start() => _enqueue(() async {
    _status.value = DoorScannerStatus.starting;
    await _controller.start();
    _onControllerChanged();
  });

  @override
  Future<void> stop() => _enqueue(() async {
    await _controller.stop();
    if (_status.value == DoorScannerStatus.running ||
        _status.value == DoorScannerStatus.starting) {
      _status.value = DoorScannerStatus.stopped;
    }
  });

  @override
  Future<void> toggleTorch() => _enqueue(_controller.toggleTorch);

  @override
  Future<void> openSettings() async {
    try {
      await ph.openAppSettings();
    } catch (_) {}
  }

  @override
  Widget buildPreview(BuildContext context) => MobileScanner(
    controller: _controller,
    fit: BoxFit.cover,
    // The screen owns start/stop (tab visibility + app lifecycle).
    useAppLifecycleState: false,
    errorBuilder: (BuildContext context, MobileScannerException error) =>
        const SizedBox.expand(),
  );

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _controller.removeListener(_onControllerChanged);
    unawaited(_sub.cancel());
    unawaited(_codes.close());
    unawaited(_controller.dispose());
    _status.dispose();
    _torch.dispose();
  }
}
