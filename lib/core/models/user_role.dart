enum UserRole {
  buyer,
  seller;

  String get storageValue => name;

  static UserRole fromString(String? value) {
    if (value == 'seller') return UserRole.seller;
    return UserRole.buyer;
  }
}

/// Stock units for marketplace listings.
class StockUnit {
  const StockUnit(this.id, this.labelEn, this.labelNe);

  final String id;
  final String labelEn;
  final String labelNe;

  static const units = [
    StockUnit('kg', 'kg', 'किलो'),
    StockUnit('litre', 'litre', 'लिटर'),
    StockUnit('piece', 'piece', 'पिस'),
    StockUnit('dozen', 'dozen', 'दर्जन'),
    StockUnit('seeds', 'seeds', 'बीउ'),
    StockUnit('bag', 'bag', 'बोरा'),
  ];

  static StockUnit byId(String id) {
    return units.firstWhere((u) => u.id == id, orElse: () => units.first);
  }
}
