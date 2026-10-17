import 'package:flutter/material.dart';

import 'nombre_mostrado.dart';

class DialogoAlias extends StatefulWidget {
  const DialogoAlias({super.key, required this.nombreApi, this.aliasActual});

  final String nombreApi;
  final String? aliasActual;

  @override
  State<DialogoAlias> createState() => _DialogoAliasState();
}

class _DialogoAliasState extends State<DialogoAlias> {
  late final TextEditingController _controlador = TextEditingController(
    text: widget.aliasActual ?? '',
  );

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _guardar() => Navigator.of(context).pop(_controlador.text);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final nombreApi = widget.nombreApi;
    return AlertDialog(
      title: Text(widget.aliasActual == null ? 'Poner alias' : 'Editar alias'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nombreApi.isNotEmpty && nombreApi != sinRotulo) ...[
            Text(
              'Sustituye a: $nombreApi',
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextField(
            controller: _controlador,
            autofocus: true,
            maxLength: 40,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _guardar(),
            decoration: const InputDecoration(
              labelText: 'Alias',
              helperText: 'Solo se guarda en este dispositivo',
            ),
          ),
        ],
      ),
      actions: [
        if (widget.aliasActual != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('Quitar alias'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
