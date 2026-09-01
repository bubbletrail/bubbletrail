import 'package:btproto/btproto.dart';

import 'ext.dart';

const _recentWindow = Duration(days: 30);
const _frequentWindow = Duration(days: 180);
const _frequentThreshold = 10;

extension DiveListBuddies on Iterable<Dive> {
  // The buddies worth offering first when editing a dive: anyone dived with
  // during the last month, plus anyone dived with at least ten times during
  // the last six months. Deleted dives don't count towards either.
  Set<String> activeBuddies({DateTime? now}) {
    final at = now ?? DateTime.now();
    final recentCutoff = at.subtract(_recentWindow);
    final frequentCutoff = at.subtract(_frequentWindow);

    final active = <String>{};
    final diveCounts = <String, int>{};
    for (final dive in this) {
      if (dive.meta.isDeleted) continue;
      final start = dive.start.toDateTime();
      if (start.isAfter(recentCutoff)) {
        // Recent enough to qualify on their own, no need to also count them.
        active.addAll(dive.buddies);
      } else if (start.isAfter(frequentCutoff)) {
        // Only the frequency threshold can qualify them, so count the dive.
        for (final buddy in dive.buddies) {
          diveCounts[buddy] = (diveCounts[buddy] ?? 0) + 1;
        }
      }
    }
    diveCounts.forEach((buddy, count) {
      if (count >= _frequentThreshold) active.add(buddy);
    });
    return active;
  }
}
