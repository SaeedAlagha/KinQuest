class FormValidators {
  FormValidators._();

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

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    return null;
  }
}