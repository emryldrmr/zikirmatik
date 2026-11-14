/// Public interface of the notifications feature (docs/architecture.md,
/// FD-2). Other features and the composition root import only this file.
library;

export 'domain/continue_notifier.dart'
    show ContinueNotifier, NoContinueNotifier;
export 'ui/continue_notification_providers.dart'
    show continueNotificationEnabledProvider, continueNotifierProvider;
