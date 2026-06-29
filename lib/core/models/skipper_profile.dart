class SkipperProfile {
  final String fullName;
  final String licenseType;
  final String licenseNumber;
  final String licenseAuthority;
  final String licenseExpiry;
  final String vhfNumber;
  final String vhfExpiry;
  final String otherCerts;

  const SkipperProfile({
    this.fullName = '',
    this.licenseType = '',
    this.licenseNumber = '',
    this.licenseAuthority = '',
    this.licenseExpiry = '',
    this.vhfNumber = '',
    this.vhfExpiry = '',
    this.otherCerts = '',
  });

  bool get isEmpty =>
      fullName.isEmpty &&
      licenseNumber.isEmpty &&
      vhfNumber.isEmpty &&
      otherCerts.isEmpty;
}
