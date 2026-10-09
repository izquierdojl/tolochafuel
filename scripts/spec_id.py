#!/usr/bin/env python3
"""Genera un identificador unico de 8 hex (estilo git) para un change OpenSpec."""

from __future__ import annotations

import re
import secrets
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CARPETAS = [
    RAIZ / "openspec" / "changes",
    RAIZ / "openspec" / "changes" / "archive",
    RAIZ / "openspec" / "specs",
]
PATRON = re.compile(r"^[a-z]+-([0-9a-f]{8})-")


def ids_existentes() -> set[str]:
    encontrados: set[str] = set()
    for carpeta in CARPETAS:
        if not carpeta.is_dir():
            continue
        for entrada in carpeta.iterdir():
            m = PATRON.match(entrada.name)
            if m:
                encontrados.add(m.group(1))
    return encontrados


def generar(usados: set[str]) -> str:
    while True:
        candidato = secrets.token_hex(4)
        if candidato not in usados:
            return candidato


def main() -> int:
    if len(sys.argv) > 1 and sys.argv[1] in {"-h", "--help"}:
        print("Uso: spec_id.py [--check <id8>]")
        return 0
    if len(sys.argv) == 3 and sys.argv[1] == "--check":
        ident = sys.argv[2]
        if not re.fullmatch(r"[0-9a-f]{8}", ident):
            print(f"ID invalido: {ident}", file=sys.stderr)
            return 1
        if ident in ids_existentes():
            print(f"ID ya utilizado: {ident}", file=sys.stderr)
            return 1
        print(ident)
        return 0
    print(generar(ids_existentes()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
