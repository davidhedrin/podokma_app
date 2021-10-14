import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier{

  double? latitude;
  double? longitude;
  bool permissionAllowed = false;
  var selectedAddress;
  bool loading = false;


  Future<void> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position!=null){

      this.latitude = position.latitude;
      this.longitude = position.longitude;

      final coordinates = new Coordinates(this.latitude, this.longitude);
      final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      this.selectedAddress = addresses.first;
      this.permissionAllowed = true;
      notifyListeners();
    }else{
      print('Permission not allowed');
    }
  }

  void onCameraMove(CameraPosition currentPosition) async {
    this.latitude = currentPosition.target.latitude;
    this.longitude = currentPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = new Coordinates(this.latitude, this.longitude);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    this.selectedAddress = addresses.first;
    notifyListeners();
    print("${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }
}