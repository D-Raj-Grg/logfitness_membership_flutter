import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/door/door_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/checkin/checkin_result_view.dart';
import 'package:logfitness_membership_flutter/features/checkin/door_scanner.dart';
import 'package:logfitness_membership_flutter/features/checkin/scan_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

class FakeScanner implements DoorScanner {
  final ValueNotifier<DoorScannerStatus> _status =
      ValueNotifier<DoorScannerStatus>(DoorScannerStatus.starting);
  final ValueNotifier<DoorTorch> _torch = ValueNotifier<DoorTorch>(
    DoorTorch.off,
  );
  final StreamController<List<String>> _codes =
      StreamController<List<String>>.broadcast();
  final List<String> calls = <String>[];
  bool disposed = false;

  @override
  ValueListenable<DoorScannerStatus> get status => _status;
  @override
  ValueListenable<DoorTorch> get torch => _torch;
  @override
  Stream<List<String>> get codes => _codes.stream;

  void emit(List<String> raw) => _codes.add(raw);
  void setStatus(DoorScannerStatus s) => _status.value = s;

  @override
  Future<void> start() async {
    calls.add('start');
    if (_status.value == DoorScannerStatus.starting ||
        _status.value == DoorScannerStatus.stopped) {
      _status.value = DoorScannerStatus.running;
    }
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    if (_status.value == DoorScannerStatus.running) {
      _status.value = DoorScannerStatus.stopped;
    }
  }

  @override
  Future<void> toggleTorch() async {
    calls.add('torch');
    _torch.value = _torch.value == DoorTorch.on ? DoorTorch.off : DoorTorch.on;
  }

  @override
  Future<void> openSettings() async => calls.add('settings');

  @override
  Widget buildPreview(BuildContext context) =>
      const ColoredBox(color: Colors.black, child: SizedBox.expand());

  @override
  void dispose() {
    disposed = true;
    unawaited(_codes.close());
  }
}

class FakeRepo implements DoorRepository {
  DoorCheckInResult result = const DoorOk(memberName: 'Sita Rai');
  Object? error;
  final List<String> calls = <String>[];

  @override
  Future<DoorCheckInResult> checkIn(DoorQrPayload payload) async {
    calls.add(payload.text);
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return result;
  }
}

Widget _app(Widget home, {List<Override> overrides = const <Override>[]}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: appLightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

Future<FakeScanner> _pumpScreen(
  WidgetTester tester, {
  required FakeRepo repo,
  bool tickersEnabled = true,
  FakeScanner? scanner,
}) async {
  final FakeScanner s = scanner ?? FakeScanner();
  await tester.pumpWidget(
    _app(
      TickerMode(enabled: tickersEnabled, child: const ScanCheckInScreen()),
      overrides: <Override>[
        doorScannerFactoryProvider.overrideWithValue(() => s),
        doorRepositoryProvider.overrideWithValue(repo),
      ],
    ),
  );
  await tester.pump();
  await tester.pump();
  return s;
}

void main() {
  group('result views', () {
    Future<void> show(
      WidgetTester tester, {
      DoorCheckInResult? result,
      AppFailure? failure,
      String? dueText,
      VoidCallback? onClose,
    }) async {
      await tester.pumpWidget(
        _app(
          CheckinResultView(
            result: result,
            failure: failure,
            dueText: dueText,
            onClose: onClose ?? () {},
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('ok shows door open, first name and days left', (tester) async {
      await show(
        tester,
        result: const DoorOk(memberName: 'Sita Rai', daysToExpiry: 12),
      );
      expect(find.byKey(checkinOkKey), findsOneWidget);
      expect(find.text('Door open'), findsOneWidget);
      expect(find.text('Hi Sita'), findsOneWidget);
      expect(find.text('12 days left'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('ok, one day left uses the singular', (tester) async {
      await show(tester, result: const DoorOk(daysToExpiry: 1));
      expect(find.text('1 day left'), findsOneWidget);
      expect(find.textContaining('Hi '), findsNothing);
    });

    testWidgets('already checked in today says welcome back', (tester) async {
      await show(
        tester,
        result: const DoorOk(
          memberName: 'Sita Rai',
          alreadyCheckedInToday: true,
        ),
      );
      expect(find.text('Welcome back — door open'), findsOneWidget);
    });

    testWidgets('tapping the success view closes it', (tester) async {
      int closed = 0;
      await show(tester, result: const DoorOk(), onClose: () => closed++);
      await tester.tap(find.byKey(checkinOkKey));
      expect(closed, 1);
    });

    testWidgets('denied explains the reason and points to the desk', (
      tester,
    ) async {
      for (final (DoorDeniedReason r, String text)
          in <(DoorDeniedReason, String)>[
            (DoorDeniedReason.expired, 'Your membership has expired.'),
            (DoorDeniedReason.frozen, 'Your membership is frozen.'),
            (DoorDeniedReason.dues, 'You have dues to clear.'),
            (DoorDeniedReason.other, 'We could not let you in this time.'),
          ]) {
        await show(tester, result: DoorDenied(reason: r));
        expect(find.byKey(checkinDeniedKey), findsOneWidget);
        expect(find.text(text), findsOneWidget);
        expect(
          find.text('Please see the front desk and they will sort it out.'),
          findsOneWidget,
        );
      }
    });

    testWidgets('denied for dues shows the amount when known', (tester) async {
      await show(
        tester,
        result: const DoorDenied(reason: DoorDeniedReason.dues, duePaisa: 1),
        dueText: 'NPR 1,500',
      );
      expect(find.text('You have NPR 1,500 due.'), findsOneWidget);
    });

    testWidgets('invalid_code asks to scan again and the button resets', (
      tester,
    ) async {
      int closed = 0;
      await show(
        tester,
        result: const DoorInvalidCode(),
        onClose: () => closed++,
      );
      expect(find.byKey(checkinInvalidKey), findsOneWidget);
      expect(
        find.text(
          'That code has expired. Scan the screen again — it refreshes every 30 seconds.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(checkinScanAgainKey));
      expect(closed, 1);
    });

    testWidgets('closed', (tester) async {
      await show(tester, result: const DoorClosed());
      expect(find.byKey(checkinClosedKey), findsOneWidget);
      expect(find.text('The gym is closed right now.'), findsOneWidget);
    });

    testWidgets('rate limited', (tester) async {
      await show(tester, result: const DoorRateLimited());
      expect(find.byKey(checkinRateLimitedKey), findsOneWidget);
      expect(
        find.text('Too many tries. Please wait a few minutes.'),
        findsOneWidget,
      );
    });

    testWidgets('offline failure offers retry', (tester) async {
      await show(
        tester,
        failure: const AppFailure(FailureKind.offline, 'No connection'),
      );
      expect(find.byKey(checkinOfflineKey), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('unknown result and other failures offer retry', (
      tester,
    ) async {
      await show(tester, result: const DoorUnknown('teleported'));
      expect(find.byKey(checkinUnknownKey), findsOneWidget);
      await show(
        tester,
        failure: const AppFailure(FailureKind.unknown, 'boom'),
      );
      expect(find.byKey(checkinUnknownKey), findsOneWidget);
    });
  });

  group('scan screen', () {
    testWidgets('starts the camera on entering the visible tab', (
      tester,
    ) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      expect(s.calls, contains('start'));
      expect(find.byKey(checkinPreviewKey), findsOneWidget);
      expect(
        find.text('Point at the QR code on the door screen'),
        findsOneWidget,
      );
    });

    testWidgets('a hidden tab never starts the camera', (tester) async {
      final FakeScanner s = await _pumpScreen(
        tester,
        repo: FakeRepo(),
        tickersEnabled: false,
      );
      expect(s.calls, isNot(contains('start')));
    });

    testWidgets('hiding the tab stops the camera; showing it restarts', (
      tester,
    ) async {
      final FakeScanner s = FakeScanner();
      final FakeRepo repo = FakeRepo();
      Future<void> pump(bool visible) async {
        await tester.pumpWidget(
          _app(
            TickerMode(enabled: visible, child: const ScanCheckInScreen()),
            overrides: <Override>[
              doorScannerFactoryProvider.overrideWithValue(() => s),
              doorRepositoryProvider.overrideWithValue(repo),
            ],
          ),
        );
        await tester.pump();
        await tester.pump();
      }

      await pump(true);
      await pump(false);
      expect(s.calls.last, 'stop');
      await pump(true);
      expect(s.calls.last, 'start');
    });

    testWidgets('app lifecycle pauses and resumes the camera', (tester) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump();
      expect(s.calls.last, 'stop');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();
      expect(s.calls.last, 'start');
    });

    testWidgets('disposing the screen disposes the scanner', (tester) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      await tester.pumpWidget(const SizedBox());
      expect(s.disposed, isTrue);
    });

    testWidgets(
      'a scanned code shows success, stops the camera, then returns',
      (tester) async {
        final FakeRepo repo = FakeRepo()
          ..result = const DoorOk(memberName: 'Sita Rai', daysToExpiry: 30);
        final FakeScanner s = await _pumpScreen(tester, repo: repo);

        s.emit(<String>['LG1.7.56789012']);
        s.emit(<String>['LG1.7.56789012']);
        await tester.pump();
        await tester.pump();

        expect(repo.calls, <String>['LG1.7.56789012']);
        expect(find.byKey(checkinOkKey), findsOneWidget);
        expect(find.text('30 days left'), findsOneWidget);
        expect(s.calls.last, 'stop');

        await tester.pump(const Duration(seconds: 7));
        expect(find.byKey(checkinOkKey), findsNothing);
        expect(s.calls.last, 'start');
      },
    );

    testWidgets('foreign QRs are silent, then hint after 8 s', (tester) async {
      final FakeRepo repo = FakeRepo();
      final FakeScanner s = await _pumpScreen(tester, repo: repo);
      s.emit(<String>['https://example.com']);
      await tester.pump(const Duration(seconds: 7));
      expect(find.byKey(checkinForeignHintKey), findsNothing);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byKey(checkinForeignHintKey), findsOneWidget);
      expect(repo.calls, isEmpty);
    });

    testWidgets('invalid_code view has Scan again that restarts scanning', (
      tester,
    ) async {
      final FakeRepo repo = FakeRepo()..result = const DoorInvalidCode();
      final FakeScanner s = await _pumpScreen(tester, repo: repo);
      s.emit(<String>['LG1.7.56789012']);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(checkinInvalidKey), findsOneWidget);
      await tester.tap(find.byKey(checkinScanAgainKey));
      await tester.pump();
      expect(find.byKey(checkinInvalidKey), findsNothing);
      expect(s.calls.last, 'start');
    });

    testWidgets('offline during submit shows the offline view', (tester) async {
      final FakeRepo repo = FakeRepo()
        ..error = const AppFailure(FailureKind.offline, 'No connection');
      final FakeScanner s = await _pumpScreen(tester, repo: repo);
      s.emit(<String>['LG1.7.56789012']);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(checkinOfflineKey), findsOneWidget);
    });

    testWidgets('torch toggle is shown and works', (tester) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      expect(find.byKey(checkinTorchKey), findsOneWidget);
      await tester.tap(find.byKey(checkinTorchKey));
      await tester.pump();
      expect(s.calls.last, 'torch');
      expect(find.byIcon(Icons.flashlight_on_rounded), findsOneWidget);
    });

    testWidgets('no torch button when the camera has none', (tester) async {
      final FakeScanner s = FakeScanner();
      s._torch.value = DoorTorch.unavailable;
      await _pumpScreen(tester, repo: FakeRepo(), scanner: s);
      expect(find.byKey(checkinTorchKey), findsNothing);
    });

    testWidgets('permission denied shows a card with Open settings', (
      tester,
    ) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      s.setStatus(DoorScannerStatus.permissionDenied);
      await tester.pump();
      expect(find.byKey(checkinPermissionCardKey), findsOneWidget);
      expect(find.text('Camera access is off'), findsOneWidget);
      expect(find.byKey(checkinPreviewKey), findsNothing);

      await tester.tap(find.byKey(checkinOpenSettingsKey));
      expect(s.calls.last, 'settings');

      await tester.tap(find.byKey(checkinRetryCameraKey));
      expect(s.calls.last, 'start');
    });

    testWidgets('no camera shows a message and no preview', (tester) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      s.setStatus(DoorScannerStatus.noCamera);
      await tester.pump();
      expect(find.byKey(checkinNoCameraKey), findsOneWidget);
      expect(find.byKey(checkinPreviewKey), findsNothing);
    });

    testWidgets('a camera that will not start offers Try again', (
      tester,
    ) async {
      final FakeScanner s = await _pumpScreen(tester, repo: FakeRepo());
      s.setStatus(DoorScannerStatus.error);
      await tester.pump();
      expect(find.byKey(checkinCameraErrorKey), findsOneWidget);
      await tester.tap(find.byKey(checkinRetryCameraKey));
      expect(s.calls.last, 'start');
    });

    testWidgets('renders in Nepali', (tester) async {
      final FakeScanner s = FakeScanner();
      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            doorScannerFactoryProvider.overrideWithValue(() => s),
            doorRepositoryProvider.overrideWithValue(FakeRepo()),
          ],
          child: MaterialApp(
            locale: const Locale('ne'),
            theme: appLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ScanCheckInScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(
        find.text('ढोकाको स्क्रिनमा रहेको QR कोडतर्फ क्यामेरा देखाउनुहोस्'),
        findsOneWidget,
      );
    });
  });
}
