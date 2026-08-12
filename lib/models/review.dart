import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String userId;
  final String address;
  final double lat;
  final double lng;
  final DateTime moveInDate;
  final DateTime moveOutDate;
  final double monthlyRent;
  final double landlordRating;
  final double conditionRating;
  final double locationRating;
  final double securityRating;
  final String rentalType; // 'house' | 'room' | 'apartment'
  final bool sharedBathroom;
  final bool sharedKitchen;
  final bool hadFormalContract;
  final bool avalRequired;
  final bool depositReturned;
  final bool utilitiesIncluded;
  final String pros;
  final String cons;
  final List<String> photoUrls;
  final String? comprobanteUrl;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.address,
    required this.lat,
    required this.lng,
    required this.moveInDate,
    required this.moveOutDate,
    required this.monthlyRent,
    required this.landlordRating,
    required this.conditionRating,
    required this.locationRating,
    required this.securityRating,
    this.rentalType = 'house',
    this.sharedBathroom = false,
    this.sharedKitchen = false,
    required this.hadFormalContract,
    required this.avalRequired,
    required this.depositReturned,
    required this.utilitiesIncluded,
    required this.pros,
    required this.cons,
    required this.photoUrls,
    this.comprobanteUrl,
    required this.createdAt,
  });

  bool get isVerified {
    if (comprobanteUrl == null) return false;
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    return moveOutDate.isAfter(threeMonthsAgo);
  }

  double get overallRating =>
      (landlordRating + conditionRating + locationRating + securityRating) / 4;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'address': address,
        'lat': lat,
        'lng': lng,
        'moveInDate': Timestamp.fromDate(moveInDate),
        'moveOutDate': Timestamp.fromDate(moveOutDate),
        'monthlyRent': monthlyRent,
        'overallRating': overallRating,
        'landlordRating': landlordRating,
        'conditionRating': conditionRating,
        'locationRating': locationRating,
        'securityRating': securityRating,
        'rentalType': rentalType,
        'sharedBathroom': sharedBathroom,
        'sharedKitchen': sharedKitchen,
        'hadFormalContract': hadFormalContract,
        'avalRequired': avalRequired,
        'depositReturned': depositReturned,
        'utilitiesIncluded': utilitiesIncluded,
        'pros': pros,
        'cons': cons,
        'photoUrls': photoUrls,
        if (comprobanteUrl != null) 'comprobanteUrl': comprobanteUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Review.fromMap(String id, Map<String, dynamic> map) => Review(
        id: id,
        userId: map['userId'] as String,
        address: map['address'] as String,
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        moveInDate: _parseDate(map['moveInDate']),
        moveOutDate: _parseDate(map['moveOutDate']),
        monthlyRent: (map['monthlyRent'] as num).toDouble(),
        landlordRating: (map['landlordRating'] as num).toDouble(),
        conditionRating: (map['conditionRating'] as num).toDouble(),
        locationRating: (map['locationRating'] as num).toDouble(),
        securityRating: (map['securityRating'] as num).toDouble(),
        rentalType: (map['rentalType'] as String?) ?? 'house',
        sharedBathroom: (map['sharedBathroom'] as bool?) ?? false,
        sharedKitchen: (map['sharedKitchen'] as bool?) ?? false,
        hadFormalContract: map['hadFormalContract'] as bool,
        avalRequired: map['avalRequired'] as bool,
        depositReturned: map['depositReturned'] as bool,
        utilitiesIncluded: map['utilitiesIncluded'] as bool,
        pros: map['pros'] as String,
        cons: map['cons'] as String,
        photoUrls: List<String>.from(map['photoUrls'] as List),
        comprobanteUrl: map['comprobanteUrl'] as String?,
        createdAt: _parseDate(map['createdAt']),
      );

  static DateTime _parseDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is String) return DateTime.parse(v);
    return DateTime.now();
  }
}
