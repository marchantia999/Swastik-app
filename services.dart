import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
class User{

  User({@required this.uid});
  final String uid;
}
abstract class AuthBase{
  Stream<User>get onAuthStateChanged;
  Future<User>currentUser();
  Future<User>signInAnonymously();
  Future<void>signOut();
  Future<User> signInWithGoogle();
  Future<User>signInWithFacebook();
  Future<User>createUserWithEmailAndPassword(String email,String password);
  Future<User>signInWithEmailAndPassword(String email,String password);
}
class Auth implements AuthBase{
  User _userFromFirebase(FirebaseUser user){
    if(user==null){
      return null;
    }
    return User(uid: user.uid);
  }
  final _firebaseAuth=FirebaseAuth.instance;
  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }
  @override
  Future<User>signInWithEmailAndPassword(String email,String password)async{
    final authResult=await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(authResult.user);
  }
  @override
  Future<User>createUserWithEmailAndPassword(String email,String password)async{
    final authResult=await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _userFromFirebase(authResult.user);
  }
  @override
  Future<User>currentUser()async{
    final user=await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }
  @override
  Future<User>signInAnonymously()async{
    final authResult= await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(authResult.user);
  }
 @override
  Future<User> signInWithGoogle()async {


    final googleSignIn = GoogleSignIn();
    final googleAccount = await googleSignIn.signIn();
    if (googleAccount != null) {
      final googleAuth = await googleAccount
          .authentication;
      if (googleAuth.idToken != null && googleAuth.accessToken != null){
        final authResult = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.getCredential(
              idToken: googleAuth.idToken, accessToken: googleAuth.accessToken
          ),
        );
      return _userFromFirebase(authResult.user);
    }else{
        throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
            message: 'missing google auth token',
        );
      }
  }
    else{
      throw PlatformException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'sign in aborted by user',
      );
    }
  }
  @override
  Future<User>signInWithFacebook() async{

   final facebookLogin=FacebookLogin();
   final result =await facebookLogin.logInWithReadPermissions(
       ['Public Profile']
   );
   if(result.accessToken !=null){
     final authResult=await _firebaseAuth.signInWithCredential(
       FacebookAuthProvider.getCredential(
         accessToken: result.accessToken.token,
       ),
     );


     return _userFromFirebase(authResult.user);
   }else{
     throw PlatformException(
       code: 'ERROR_ABORTED_BY_USER',
       message: 'sign in aborted by user',
     );
   }
  }
  @override
  Future<void>signOut()async{
    final googleSignIn=GoogleSignIn();
    await googleSignIn.signOut();
    final facebookLogin=FacebookLogin();
    await facebookLogin.logOut();
    await _firebaseAuth.signOut();
  }

}