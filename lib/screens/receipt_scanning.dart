import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:grocery_mule/painters/text_detector_painter.dart';
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
      final inputImage = InputImage.fromFile(receipt_image!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);


      String text = recognizedText.text;
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          // Same getters as TextBlock
          for (TextElement element in line.elements) {
            // Same getters as TextBlock
            print(element.text);
          }
        }
      }
      textRecognizer.close();


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
