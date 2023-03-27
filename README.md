# Control IVA

Para usar el control de IVA, debe descargarse el comando para consola desde el siguiente enlace:

Para Mac: [control_iva-osx](https://github.com/facundoosti/control_iva/blob/main/control_iva-1.0.0-osx.tar.gz)\
Para Linux-x86: [control_iva-linux-x86](https://github.com/facundoosti/control_iva/blob/main/control_iva-1.0.0-linux-x86.tar.gz)\
Para Linux-x86_64: [control_iva-linux-x86_64](https://github.com/facundoosti/control_iva/blob/main/control_iva-1.0.0-linux-x86_64.tar.gz)

## Uso

- Crear una carpeta llamada `control_iva` en el escritorio.
- Descargar los archivos de holistor y afip para control.
- Renombrar los archivos de excel a `holistor.xlsx` y `afip.xlsx` respectivamente.

Ejecutar el siguiente comando:

```bash
    ./control_iva holistor.xlsx afip.xlsx
```

## Salida

El comando generará un archivo llamado `control_iva.xlsx` en la carpeta `control_iva` en el escritorio.
