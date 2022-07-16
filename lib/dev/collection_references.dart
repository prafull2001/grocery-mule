import 'package:cloud_firestore/cloud_firestore.dart';

final CollectionReference userCollection =
    FirebaseFirestore.instance.collection('beta_users');
final CollectionReference tripCollection =
    FirebaseFirestore.instance.collection('beta_trips');
