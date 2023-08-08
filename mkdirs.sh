#!/bin/bash
END="${1:-21}"
for i in $(seq 3 $END); do
    mkdir "Data/${i}"
done