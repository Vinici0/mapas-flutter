import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/views/map_view.dart';
import 'package:flutter_maps_adv/widgets/btn_follow_user.dart';
import 'package:flutter_maps_adv/widgets/btn_toggle_user_route.dart';
import 'package:flutter_maps_adv/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  /*
    TODO: Importante, ya se tiene al ultima ubicacion conocida
    //Nuevas funciones
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocBuilder<LocaltionBloc, LocaltionState>(
          builder: (context, localtionState) {
            if (localtionState.lastKnownLocation == null) {
              return const Center(
                  child: Text("No se ha encontrado la ubicación"));
            }

            return BlocBuilder<MapBloc, MapState>(
              builder: (context, mapState) {
                //Se esta realizando la copia de la lista de polylines
                Map<String, Polyline> polylines = Map.from(mapState.polylines);

                if (!mapState.showRoutePreview) {
                  //Se remueve si solo si esta en false
                  polylines.removeWhere((key, value) => key == 'myRoute');
                }

                return SingleChildScrollView(
                  child: Stack(
                    children: [
                      MapView(
                        initialLocation: localtionState.lastKnownLocation!,
                        polylines: polylines.values.toSet(),
                      ),
                      //TODO: BotonES....
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            BtnToggleUserRoute(),
            BtnCurrentLocation(),
            BtnFollowUser()
          ],
        ));
  }
}
