part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class OnMapInitialzedEvent extends MapEvent {
  //Sirve para controlar el mapa y sus funciones
  final GoogleMapController controller;
  const OnMapInitialzedEvent(this.controller);
}

class OnStopFollowingUserEvent extends MapEvent {}

class OnStartFollowingUserEvent extends MapEvent {}
