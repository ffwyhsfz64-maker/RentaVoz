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
  final bool hadFormalContract;
  final bool avalRequired;
  final bool depositReturned;
  final bool utilitiesIncluded;
  final String pros;
  final String cons;
  final List<String> photoUrls;
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
    required this.hadFormalContract,
    required this.avalRequired,
    required this.depositReturned,
    required this.utilitiesIncluded,
    required this.pros,
    required this.cons,
    required this.photoUrls,
    required this.createdAt,
  });

  double get overallRating =>
      (landlordRating + conditionRating + locationRating + securityRating) / 4;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'address': address,
        'lat': lat,
        'lng': lng,
        'moveInDate': moveInDate.toIso8601String(),
        'moveOutDate': moveOutDate.toIso8601String(),
        'monthlyRent': monthlyRent,
        'landlordRating': landlordRating,
        'conditionRating': conditionRating,
        'locationRating': locationRating,
        'securityRating': securityRating,
        'hadFormalContract': hadFormalContract,
        'avalRequired': avalRequired,
        'depositReturned': depositReturned,
        'utilitiesIncluded': utilitiesIncluded,
        'pros': pros,
        'cons': cons,
        'photoUrls': photoUrls,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Review.fromMap(String id, Map<String, dynamic> map) => Review(
        id: id,
        userId: map['userId'] as String,
        address: map['address'] as String,
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        moveInDate: DateTime.parse(map['moveInDate'] as String),
        moveOutDate: DateTime.parse(map['moveOutDate'] as String),
        monthlyRent: (map['monthlyRent'] as num).toDouble(),
        landlordRating: (map['landlordRating'] as num).toDouble(),
        conditionRating: (map['conditionRating'] as num).toDouble(),
        locationRating: (map['locationRating'] as num).toDouble(),
        securityRating: (map['securityRating'] as num).toDouble(),
        hadFormalContract: map['hadFormalContract'] as bool,
        avalRequired: map['avalRequired'] as bool,
        depositReturned: map['depositReturned'] as bool,
        utilitiesIncluded: map['utilitiesIncluded'] as bool,
        pros: map['pros'] as String,
        cons: map['cons'] as String,
        photoUrls: List<String>.from(map['photoUrls'] as List),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
