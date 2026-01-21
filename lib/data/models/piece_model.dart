class PieceModel {
  int? id;
  String? customerPhone;
  String name;
  String type;
  double price;
  double length;
  double width;
  String notes;
  double paidAmount;
  DateTime createdAt;

  PieceModel({
    this.id,
    required this.customerPhone,
    required this.name,
    required this.type,
    required this.price,
    required this.length,
    required this.width,
    required this.notes,
    required this.paidAmount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_phone': customerPhone,
      'name': name,
      'type': type,
      'price': price,
      'length': length,
      'width': width,
      'notes': notes,
      'paid_amount': paidAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PieceModel.fromMap(Map<String, dynamic> map) {
    return PieceModel(
      id: map['id'],
      customerPhone: map['customer_phone'],
      name: map['name'],
      type: map['type'],
      price: map['price'],
      length: map['length'],
      width: map['width'],
      notes: map['notes'],
      paidAmount: map['paid_amount'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  double get remainingAmount => price - paidAmount;
}