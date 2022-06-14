import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../components/rounded_ button.dart';
import '../constants.dart';

class ReceiptScanning extends StatefulWidget {
  static String id = 'receipts_scanning';

  @override
  _ReceiptScanningState createState() => _ReceiptScanningState();
}


class _ReceiptScanningState extends State<ReceiptScanning> {
  File? receipt_image;
  //final inputImage;


  Future pickImage() async{
    try{
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => receipt_image = imageTemp);

      // final inputImage = InputImage.fromFile(imageTemp);

      // setState(() {
      //   receipt_image = imageTemp;
      // });
    } on PlatformException catch(e){
      print('Failed to pick image: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Receipt Scanning'),
        backgroundColor: light_orange,
      ),
      body: Column(

        children: [
          RoundedButton(
            onPressed: () => pickImage(),
            title: "Pick Image From Gallery",
            color: Colors.blueAccent,
          ),
          SizedBox(
          height: 20,
          ),
          receipt_image != null ? Image.file(receipt_image!): Text("no image selected")
        ]
      ),

    );
  }


}
