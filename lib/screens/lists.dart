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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Grocery Lists'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu Options',
                style: TextStyle(
                  color: Colors.white,
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
                  itemCount: streamSnapshot.data.docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, int index) {
                    return ElevatedButton(
                      child: Text(
                        '${streamSnapshot.data.docs[index]['trip_title']}\n'
                            '${streamSnapshot.data.docs[index]['trip_description']}\n'
                            '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().month}'+
                            '/'+
                            '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().day}'+
                            '/'+
                            '${(streamSnapshot.data.docs[index]['trip_date'] as Timestamp).toDate().day}',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () async {
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
    );
  }
}