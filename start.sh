#!/bin/bash

export PORT=5102

cd ~/www/memory2
./bin/memory2 stop || true
./bin/memory2 start

