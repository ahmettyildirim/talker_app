
import 'package:talker_app/common/models/user_model.dart';

enum Providers{
  Google
}
abstract class BaseAuth{
  Future<UserModel> signInWithEmailAndPassword({String email, String password});
  Future<UserModel> signInWithProvider(Providers provider);
  Future<UserModel> currentUser();
  Future<void> signOut();

}