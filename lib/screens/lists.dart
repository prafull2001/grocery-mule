import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smart_shopper/components/rounded_ button.dart';
import 'package:smart_shopper/constants.dart';
import 'package:smart_shopper/screens/createlist.dart';
import 'package:smart_shopper/screens/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_shopper/classes/ListData.dart';
import 'package:smart_shopper/database/updateListData.dart';
import 'package:smart_shopper/screens/user_info.dart';



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

  void updateGridView(String tripTitle, String tripDescription,
      DateTime tripDate, String unique_id) async {
    try {
      ListData data = new ListData(
          tripTitle, tripDescription, tripDate, unique_id);
      await DatabaseService(userID: curUser.email).createListData(data);
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
                    Navigator.pushNamed(context, WelcomeScreen.id);
                  },
                ),
              ],
            ),
          ),

          body: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users_test').doc(
                  curUser.email).collection('shopping_trips')
                  .snapshots(),
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
                            '\n${streamSnapshot.data.docs[index]['trip_title']}\n'
                                '${streamSnapshot.data.docs[index]['trip_description']}\n\n'
                                '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().month}'+
                                '/'+
                                '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().day}'+
                                '/'+
                                '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().year}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () async {
                            ListData curList = new ListData(streamSnapshot.data.docs[index]['trip_title'],
                                streamSnapshot.data.docs[index]['trip_description'],
                                (streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate(),
                                streamSnapshot.data.docs[index].id);
                            //check if the curData's field is null, if so, set flag
                            final updatedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateListScreen(curList))
                            );
                            if (updatedData != null) {
                              updateGridView(
                                  updatedData.name, updatedData.description,
                                  updatedData.date, updatedData.unique_id);
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
                final listData = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateListScreen(null))
                );
                updateGridView(listData.name, listData.description, listData.date, listData.unique_id);
              },
            ),
          ),
        ),
    );
  }
}