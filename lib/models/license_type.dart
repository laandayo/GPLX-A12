enum LicenseType { a1, a2 }

extension LicenseTypeExtension on LicenseType {
  String get displayName {
    switch (this) {
      case LicenseType.a1:
        return 'A1';
      case LicenseType.a2:
        return 'A';
    }
  }

  String get icon {
    switch (this) {
      case LicenseType.a1:
        return '🚗';
      case LicenseType.a2:
        return '🚙';
    }
  }
}
