import 'package:flutter/material.dart';
import 'package:swastil11/services.dart';
import 'HomePage.dart';
import 'SignInPage.dart';

class LandingPage extends StatelessWidget {
  LandingPage({@required this.auth});
  final AuthBase auth;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream:auth.onAuthStateChanged,
      builder: (context,snapshot){
       if(snapshot.connectionState==ConnectionState.active){
         User user=snapshot.data;
         if(user==null){
           return SignInPage(
             auth: auth,
           );
         }
         return HomePage(
           auth: auth,
         );
       }
       else{
         return Scaffold(
           body: Center(
             child: CircularProgressIndicator(),
           ),
         );
       }
      }
    );

  }
}
