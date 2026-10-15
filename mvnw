#!/bin/sh
# Delega a mvn real si está instalado (imagen Jenkins lo lleva); si no,
# corre maven en contenedor (gates del host sin JDK/Maven).
if command -v mvn >/dev/null 2>&1; then
  exec mvn "$@"
fi
exec docker run --rm -v "$PWD:/ws" -w /ws maven:3.9-eclipse-temurin-21 mvn "$@"
