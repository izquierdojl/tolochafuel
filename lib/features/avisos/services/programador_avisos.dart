abstract class ProgramadorAvisos {
  Future<void> programar(DateTime? proxima);

  Future<void> cancelar();
}

class ProgramadorPrimerPlano implements ProgramadorAvisos {
  DateTime? proxima;

  @override
  Future<void> programar(DateTime? fecha) async {
    proxima = fecha;
  }

  @override
  Future<void> cancelar() async {
    proxima = null;
  }
}
