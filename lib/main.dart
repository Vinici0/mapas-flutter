import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/screens/screens.dart';

void main() {
  runApp(MultiBlocProvider(providers: [
    //Dependencias que van en cascada
    BlocProvider(create: (context) => GpsBloc()),
    BlocProvider(create: (context) => LocaltionBloc()),
    //Se le envia la instancia del bloc de localizacion
    BlocProvider(
        create: (context) =>
            MapBloc(locationBloc: BlocProvider.of<LocaltionBloc>(context))),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MapApp',
        home: LoadingScreen());
  }
}
