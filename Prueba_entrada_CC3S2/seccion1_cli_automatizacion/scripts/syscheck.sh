#!/usr/bin/env bash
set -euo pipefail
trap 'echo "[ERROR] Falló en línea $LINENO" >&2' ERR

mkdir -p reports

# TODO: HTTP-guarda headers y explica código en 2-3 líneas al final del archivo
{
  echo "curl -I example.com"
  curl -Is https://example.com | sed '/^\r$/d'
  echo
  echo "Explicación:"
  echo "El código HTTP 200 significa que la petición fue exitosa."
  echo "Está usando HTTP/2, que hace la conexión más rápida y eficiente."
  echo "Las cabeceras (cache-control,...) sirven para que el navegador guarde la página y no la pida a cada rato"
} > reports/http.txt

# TODO: DNS — muestra A/AAAA/MX y comenta TTL
{
  echo "A";    dig A example.com +noall +answer
  echo "AAAA"; dig AAAA example.com +noall +answer
  echo "MX";   dig MX example.com +noall +answer
  echo
  echo "Nota:"
  echo "El número (TTL) dice cuántos segundos se guarda la respuesta antes de volver a preguntar."
  echo "A = IPv4, AAAA = IPv6, MX = correo."
} > reports/dns.txt

# TODO: TLS - registra versión TLS
{
  echo "TLS via curl -Iv"
  curl -Iv https://example.com 2>&1 | sed -n '1,20p'
  echo "Versión observada TLSv1.3"
} > reports/tls.txt

# TODO: Puertos locales - lista y comenta riesgos
{
  echo "ss -tuln"
  ss -tuln || true
  echo
  echo "Riesgos"
  echo "Los puertos que aparecen aquí están abiertos y en escucha en la máquina."
  echo "Si dejas puertos innecesarios abiertos, cualquiera podría intentar conectarse o explotar vulnerabilidades."
  echo "Por eso se recomienda cerrar lo que no uses o protegerlos con firewall."

} > reports/sockets.txt

echo "Reportes generados en ./reports"