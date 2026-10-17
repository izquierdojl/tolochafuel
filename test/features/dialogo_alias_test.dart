import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tolochafuel/features/alias/ui/dialogo_alias.dart';

class _Lanzador extends StatelessWidget {
  const _Lanzador({
    required this.nombreApi,
    required this.aliasActual,
    required this.onResultado,
  });

  final String nombreApi;
  final String? aliasActual;
  final ValueChanged<String?> onResultado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            final resultado = await showDialog<String>(
              context: context,
              builder: (_) =>
                  DialogoAlias(nombreApi: nombreApi, aliasActual: aliasActual),
            );
            onResultado(resultado);
          },
          child: const Text('Abrir'),
        ),
      ),
    );
  }
}

Future<void> _abrir(
  WidgetTester tester, {
  String nombreApi = 'REPSOL',
  String? aliasActual,
  required ValueChanged<String?> alCerrar,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: _Lanzador(
        nombreApi: nombreApi,
        aliasActual: aliasActual,
        onResultado: alCerrar,
      ),
    ),
  );
  await tester.tap(find.text('Abrir'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('precarga el alias y muestra la referencia y el aviso', (
    tester,
  ) async {
    await _abrir(tester, aliasActual: 'La de la rotonda', alCerrar: (_) {});

    expect(find.text('Editar alias'), findsOneWidget);
    expect(find.text('Sustituye a: REPSOL'), findsOneWidget);
    expect(find.text('Solo se guarda en este dispositivo'), findsOneWidget);
    expect(find.text('Quitar alias'), findsOneWidget);
    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.controller!.text, 'La de la rotonda');
  });

  testWidgets('guardar devuelve el texto escrito', (tester) async {
    String? resultado;
    var cerrado = false;
    await _abrir(
      tester,
      alCerrar: (valor) {
        resultado = valor;
        cerrado = true;
      },
    );

    expect(find.text('Poner alias'), findsOneWidget);
    expect(find.text('Quitar alias'), findsNothing);

    await tester.enterText(find.byType(TextField), 'La del polígono');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(cerrado, isTrue);
    expect(resultado, 'La del polígono');
  });

  testWidgets('quitar alias devuelve un texto vacío', (tester) async {
    String? resultado;
    await _abrir(
      tester,
      aliasActual: 'La de la rotonda',
      alCerrar: (valor) => resultado = valor,
    );

    await tester.tap(find.text('Quitar alias'));
    await tester.pumpAndSettle();

    expect(resultado, isEmpty);
  });

  testWidgets('cancelar no devuelve texto', (tester) async {
    String? resultado;
    var cerrado = false;
    await _abrir(
      tester,
      aliasActual: 'La de la rotonda',
      alCerrar: (valor) {
        resultado = valor;
        cerrado = true;
      },
    );

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(cerrado, isTrue);
    expect(resultado, isNull);
  });

  testWidgets('limita el alias a 40 caracteres', (tester) async {
    String? resultado;
    await _abrir(tester, alCerrar: (valor) => resultado = valor);

    await tester.enterText(find.byType(TextField), 'a' * 45);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(resultado, hasLength(40));
  });

  testWidgets('sin rótulo en la API no muestra la referencia', (tester) async {
    await _abrir(tester, nombreApi: 'Sin rótulo', alCerrar: (_) {});

    expect(find.textContaining('Sustituye a'), findsNothing);
  });
}
