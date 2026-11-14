/// Which counter got the latest counting tap (spec 0017, Req. 1–2): one of
/// the user's dhikrs by id, or the tesbihat.
sealed class CountedItem {
  const CountedItem();
}

final class CountedDhikr extends CountedItem {
  const CountedDhikr(this.id);

  final int id;

  @override
  bool operator ==(Object other) => other is CountedDhikr && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CountedDhikr($id)';
}

final class CountedTesbihat extends CountedItem {
  const CountedTesbihat();

  @override
  bool operator ==(Object other) => other is CountedTesbihat;

  @override
  int get hashCode => (CountedTesbihat).hashCode;

  @override
  String toString() => 'CountedTesbihat()';
}

/// Where the user left off (spec 0017, Req. 2): the counter that got the
/// latest counting tap with its values as they are now.
sealed class ResumePoint {
  const ResumePoint();

  /// The counter this point belongs to.
  CountedItem get item;
}

/// A dhikr: its name as the user wrote it (BR-1), the current round's count
/// and its target, if any.
final class DhikrResume extends ResumePoint {
  const DhikrResume({
    required this.id,
    required this.name,
    required this.count,
    this.target,
  });

  final int id;
  final String name;
  final int count;
  final int? target;

  @override
  CountedItem get item => CountedDhikr(id);

  @override
  bool operator ==(Object other) =>
      other is DhikrResume &&
      other.id == id &&
      other.name == name &&
      other.count == count &&
      other.target == target;

  @override
  int get hashCode => Object.hash(id, name, count, target);

  @override
  String toString() =>
      'DhikrResume(id: $id, name: $name, count: $count, target: $target)';
}

/// The tesbihat: the current step (1 is the first), its count and target. The
/// step's religious text is deliberately not here (Req. 3).
final class TesbihatResume extends ResumePoint {
  const TesbihatResume({
    required this.stepNumber,
    required this.count,
    required this.target,
  });

  final int stepNumber;
  final int count;
  final int target;

  @override
  CountedItem get item => const CountedTesbihat();

  @override
  bool operator ==(Object other) =>
      other is TesbihatResume &&
      other.stepNumber == stepNumber &&
      other.count == count &&
      other.target == target;

  @override
  int get hashCode => Object.hash(stepNumber, count, target);

  @override
  String toString() =>
      'TesbihatResume(step: $stepNumber, count: $count, target: $target)';
}
