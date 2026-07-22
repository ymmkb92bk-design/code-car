import 'dtc_result.dart';

enum SearchOutcomeType { found, notFound, quotaExceeded, rateLimited }

class SearchOutcome {
  final SearchOutcomeType type;
  final DtcResult? result;

  const SearchOutcome._(this.type, this.result);

  factory SearchOutcome.found(DtcResult result) => SearchOutcome._(SearchOutcomeType.found, result);
  factory SearchOutcome.notFound() => const SearchOutcome._(SearchOutcomeType.notFound, null);
  factory SearchOutcome.quotaExceeded() => const SearchOutcome._(SearchOutcomeType.quotaExceeded, null);
  factory SearchOutcome.rateLimited() => const SearchOutcome._(SearchOutcomeType.rateLimited, null);
}
