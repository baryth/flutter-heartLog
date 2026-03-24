class Measurement {
  final int? id;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String datetime;

  const Measurement({
    this.id,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.datetime,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse': pulse,
        'datetime': datetime,
      };

  factory Measurement.fromMap(Map<String, dynamic> map) => Measurement(
        id: map['id'] as int?,
        systolic: map['systolic'] as int,
        diastolic: map['diastolic'] as int,
        pulse: map['pulse'] as int,
        datetime: map['datetime'] as String,
      );
}
