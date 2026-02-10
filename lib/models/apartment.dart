class Apartment {
  int? id;
  int number;
  int floor;
  int? buildingId; // Связь со зданием
  
  Apartment({
    this.id,
    required this.number,
    required this.floor,
    this.buildingId,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'floor': floor,
    'buildingId': buildingId,
  };
  
  factory Apartment.fromJson(Map<String, dynamic> json) => Apartment(
    id: json['id'],
    number: json['number'],
    floor: json['floor'],
    buildingId: json['buildingId'],
  );
}