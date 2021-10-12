import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider with ChangeNotifier{

  late double latitude;
  late double longtitude;
  bool permissionAllowed = false;
  var selectedAddress;

  Future<void> getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if(position!=null){
      this.latitude = position.latitude;
      this.longtitude = position.longitude;
      this.permissionAllowed = true;
      notifyListeners();
    }else{
      print('Permission not allowed');
    }
  }

  void onCameraMove(CameraPosition currentPosition) async {
    this.latitude = currentPosition.target.latitude;
    this.longtitude = currentPosition.target.longitude;
    notifyListeners();
  }

  Future<void> getMoveCamera() async {
    final coordinates = new Coordinates(this.latitude, this.longtitude);
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    this.selectedAddress = addresses.first;
    print("${selectedAddress.featureName} : ${selectedAddress.addressLine}");
  }
}