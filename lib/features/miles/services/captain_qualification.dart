import '../../../core/models/crew_member_ref.dart';
import '../../../core/models/skipper_profile.dart';

/// The highest qualification to offer for the captain of a voyage, or `null`
/// when nobody ever wrote one down.
///
/// The voyage's own skipper card comes first: it is what the skipper entered
/// for that voyage. The remembered profile of the phone's owner is the
/// fallback. A licence number is not a qualification and is never offered
/// here; guessing one from it would put a number where "Yacht Master" belongs.
String? suggestedQualification({
  required List<CrewMemberRef> crew,
  required SkipperProfile profile,
}) {
  for (final member in crew) {
    final q = member.qualification?.trim();
    if (member.isSkipper && q != null && q.isNotEmpty) return q;
  }
  final remembered = profile.licenseType.trim();
  return remembered.isEmpty ? null : remembered;
}
