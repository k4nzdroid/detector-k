#!/bin/sh

str_ends_with() {
    echo "$1" | grep -q -E "$2"'$' && echo true || echo false
}