import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
);

/// Kľúč k WorldTides API, ktorý appka kedysi vyžadovala pre predpoveď
/// prílivu. Predpoveď dnes berieme z Open-Meteo, kde sa kľúč nepoužíva.
const _kLegacyTideApiKey = 'tide_api_key';

/// Zmaže zvyšný WorldTides kľúč zo secure storage.
///
/// Beží pri každom štarte — po prvom zmazaní je to lacný no-op. Cudzí
/// credential nemá čo ležať v zariadení potom, čo ho appka prestala
/// používať.
Future<void> purgeLegacyTideApiKey() async {
  try {
    await _storage.delete(key: _kLegacyTideApiKey);
  } catch (_) {
    // Secure storage vie na niektorých zariadeniach zamrznúť alebo zlyhať
    // (viď keystore hang pri profile skipéra). Upratovanie nesmie zablokovať
    // štart appky — skúsi sa znova nabudúce.
  }
}
