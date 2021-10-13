import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/homeScreen.dart';
import 'package:podokma_ecom/services/user_services.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  late String smsOtp;
  late String verificationId;
  String error = '';
  UserServices _userServices = UserServices();
  bool loading = false;
  LocationProvider locationData = LocationProvider();

  Future<void> verifyPhone({required BuildContext context, required String number, double? latitude, double? longitude, String? address}) async {
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
      smsOtpDialog(context, number, latitude, longitude, address);
    };

    try {
      _auth.verifyPhoneNumber(
        phoneNumber: number,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsOtpSend,
        codeAutoRetrievalTimeout: (String verId){
          this.verificationId = verId;
        },
      );
    } catch (e) {
      this.error = e.toString();
      notifyListeners();
      print(e);
    }
  }

  Future<void> smsOtpDialog(BuildContext context, String number, double? latitude, double? longitude, String? address) async {
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
                  try{
                    PhoneAuthCredential credential =
                    PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: smsOtp,
                    );

                    final User? user =  (await _auth.signInWithCredential(credential)).user;
                    if(locationData.selectedAddress!=null){
                      updateUser(id: user!.uid, number: user.phoneNumber!, latitude: locationData.latitude, longitude: locationData.longitude, address: locationData.selectedAddress.addressLine);
                    }else{
                      //create user data to firebase after success register
                      _createUser(id: user!.uid, number: user.phoneNumber!, latitude: latitude, longitude: longitude, address: address);
                    }

                    //navigate to Home age after login.
                    if(user!=null){
                      Navigator.of(context).pop();
                      //dont want come back to welcome page after login
                      Navigator.pushReplacementNamed(context, HomeScreen.id);
                    }else{
                      print('login Failed');
                    }
                  }catch(e){
                    this.error = 'Invalid OTP';
                    notifyListeners();
                    print(e.toString());
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Done', style: TextStyle(color: Theme.of(context).primaryColor),),
              ),
            ],
          );
        }
    );
  }

  // ignore: unused_element
  void _createUser({required String id, required String number, double? latitude, double? longitude, String? address}){
    _userServices.createUserData({
      'id' : id,
      'number' : number,
      'latitude' : latitude,
      'longitude' : longitude,
      'address' : address,
    });
  }
  void updateUser({required String id, required String number, double? latitude, double? longitude, String? address}){
    _userServices.updateUserData({
      'id' : id,
      'number' : number,
      'latitude' : latitude,
      'longitude' : longitude,
      'address' : address,
    });
  }
}
