import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';

class MapScreen extends StatefulWidget {
  static const String routemap = 'map_screen';
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LocaltionBloc localtionBloc = BlocProvider.of<LocaltionBloc>(context);

  @override
  void initState() {
    //Solo se ejcuta una vez y despues realiza una limpieza
    super.initState();
    // localtionBloc.getCurrentLocation();
    localtionBloc.startFollowingUser();
  }

  @override
  void dispose() {
    //Se ejecuta cuando se cierra la pantalla
    localtionBloc.stopFollowingUser();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: BlocBuilder<LocaltionBloc, LocaltionState>(
        builder: (context, state) {
          if (state.lastKnownLocation == null) {
            return const Center(
                child: Text("No se ha encontrado la ubicación"));
          }
          return Center(
            child: Text(
                "Latitud: ${state.lastKnownLocation!.latitude} - Longitud: ${state.lastKnownLocation!.longitude}"),
          );
        },
      )),
    );
  }
}
