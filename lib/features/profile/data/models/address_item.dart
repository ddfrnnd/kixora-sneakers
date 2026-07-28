class AddressItem {
  final String id;
  String title;
  String fullAddress;
  double? latitude;
  double? longitude;
  bool isDefault;

  AddressItem({
    required this.id,
    required this.title,
    required this.fullAddress,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory AddressItem.fromMap(Map<String, dynamic> map) {
    return AddressItem(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      fullAddress: map['full_address']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['is_default'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
