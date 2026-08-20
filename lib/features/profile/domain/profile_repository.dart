import 'user_profile.dart';

abstract class ProfileRepository {
  Stream<UserProfile?> watchProfile(String uid);

  Future<UserProfile?> getProfile(String uid);

  Future<void> saveProfile(UserProfile profile);
}