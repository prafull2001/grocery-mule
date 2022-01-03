import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_mule/classes/ListData.dart';
import 'package:grocery_mule/classes/data_structures.dart';

class DatabaseService {
  final String uuid;
  DatabaseService({this.uuid});

  final CollectionReference userTestingCollection = FirebaseFirestore.instance.collection('users_test');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('updated_users_test');
  final CollectionReference tripCollection = FirebaseFirestore.instance.collection('shopping_trips_test');

  Future createShoppingTrip(ShoppingTrip new_trip) async{
    return await tripCollection.doc(new_trip.uuid).set({
      'uuid': new_trip.uuid,
      'date': new_trip.date,
      'title': new_trip.title,
      'description': new_trip.description,
      'host': new_trip.host,
      'beneficiaries': new_trip.beneficiaries,
      'items': new_trip.items,
      'receipt:': new_trip.items,
    });
  }
  Future updateUserData(String first, String last, String email) async{
    print(uuid);
    return await userTestingCollection.doc(uuid).update({
      'first_name': first,
      'last_name': last,
      'email': email,
    });
  }
  Future initializeUserData(Cowboy new_cowboy) async{
    return await userCollection.doc(uuid).set({
      'uuid': new_cowboy.uuid,
      'first_name': new_cowboy.first_name,
      'last_name': new_cowboy.last_name,
      'email': new_cowboy.email,
      'shopping_trips': new_cowboy.shopping_trips,
    });
  }

}