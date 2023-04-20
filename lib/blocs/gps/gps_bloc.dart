import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

part 'gps_event.dart';
part 'gps_state.dart';

class GpsBloc extends Bloc<GpsEvent, GpsState> {
  StreamSubscription? gpsSubscription;

  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    on<GpsPermissionGranted>((event, emit) {
      emit(state.copyWith(
          isGpsEnabled: event.isGpsEnabled,
          isGpsPermissionGranted: event.isGpsPermissionGranted));
    });

    init();
  }

  /*
    Cuando se crea el init revisa el estado y manda la rcreacion del nuevo estado
   */
  Future<void> init() async {
    final gpsInitState =
        await Future.wait([_checkGpsPermission(), _isPermissionGranted()]);

    // print("El estado del gps es: ${gpsInitState[0]}" +
    //     "y el permiso es: ${gpsInitState[1]}");
    //Dispara el evento
    add(GpsPermissionGranted(
        //El estado que este actualmente
        isGpsPermissionGranted: gpsInitState[1],
        isGpsEnabled: gpsInitState[0]));
  }

  Future<bool> _isPermissionGranted() async {
    //Sirve para saber si el permiso esta activo
    final isGranted = await Permission.location.isGranted;
    return isGranted;
  }

  //Para saber si el servicio de !!!gps esta activo
  Future<bool> _checkGpsPermission() async {
    //Cuando la aplicacion carga y se crea sale el estado de gps activo o no
    final isEnable = await Geolocator.isLocationServiceEnabled();
    //Aqui es cuando se activa o desactiva el gps en tiempo real
    gpsSubscription = Geolocator.getServiceStatusStream().listen((status) {
      print("Comprobando el estado del gps: $status" + status.index.toString());
      final isGpsEnabled = (status.index == 1) ? true : false;
      add(GpsPermissionGranted(
          //El estado que este actualmente
          isGpsPermissionGranted: state.isGpsPermissionGranted,
          isGpsEnabled: isGpsEnabled));
    });
    return isEnable;
  }

  //Para saber si el permiso de gps esta activo o no
  Future<void> askGpsAccess() async {
    final status = await Permission.location.request();
    switch (status) {
      //Cuando se acepta el permiso
      case PermissionStatus.granted:
        add(GpsPermissionGranted(
            isGpsPermissionGranted: true, isGpsEnabled: state.isGpsEnabled));
        break;
      //Cuando se deniega el permiso
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        add(GpsPermissionGranted(
            isGpsPermissionGranted: false, isGpsEnabled: state.isGpsEnabled));
        openAppSettings();
        break;
    }
  }

  //limpiar el stream - siempre es muy buena practica
  @override
  Future<void> close() {
    gpsSubscription?.cancel();
    return super.close();
  }
}
