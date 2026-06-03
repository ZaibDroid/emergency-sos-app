class ContactModel {
  final String id;
  final String name;
  final String phoneNumber;

  ContactModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'phoneNumber': phoneNumber};
  }
}
