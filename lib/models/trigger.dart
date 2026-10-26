class Trigger {
  final String id;
  final DateTime date;
  final String description;

  Trigger({required this.id, required this.date, required this.description});

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'description': description,
  };

  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
    id: json['id'],
    date: DateTime.parse(json['date']),
    description: json['description'],
  );
}