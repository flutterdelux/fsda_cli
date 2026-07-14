// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get create => 'Create';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get remove => 'Remove';

  @override
  String get delete => 'Delete';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get seeAll => 'See All';

  @override
  String get more => 'More';

  @override
  String get invalidArgumentPageTitle => 'Invalid Argument';

  @override
  String get invalidArgumentPageMessage =>
      'The requested operation could not be performed due to an invalid argument.';

  @override
  String get notFoundPageTitle => 'Not Found';

  @override
  String get notFoundPageMessage =>
      'The page you are looking for does not exist.';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get coreFailureUnauthenticated => 'Unauthenticated';

  @override
  String get coreFailureServiceUnavailable => 'Service unavailable';

  @override
  String get coreFailureNetworkError => 'Network error';

  @override
  String get coreFailureTimeoutError => 'Request timed out';

  @override
  String get coreFailureServerError => 'Server error';

  @override
  String get coreFailureCacheError => 'Cache error';
}
