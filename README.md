# Control IVA
clonar el repositorio en un directorio local y acceder al directorio:

```bash
    git clone https://github.com/facundoosti/control_iva.git
    cd control_iva
```

### Instalar dependencias

```bash
    bundle install
```
## Uso
Deberas pasar como parametro la ruta del archivo de holistor y afip, 
en este caso estan copiados y pegados dentro de la misma carpeta control_iva.

Ejecutar el siguiente comando:

```bash
    ruby control_iva holistor.xlsx afip.xlsx
```

## Salida

El comando generará un archivo llamado `control_iva.xlsx` en la carpeta `control_iva` en el escritorio.
