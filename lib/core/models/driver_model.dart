class DriverModel {
  final String driverId;      // AMB-XXXX
  final String fullName;
  final String phone;         // +91XXXXXXXXXX
  final String aadhaar;       // 12-digit text only
  final String licence;
  final String vehiclePlate;
  final String profilePhotoUrl;
  final String vehiclePhotoUrl;
  final String fcmToken;
  final DateTime createdAt;

  const DriverModel({
    required this.driverId,
    required this.fullName,
    required this.phone,
    required this.aadhaar,
    required this.licence,
    required this.vehiclePlate,
    this.profilePhotoUrl = '',
    this.vehiclePhotoUrl = '',
    this.fcmToken = '',
    required this.createdAt,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map) {
    return DriverModel(
      driverId: map['driverId'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      aadhaar: map['aadhaar'] ?? '',
      licence: map['licence'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
      vehiclePhotoUrl: map['vehiclePhotoUrl'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'fullName': fullName,
      'phone': phone,
      'aadhaar': aadhaar,
      'licence': licence,
      'vehiclePlate': vehiclePlate,
      'profilePhotoUrl': profilePhotoUrl,
      'vehiclePhotoUrl': vehiclePhotoUrl,
      'fcmToken': fcmToken,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DriverModel copyWith({
    String? driverId,
    String? fullName,
    String? phone,
    String? aadhaar,
    String? licence,
    String? vehiclePlate,
    String? profilePhotoUrl,
    String? vehiclePhotoUrl,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return DriverModel(
      driverId: driverId ?? this.driverId,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      aadhaar: aadhaar ?? this.aadhaar,
      licence: licence ?? this.licence,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      vehiclePhotoUrl: vehiclePhotoUrl ?? this.vehiclePhotoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
