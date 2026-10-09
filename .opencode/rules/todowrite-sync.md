# Sincronización de todowrite con el plan

El panel lateral "Todo" de OpenCode solo refleja el estado de la herramienta
`todowrite`; no se actualiza solo.

- Al empezar un trabajo de varios pasos (incluidas las tareas de un change
  OpenSpec en `tasks.md`), inicializa `todowrite` con la lista de tareas.
- Tras completar cada tarea, llama a `todowrite` con el estado actualizado
  (tarea en curso como `in_progress`, terminadas como `completed`), además de
  marcar el checkbox en `tasks.md` cuando aplique.
- Nunca dejes la lista en el estado de llamadas anteriores.
