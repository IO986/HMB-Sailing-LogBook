import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:hmb_sailing_log/shared/utils/network_error_text.dart';

/// The message a skipper reads at the helm when the forecast will not load.
///
/// The one it replaced, captured on the boat, was:
///   DioException [connection error]: Failed host lookup: 'api.open-meteo.com'
///   This indicates an error which most likely cannot be solved by the library
/// — written for the author of a package, and silent about the only thing
/// that mattered: the phone was on the plotter's Wi-Fi, which has no internet.
void main() {
  late AppLocalizations l;

  setUpAll(() async {
    l = await AppLocalizations.delegate.load(const Locale('sk'));
  });

  /// Exactly what Dio hands over when DNS fails on Android: errno 7.
  DioException hostLookupFailure() => DioException(
        requestOptions: RequestOptions(path: 'https://api.open-meteo.com/v1'),
        type: DioExceptionType.connectionError,
        error: const SocketException(
          "Failed host lookup: 'api.open-meteo.com'",
          osError: OSError('No address associated with hostname', 7),
        ),
      );

  test('a Wi-Fi with no internet says so, and says what to do', () {
    final text = networkErrorText(hostLookupFailure(), l);
    expect(text, l.errorNoInternetOnThisNetwork);
    // None of the library's own vocabulary reaches the skipper.
    expect(text, isNot(contains('DioException')));
    expect(text, isNot(contains('SocketException')));
    expect(text, isNot(contains('errno')));
    expect(text, isNot(contains('library')));
  });

  test('the same failure raised bare, without Dio around it', () {
    const bare = SocketException(
      "Failed host lookup: 'api.open-meteo.com'",
      osError: OSError('No address associated with hostname', 7),
    );
    expect(networkErrorText(bare, l), l.errorNoInternetOnThisNetwork);
  });

  test('a host lookup failure is recognised by text where errno differs', () {
    // iOS and Windows number the same failure differently.
    const other = SocketException(
      "Failed host lookup: 'api.open-meteo.com'",
      osError: OSError('nodename nor servname provided', 8),
    );
    expect(networkErrorText(other, l), l.errorNoInternetOnThisNetwork);
  });

  test('no network at all is a different sentence', () {
    final timeout = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.connectionTimeout,
    );
    expect(networkErrorText(timeout, l), l.errorNoConnection);
  });

  test('a server that answers badly is reported as a status, not a stack', () {
    final http500 = DioException(
      requestOptions: RequestOptions(path: '/'),
      type: DioExceptionType.badResponse,
      response: Response(
          requestOptions: RequestOptions(path: '/'), statusCode: 500),
    );
    final text = networkErrorText(http500, l);
    expect(text, contains('HTTP 500'));
    expect(text, isNot(contains('DioException')));
  });

  test('anything unexpected still yields a sentence, never a crash', () {
    expect(networkErrorText(Exception('nonsense'), l), isNotEmpty);
    expect(networkErrorText('a bare string', l), isNotEmpty);
  });
}
