class FormValidators {
  FormValidators._();

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return 'Full name is required.';
    }

    if (name.length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    if (name.length > 40) {
      return 'Name cannot contain more than 40 characters.';
    }

    final validNamePattern = RegExp(r"^[a-zA-ZÀ-ÿ\s'-]+$");

    if (!validNamePattern.hasMatch(name)) {
      return 'Name can only contain letters.';
    }

    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return 'Email address is required.';
    }

    if (email.contains(' ')) {
      return 'Email address cannot contain spaces.';
    }

    final emailPattern = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Password is required.';
    }

    if (password.length < 8) {
      return 'Password must contain at least 8 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number.';
    }

    return null;
  }

  static String? validateConfirmPassword(
    String? value,
    String password,
  ) {
    final confirmedPassword = value ?? '';

    if (confirmedPassword.isEmpty) {
      return 'Please confirm your password.';
    }

    if (confirmedPassword != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
  static String? validateFamilyName(String? value) {
  final familyName = value?.trim() ?? '';

  if (familyName.isEmpty) {
    return 'Family name is required.';
  }

  if (familyName.length < 2) {
    return 'Family name must contain at least 2 characters.';
  }

  if (familyName.length > 40) {
    return 'Family name cannot contain more than 40 characters.';
  }

  final validPattern = RegExp(r"^[a-zA-ZÀ-ÿ0-9\s'-]+$");

  if (!validPattern.hasMatch(familyName)) {
    return 'Family name contains invalid characters.';
  }

  return null;
}
static String? validateInvitationCode(String? value) {
  final code = value?.trim() ?? '';

  if (code.isEmpty) {
    return 'Invitation code is required.';
  }

  if (code.length != 6) {
    return 'Invitation code must contain exactly 6 characters.';
  }

  if (!RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(code)) {
    return 'Invitation code can only contain letters and numbers.';
  }

  return null;
}
}