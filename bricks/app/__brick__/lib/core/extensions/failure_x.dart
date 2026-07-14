import 'package:app_core/app_core.dart';
import 'package:app_l10n/app_l10n.dart';
import 'package:flutter/material.dart';

extension FailureX on Failure {
  String localizeAny(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (this is CoreFailure) {
      final l10n = AppLocalizations.of(context)!;
      return switch (this as CoreFailure) {
        .cacheError => l10n.coreFailureCacheError,
        .networkError => l10n.coreFailureNetworkError,
        .timeoutError => l10n.coreFailureTimeoutError,
        .serverError => l10n.coreFailureServerError,
        .unauthenticated => l10n.coreFailureUnauthenticated,
        .serviceUnavailable => l10n.coreFailureServiceUnavailable,
      };
    }

    // Module Failures

    return l10n.unknownError;
  }
}
