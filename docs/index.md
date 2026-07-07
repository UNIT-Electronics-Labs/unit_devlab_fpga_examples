---
layout: home

hero:
  name: Gowin FPGA Labs
  text: Ejemplos DevLab para FPGA Gowin
  tagline: Documentación práctica para compilar, cargar y estudiar ejemplos en Verilog y VHDL sin amarrar el SDK a una tarjeta específica.
  actions:
    - theme: brand
      text: Ver ejemplos
      link: /examples/
    - theme: alt
      text: Usar DevLab
      link: /guide/devlab

features:
  - title: Flujo portable
    details: Usa DevLab como entrada principal para evitar depender de Make en Windows o macOS.
  - title: Dos HDLs
    details: Cada práctica conserva Verilog como flujo por defecto y VHDL como variante explícita.
  - title: Target configurable
    details: La referencia actual usa un GW1NR-LV9QN88PC6/I5, pero la tarjeta se define por los archivos CST y la sección flash.
  - title: Soporte Windows
    details: Documentación específica para configurar DevLab en Windows, incluyendo exclusiones de Windows Defender.
---

## Mapa Rápido

- [Guía de DevLab](./guide/devlab.md)
- [Guía para Windows](./guide/windows.md) ⭐
- [Introducción a Verilog](./guide/verilog.md)
- [Introducción a VHDL](./guide/vhdl.md)
- [Archivos CST](./guide/cst.md)
- [Ejemplos básicos](./examples/index.md)
- [Digital Labs](./examples/digital-labs/index.md)

## Uso Básico

```bash
npm install
npm run docs:dev
```

El sitio se sirve localmente con VitePress y documenta los ejemplos que viven en este repositorio.
