/// Direct port of the validation logic from dtc-app-prototype.jsx
/// (PROJECT_SPEC.md Section 4.2) — validated on every keystroke, not on
/// submit.
String sanitizeDtcInput(String raw, String prevValid) {
  var cleaned = raw.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  cleaned = cleaned.toUpperCase();
  if (cleaned.length > 5) cleaned = cleaned.substring(0, 5);

  if (cleaned.isNotEmpty && !const ['P', 'B', 'C', 'U'].contains(cleaned[0])) {
    return prevValid;
  }
  return cleaned;
}
