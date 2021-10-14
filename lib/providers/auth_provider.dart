import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/homeScreen.dart';
import 'package:podokma_ecom/screens/map_screen.dart';
import 'package:podokma_ecom/services/user_services.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  late String smsOtp;
  late String verificationId;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();
  String? screen;
  double? latitude, longitude;
  String? address;

  Future<void> verifyPhone({required BuildContext context, required String number}) async {
    this.loading = true;
    notifyListeners();
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) async {
      this.verificationId = verId;
      //open dialog to enter OTP
      smsOtpDialog(context, number);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId) {
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  Future<void> smsOtpDialog(BuildContext context, String number) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                Text('Verification Code'),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'Enter 6 digit OTP code',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              // ignore: deprecated_member_use
              FlatButton(
                onPressed: () async {
                  try {
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: smsOtp,
                    );

                    final User? user =
                        (await _auth.signInWithCredential(credential)).user;

                    if (user != null) {
                      this.loading = false;
                      notifyListeners();

                      _userServices.getUserById(user.uid).then((snapShot) {
                        if (snapShot.exists) {
                          //if user data already exists
                          if (this.screen == 'Login') {
                            //check user data already in database,
                            //if exists data will update or create new
                            Navigator.pushReplacementNamed(
                                context, HomeScreen.id);
                          } else {
                            //need to update selected address
                            print('${locationData.latitude} : ${locationData.longitude}');
                            updateUser(id: user.uid, number: user.phoneNumber!);
                            Navigator.pushReplacementNamed(
                                context, HomeScreen.id);
                          }
                        } else {
                          //if user data does not exists,
                          //will create new data in database
                          _createUser(id: user.uid, number: user.phoneNumber!);
                          Navigator.pushReplacementNamed(
                              context, HomeScreen.id);
                        }
                      });
                    } else {
                      print('Login failed');
                    }
                  } catch (e) {
                    this.error = 'Invalid OTP';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
            ],
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  // ignore: unused_element
  void _createUser({required String id, required String number}) {
    _userServices.createUserData({
      'id': id,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
    });
    this.loading = false;
    notifyListeners();
  }

  Future<bool> updateUser(
      {required String id,
      required String number}) async {
    try{
      _userServices.updateUserData({
        'id': id,
        'number': number,
        'latitude': this.latitude,
        'longitude': this.longitude,
        'address': this.address,
      });
      this.loading = false;
      notifyListeners();
      return true;
    }catch(e){
      print('Error $e');
      return false;
    }
  }
}
