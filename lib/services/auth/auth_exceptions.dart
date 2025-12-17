// login exceptions
class InvalidCredentialsAuthException implements Exception {}

class UserNotFoundAuthException implements Exception {}

class UserDisabledAuthException implements Exception {}

// registration exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

// generic exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
