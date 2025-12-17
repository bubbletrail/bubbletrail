/// Mixin for details BLoC states that follow the loading/loaded/error pattern.
///
/// This provides a common interface for [DetailsAvailable] to check state types
/// without needing to know the specific BLoC state class.
mixin DetailsStateMixin {
  bool get isInitial => false;
  bool get isLoading => false;
  bool get isLoaded => false;
  bool get isError => false;
  String? get errorMessage => null;
}

/// Mixin for the initial state
mixin DetailsInitialMixin implements DetailsStateMixin {
  @override
  bool get isInitial => true;
  @override
  bool get isLoading => false;
  @override
  bool get isLoaded => false;
  @override
  bool get isError => false;
  @override
  String? get errorMessage => null;
}

/// Mixin for the loading state
mixin DetailsLoadingMixin implements DetailsStateMixin {
  @override
  bool get isInitial => false;
  @override
  bool get isLoading => true;
  @override
  bool get isLoaded => false;
  @override
  bool get isError => false;
  @override
  String? get errorMessage => null;
}

/// Mixin for the loaded state
mixin DetailsLoadedMixin implements DetailsStateMixin {
  @override
  bool get isInitial => false;
  @override
  bool get isLoading => false;
  @override
  bool get isLoaded => true;
  @override
  bool get isError => false;
  @override
  String? get errorMessage => null;
}

/// Mixin for the error state - requires [errorMessage] to be implemented
mixin DetailsErrorMixin implements DetailsStateMixin {
  @override
  bool get isInitial => false;
  @override
  bool get isLoading => false;
  @override
  bool get isLoaded => false;
  @override
  bool get isError => true;
  @override
  String? get errorMessage;
}
