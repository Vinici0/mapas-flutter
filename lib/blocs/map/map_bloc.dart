import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_maps_adv/blocs/location/localtion_bloc.dart';
import 'package:flutter_maps_adv/themes/themes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  //Importante lo que recibe el LocationBloc
  final LocaltionBloc locationBloc;
  GoogleMapController? _mapController;

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    on<OnMapInitialzedEvent>(_onInitMap);
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowUser: false)));
    /*
      No se puede usar el on porque es un stream y no un evento 
      -> locationBloc.state.lastKnownLocation;
    */

    locationBloc.stream.listen((locationState) {
      if (!state.isFollowUser) return;
      if (locationState.lastKnownLocation == null) return;
      moveCamera(locationState.lastKnownLocation!);
    });
  }

  //para inicializar el mapa y ponerle el estilo de uber
  void _onInitMap(OnMapInitialzedEvent event, Emitter<MapState> emit) {
    _mapController = event.controller;
    _mapController!.setMapStyle(jsonEncode(uberMapTheme));

    emit(state.copyWith(isMapInitialized: true));
  }

  //para ubicar el mapa en la posicion del usuario en el centro en tiempo real
  void moveCamera(LatLng newLocation) {
    final cameraUpdate = CameraUpdate.newLatLng(newLocation);
    _mapController?.animateCamera(cameraUpdate);
  }

  // //para seguir al usuario
  void _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) {
    emit(state.copyWith(isFollowUser: true));
    if (locationBloc.state.lastKnownLocation == null) return;
    moveCamera(locationBloc.state.lastKnownLocation!);
  }

  // //para dejar de seguir al usuario
  // void _onStopFollowingUser(
  //     OnStopFollowingUserEvent event, Emitter<MapState> emit) {
  //   // _mapController?.animateCamera(CameraUpdate.zoomOut());
  //   emit(state.copyWith(isFollowUser: false));
  // }
}
