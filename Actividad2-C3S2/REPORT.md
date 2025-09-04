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


