class CustomerModel {
  int? id;
  String name;
  String phone;
  String location;
  // DateTime createdAt;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    required this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'location': location,
      // 'created_at': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      location: map['location'],
      // createdAt: DateTime.parse(map['created_at']),
    );
  }
}