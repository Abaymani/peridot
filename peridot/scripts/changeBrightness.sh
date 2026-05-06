#!/bin/bash

brillo "$@"

NEW_VAL=$(brillo -G)
qs ipc call brightness update "$NEW_VAL"