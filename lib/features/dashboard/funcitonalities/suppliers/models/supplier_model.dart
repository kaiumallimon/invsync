class Supplier {
  final String id;
  final String name;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final String address;
  final String website;

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.website,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['_id'],
      name: json['name'],
      contactPerson: json['contactPerson'],
      contactEmail: json['contactEmail'],
      contactPhone: json['contactPhone'],
      address: json['address'],
      website: json['website'],
    );
  }
}
