class SignUpWithEmailandPasswordFailure {
  final String message;

  const SignUpWithEmailandPasswordFailure(
      [this.message = "An error occurred."]);

  factory SignUpWithEmailandPasswordFailure.code(String code) {
    switch (code) {
      case 'weak-password':
        return const SignUpWithEmailandPasswordFailure(
            'Password must contain at least 6 characters.');
      case 'invalid-email':
        return const SignUpWithEmailandPasswordFailure(
            'Please enter a valid email address.');
      case 'email-already-in-use':
        return const SignUpWithEmailandPasswordFailure(
            'Email already exists. Try logging in.');
      case 'operation-not-allowed':
        return const SignUpWithEmailandPasswordFailure(
            'Operation not allowed. Please contact support.');
      case 'user-disabled':
        return const SignUpWithEmailandPasswordFailure(
            'This user has been disabled. Please contact support.');
      default:
        return const SignUpWithEmailandPasswordFailure();
    }
  }
}
