import 'package:flutter/material.dart';
import 'package:podokma_ecom/providers/auth_provider.dart';
import 'package:podokma_ecom/providers/location_provider.dart';
import 'package:podokma_ecom/screens/map_screen.dart';
import 'package:podokma_ecom/screens/onboard_screen.dart';
import 'package:provider/provider.dart';

class WelcomeScreen extends StatelessWidget {
  static const String id = 'welcome-screen';

  @override
  Widget build(BuildContext context) {

    final auth = Provider.of<AuthProvider>(context);

    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();

    void showBottomSheet(context){
      showModalBottomSheet(
        context : context,
        builder: (context) => StatefulBuilder(
          builder: (context, StateSetter myState){
            return Container(
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
                          myState((){
                            _validPhoneNumber = true;
                          });
                        }else{
                          myState((){
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
                                String number = '+62${_phoneNumberController.text}';
                                auth.verifyPhone(context, number).then((value){
                                  _phoneNumberController.clear();
                                });
                              },
                              color: _validPhoneNumber ? Theme.of(context).primaryColor : Colors.grey,
                              child: Text(_validPhoneNumber ? 'Continue' : 'Enter Phone Number', style: TextStyle(color: Colors.white),),

                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            Positioned(
              right: 0.0,
              top: 10.0,
              // ignore: deprecated_member_use
              child: FlatButton(
                child: Text('Skip', style: TextStyle(color: Colors.blue),),
                onPressed: (){},
              ),
            ),
            Column(
              children: [
                Expanded(child: OnBoardScreen()),
                Text('Ready to Order From Your Need?', style: TextStyle(color: Colors.grey),),
                SizedBox(
                  height: 5,
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: Text(
                    'Set Delivery Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                  onPressed: () async {
                    await locationData.getCurrentPosition();
                    if(locationData.permissionAllowed==true){
                      Navigator.pushReplacementNamed(context, MapScreen.id);
                    }else{
                      print('Permission not allowed');
                    }
                  },
                ),
                // ignore: deprecated_member_use
                FlatButton(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have account? ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    showBottomSheet(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
