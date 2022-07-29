import 'dart:io';
import 'package:discovid/components/MapMarker.dart';
import 'package:discovid/screens/MapSample.dart';
import 'package:discovid/screens/PlacePicker.dart';
import 'package:discovid/screens/SignIn.dart';
import 'StatsScreen.dart';
import 'package:discovid/screens/StatsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:discovid/constants.dart';
import 'package:share/share.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:discovid/components/RFlutterAlertStyle.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

FirebaseUser loggedInUser;

class LiveMap extends StatefulWidget {
  static const String id = 'live_map_screen';

  @override
  _LiveMapState createState() => _LiveMapState();
}

int currentIndex = 0;

class _LiveMapState extends State<LiveMap> {

  final FirebaseMessaging _messaging = FirebaseMessaging();
  final _auth = FirebaseAuth.instance;
  final _firestore = Firestore.instance;

  bool mapToggle = false;

  bool markerToggle = false;

  Geolocator geoLocator = Geolocator();
  Position _currentLocation;
  LatLng _initialPosition;
  Position currentLocation;
  GoogleMapController mapController;
  String searchAddress;

  List<Marker> _markers = <Marker>[];

  List<Marker> _markers2 = <Marker>[];
  setMarkers() {
    return _markers2;
  }


//TODO add test center locations
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //add UI for logged in user
    getCurrentUser();
    getCurrentLocation();
    //populateMap();

    //loadAllMarkers();
    currentIndex = 0;
    //print(currentIndex);
    getUserVerifyUserStatus();
    //MOVED THIS AFTER VERIFYING STATUS, CONSIDER FUTURES
    populateMap2();
    populateMapWithNonAppUsers();
    addUserTokenToDb();
 
  }

  //////
  //get the token of device for firebase messaging

void addUserTokenToDb() async{
  final fbTokens = await _firestore.collection('user_tokens').getDocuments();

  //list to hold tokens from firebase db
  List<String> listOfTokens= [];
  var currentToken;
  for (var tokens in fbTokens.documents)  {
    print(tokens.data['token']);
    //TODO format token to only add new tokens
   // if(tokens.data['token']!=_messaging.getToken()){
      //get the token of device for firebase messaging
     await  _messaging.getToken().then((userToken)  {
       //assign token value to current token
        currentToken= userToken;
        //add list of tokens to array
        listOfTokens.add(tokens.data['token']);
      //print Token
        print('$currentToken DEVICE TOKEN CURRENT');
     });
  }
  //  //if list does not contain the current token of current device, add token to firebase
  if(!listOfTokens.contains(currentToken)){
    print("DO SOMETHING");
    _firestore.collection('user_tokens').add({
      'token':currentToken,
    });
    //print the length of the list
    print(listOfTokens.length);

  }
}


  void getUserVerifyUserStatus() async {

    //Variables used to hold the document IDs of verified_cases collection and user collection
    String verifiedCasesDocID;
    String userDocID;
  

    //Variables to hold data parsed from verified_cases collection to user collection
    String vStatus;
    String vCellNumber;
    String vSymptoms;
    String vID;
    GeoPoint vLocation;

    //bool to check if user exists in verified_case and is positive
    bool statusVerified =false;
    bool isAppUser;

    //TODO add rules for when verified_cases data should be parsed to users collection profile(maybe if records do exist in verified cases and oif user is tested as positive)
    Timestamp vPositiveDate;
    Timestamp vLastUpdated;

    //Find the email of the logged in user
    final emails = await _firestore.collection('verified_cases').getDocuments();
    for (var emails in emails.documents) {
      print(emails.data['email']);

      //If the loggged in user is found in verified_cases...
      if (emails.data['email'] == loggedInUser.email&&emails.data['status'] == 'positive'&&emails.data['isAppUser'] == false) {
        //..print true
        print(true);
        //if user exists in verified_cases and status positive, set statusVerified to true
        statusVerified = true;
        //if user is not yet an app user as a positive case, set is isAppUser to true
        isAppUser=false;


        //Find the document ID in this collection that email belongs to
        await _firestore
            .collection('verified_cases')
            .where('email', isEqualTo: loggedInUser.email)
            .getDocuments()
            .then((querySnapShot) {
          for (var verifiedDocumentDetails in querySnapShot.documents) {
            //print the document Id...
            print(verifiedDocumentDetails.documentID);

            //print the respective fields associated with this document
            print(
                '${verifiedDocumentDetails.data['location'].latitude}, ${verifiedDocumentDetails.data['location'].longitude}');
            print(verifiedDocumentDetails.data['id_number']);
            print(verifiedDocumentDetails.data['cell_number']);
            print(verifiedDocumentDetails.data['status']);
            print(verifiedDocumentDetails.data['symptoms']);
            print(verifiedDocumentDetails.data['positive_date']);

            //performed substring method on positive_date field to get the date only(use SUBSTRING TO TRIM this method to set daa in UI by )
            print(DateTime.parse(
                verifiedDocumentDetails.data['positive_date'].toDate().toString()));

            print(verifiedDocumentDetails.data['last_updated']);

            //performed substring method on last_updated field to get the date only
            print(DateTime.parse(
                verifiedDocumentDetails.data['last_updated'].toDate().toString()));

            //assign the document ID for logged in user to verifiedCasesDocID variable
            verifiedCasesDocID = verifiedDocumentDetails.documentID;
            print('$verifiedCasesDocID FROMVERIFYTABLE');
            ///////////////////////////////////////////////////

            //store data from fields in that document to v variables created earlier
            vID=(verifiedDocumentDetails.data['id_number']);
            vCellNumber=(verifiedDocumentDetails.data['cell_number']);
            vStatus=(verifiedDocumentDetails.data['status']);
            vSymptoms=(verifiedDocumentDetails.data['symptoms']);
            vLocation=verifiedDocumentDetails.data['location'];
            //TODO uncomment this when ready to parse
            vPositiveDate=verifiedDocumentDetails.data['positive_date'];
            vLastUpdated =verifiedDocumentDetails.data['last_updated'];
            //vPositiveDate=emails.data['positive_date'];
          }
        });
      }
    }

    //if user statusVerified is true, they are positive. Update their user document with relevant information from verified_cases
    //if user is not yet an app user, update there profile. This prevents database from overwriting existing data like their location if they are already using the app
    if(statusVerified==true&&isAppUser==false){

      Alert(
        context: context,
        style: alertStyle,
        title: "ALERT",
        desc: "According to our database, you've tested positive for COVID-19. "
            "Your account will now be updated and your last known location will be added to the map. Rest assured, "
            "your personal data will remain anonymous to all other users. Be sure to regualrly update your location if you are not in self-isolation and don't forget to practice social distancing.",
        image: Image.asset("assets/alert_icon.png"),
        buttons: [
          DialogButton(
            child: Text('OKAY', style: TextStyle(fontSize: 18,
                fontFamily: 'SFUIDisplay',
                fontWeight: FontWeight.bold,
                color: Colors.white),) ,
            onPressed: () {
              Navigator.pop(context);

            },
            gradient: LinearGradient(colors: kGradient, begin: Alignment.bottomLeft, end: Alignment.topRight),)
        ],
      ).show();

      //Find the document ID in the users collection that email belongs to
      await _firestore
          .collection('users')
          .where('email', isEqualTo: loggedInUser.email)
          .getDocuments()
          .then((querySnapShot) {
        for (var emails in querySnapShot.documents) {
          print(emails.documentID);

          //assign the document ID for logged in user to userDocID variable
          userDocID=emails.documentID;
          print('$userDocID FROMUSERCOLLECTION');

          //call update method to parse verified data to users profile
          updateUserWithVerifiedDetails(userDocID, vID, vStatus, vCellNumber, vSymptoms, vLocation, vPositiveDate, vLastUpdated);
          //update verified_cases and set isAppUser to true once the users profile has been updated
          updateVerifiedCasesIsAppUser(verifiedCasesDocID);
        }
      });
    }
  }
  //A method to used to parse data from verified_cases collection to users collection, use userDocID to detect email of current logged in user
  void updateUserWithVerifiedDetails(String userDocID, String ID, String status, String cellNumber, String symptoms, GeoPoint location, Timestamp positiveDate, Timestamp updatedDate ) {

    _firestore
        .collection('users')
        .document(userDocID)
        .updateData({'status': status, 'cell_number': cellNumber, 'symptoms': symptoms, 'id_number':ID, 'location':location, 'positive_date':positiveDate,'last_updated':updatedDate});
  }

  /*A method used to set isAppUser field to true in verified_cases collection so that when this code runs again,
  it checks to see if the user is already using the app as a positive case, prevents overwriting existing user data*/
  void updateVerifiedCasesIsAppUser(verifiedCaseDocID){

    _firestore.collection('verified_cases').document(verifiedCaseDocID).updateData({'isAppUser':true});
  }

  String shareText =
      "Hey! I just downloaded Discovid. South Africa's first real-time Covid-19 tracing app. Give it a try";
  String shareSubject = "Discovid - Track Covid-19 in your local neighbourhood";

  void changePage(int index) {
    setState(() {
      currentIndex = index;
      if (index == 0) {
        print('0');
      }
      if (index == 1) {
        print('1');
        Navigator.pushNamed(context, StatsScreen.id);
      }
      if (index == 2) {
        print('2');
        Share.share(shareText);
      }
    });
  }

  populateMap() {
    _firestore.collection('fb_markers').getDocuments().then((docs) {
      if (docs.documents.isNotEmpty) {
        for (var marker in docs.documents) {


          _markers.add(
            Marker(
              markerId: MarkerId(marker.data['name']),
              position: LatLng(marker.data['location'].latitude,
                  marker.data['location'].longitude),
              // position: LatLng(marker.data['location'].latitude, marsker.data['location'].longitude)
            ),
          );

          //print marker name to console
          print(marker.data['name']);
          //print geopoint to console. USe implementation to loop through list
          print(
              '${marker.data['location'].latitude},${marker.data['location'].longitude}');


          //////////////////////PRINT TO TEST MARKER LIST/////////////////

        }
      }

//TODO replace this approach with stream builder
      setState(() {
        markerToggle = true;
      });
    });
  }


  void populateMap2() async {
    String lastSeenTime;
    //ImageConfiguration configuration=createLocalImageConfiguration(context);

    await for (var snapshot in _firestore.collection('users').snapshots()) {

      for (var message in snapshot.documents) {
        if (message.data['location'] != null) {
          _markers2.add(
            Marker(
                markerId: MarkerId(message.data['UID']),
                position: LatLng(message.data['location'].latitude,
                    message.data['location'].longitude),
                infoWindow: InfoWindow(
                  title: 'Last Seen',
                  snippet: message.data['last_updated']
                      .toDate()
                      .toString()
                      .substring(0, 19),
                ),
                // position: LatLng(marker.data['location'].latitude, marsker.data['location'].longitude)
                //onTap: (){print(MarkerId(message.data['UID']));}
                ),
          );

//          //performed substring method on last_updated field to get the date only
//          print(DateTime.parse(
//              verifiedDocumentDetails.data['last_updated'].toDate().toString()));

          print(message.data['UID']);
          print(message.data['location'].latitude);
          print(message.data['location'].longitude);
        }
      }
      setState(() {
        markerToggle = true;

      });
    }
  }

  void populateMapWithNonAppUsers() async {

    //ImageConfiguration configuration=createLocalImageConfiguration(context);

    await for (var snapshot in _firestore.collection('verified_cases').snapshots()) {

      for (var message in snapshot.documents) {
        if (message.data['location'] != null&&message.data['isAppUser']==false&&message.data['status']=="positive") {
          _markers2.add(
            Marker(
              markerId: MarkerId(message.documentID),
              position: LatLng(message.data['location'].latitude,
                  message.data['location'].longitude),
              infoWindow: InfoWindow(
                title: 'Last Seen',
                snippet: message.data['last_updated']
                    .toDate()
                    .toString()
                    .substring(0, 19),
              ), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
              // position: LatLng(marker.data['location'].latitude, marsker.data['location'].longitude)
              //onTap: (){print(MarkerId(message.data['UID']));}
            ),
          );

//          //performed substring method on last_updated field to get the date only
//          print(DateTime.parse(
//              verifiedDocumentDetails.data['last_updated'].toDate().toString()));

          print(message.documentID);
          print(message.data['isAppUser']);
          print(message.data['status']);
          print(message.data['location'].latitude);
          print(message.data['location'].longitude);
        }
      }
      //////////////
      setState(() {
        markerToggle = true;


      });
    }
  }


//get my current location
  Future<void> getCurrentLocation() async {
    try {
      currentLocation = await geoLocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      setState(() {
        //currentLocation = LatLng(, longitude)
        mapToggle = true;
        //currentLocation;
      });
    } catch (e) {
      print(e);
    }
  }

  //loop through all emails in users collection
  void getEmail() async {
    final emails = await _firestore.collection('users').getDocuments();
    for (var emails in emails.documents) {
      print(emails.data['email']);
    }
  }

  //gets the document ID associated where email is equal to current user email and assigns ID to users document
  void getDocumentID() async {
    await _firestore
        .collection('users')
        .where('email', isEqualTo: loggedInUser.email)
        .getDocuments()
        .then((querySnapShot) {
      for (var emails in querySnapShot.documents) {
        print(emails.documentID);
        print(loggedInUser.email);

        addUID(emails.documentID);
      }
    });
  }

  /*add a UID field to user's document (this UID is the one given to the user
 when they register, takes in docID parameter to find specific user based on their email)*/
  void addUID(String docID) {
    _firestore
        .collection('users')
        .document(docID)
        .updateData({'UID': loggedInUser.uid});
  }

  //gets the current logged in user details to perform getDocumentID() method
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
        print(loggedInUser.uid);
        getDocumentID();
      } else {
        print('No user signed in');
      }
    } catch (e) {
      print(e);
    }
  }

  //get users current location to update firebase db location
  //TODO animate camera to new location
  //TODO DO NOT PLOT NEGATIVE USER LOCATIONS
  _getCurrentLocation () async {
    geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((
        Position position) {
      setState(() {
        _currentLocation = position;
        if(_currentLocation!=null)
        print( "LAT: ${_currentLocation.latitude}, LNG: ${_currentLocation.longitude}");
        print(new DateTime.now());
      });
    }).catchError((e) {
      print(e);
    });

    await _firestore
        .collection('users')
        .where('email', isEqualTo: loggedInUser.email)
        .getDocuments()
        .then((querySnapShot) {
      for (var emails in querySnapShot.documents) {
        print(emails.documentID);
        print(loggedInUser.email);
        print(emails.data['status']);

        //only if user is positive, allow location update

        if(emails.data['status']=="positive") {
          updateUserLocation(emails.documentID, _currentLocation.latitude,
              _currentLocation.longitude);
        }
      }
    });
  }

  void updateUserLocation(String docID, double userLat, userLong ) async {
   await  _firestore
        .collection('users')
        .document(docID)
        .updateData({'location': GeoPoint(userLat, userLong), 'last_updated': DateTime.now().toUtc()});
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  navigateToAddress() {
    geoLocator.placemarkFromAddress(searchAddress).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 18.0)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
         // _auth.signOut();
          _getCurrentLocation();
          //Navigator.popAndPushNamed(context, SignIn.id);
          //Navigator.pushNamed(context, MapSample.id);
        },
        child: Icon(Icons.refresh),
        backgroundColor: Colors.blue[500],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        hasNotch: true,
        fabLocation: BubbleBottomBarFabLocation.end,
        opacity: 1,
        currentIndex: currentIndex,
        onTap: changePage,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(
                16)), //border radius doesn't work when the notch is enabled.
        elevation: 8,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
            backgroundColor: kOnHoverNavBarItem,
            icon: Icon(
              Icons.search,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            title: Text(
              "Search",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          BubbleBottomBarItem(
            backgroundColor: kOnHoverNavBarItem,
            icon: Icon(
              Icons.trending_up,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.trending_up,
              color: Colors.white,
            ),
            title: Text(
              "Trends",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          BubbleBottomBarItem(
            backgroundColor: kOnHoverNavBarItem,
            icon: Icon(
              Icons.share,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.share,
              color: Colors.white,
            ),
            title: Text(
              "Share",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

        ],
      ),

//
      body: Column(
        children: <Widget>[
          Flexible(
            child: Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: mapToggle
                      ? GoogleMap(
                          onMapCreated: onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                                currentLocation.latitude,
                                currentLocation
                                    .longitude), //_initialPosition,//LatLng(currentLocation.latitude, currentLocation.longitude),
                            tilt: 0.0,
                            zoom: 18.0,
                          ),
                          markers: /*markerToggle ?*/ Set<Marker>.of(
                              _markers2) /*: null*/,
                          myLocationEnabled: true,
                          mapType: MapType.hybrid,
                          compassEnabled: true,
                          zoomControlsEnabled: false,

                          //trackCameraPosition: true,
                        )
                      : Center(
                          child: Text(
                            'Loading...',
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ),
                ),
                Positioned(
                  top: 30.0, //30
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 45.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                    ),
                    child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Suburb',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                            left: 15.0,
                            top: 12,
                          ),
                          suffixIcon: IconButton(
                              icon: Icon(Icons.location_on),
                              onPressed: navigateToAddress,
                              iconSize: 28.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchAddress = value;
                          });
                        }),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

Marker marker1 = Marker(
    markerId: MarkerId('mark1'),
    position: LatLng(-33.9237, 18.6893),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 3 days ago',
        snippet: 'Symptoms: Asymptomatic'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));
Marker marker2 = Marker(
    markerId: MarkerId('mark2'),
    position: LatLng(-33.9201, 18.6870),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 7 days ago',
        snippet: 'Symptoms: Symptomatic'));
Marker marker3 = Marker(
    markerId: MarkerId('mark3'),
    position: LatLng(-33.9200, 18.6937),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 2 days ago',
        snippet: 'Symptoms: Symptomatic'));
Marker marker4 = Marker(
    markerId: MarkerId('mark4'),
    position: LatLng(-33.9255, 18.6929),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 5 days ago',
        snippet: 'Symptoms: Symptomatic'));
Marker marker5 = Marker(
    markerId: MarkerId('mark5'),
    position: LatLng(-33.9324, 18.6876),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 7 days ago',
        snippet: 'Symptoms: Symptomatic'));
Marker marker6 = Marker(
    markerId: MarkerId('mark6'),
    position: LatLng(-33.9285, 18.7003),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 2 days ago',
        snippet: 'Symptoms: Symptomatic'));
Marker marker7 = Marker(
    markerId: MarkerId('mark7'),
    position: LatLng(-33.9203, 18.6922),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 10 days ago',
        snippet: 'Symptoms: Symptomatic'));

Marker marker8 = Marker(
    markerId: MarkerId('mark8'),
    position: LatLng(-33.9299, 18.7049),
    infoWindow: InfoWindow(
        title: 'Tested Positive: 8 days ago',
        snippet: 'Symptoms: Asymptomatic'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));
