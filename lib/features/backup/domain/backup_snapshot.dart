/// A backup of all the user's data (spec 0018, Req. 1): taken at [createdAt]
/// by app [appVersion], holding [data]. Pure values; the file format lives in
/// `data/backup_json.dart`.
final class BackupSnapshot {
  const BackupSnapshot({
    required this.createdAt,
    required this.appVersion,
    required this.data,
  });

  /// When the backup was taken (shown in the restore confirmation, G8).
  final DateTime createdAt;

  /// The app version that took it; null when it could not be read.
  final String? appVersion;

  final BackupData data;

  @override
  bool operator ==(Object other) =>
      other is BackupSnapshot &&
      other.createdAt == createdAt &&
      other.appVersion == appVersion &&
      other.data == data;

  @override
  int get hashCode => Object.hash(createdAt, appVersion, data);
}

/// What a backup restores (Req. 1): the dhikrs in Zikirlerim's order (= id
/// order), the selected dhikr, the tesbihat's progress, the daily counts and
/// the settings. The Quran cache and the resume point are never in it.
final class BackupData {
  BackupData({
    required List<BackupDhikr> dhikrs,
    required this.selectedDhikrId,
    required this.tesbihat,
    required List<BackupDay> days,
    required this.settings,
  }) : dhikrs = List.unmodifiable(dhikrs),
       days = List.unmodifiable(days);

  final List<BackupDhikr> dhikrs;

  /// Null when no dhikr is selected (an empty list, or none stored).
  final int? selectedDhikrId;

  final BackupTesbihat tesbihat;
  final List<BackupDay> days;
  final BackupSettings settings;

  BackupData withSettings(BackupSettings settings) => BackupData(
    dhikrs: dhikrs,
    selectedDhikrId: selectedDhikrId,
    tesbihat: tesbihat,
    days: days,
    settings: settings,
  );

  @override
  bool operator ==(Object other) =>
      other is BackupData &&
      _sameList(other.dhikrs, dhikrs) &&
      other.selectedDhikrId == selectedDhikrId &&
      other.tesbihat == tesbihat &&
      _sameList(other.days, days) &&
      other.settings == settings;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(dhikrs),
    selectedDhikrId,
    tesbihat,
    Object.hashAll(days),
    settings,
  );

  @override
  String toString() =>
      'BackupData(dhikrs: $dhikrs, selected: $selectedDhikrId, '
      'tesbihat: $tesbihat, days: $days, settings: $settings)';
}

bool _sameList<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// One dhikr with its counter (same id).
final class BackupDhikr {
  const BackupDhikr({
    required this.id,
    required this.name,
    required this.target,
    required this.count,
    required this.rounds,
    required this.total,
  });

  final int id;
  final String name;
  final int? target;
  final int count;
  final int rounds;
  final int total;

  @override
  bool operator ==(Object other) =>
      other is BackupDhikr &&
      other.id == id &&
      other.name == name &&
      other.target == target &&
      other.count == count &&
      other.rounds == rounds &&
      other.total == total;

  @override
  int get hashCode => Object.hash(id, name, target, count, rounds, total);

  @override
  String toString() =>
      'BackupDhikr($id, $name, target: $target, count: $count, '
      'rounds: $rounds, total: $total)';
}

/// The tesbihat's progress and whether it is selected (spec 0006).
final class BackupTesbihat {
  const BackupTesbihat({
    this.step = 0,
    this.count = 0,
    this.finished = false,
    this.completions = 0,
    this.selected = false,
  });

  final int step;
  final int count;
  final bool finished;
  final int completions;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      other is BackupTesbihat &&
      other.step == step &&
      other.count == count &&
      other.finished == finished &&
      other.completions == completions &&
      other.selected == selected;

  @override
  int get hashCode => Object.hash(step, count, finished, completions, selected);

  @override
  String toString() =>
      'BackupTesbihat(step: $step, count: $count, finished: $finished, '
      'completions: $completions, selected: $selected)';
}

/// One calendar day's count (spec 0014); [day] is `YYYY-MM-DD`.
final class BackupDay {
  const BackupDay(this.day, this.count);

  final String day;
  final int count;

  @override
  bool operator ==(Object other) =>
      other is BackupDay && other.day == day && other.count == count;

  @override
  int get hashCode => Object.hash(day, count);

  @override
  String toString() => 'BackupDay($day, $count)';
}

/// The settings as stored (spec 0004 … 0017): [theme] and [handLayout] are
/// the stored names, already checked when the file was read.
final class BackupSettings {
  const BackupSettings({
    required this.vibration,
    required this.theme,
    required this.tapVibration,
    required this.keepScreenOn,
    required this.largeCount,
    required this.handLayout,
    required this.continueNotification,
  });

  final bool vibration;
  final String theme;
  final bool tapVibration;
  final bool keepScreenOn;
  final bool largeCount;
  final String handLayout;
  final bool continueNotification;

  BackupSettings withContinueNotification(bool on) => BackupSettings(
    vibration: vibration,
    theme: theme,
    tapVibration: tapVibration,
    keepScreenOn: keepScreenOn,
    largeCount: largeCount,
    handLayout: handLayout,
    continueNotification: on,
  );

  @override
  bool operator ==(Object other) =>
      other is BackupSettings &&
      other.vibration == vibration &&
      other.theme == theme &&
      other.tapVibration == tapVibration &&
      other.keepScreenOn == keepScreenOn &&
      other.largeCount == largeCount &&
      other.handLayout == handLayout &&
      other.continueNotification == continueNotification;

  @override
  int get hashCode => Object.hash(
    vibration,
    theme,
    tapVibration,
    keepScreenOn,
    largeCount,
    handLayout,
    continueNotification,
  );

  @override
  String toString() =>
      'BackupSettings(vibration: $vibration, theme: $theme, '
      'tapVibration: $tapVibration, keepScreenOn: $keepScreenOn, '
      'largeCount: $largeCount, handLayout: $handLayout, '
      'continueNotification: $continueNotification)';
}
