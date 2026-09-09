#!/bin/bash
if [[ $# -ne 1 ]]; then
    echo "Error: expected exactly 1 argument, got $#"
    exit 1
fi 

if [[ ! -f "1" ]]; then
    echo "Error: '$1' does not exist or is not a regular file"
    exit 1
fi

if [[ "$1" != *.vsc ]]; then
    echo "Error: '$1' must have a .vsc extension"
    exit 1
fi

echo "Input file '$1' is valid, proceeding..."
