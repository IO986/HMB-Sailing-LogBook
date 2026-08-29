import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Prečo sa sťahovanie nepodarilo — vetou, ktorú vie skiper použiť.
///
/// Vzniklo z reálneho záberu z lode: pri obnovení počasia sa vypísalo
/// `DioException [connection error] … Failed host lookup … This indicates an
/// error which most likely cannot be solved by the library`. To je text
/// určený autorovi knižnice, nie človeku pri kormidle, a hlavne zamlčal
/// jedinú vec, na ktorej záležalo — telefón bol pripojený na WiFi plotra,
/// ktorá nemá internet.
///
/// Rozlišujú sa tri prípady, lebo každý má inú odpoveď:
///
/// * **sieť je pripojená, ale nevedie von** (zlyhá preklad mena, `errno 7`)
///   — typicky WiFi lodných prístrojov. Riešenie: mobilné dáta.
/// * **žiadne pripojenie** — riešenie: počkať na signál.
/// * **čokoľvek iné** — server odpovedal zle; surová výnimka sa nezobrazuje,
///   ale zachová sa jej typ, aby sa dalo hlásiť, čo sa stalo.
String networkErrorText(Object error, AppLocalizations l) {
  if (_isNameResolutionFailure(error)) return l.errorNoInternetOnThisNetwork;
  if (_isConnectionFailure(error)) return l.errorNoConnection;
  return l.downloadError(_shortDescription(error));
}

/// Meno sa nepodarilo preložiť: sieť je, DNS odpoveď nie.
bool _isNameResolutionFailure(Object error) {
  final socket = _socketException(error);
  if (socket == null) return false;
  // `errno 7` je EAI_NONAME/EAI_NODATA na Androide aj Linuxe. Kontroluje sa
  // aj text, lebo na iOS a Windows má to isté zlyhanie iné číslo.
  final os = socket.osError;
  if (os != null && os.errorCode == 7) return true;
  return socket.message.toLowerCase().contains('failed host lookup');
}

bool _isConnectionFailure(Object error) {
  if (_socketException(error) != null) return true;
  if (error is DioException) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }
  return false;
}

SocketException? _socketException(Object error) {
  if (error is SocketException) return error;
  if (error is DioException) {
    final inner = error.error;
    if (inner is SocketException) return inner;
  }
  return null;
}

/// Typ chyby bez vnútorností knižnice — dosť na nahlásenie, nič navyše.
String _shortDescription(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    return status == null ? error.type.name : 'HTTP $status';
  }
  return error.runtimeType.toString();
}
