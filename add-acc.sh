#!/bin/bash 

PLIK="${1:-uzytkownicy.txt}" 

TRYB="${2:---dry-run}" 

  

if [[ ! -f "$PLIK" || ! -r "$PLIK" ]]; then 

    echo "Nie mozna odczytac pliku: $PLIK" >&2 

    exit 1 

fi 

if [[ "$TRYB" != "--dry-run" && "$TRYB" != "--apply" ]]; then 

    echo "Uzycie: $0 [plik] [--dry-run|--apply]" >&2 

    exit 1 

fi 

if [[ "$TRYB" == "--apply" && $EUID -ne 0 ]]; then 

    echo "Tryb --apply wymaga sudo" >&2 

    exit 1 

fi 

  

while IFS= read -r login || [[ -n "$login" ]]; do 

    login="${login%$'\r'}" 

    [[ -z "$login" || "$login" == \#* ]] && continue 

    if [[ ! "$login" =~ ^[a-z_][a-z0-9_-]*$ ]]; then 

        echo "Pominieto nieprawidlowa nazwe: $login" 

        continue 

    fi 

    if getent passwd "$login" >/dev/null; then 

        echo "Istnieje: $login" 

        continue 

    fi 

    if [[ "$TRYB" == "--dry-run" ]]; then 

        echo "[TEST] Utworzylbym: $login" 

    elif useradd -m -s /bin/bash "$login"; then 

        echo "[OK] Utworzono: $login" 

    else 

        echo "[BLAD] Nie utworzono: $login" >&2 

    fi 

done < "$PLIK" 
