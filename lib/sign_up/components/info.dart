import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinterest_clone/log_in/login_screen.dart';
import 'package:pinterest_clone/widgets/account_check.dart';
import 'package:pinterest_clone/widgets/rectangular_button.dart';
import 'package:pinterest_clone/widgets/rectangular_input_field.dart';

import '../../home_screen.dart';

class Credentials extends StatefulWidget {
  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late TextEditingController _fullNameController = TextEditingController(text: '');

  late TextEditingController _emailTextController = TextEditingController(text: '');

  late TextEditingController _passTextController = TextEditingController(text: '');

  File? imageFile;

  String? imageURL;

  void _getFromGallery() async{
    PickedFile? pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxHeight: 1080,
        maxWidth: 1080,
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _getFromCamera() async{
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    _cropImage(pickedFile!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async{
    File? croppedImage = await ImageCropper().cropImage(
    sourcePath: filePath, maxHeight: 1080, maxWidth: 1080
    );
    if(croppedImage != null){
      setState((){
        imageFile = croppedImage;
      });
    }
  }

  void _showImageDialog(){
  showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text('Please choose an option'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: (){
              _getFromCamera();
            },
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.camera,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  'Camera',
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
          InkWell(
            onTap: (){
              _getFromGallery();
            },
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.image,
                    color: Colors.purple,
                  ),
                ),
                Text(
                  'Gallery',
                  style: TextStyle(color: Colors.red),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: (){
              _showImageDialog();
            },
            child: CircleAvatar(
              radius: 60,
              backgroundImage: imageFile == null ? AssetImage(
                "assets/avatar.png",
              ): Image.file(imageFile!).image,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RectangularInputField(
              hintText: 'Enter Username',
              icon: Icons.person,
              obscureText: false,
              textEditingController: _fullNameController
          ),
          SizedBox(
            height: 30.0 / 2,
          ),
          RectangularInputField(
              hintText: 'Enter Email',
              icon: Icons.email_rounded,
              obscureText: false,
              textEditingController: _emailTextController
          ),
          SizedBox(
            height: 30.0 / 2,
          ),
          RectangularInputField(
              hintText: 'Enter Password',
              icon: Icons.lock,
              obscureText: true,
              textEditingController: _passTextController
          ),
          SizedBox(
            height: 30.0 / 2,
          ),
          RectangularButton(
            text: 'Create Account',
            colors1: Colors.red,
            colors2: Colors.redAccent,
            press: () async {

              if(imageFile == null){
                Fluttertoast.showToast(msg: 'Please select an image');
                return;
              }
              try{
                final ref = FirebaseStorage.instance.ref().child('userImages').child(DateTime.now().toString() + '.jpg');
                await ref.putFile(imageFile!);
                imageURL = await ref.getDownloadURL();
                await _auth.createUserWithEmailAndPassword(
                email: _emailTextController.text.trim().toLowerCase(),
                password: _passTextController.text.trim(),
                );
                final User? user = _auth.currentUser;
                final _uid = user!.uid;
                FirebaseFirestore.instance.collection('users').doc(_uid).set({
                'id' : _uid,
                'userImage' : imageURL,
                'name' : _fullNameController.text,
                'email' : _emailTextController.text,
                'createdAt' : Timestamp.now(),
                });
                Navigator.canPop(context) ? Navigator.pop(context): null;
                } catch(error){
                Fluttertoast.showToast(msg: error.toString());
              }
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
            },
          ),
          AccountCheck(
              login: false,
              press: (){
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
          ),
        ],
      ),

    );
  }
}
