class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String? notes;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'frequency': frequency,
    'notes': notes,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'],
    name: json['name'],
    dosage: json['dosage'],
    frequency: json['frequency'],
    notes: json['notes'],
  );
}