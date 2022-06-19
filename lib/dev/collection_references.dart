import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final CollectionReference userCollection = FirebaseFirestore.instance.collection('paypal_users');
final CollectionReference tripCollection = FirebaseFirestore.instance.collection('paypal_shopping_trips');