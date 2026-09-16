                                                                            

#!/bin/bash

if [[ $# -eq 0 ]]; then
    echo "usage: no argument is provided"
    exit 1
fi

if [[ $# -gt 1 ]]; then
    echo "usage: more than one arguments are provided"
    exit 1
fi

if [[ ! -f "$1" ]]; then
    echo "usage: input is not a file or it does not exist"
    exit 1
fi

if [[ "$1" != *.vsc ]]; then
    echo "usage: input does not have the extension .vsc"
    exit 1
fi

lines=()
while IFS= read -r line || [[ -n "$line" ]]; do
    lines+=("$line")
done < "$1"

if [[ ${#lines[@]} -eq 0 ]]; then
    echo "usage: the file is empty – no .bin file is produced"
    exit 1
fi

n_values="${lines[0]}"

if [[ "$n_values" != "0" && "$n_values" != "2" ]]; then
    echo "usage: line 1 must be 0 or 2"
    exit 1
fi

output="${1%.vsc}.bin"

if [[ "$n_values" == "0" ]]; then
    if [[ ${#lines[@]} -ne 2 || "${lines[1]}" != "QUIT,0,0" ]]; then
        echo "usage: when line 1 is 0, line 2 must be exactly QUIT,0,0"
        exit 1
    fi

    {
        printf '\x20'
        printf '\x00'
    } > "$output"

    echo "It is a QUIT program"
    echo "The content of the .bin file is"
    od -An -tx1 "$output" | tr -s ' ' '\n' | sed '/^$/d'

    exit 0
fi

if [[ "$n_values" == "2" ]]; then
    if [[ ${#lines[@]} -lt 3 ]]; then
        echo "usage: line 1 is 2 but line 2 and/or line 3 is missing"
        exit 1
    fi

    val1="${lines[1]}"
    val2="${lines[2]}"

    if ! grep -Eq '^[0-9]+$' <<< "$val1"; then
        echo "usage: line 2 must be a non-negative integer"
        exit 1
    fi

    if ! grep -Eq '^[0-9]+$' <<< "$val2"; then
        echo "usage: line 3 must be a non-negative integer"
        exit 1
    fi

    if (( val1 < 0 || val1 > 127 )); then
        echo "usage: line 2 must be in range [0,128)"
        exit 1
    fi

    if (( val2 < 0 || val2 > 127 )); then
        echo "usage: line 3 must be in range [0,128)"
        exit 1
    fi

    dataArray=()
    dataArray[0]=$val1
    dataArray[1]=$val2

    valid_instructions="LOAD STORE ADD SUB QUIT PRINT"

    for (( i = 3; i < ${#lines[@]}; i++ )); do
        instr_line="${lines[$i]}"

        name="${instr_line%%,*}"

        match=0
        for valid in $valid_instructions; do
            if [[ "$name" == "$valid" ]]; then
                match=1
                break
            fi
        done

        if [[ $match -eq 0 ]]; then
            echo "usage: line $((i+1)) has an invalid instruction '$name'"
            exit 1
        fi

        if (( ${#instr_line} > 11 )); then
            echo "usage: line $((i+1)) exceeds the maximum instruction length of 11 characters"
            exit 1
        fi
    done

    echo "all instruction names and lengths validated"
fi
