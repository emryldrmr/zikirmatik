import 'package:flutter_test/flutter_test.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_list.dart';
import 'package:zikirmatik/features/counter/domain/dhikr_name.dart';

DhikrEntry _e(int id, String name) => DhikrEntry(id, DhikrName.stored(name));

void main() {
  final a = _e(1, 'Zikir');
  final b = _e(2, 'Sabah');
  final c = _e(3, 'Akşam');

  test('a stored selection pointing nowhere selects the first entry', () {
    expect(DhikrList([a, b], selectedId: 9).selectedId, 1);
    expect(DhikrList([a, b]).selectedId, 1);
    expect(DhikrList(const []).selectedId, isNull);
  });

  test('adding appends and selects the new entry', () {
    final list = DhikrList([a], selectedId: 1).added(b);
    expect(list.entries, [a, b]);
    expect(list.selected, b);
  });

  test('renaming changes only the name', () {
    final list = DhikrList([
      a,
      b,
    ], selectedId: 2).renamed(2, DhikrName.stored('Sabah zikri'));
    expect(list.entries, [a, _e(2, 'Sabah zikri')]);
    expect(list.selectedId, 2);
  });

  test('deleting the selected one selects the first remaining', () {
    expect(DhikrList([a, b, c], selectedId: 2).deleted(2).selected, a);
    expect(DhikrList([a, b, c], selectedId: 1).deleted(1).selected, b);
  });

  test('deleting another one keeps the selection', () {
    final list = DhikrList([a, b, c], selectedId: 3).deleted(1);
    expect(list.entries, [b, c]);
    expect(list.selected, c);
  });

  test('deleting the last one leaves an empty list with no selection', () {
    final list = DhikrList([a], selectedId: 1).deleted(1);
    expect(list.isEmpty, isTrue);
    expect(list.selected, isNull);
  });

  test('selecting an unknown id changes nothing', () {
    final list = DhikrList([a, b], selectedId: 2);
    expect(list.selecting(7), list);
    expect(list.selecting(1).selected, a);
  });

  test('appended keeps the selection', () {
    final list = DhikrList([a, b], selectedId: 1).appended(c);
    expect(list.entries, [a, b, c]);
    expect(list.selected, a);
    // The invariant still holds: a first entry is selected.
    expect(DhikrList(const []).appended(a).selected, a);
  });

  test('same names are separate entries', () {
    final list = DhikrList([a, _e(2, 'Zikir')]).added(_e(3, 'Zikir'));
    expect(list.entries.map((e) => e.id), [1, 2, 3]);
  });

  // Spec 0015, AC-6: a delete that was not stored is put back.
  group('restored', () {
    test('goes back to its old place in the middle', () {
      final list = DhikrList([
        a,
        c,
      ], selectedId: 3).restored(b, 1, select: false);
      expect(list.entries, [a, b, c]);
      expect(list.selected, c);
    });

    test('goes to the end when the list is now shorter', () {
      final list = DhikrList([a], selectedId: 1).restored(c, 2, select: false);
      expect(list.entries, [a, c]);
      expect(list.selected, a);
    });

    test('with select brings the selection back too', () {
      final list = DhikrList([
        b,
        c,
      ], selectedId: 2).restored(a, 0, select: true);
      expect(list.entries, [a, b, c]);
      expect(list.selected, a);
    });

    test('into an empty list selects it', () {
      final list = DhikrList(const []).restored(a, 0, select: false);
      expect(list.entries, [a]);
      expect(list.selected, a);
    });

    test('a dhikr still in the list changes nothing', () {
      final list = DhikrList([a, b], selectedId: 2);
      expect(list.restored(a, 1, select: true), list);
    });
  });
}
