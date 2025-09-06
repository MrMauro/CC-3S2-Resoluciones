# HTTP, DNS, TLS y 12-Factor (port binding, configuración, logs)
Maurizio Berdiales Díaz - 20202113E

## Ejecución y Verificación de la App Flask

Este documento describe los pasos para levantar y probar la aplicación Flask siguiendo las buenas prácticas del principio **12-Factor**.

---

## Crear y activar el entorno virtual

Dentro de la carpeta del laboratorio:

```bash
python3 -m venv venv
source venv/bin/activate
```

* `python3 -m venv venv` crea un entorno virtual llamado `venv`

* `source venv/bin/activate` lo activa, de forma que todas las librerías que instalemos quedan aisladas para este proyecto.

## Instalar dependencias

Con el entorno virtual activado, instalamos **Flask**:

```bash
pip install flask
```

Levantamos la aplicación Flask pasando las variables de entorno directamente en el comando:

```bash
PORT=8080 MESSAGE="Hola CC3S2" RELEASE="v1" python3 app.py
```

![Requerimientos](./capturas%20de%20terminal/1requerimientos.png)

![Respuesta HTTP](./capturas%20de%20terminal/2respuestahttp.png)

## Pregunta guía: Campos que cambian si actualizo MESSEGE/RELEASE sin reiniciar el proceso

Si actualizo las variables de entornoen la misma terminal pero sin reiniciar el proceso, NO cambian en la respuesta JSON. Las variables de entorno se cargan al inicio del proceso, por lo que la aplicación sigue usando los valores que tenía al arrancar.
Para ver el cambio, es necesario detener con **CTRL+C** y volver a ejecutar el comando con las nuevas variables.

## Puertos abiertos con ss

Para verificar que la aplicación está escuchando en el puerto configurado, se ejecuta lo documentado y la salida es satisfactoria

Se confirma que el socket está en estado **LISTEN**. Está atado a la dirección **127.0.0.1** en el puerto **8080**. EL proceso que lo mantiene abierto es **python3** (nuestra app Flask).

![Puertos ss](./capturas%20de%20terminal/3puertosss.png)

## Logs como flujo (stdout)

La aplicación imprime los logs directamente en la consola (stdout).

* Los logs no se escriben en un archivo porque el principio **12-Factor: Logs** indica que deben tratarse coomo un flujo continuo.

* Esto facilita que en entornos d producción (contenedores, sistemas distribuidos) herramientas como `systemd`, `docker logs` o servicios de monitoreo los capturen y procesen.

* Permite un despliegue reproducible sin configuración especial de rutas de archivos de log.

## DNS: nombres, registros y caché

### Configuración del host local

El comando `make hosts-setup` nos da como respuesta que `miapp.local ya está presente en /etc/hosts`.

![Hosts Local, comprueba resolución](./capturas%20de%20terminal/4diggetent.png)

Se comprueba la resolución correcta usando la base de hosts locales.

### Observación de TTL y caché (conceptual)

Si se ejecuta el comando, dará como resultado el **TTL (Time To Live)**. Si se ejecutara el mismo comando rápidamente, el valor disminuiría, esto debido a que se usará la **respuesta cacheada** hasta que el TTL expire y se haga una nueva consulta al servidor autoritativo.

## Pregunta guía: etc/hosts vs. Zona DNS

`/etc/hosts` es un archivo local  que actúa como un mapa estático de nombres a IPs. Una **zona DNS autoritativa** está gestionada por servidores DNS que responden de forma dinámica para toda la red. Para laboratorio, `/etc/hosts` es suficiente porque permite simular la resolución de nombres sin levantar un servidor DNS real ni depender de internet. Esto asegura reproducibilidad y control en entornos aislados.  

## TLS: seguridad en tránsito con Nginx como reverse proxy

Se genera certificados y se configura Nginx (reverse proxy + TLS) con los comandos en Instrucciones.md.

![Configuración nginx](./capturas%20de%20terminal/5nginx.png)

Para verificar que la aplicación es accesible mediante HTTPS, se utilizó:

```bash
curl -k https://miapp.local/
```

![Valida en handshake](./capturas%20de%20terminal/6ssl.png)

El parámetro `-k` (o `--insecure`) le indica a `curl` que **ignore los errores de verificación de certificados**. Esto es necesario en este laboratorio porque estamos usando un **certificado autofirmado**, que no está firmado por una autoridad de certificación de confianza.

Si no se usa `-k`, `curl` mostraría un error

## 12-Factor App: Port binding, Configuración y Logs

### Port Binding

La aplicación se configuró para escuchar en el puerto especificado por la variable de entorno `PORT`.  
Se verificó con el comando `ss -ltnp` que muestra los puertos abiertos:

```bash
PORT=8080 make run &
ss -ltnp | grep 8080
```

![Port Binding](./capturas%20de%20terminal/7portbinding.png)

### Configuración por entorno

Se probaron dos configuraciones distintas de `MESSAGE` y `RELEASE` para confirmar que afectan la respuesta JSON, se demuestra entonces que la configuración está desacoplada del código y se maneja por variables de entorno.

### Logs a stdout

Por diseño, la aplicación imprime logs en `stdout` y no en archivos. Esto permite que cualquier sistema de orquestación (como systemd o Docker) capture y rote logs centralmente.

No se configura un log file en la app porque el principio 12-Factor recomienda emitir logs a stdout/stderr, delegando la persistencia y gestión de logs al entorno de ejecución (systemd, Docker, Kubernetes, etc.).

## Operación reproducible (Make/WSL/Linux)

Para garantizar reproducibilidad, se usaron los `Makefile` provistos en el repositorio.
En cada máquina nueva se deben seguir estos pasos:

| Comando                  | Resultado esperado |
|-------------------------|------------------|
| `make prepare`          | Crea entornos virtuales, instala dependencias. |
| `make run`              | Lanza el servidor Flask en `127.0.0.1:8080`. |
| `make check-http`       | Verifica que la app responde vía HTTP (código 200). |
| `make tls-cert`         | Genera certificado autofirmado en `certs/`. |
| `make nginx`            | Copia archivos de configuración a `/etc/nginx/sites-enabled/`. |
| `sudo systemctl restart nginx` | Reinicia Nginx para aplicar configuración TLS. |
| `make check-tls`        | Prueba conexión HTTPS a `https://miapp.local/`. |
| `make dns-demo`         | Ejecuta consultas DNS mostrando resolución de `miapp.local`. |


## Preguntas Guía

### HTTP: Idempotencia y su impacto
La **idempotencia** significa que ejecutar el mismo método varias veces produce el mismo resultado.  
- **Ejemplo**:  
  - `curl -X PUT -d '{"nombre":"Juan"}' http://127.0.0.1:8080/recurso/1`  
    Actualiza el recurso y si lo repites, el estado final es el mismo → seguro para retries y health checks.  
  - `curl -X POST -d '{"nombre":"Juan"}' http://127.0.0.1:8080/recurso`  
    Crea un nuevo recurso cada vez → NO idempotente, puede duplicar datos en reintentos.

Por eso los **health checks** usan `GET` (idempotente) para evitar efectos secundarios en la app.

---

### DNS: uso de hosts y TTL
- **Archivo hosts** es útil en laboratorio porque:
  - No requiere un DNS público ni modificar infraestructura real.
  - Permite resolver `miapp.local` hacia `127.0.0.1` de forma inmediata.
- **No se usa en producción** porque:
  - Es manual, no escala y cada máquina necesitaría edición propia.
  - No permite cambios dinámicos de IP.
- **TTL** define cuánto tiempo se cachea la respuesta.
  - Un TTL bajo permite que los cambios de IP se propaguen rápido pero aumenta consultas al DNS.
  - Un TTL alto reduce latencia y carga en el DNS, pero puede dejar cacheadas IPs antiguas.

---

### TLS: rol de SNI
**SNI (Server Name Indication)** envía el nombre del host durante el handshake TLS para que el servidor devuelva el certificado correcto.  
- **Demostración**:
```bash
openssl s_client -connect miapp.local:443 -servername miapp.local -brief
```

Se ve que el certificado entregado corresponde a `miapp.local`.
Si omites `-servername`, algunos servidores devuelven un certificado por defecto (o el handshake falla si hay múltiples sitios en el mismo host).

### 12-Factor: logs y configuración
- Logs a stdout: permiten que cualquier sistema (Docker, systemd, CI/CD) los capture sin configuración extra. No se usa un archivo de log en la app para evitar acoplarla al filesystem de la máquina.

- Configuración por entorno: cambiar `MESSAGE`, `PORT`, `RELEASE` sin modificar el código facilita despliegues en múltiples entornos (dev/staging/prod).

### Operación y diagnóstico
- `ss -ltnp` muestra puertos en escucha, PID y proceso que los está usando. Esto confirma que la app está corriendo incluso si `curl` falla.
- Triangulación de problemas
    1. Usar `ss` para ver si el puerto 8080/443 está abierto.
    2. Revisar `journalctl -u nginx` para detectar errores de Nginx (p.ej. certificado mal configurado). 
    3. Revisar `/var/log/nginx/error.log` para detalles de errores HTTP/TLS. Esto ayuda a diferenciar si el problema es de aplicación, de proxy o de red.