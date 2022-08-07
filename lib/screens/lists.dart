import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grocery_mule/dev/collection_references.dart';
import 'package:grocery_mule/providers/cowboy_provider.dart';
import 'package:grocery_mule/providers/shopping_trip_provider.dart';
import 'package:grocery_mule/screens/createlist.dart';
import 'package:grocery_mule/screens/email_reauth.dart';
import 'package:grocery_mule/screens/friend_screen.dart';
import 'package:grocery_mule/screens/user_info.dart';
import 'package:grocery_mule/screens/welcome_screen.dart';
import 'package:grocery_mule/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import 'editlist.dart';

class UserName extends StatefulWidget {
  late final String userUUID;
  UserName(String userUUID) {
    this.userUUID = userUUID;
  }

  @override
  _UserNameState createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  late String userUUID;
  @override
  void initState() {
    userUUID = widget.userUUID;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userCollection.doc(userUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot == null || snapshot.data == null) {
            return Text('Howdy!', style: TextStyle(fontSize: 25, color: Colors.black));
          }
          return Text('Howdy ${snapshot.data!['first_name']}!',
              style: TextStyle(fontSize: 25, color: Colors.white));
        });
  }
}

class ListsScreen extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  static String id = 'lists_screen';

  @override
  _ListsScreenState createState() => _ListsScreenState();
}

class ShoppingTripQuery extends StatefulWidget {
  final _auth = FirebaseAuth.instance;
  late String listUUID;

  ShoppingTripQuery(String listUUID, {required Key key}) : super(key: key) {
    this.listUUID = listUUID;
  }

  @override
  _ShoppingTripQueryState createState() => _ShoppingTripQueryState();
}

class _ShoppingTripQueryState extends State<ShoppingTripQuery> {
  late String listUUID;

  @override
  void initState() {
    listUUID = widget.listUUID;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return StreamBuilder<DocumentSnapshot>(
        stream: tripCollection.doc(listUUID).snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Card(
              elevation: 10,
              color: appColor,
              shadowColor: appOrange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                title: Container(
                  child: Text(
                    'Loading Title...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
                subtitle: Row(children: [
                  Text(
                    'Loading Info...\n\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ]),
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditListScreen(listUUID)));
                },
                isThreeLine: true,
              ),
            );
          }
          if (snapshot.data!.data() != null) {
            String desc_short = snapshot.data!['description'];
            String title_short = snapshot.data!['title'];
            if (title_short.length > 30) {
              title_short = title_short.substring(0, 11) + "...";
            }
            if (desc_short.length > 50) {
              desc_short = desc_short.substring(0, 11) + "...";
            }

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
              child: Card(
                elevation: 10,
                color: appColor,
                shadowColor: appOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                child: ListTile(
                  title: Container(
                    child: Text(
                      '${title_short}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  subtitle: Row(children: [
                    Text(
                      '${desc_short}\n\n'
                              '${(snapshot.data!['date'] as Timestamp).toDate().month}' +
                          '/' +
                          '${(snapshot.data!['date'] as Timestamp).toDate().day}' +
                          '/' +
                          '${(snapshot.data!['date'] as Timestamp).toDate().year}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                  ]),
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditListScreen(listUUID)));
                  },
                  isThreeLine: true,
                ),
              ),
            );
          }
          return Container();
        });
  }
}

class _ListsScreenState extends State<ListsScreen> {
  final _auth = FirebaseAuth.instance;
  final User? curUser = FirebaseAuth.instance.currentUser;
  late Stream<DocumentSnapshot> personalTrip =
      userCollection.doc(curUser!.uid).snapshots();
  Future<void>? Cowsnapshot;
  List<String> dev = [
    "ZzIAu0Hqzoa0YDerS408uZN5lrf1", // harra
    "GqZ1wHAr3aUPTlz2Z3IkqS3vsk52", // praffa
    "W9J3qDwNQgSBbsDvyT6RZtvbm572", // dhruva
  ];
  @override
  void initState() {
    Cowsnapshot = _loadCurrentCowboy();
    super.initState();
  }

  Future<void> _loadCurrentCowboy() async {
    final DocumentSnapshot<Object?>? snapshot =
        await (_queryCowboy() as Future<DocumentSnapshot<Object?>?>);
    readInData(snapshot!);
    // final Stream<QuerySnapshot<Map<String, dynamic>>> tripstream = userCollection.doc(context.read<Cowboy>().uuid).collection('shopping_trips').snapshots();
  }

  void readInData(DocumentSnapshot snapshot) {
    List<String> shoppingTrips = [];

    List<String> friends = [];
    List<String> requests = [];
    // extrapolating data into provider
    if (!(snapshot['friends'] as List<dynamic>).isEmpty) {
      (snapshot['friends'] as List<dynamic>).forEach((dynamicKey) {
        friends.add(dynamicKey.toString());
      });
    }
    if (!(snapshot['requests'] as List<dynamic>).isEmpty) {
      (snapshot['requests'] as List<dynamic>).forEach((key) {
        requests.add(key.toString().trim());
      });
    }

    // reads and calls method
    context.read<Cowboy>().fillFields(
        snapshot['uuid'].toString(),
        snapshot['first_name'].toString(),
        snapshot['last_name'].toString(),
        snapshot['email'].toString(),
        shoppingTrips,
        friends,
        requests);
    //print(context.read<Cowboy>().shoppingTrips);
  }

  Future<DocumentSnapshot?> _queryCowboy() async {
    if (curUser != null) {
      DocumentSnapshot? tempShot;
      await userCollection.doc(curUser!.uid).get().then((docSnapshot) {
        tempShot = docSnapshot;

        //print('L TYPE: '+docSnapshot.data['']);
      });
      return tempShot;
    } else {
      return null;
    }
  }

  List<String> readInShoppingTripsData(QuerySnapshot tripshot) {
    List<String> shopping_trips = [];
    if (tripshot.docs == null || tripshot.docs.isEmpty) {
      return [];
    }
    tripshot.docs.forEach((element) {
      if (element.id != 'dummy') {
        shopping_trips.add(element.id.trim());
      }
    });
    context.read<Cowboy>().setTrips(shopping_trips);
    return shopping_trips;
  }

  Future<void> loadItemToProvider() async {
    QuerySnapshot itemColQuery = await tripCollection.doc(context.read<ShoppingTrip>().uuid).collection('items').get();
    List<String> rawItemList = [];
    itemColQuery.docs.forEach((document) {
      String itemID = document['uuid'];
      // TODO maybe don't need this check at all
      if ((itemID != 'dummy') && (itemID != 'add. fees') && (itemID != "tax")) {
        rawItemList.add(itemID);
      }
    });
    //check if every id from firebase is in local itemUUID
    rawItemList.forEach((itemID) {
      if (!context.read<ShoppingTrip>().itemUUID.contains(itemID)) {
        context.read<ShoppingTrip>().itemUUID.add(itemID);
      }
    });
    List<String> tobeDeleted = [];
    //check if any local uuid needs to be deleted
    context.read<ShoppingTrip>().itemUUID.forEach((itemID) {
      if (!rawItemList.contains(itemID)) {
        tobeDeleted.add(itemID);
      }
    });
    context
        .read<ShoppingTrip>()
        .itemUUID
        .removeWhere((element) => tobeDeleted.contains(element));
  }

  Future<void> deleteAllUserFields() async {
    // step 1 - delete trip / remove self from trip
    bool step1 = true;
    // step 2 - clear and delete shopping_trips reference
    bool step2 = false;
    // step 3 - delete friends
    bool step3 = false;
    // step 4 - delete self
    bool step4 = false;

    while (true) {
      if (step1) {
        // DELETE TRIP
        QuerySnapshot trips = await userCollection.doc(curUser!.uid).collection('shopping_trips').get();
        int total_trips = trips.docs.length; // actual number of trips plus 1 for dummy
        int count_trips = 0;
        trips.docs.forEach((trip) async {
          if (trip.id == 'dummy') {
            count_trips++;
          } else {
            DocumentSnapshot trip_snapshot =
                await tripCollection.doc(trip.id).get();
            List<String> benes = [];
            (trip_snapshot['beneficiaries'] as List<dynamic>)
                .forEach((bene_uuid) {
              benes.add(bene_uuid);
            });
            context.read<ShoppingTrip>().initializeTripFromDB(
                trip.id,
                trip_snapshot['title'],
                DateTime(2001),
                trip_snapshot['description'],
                trip_snapshot['host'],
                benes,
                false);
            await loadItemToProvider();
            if (context.read<ShoppingTrip>().host == curUser!.uid) {
              await context.read<ShoppingTrip>().deleteTripDB();
              print('deleting trip where host: ${context.read<ShoppingTrip>().host} and uuid: ${context.read<ShoppingTrip>().uuid}');
              count_trips++;
            } else {
              // remove self from subitems
              await context
                  .read<ShoppingTrip>()
                  .removeBeneficiaries([curUser!.uid]);
              print('removing beneficiary where bene: ${context.read<ShoppingTrip>().uuid}');
              count_trips++;
            }
          }
        });
        if (count_trips == total_trips) {
          print('step 1 finished');
          step1 = false;
          step2 = true;
        }
      }
      if (step2) {
        // CLEAR AND DELETE SHOPPING TRIPS REFERENCE
        QuerySnapshot trips = await userCollection.doc(curUser!.uid).collection('shopping_trips').get();
        int total_trips = trips.docs.length;
        int count_trips = 0;
        trips.docs.forEach((trip_uuid) async {
          await trip_uuid.reference.delete();
          count_trips++;
        });
        if (count_trips == total_trips) {
          print('step 2 finished');
          step2 = false;
          step3 = true;
        }
      }
      if (step3) {
        // DELETE FRIENDS
        await context.read<Cowboy>().removeAllFriends();
        print('step 3 finished');
        step3 = false;
        step4 = true;
      }
      if (step4) {
        // DELETE SELF
        await userCollection.doc(curUser!.uid).delete();
        Navigator.of(context).popUntil((route) {
          return route.settings.name == WelcomeScreen.id;
        });
        Navigator.pushNamed(context, WelcomeScreen.id);
        context.read<Cowboy>().clearData();
        step4 = false;
        print('step 4 finished');
      }
      if (!step1 && !step2 && !step3 && !step4) {
        print('all steps finished u dirty cuck slut !!!!!!');
        break;
      }
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> reauthUser() async {
    print('reauth: REAUTHING USER');
    String curProviderID = FirebaseAuth
        .instance.currentUser!.providerData[0].providerId
        .toString();
    if (curProviderID == "google.com") {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      // Create a new credential.
      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(googleCredential);
    } else if (curProviderID == "password") {
      final reauth_info = await Navigator.pushNamed(context, ReauthScreen.id);
      print('USER CREDS: ' + '${reauth_info}');
      List<dynamic> user_info = reauth_info as List<dynamic>;
      try {
        AuthCredential credential = EmailAuthProvider.credential(email: user_info[0].toString(), password: user_info[1].toString());
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        Fluttertoast.showToast(msg: 'Invalid Credentials');
        throw e;
      }

    } else if (curProviderID == "apple.com") {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(oauthCredential);
    }
    print('reauth: FINISHED REAUTHING USER');
  }

  @override
  Widget build(BuildContext context) {
    //print(context.watch<Cowboy>().shoppingTrips);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: UserName(curUser!.uid),
          backgroundColor: appOrange,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          elevation: 0,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                height: 150.0,
                //alignment: Alignment.center,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: appOrange,
                  ),
                  child: Center(
                    child: Text(
                      'Menu Options',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Edit Profile'),
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.pushNamed(context, UserInfoScreen.id);
                },
              ),
              ListTile(
                title: const Text('Cowamigos'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, FriendScreen.id);
                },
              ),
              ListTile(
                title: const Text('Report a 🐞'),
                onTap: () async {
                  Fluttertoast.showToast(
                      msg: 'Google Sign in required to upload bug report');
                  String paypalStr = "https://forms.gle/xHy3ixadwacFuFMi9";
                  Uri paypal_link = Uri.parse(paypalStr);
                  if (await canLaunchUrl(paypal_link)) {
                    launchUrl(paypal_link);
                  }
                },
              ),
              ListTile(
                title: const Text('Feature Request'),
                onTap: () async {
                  String paypalStr =
                      "https://docs.google.com/forms/d/e/1FAIpQLSf7gVxRoyMq0C8tuLMdnw4T2hxr8LUgIbZFFWQv2sJFSafndg/viewform";
                  Uri paypal_link = Uri.parse(paypalStr);
                  if (await canLaunchUrl(paypal_link)) {
                    launchUrl(paypal_link);
                  }
                },
              ),
              ListTile(
                title: const Text('Log Out'), //
                onTap: () async {
                  var currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    //clearUserField();
                    context.read<Cowboy>().clearData();
                    context.read<ShoppingTrip>().clearField();
                    await _auth.signOut();
                    print('User signed out');
                  }
                  //Navigator.pop(context);
                  Navigator.of(context).popUntil((route) {
                    return route.settings.name == WelcomeScreen.id;
                  });
                  Navigator.pushNamed(context, WelcomeScreen.id);
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () async {
                  String ppstr = "https://grocerymule.net/privacy.html";
                  Uri pp_link = Uri.parse(ppstr);
                  if (await canLaunchUrl(pp_link)) {
                    launchUrl(pp_link);
                  }
                },
              ),
              ListTile(
                title: const Text('Delete Account'),
                onTap: () async {
                  return showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text(
                            "Are you sure you want to delete your account?"),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () async {
                                try {
                                  await reauthUser();
                                  print('STARTED DELETE OF USER');
                                  await deleteAllUserFields();
                                  print('STARTED DELETE OF AUTH');
                                  await FirebaseAuth.instance.currentUser!.delete();
                                  // print(context.read<Cowboy>().uuid),
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'requires-recent-login') {
                                    // print('The user must reauthenticate before this operation can be executed.');
                                    print("reauth failed");
                                  }
                                }
                                // deleteAccountTrips(),
                                // Navigator.of(context).pop(),
                              },
                              child: const Text("DELETE")),
                          TextButton(
                            onPressed: () => {
                              Navigator.of(context).pop(),
                            },
                            child: const Text("CANCEL"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot<Object?>>(
            stream: userCollection
                .doc(curUser!.uid)
                .collection('shopping_trips')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong StreamBuilder');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              return SafeArea(
                child: ListView.builder(
                  //scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, int index) {
                    return new ShoppingTripQuery(
                        snapshot.data!.docs.toList()[index].id,
                        key: Key(snapshot.data!.docs.toList()[index].id));
                  },
                ),
                // ),
              );
            }),
        floatingActionButton: Container(
          height: 80,
          width: 80,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            backgroundColor: appOrange,
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CreateListScreen(true, "dummy")));
            },
          ),
        ),
      ),
    );
  }
}
