class DtcResult {
  final String code;
  final String meaning;
  final String severity;
  final List<String> causes;
  final String action;
  final String symptoms;

  const DtcResult({
    required this.code,
    required this.meaning,
    required this.severity,
    required this.causes,
    required this.action,
    required this.symptoms,
  });

  factory DtcResult.fromRow(Map<String, dynamic> row) {
    return DtcResult(
      code: row['code'] as String,
      meaning: row['meaning'] as String,
      severity: row['severity'] as String,
      causes: List<String>.from(row['causes'] as List),
      action: row['action'] as String,
      symptoms: row['symptoms'] as String,
    );
  }
}
