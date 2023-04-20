import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_maps_adv/blocs/gps/gps_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'localtion_event.dart';
part 'localtion_state.dart';

class LocaltionBloc extends Bloc<LocaltionEvent, LocaltionState> {
  StreamSubscription? positionStream;
  final GpsBloc _gpsBloc = GpsBloc();

  LocaltionBloc() : super(LocaltionState()) {
    //siguiendo al usuario
    on<OnStartFollowingUser>((event, emit) {
      emit(state.copyWith(followingUser: true));
    });

    //Dejar de seguir al usuario
    on<OnStopFollowingUser>((event, emit) {
      emit(state.copyWith(followingUser: false));
    });

    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copyWith(
        lastKnownLocation: event.newLocation,
        myLocationHistory: [...state.myLocationHistory, event.newLocation],
      ));
    });
  }

  Future getCurrentLocation() async {
    if (!_gpsBloc.state.isAllGranted) {
      print("No se puede obtener la ubicación");
      return;
    }

    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      print("Los servicios de ubicación no están habilitados.");
      // Aquí puedes mostrar un mensaje al usuario o redirigirlo a la configuración de ubicación del dispositivo para que pueda habilitar los servicios de ubicación.
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      // print("getCurrentLocation - La ubicación actual es: $position");
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
      // TODO return LatLng from Google Maps API
      return position;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void startFollowingUser() {
    add(OnStartFollowingUser());
    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
      print("");
      // print("startFollowingUser - La ubicación actual es: $position");
    });
  }

  void stopFollowingUser() {
    positionStream?.cancel(); //Sirve para cancelar el stream
    add(OnStopFollowingUser());
    print("Stop following user");
  }

  @override
  Future<void> close() {
    // TODO: implement close
    stopFollowingUser();
    return super.close();
  }
}
