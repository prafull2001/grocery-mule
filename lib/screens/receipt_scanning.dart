import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class ReceiptScanningScreen extends StatefulWidget {
  static String id = 'receipts_screen';

  @override
  _ReceiptScanningScreenState createState() => _ReceiptScanningScreenState();
}


class _ReceiptScanningScreenState extends State<ReceiptScanningScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Receipt Scanning'),
      ),
    );
  }
}
