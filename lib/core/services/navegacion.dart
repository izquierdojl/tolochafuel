import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/gasolinera.dart';

class Navegacion {
  const Navegacion();

  Future<bool> abrirDestino(Gasolinera gasolinera) async {
    if (await _lanzar(uriParaNavegar(gasolinera))) return true;
    if (_esAndroid) return _lanzar(_mapsWeb(gasolinera));
    return false;
  }

  Uri uriParaNavegar(Gasolinera gasolinera, {TargetPlatform? plataforma}) {
    final destino = plataforma ?? defaultTargetPlatform;
    if (destino == TargetPlatform.android || destino == TargetPlatform.iOS) {
      return Uri(
        scheme: 'geo',
        path: '0,0',
        query: 'q=${gasolinera.lat},${gasolinera.lng}(${gasolinera.nombre})',
      );
    }
    return _mapsWeb(gasolinera);
  }

  bool get _esAndroid => defaultTargetPlatform == TargetPlatform.android;

  Uri _mapsWeb(Gasolinera gasolinera) =>
      Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '${gasolinera.lat},${gasolinera.lng}',
        'travelmode': 'driving',
      });

  Future<bool> _lanzar(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
