# Resolución de la Prueba de Entrada

Maurizio Berdiales Díaz - 20202113E

## Sección 1

### syscheck.sh

Luego de replicar la estructura solicitada en Intrucciones.md, para poder explicar en http.txt, se tiene que editar directamente, de manera que corriendo `make all`, se genere la explicación **sin intervención**.

Se edita nuevamente `syscheck,sh` para poder generar sin intervención la explicación de DNS (TTL).

A continuación, se corre el script `curl Iv https://example.com`. Se observa en la salida del terminal la versión TLS.

Se ejecuta `ss -tuln`. Se explica por qué es importante cerrar los puertos que son innecesarios tener abiertos.

### Makefile

## Sección 2

Todos los target funcionan correctamente. Además de ser idempotente (no importa cuántas veces lo corramos, no se rompe).


