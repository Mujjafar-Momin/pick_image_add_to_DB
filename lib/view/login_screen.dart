import 'package:flutter/material.dart';
import 'package:mvvm/utils/constants/user_image.dart';
import 'package:mvvm/utils/routes/routes_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String imageUrl='';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:const Icon(Icons.arrow_back),
        title: const Text('Add New Item'),
      ),
      body: ListView(
        children: [
        const  SizedBox(height: 20,),
        UserImage(onFileChanged: (imageUrl){
          setState(){
            this.imageUrl=imageUrl;
          }
        })
        ],
      )
    );
  }
}
