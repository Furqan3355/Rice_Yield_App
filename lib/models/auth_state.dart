class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? userEmail;
  final String? userName;
  final String? userId;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.userEmail,
    this.userName,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? userEmail,
    String? userName,
    String? userId,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : error ?? this.error,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
    );
  }

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, userEmail: $userEmail)';
  }
}