import '../../l10n/app_localizations.dart';

typedef FormValidationMessageResolver =
    String Function(FormValidationError error);

enum FormValidationError {
  fullNameRequired,
  nameMinLength,
  nameMaxLength,
  nameLettersOnly,
  emailRequired,
  emailNoSpaces,
  emailInvalid,
  passwordRequired,
  passwordMinLength,
  passwordUppercase,
  passwordLowercase,
  passwordNumber,
  confirmPasswordRequired,
  passwordsMismatch,
  familyNameRequired,
  familyNameMinLength,
  familyNameMaxLength,
  familyNameInvalid,
  invitationCodeRequired,
  invitationCodeLength,
  invitationCodeCharacters,
  memoryTitleRequired,
  memoryTitleMinLength,
  memoryTitleMaxLength,
}

class FormValidators {
  FormValidators._();

  static String _message(
    FormValidationError error,
    FormValidationMessageResolver? messageFor,
    String fallback,
  ) {
    return messageFor?.call(error) ?? fallback;
  }

  static String? validateName(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return _message(
        FormValidationError.fullNameRequired,
        messageFor,
        'Full name is required.',
      );
    }

    if (name.length < 2) {
      return _message(
        FormValidationError.nameMinLength,
        messageFor,
        'Name must contain at least 2 characters.',
      );
    }

    if (name.length > 40) {
      return _message(
        FormValidationError.nameMaxLength,
        messageFor,
        'Name cannot contain more than 40 characters.',
      );
    }

    final validNamePattern = RegExp(
      r"^[a-zA-ZÀ-ÿ\u0621-\u063A\u0641-\u064A\u064B-\u065F\u0670\u0671-\u06D3\s'-]+$",
    );

    if (!validNamePattern.hasMatch(name)) {
      return _message(
        FormValidationError.nameLettersOnly,
        messageFor,
        'Name can only contain letters.',
      );
    }

    return null;
  }

  static String? validateEmail(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return _message(
        FormValidationError.emailRequired,
        messageFor,
        'Email address is required.',
      );
    }

    if (email.contains(' ')) {
      return _message(
        FormValidationError.emailNoSpaces,
        messageFor,
        'Email address cannot contain spaces.',
      );
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return _message(
        FormValidationError.emailInvalid,
        messageFor,
        'Enter a valid email address.',
      );
    }

    return null;
  }

  static String? validatePassword(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final password = value ?? '';

    if (password.isEmpty) {
      return _message(
        FormValidationError.passwordRequired,
        messageFor,
        'Password is required.',
      );
    }

    if (password.length < 8) {
      return _message(
        FormValidationError.passwordMinLength,
        messageFor,
        'Password must contain at least 8 characters.',
      );
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return _message(
        FormValidationError.passwordUppercase,
        messageFor,
        'Password must contain an uppercase letter.',
      );
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return _message(
        FormValidationError.passwordLowercase,
        messageFor,
        'Password must contain a lowercase letter.',
      );
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return _message(
        FormValidationError.passwordNumber,
        messageFor,
        'Password must contain a number.',
      );
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password, {
    FormValidationMessageResolver? messageFor,
  }) {
    final confirmedPassword = value ?? '';

    if (confirmedPassword.isEmpty) {
      return _message(
        FormValidationError.confirmPasswordRequired,
        messageFor,
        'Please confirm your password.',
      );
    }

    if (confirmedPassword != password) {
      return _message(
        FormValidationError.passwordsMismatch,
        messageFor,
        'Passwords do not match.',
      );
    }

    return null;
  }

  static String? validateFamilyName(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final familyName = value?.trim() ?? '';

    if (familyName.isEmpty) {
      return _message(
        FormValidationError.familyNameRequired,
        messageFor,
        'Family name is required.',
      );
    }

    if (familyName.length < 2) {
      return _message(
        FormValidationError.familyNameMinLength,
        messageFor,
        'Family name must contain at least 2 characters.',
      );
    }

    if (familyName.length > 40) {
      return _message(
        FormValidationError.familyNameMaxLength,
        messageFor,
        'Family name cannot contain more than 40 characters.',
      );
    }

    final validPattern = RegExp(
      r"^[a-zA-ZÀ-ÿ0-9\u0660-\u0669\u0621-\u063A\u0641-\u064A\u064B-\u065F\u0670\u0671-\u06D3\s'-]+$",
    );

    if (!validPattern.hasMatch(familyName)) {
      return _message(
        FormValidationError.familyNameInvalid,
        messageFor,
        'Family name contains invalid characters.',
      );
    }

    return null;
  }

  static String? validateInvitationCode(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final code = value?.trim() ?? '';

    if (code.isEmpty) {
      return _message(
        FormValidationError.invitationCodeRequired,
        messageFor,
        'Invitation code is required.',
      );
    }

    if (code.length != 6) {
      return _message(
        FormValidationError.invitationCodeLength,
        messageFor,
        'Invitation code must contain exactly 6 characters.',
      );
    }

    if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(code)) {
      return _message(
        FormValidationError.invitationCodeCharacters,
        messageFor,
        'Invitation code can only contain letters and numbers.',
      );
    }

    return null;
  }

  static String? validateMemoryTitle(
    String? value, {
    FormValidationMessageResolver? messageFor,
  }) {
    final title = value?.trim() ?? '';

    if (title.isEmpty) {
      return _message(
        FormValidationError.memoryTitleRequired,
        messageFor,
        'Memory title is required.',
      );
    }

    if (title.length < 2) {
      return _message(
        FormValidationError.memoryTitleMinLength,
        messageFor,
        'Memory title must contain at least 2 characters.',
      );
    }

    if (title.length > 60) {
      return _message(
        FormValidationError.memoryTitleMaxLength,
        messageFor,
        'Memory title cannot exceed 60 characters.',
      );
    }

    return null;
  }
}

class LocalizedFormValidators {
  const LocalizedFormValidators(this.strings);

  final AppLocalizations strings;

  String? validateName(String? value) =>
      FormValidators.validateName(value, messageFor: _messageFor);

  String? validateEmail(String? value) =>
      FormValidators.validateEmail(value, messageFor: _messageFor);

  String? validatePassword(String? value) =>
      FormValidators.validatePassword(value, messageFor: _messageFor);

  String? validateConfirmPassword(String? value, String password) =>
      FormValidators.validateConfirmPassword(
        value,
        password,
        messageFor: _messageFor,
      );

  String? validateFamilyName(String? value) =>
      FormValidators.validateFamilyName(value, messageFor: _messageFor);

  String? validateInvitationCode(String? value) =>
      FormValidators.validateInvitationCode(value, messageFor: _messageFor);

  String? validateMemoryTitle(String? value) =>
      FormValidators.validateMemoryTitle(value, messageFor: _messageFor);

  String _messageFor(FormValidationError error) => switch (error) {
    FormValidationError.fullNameRequired => strings.validationFullNameRequired,
    FormValidationError.nameMinLength => strings.validationNameMinLength,
    FormValidationError.nameMaxLength => strings.validationNameMaxLength,
    FormValidationError.nameLettersOnly => strings.validationNameLettersOnly,
    FormValidationError.emailRequired => strings.validationEmailRequired,
    FormValidationError.emailNoSpaces => strings.validationEmailNoSpaces,
    FormValidationError.emailInvalid => strings.validationEmailInvalid,
    FormValidationError.passwordRequired => strings.validationPasswordRequired,
    FormValidationError.passwordMinLength =>
      strings.validationPasswordMinLength,
    FormValidationError.passwordUppercase =>
      strings.validationPasswordUppercase,
    FormValidationError.passwordLowercase =>
      strings.validationPasswordLowercase,
    FormValidationError.passwordNumber => strings.validationPasswordNumber,
    FormValidationError.confirmPasswordRequired =>
      strings.validationConfirmPasswordRequired,
    FormValidationError.passwordsMismatch =>
      strings.validationPasswordsMismatch,
    FormValidationError.familyNameRequired =>
      strings.validationFamilyNameRequired,
    FormValidationError.familyNameMinLength =>
      strings.validationFamilyNameMinLength,
    FormValidationError.familyNameMaxLength =>
      strings.validationFamilyNameMaxLength,
    FormValidationError.familyNameInvalid =>
      strings.validationFamilyNameInvalid,
    FormValidationError.invitationCodeRequired =>
      strings.validationInvitationCodeRequired,
    FormValidationError.invitationCodeLength =>
      strings.validationInvitationCodeLength,
    FormValidationError.invitationCodeCharacters =>
      strings.validationInvitationCodeCharacters,
    FormValidationError.memoryTitleRequired =>
      strings.validationMemoryTitleRequired,
    FormValidationError.memoryTitleMinLength =>
      strings.validationMemoryTitleMinLength,
    FormValidationError.memoryTitleMaxLength =>
      strings.validationMemoryTitleMaxLength,
  };
}
