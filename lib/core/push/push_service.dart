abstract interface class PushRegistrationService {
  Future<String?> token();
}

class DeferredPushRegistrationService implements PushRegistrationService {
  @override
  Future<String?> token() async => null;
}
