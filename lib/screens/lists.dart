import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_mule/components/rounded_ button.dart';
import 'package:grocery_mule/constants.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_mule/classes/ListData.dart';
import 'package:grocery_mule/classes/data_structures.dart';
import 'package:grocery_mule/database/updateListData.dart';
import 'package:grocery_mule/screens/user_info.dart';



class ListsScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;
  static String id = 'lists_screen';

  @override
  _ListsScreenState createState() => _ListsScreenState();
}


class _ListsScreenState extends State<ListsScreen> {

  final _auth = FirebaseAuth.instance;
  final User curUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void updateGridView(String tripTitle, String tripDescription, DateTime tripDate, String temp_uuid, bool new_trip) async {
    try {
      // ListData data = new ListData(tripTitle, tripDescription, tripDate, unique_id);
      var host = 'cringe';
      var beneficiaries = ['cringo', 'cringo', 'cringo'];
      ShoppingTrip temp_trip = new ShoppingTrip(tripTitle, tripDate, tripDescription, host, beneficiaries);
      temp_trip.uuid = temp_uuid;
      if(new_trip) {
        await DatabaseService(uuid: temp_uuid).createShoppingTrip(temp_trip);
      } else {
        await DatabaseService(uuid: temp_uuid).updateShoppingTrip(temp_trip);
      }
    } catch (e) {
      print(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    print('pulling data');
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Grocery Lists'),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf57f17),
                  ),
                  child: Text(
                    'Menu Options',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, UserInfoScreen.id);
                  },
                ),
                ListTile(
                  title: const Text('Log Out'),
                  onTap: () async {
                    var currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null) {
                      await _auth.signOut();
                      print('User signed out');
                    }
                    Navigator.pop(context);
                    Navigator.of(context).popUntil((route){
                      return route.settings.name == WelcomeScreen.id;
                    });
                    Navigator.pushNamed(context, WelcomeScreen.id);
                  },
                ),
              ],
            ),
          ),

          body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('shopping_trips_test').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if(streamSnapshot.data == null) return CircularProgressIndicator();
                return SafeArea(
                  child: Scrollbar(
                  isAlwaysShown: true,
                  child: GridView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: streamSnapshot.data.docs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 7),
                    itemBuilder: (context, int index) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFFf57f17),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFffab91),
                              blurRadius: 3,
                              offset: Offset(3, 6), // Shadow position
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            '\n${streamSnapshot.data.docs[index]['title']}\n'
                                '${streamSnapshot.data.docs[index]['description']}\n\n'
                                '${(streamSnapshot.data.docs[index]['date'] as Timestamp).toDate().month}'+
                                '/'+
                                '${(streamSnapshot.data.docs[index]['date'] as Timestamp).toDate().day}'+
                                '/'+
                                '${(streamSnapshot.data.docs[index]['date'] as Timestamp).toDate().year}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () async {
                            ShoppingTrip cur_trip = new ShoppingTrip(streamSnapshot.data.docs[index]['title'],
                                (streamSnapshot.data.docs[index]['date'] as Timestamp).toDate(),
                                streamSnapshot.data.docs[index]['description'],
                                curUser.uid, []);
                            cur_trip.uuid = streamSnapshot.data.docs[index]['uuid'];
                            print("lists.dart method (uuid): "+cur_trip.uuid);
                            //check if the curData's field is null, if so, set flag
                            //print("rig rag shig shag: "+cur_trip.uuid);
                            final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => CreateListScreen(cur_trip))
                            );
                            if (updatedData != null) {
                              updateGridView(updatedData.title, updatedData.description, updatedData.date, cur_trip.uuid, false);
                            } else {
                              print('no changes made to be saved!');
                            }
                          },
                        ),
                      );
                    },
                  ),
                  ),
                );
              }
          ),

          floatingActionButton: Container(
            height: 80,
            width: 80,
            child: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final shopping_trip = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateListScreen(new ShoppingTrip('', new DateTime.now(), '', curUser.uid, [])))
                );
                updateGridView(shopping_trip.title, shopping_trip.description, shopping_trip.date, shopping_trip.uuid, true);
              },
            ),
          ),
        ),
    );
  }
}