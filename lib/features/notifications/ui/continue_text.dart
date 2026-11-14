import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../counter/counter.dart';

/// What the continue notification says and which counter it opens (spec
/// 0017, Req. 3, Req. 5).
typedef ContinueText = ({String title, String body, String payload});

/// The app's strings outside any widget: the notification is built while the
/// app leaves the screen (docs/conventions.md, Language: Turkish only).
AppLocalizations get _l10n => lookupAppLocalizations(const Locale('tr'));

/// Req. 3: title and one-line body, numbers with thousands separators
/// (0014 G2). The dhikr's name as written (BR-1); a tesbihat step's religious
/// text is never shown.
ContinueText continueText(ResumePoint point) {
  final l10n = _l10n;
  final n = NumberFormat.decimalPattern('tr');
  final title = switch (point) {
    DhikrResume(:final name, :final count, target: final int target) =>
      l10n.continueTitleTarget(name, n.format(count), n.format(target)),
    DhikrResume(:final name, :final count) => l10n.continueTitleNoTarget(
      name,
      n.format(count),
    ),
    TesbihatResume(:final stepNumber, :final count, :final target) =>
      l10n.continueTitleTesbihat(
        n.format(stepNumber),
        n.format(count),
        n.format(target),
      ),
  };
  return (
    title: title,
    body: l10n.continueBody,
    payload: payloadOf(point.item),
  );
}

/// The channel's name in the phone's notification settings.
String continueChannelName() => _l10n.continueChannelName;

const _dhikrPrefix = 'dhikr:';
const _tesbihat = 'tesbihat';

/// The payload that brings the user back to [item] (Req. 5).
String payloadOf(CountedItem item) => switch (item) {
  CountedDhikr(:final id) => '$_dhikrPrefix$id',
  CountedTesbihat() => _tesbihat,
};

/// The counter a payload names; null for anything else.
CountedItem? itemOf(String payload) {
  if (payload == _tesbihat) return const CountedTesbihat();
  if (!payload.startsWith(_dhikrPrefix)) return null;
  final digits = payload.substring(_dhikrPrefix.length);
  if (!RegExp(r'^[0-9]+$').hasMatch(digits)) return null;
  final id = int.tryParse(digits);
  return id == null ? null : CountedDhikr(id);
}
