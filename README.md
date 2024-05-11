
# Fudo Backend Dev Challenge

API sencilla de productos 

## Instalación

Instalar mediante docker utilizando el dockerfile provisto en el root del repositorio. El contenedor de docker manejará la instalación de dependencias y gemas de ruby.

Hacer el build de la imagen:
```bash
    sudo docker build -t fudo-challenge:latest .
```
    
Correr la imagen:
```bash
    sudo docker run -it --rm fudo-challenge:latest
```

Esto ejecutará el archivo ```main.rb``` que se autentica y utiliza las funcionalidades principales de la API.

Para correr los tests de la API:
```bash
    sudo docker run -it fudo-challenge:latest /bin/bash -c "cd /app/src && rspec api_rspec.rb"
```
