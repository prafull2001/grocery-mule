import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_shopper/classes/ListData.dart';

class DatabaseService {
  final String userID;
  DatabaseService({this.userID});

  final CollectionReference userTestingCollection = FirebaseFirestore.instance.collection('users_test');


  Future createListData(ListData newList) async{
    print(userID);
    return await userTestingCollection.doc(userID).collection('shopping_trips').doc(newList.unique_id).set({
      'trip_title': newList.name,
      'trip_description': newList.description,
      'trip_date': newList.date,
    });
  }
  Future updateUserData(String first, String last, String email) async{
    print(userID);
    return await userTestingCollection.doc(userID).update({
      'first_name': first,
      'last_name': last,
      'email': email,
    });
  }
  Future initializeUserData(String first, String last, String email) async{
    return await userTestingCollection.doc(userID).set({
      'first_name': first,
      'last_name': last,
      'email': email,
    });
  }

}