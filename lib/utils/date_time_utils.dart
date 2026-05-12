DateTime localDateTime(DateTime date) {
  return date.isUtc ? date.toLocal() : date;
}

DateTime? parseLocalDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

String toBackendIsoString(DateTime date) {
  return date.toUtc().toIso8601String();
}
