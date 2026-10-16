#!/bin/bash 

PLIK="uzytkownicy.txt" 

RAPORT="raport.txt" 

[[ -f "$PLIK" ]] || { echo "Brak pliku" >&2; exit 1; } 

echo "Raport kont: $(date)" > "$RAPORT" 

while IFS= read -r login || [[ -n "$login" ]]; do 

    login="${login%$'\r'}" 

    [[ -z "$login" || "$login" == \#* ]] && continue 

    if [[ ! "$login" =~ ^[a-z_][a-z0-9_-]*$ ]]; then 

        echo "$login: niepoprawna nazwa" | tee -a "$RAPORT" 

    elif getent passwd "$login" >/dev/null; then 

        echo "$login: istnieje, UID=$(id -u "$login")" | tee -a "$RAPORT" 

    else 

        echo "$login: brak konta" | tee -a "$RAPORT" 

    fi 

done < "$PLIK"
