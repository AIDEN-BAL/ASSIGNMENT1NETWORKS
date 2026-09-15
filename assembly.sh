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

lines=()                                              # CHANGED: replaced "mapfile -t lines < "$1"" with this block
while IFS= read -r line || [[ -n "$line" ]]; do        # CHANGED: portable read loop, works on old Bash too
    lines+=("$line")                                   # CHANGED
done < "$1"                                             # CHANGED

if [[ ${#lines[@]} -eq 0 ]]; then
    echo "usage: the file is empty – no .bin file is produced"
    exit 1
fi

n_values="${lines[0]}"

if [[ "$n_values" != "0" && "$n_values" != "2" ]]; then
    echo "usage: line 1 must be 0 or 2"
    exit 1
fi

echo "n_values is '$n_values', proceeding..."
