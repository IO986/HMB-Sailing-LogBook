class SkipperProfile {
  final String fullName;
  final String licenseType;
  final String licenseNumber;
  final String licenseAuthority;
  final String licenseExpiry;
  final String vhfNumber;
  final String vhfExpiry;
  final String otherCerts;

  /// Číslo pasu alebo občianskeho preukazu držiteľa telefónu.
  ///
  /// Potvrdenie o naplávaných míľach ho tlačí, lebo ho pýta škola aj úrad.
  /// Uložené je len toto jedno — svoje. Doklady posádky appka neuchováva,
  /// tie sa zadávajú až pri vystavovaní konkrétneho potvrdenia.
  final String idNumber;

  const SkipperProfile({
    this.fullName = '',
    this.licenseType = '',
    this.licenseNumber = '',
    this.licenseAuthority = '',
    this.licenseExpiry = '',
    this.vhfNumber = '',
    this.vhfExpiry = '',
    this.otherCerts = '',
    this.idNumber = '',
  });

  bool get isEmpty =>
      fullName.isEmpty &&
      licenseNumber.isEmpty &&
      vhfNumber.isEmpty &&
      otherCerts.isEmpty;

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'licenseType': licenseType,
        'licenseNumber': licenseNumber,
        'licenseAuthority': licenseAuthority,
        'licenseExpiry': licenseExpiry,
        'vhfNumber': vhfNumber,
        'vhfExpiry': vhfExpiry,
        'otherCerts': otherCerts,
        'idNumber': idNumber,
      };

  factory SkipperProfile.fromJson(Map<String, dynamic> json) => SkipperProfile(
        fullName: json['fullName'] as String? ?? '',
        licenseType: json['licenseType'] as String? ?? '',
        licenseNumber: json['licenseNumber'] as String? ?? '',
        licenseAuthority: json['licenseAuthority'] as String? ?? '',
        licenseExpiry: json['licenseExpiry'] as String? ?? '',
        vhfNumber: json['vhfNumber'] as String? ?? '',
        vhfExpiry: json['vhfExpiry'] as String? ?? '',
        otherCerts: json['otherCerts'] as String? ?? '',
        idNumber: json['idNumber'] as String? ?? '',
      );
}
