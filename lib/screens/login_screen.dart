import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/auth_provider.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/homeScreen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login-screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _validPhoneNumber = false;
  var _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                Text('Enter your phone number to buy', style: TextStyle(fontSize: 12, color: Colors.grey),),
                SizedBox(height: 20,),
                Visibility(
                  visible: auth.error == 'Invalid OTP' ? true:false,
                  child: Container(
                    child: Column(
                      children: [
                        Text(auth.error,style: TextStyle(color: Colors.red, fontSize: 12),),
                      ],
                    ),
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    prefixText: '+62 ',
                    labelText: '11 digit phone number',
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  controller: _phoneNumberController,
                  onChanged: (value){
                    if(value.length==11){
                      setState((){
                        _validPhoneNumber = true;
                      });
                    }else{
                      setState((){
                        _validPhoneNumber = false;
                      });
                    }
                  },
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: _validPhoneNumber ? false:true,
                        // ignore: deprecated_member_use
                        child: FlatButton(
                          onPressed: (){
                            setState((){
                              auth.loading = true;
                            });
                            String number = '+62${_phoneNumberController.text}';
                            auth.verifyPhone(
                              context : context,
                              number : number,
                              latitude: locationData.latitude,
                              longitude: locationData.longitude,
                              address: locationData.selectedAddress.addressLine,
                            ).then((value){
                              _phoneNumberController.clear();
                              setState(() {
                                auth.loading = false;
                              });
                            });
                            Navigator.pushNamed(context, HomeScreen.id);
                          },
                          color: _validPhoneNumber ? Theme.of(context).primaryColor : Colors.grey,
                          child: auth.loading ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ) : Text(_validPhoneNumber ? 'Continue' : 'Enter Phone Number', style: TextStyle(color: Colors.white),),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
