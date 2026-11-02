import 'dhikr_name.dart';

/// One of the user's dhikrs; its counter state lives under the same [id].
final class DhikrEntry {
  const DhikrEntry(this.id, this.name);

  final int id;
  final DhikrName name;

  @override
  bool operator ==(Object other) =>
      other is DhikrEntry && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);

  @override
  String toString() => 'DhikrEntry($id, ${name.value})';
}

/// The user's dhikrs in creation order and which one is selected (spec 0003).
///
/// Invariant: when the list is not empty exactly one entry is selected; when it
/// is empty nothing is. A stored selection that points nowhere selects the
/// first entry.
final class DhikrList {
  factory DhikrList(List<DhikrEntry> entries, {int? selectedId}) {
    final ids = entries.map((e) => e.id);
    final selected = ids.contains(selectedId)
        ? selectedId
        : (entries.isEmpty ? null : entries.first.id);
    return DhikrList._(List.unmodifiable(entries), selected);
  }

  const DhikrList._(this.entries, this.selectedId);

  final List<DhikrEntry> entries;
  final int? selectedId;

  bool get isEmpty => entries.isEmpty;

  DhikrEntry? get selected {
    for (final e in entries) {
      if (e.id == selectedId) return e;
    }
    return null;
  }

  /// AC-3: a new dhikr goes to the end and becomes selected.
  DhikrList added(DhikrEntry entry) =>
      DhikrList([...entries, entry], selectedId: entry.id);

  /// AC-5: only the name changes.
  DhikrList renamed(int id, DhikrName name) => DhikrList([
    for (final e in entries) e.id == id ? DhikrEntry(id, name) : e,
  ], selectedId: selectedId);

  /// AC-6, AC-7: removing the selected one selects the first remaining.
  DhikrList deleted(int id) => DhikrList([
    for (final e in entries)
      if (e.id != id) e,
  ], selectedId: selectedId == id ? null : selectedId);

  /// AC-4: selects an existing dhikr; an unknown id changes nothing.
  DhikrList selecting(int id) => entries.any((e) => e.id == id)
      ? DhikrList(entries, selectedId: id)
      : this;

  @override
  bool operator ==(Object other) {
    if (other is! DhikrList ||
        other.selectedId != selectedId ||
        other.entries.length != entries.length) {
      return false;
    }
    for (var i = 0; i < entries.length; i++) {
      if (other.entries[i] != entries[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(selectedId, Object.hashAll(entries));

  @override
  String toString() => 'DhikrList($entries, selected: $selectedId)';
}
