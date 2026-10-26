class Entry {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final int severity; // 1-5
  final String? note;

  Entry({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.severity,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'symptoms': symptoms,
    'severity': severity,
    'note': note,
  };

  factory Entry.fromJson(Map<String, dynamic> json) => Entry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    symptoms: List<String>.from(json['symptoms']),
    severity: json['severity'],
    note: json['note'],
  );
}

const List<String> allSymptoms = [
  'Fast Heartbeat',
  'Headache',
  'Back Pain',
  'Emotional Stress',
  'Anxiety',
  'Tingling in Head',
  'Flashbacks',
  'Nightmares',
  'Dizziness',
  'Nausea',
];