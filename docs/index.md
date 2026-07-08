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
- [Ruta del curso](./guide/curso.md)
- [Introducción a Verilog](./guide/verilog.md)
- [Introducción a VHDL](./guide/vhdl.md)
- [Archivos CST](./guide/cst.md)
- [Esquemático Tang Nano 9K](./guide/esquematico.md)
- [Ejemplos básicos](./examples/index.md)
- [Digital Labs](./examples/digital-labs/index.md)

## Cursos

<div class="course-grid">
  <section class="course-card course-basic">
    <h3>Inicio FPGA</h3>
    <p>Primeros ejemplos para validar reloj, botones, LEDs y flujo DevLab.</p>
    <a href="./examples/">Abrir ejemplos básicos</a>
  </section>
  <section class="course-card course-digital">
    <h3>Digital Labs</h3>
    <p>Prácticas combinacionales, contadores y máquinas de estado en Verilog y VHDL.</p>
    <a href="./examples/digital-labs/">Abrir prácticas</a>
  </section>
  <section class="course-card course-tooling">
    <h3>Toolchain</h3>
    <p>Instalación, compilación, carga en placa y solución de problemas por sistema operativo.</p>
    <a href="./guide/devlab.md">Abrir guía DevLab</a>
  </section>
  <section class="course-card course-reference">
    <h3>Referencia de Hardware</h3>
    <p>CST, pinout, esquemático y criterios para adaptar la tarjeta objetivo.</p>
    <a href="./guide/cst.md">Abrir pines CST</a>
  </section>
</div>
