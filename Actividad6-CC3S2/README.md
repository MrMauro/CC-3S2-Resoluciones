# Resolución de la Actividad 6
Maurizio Berdiales Díaz - 20202113E

Se ejecuta en el git bash de la actividad número 6:

```bash
git config --global user.name "Maurizio Berdiales"
git config --global user.email "maurizio3324@gmail.com"
git --version > logs/git-version.txt
git config --list > logs/config.txt
```

Donde `git --version > logs/git-version.txt` muestra en pantalla la versión instalada de Git, y en lugar de mostrar ese texto en la terminal, lo guarda dentro del archivo `logs/git-version.txt`

`git config --list > logs/config.txt` muestra todas las configuraciones activas de Git en el entorno, tales como `user.name` `user.email`. Así mismo, en lugar de mostrar todo en la terminal, lo guarda en `logs/config.txt`.

Se ejecutan en el git branch:

```bash
git init > logs/init-status.txt
git status >> logs/init-status.txt
```

Responsables de crear el archivo con la salida de `git init` y agregar la salida de `git status` al mismo archivo, sin borrar lo anterior.

Se procede con el llenado de `add-commit.txt`

