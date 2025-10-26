# Parqueadero Vertical Automatizado en VHDL

## Introducción

Este proyecto presenta el diseño e implementación de un sistema de parqueadero vertical totalmente automatizado, controlado por una FPGA utilizando VHDL. El sistema gestiona el almacenamiento de hasta 6 vehículos, optimizando el espacio y ofreciendo una interfaz de usuario simple basada en un teclado matricial. Incluye control preciso de motores, gestión individual del tiempo de estacionamiento, cálculo de tarifas y retroalimentación visual mediante 4 displays de 7 segmentos.

***


## Componentes de Hardware

### Entrada / Interfaz de usuario
- **Teclado matricial 4x4** (16 teclas)
- **Botón pulsador rojo** (función: emergencia)
- **Botón pulsador azul** (función: inicio o entrada)

### Indicadores y señalización
- **LED rojo**
- **LED verde**
- **LED amarillo**
- **Resistencias limitadoras de corriente** (para los LED, típicamente 220 Ω o 330 Ω)

### Actuadores
- **Motor paso a paso NEMA 17**
- **Driver A4988** (control del motor paso a paso)
- **Servomotor SG90 o similar**
- **Zumbador (buzzer)**

### Sensores
- **2 Sensores infrarrojos TCRT5000 IR**

### 🔌 Alimentación y conexión
- **Fuente de alimentación de 9 V** (para el motor paso a paso)
- **Alimentación de 5 V** (para lógica y sensores)
- **Protoboard (breadboard)**
- **Cables Dupont** (macho-macho / macho-hembra)

### Módulos de expansión
- **Módulos “Breakout” J4 y J5** (expansión de pines para microcontrolador o tarjeta principal)

## Notas
- Los módulos *J4 y J5* pertenecen a la tarjeta FPGA CYCLON III.
---

## Diagrama de Conexión
El siguiente esquema muestra la interconexión de todos los componentes descritos:
<img width="1115" height="681" alt="esquematico" src="https://github.com/user-attachments/assets/19831baa-e15b-4f01-ad3f-60c580e77eb1" />

---

## Posibles Extensiones
- Agregar pantalla LCD o display OLED para mostrar información.
- Integrar comunicación serial o por radio (Bluetooth / WiFi).
- Implementar control mediante microcontrolador programable.

---

© 2025 — Parqueadero vertical automático con control por teclado, sensores y actuadores.


## Colaboración y Roles 

Aurelio Muñoz: Project Manager y diseño 3D.

Kelly Bunay: Desarrollador de Softaware, componentes modulares, estetica, organización y etiquetado de maqueta.

Brayan Mosquera: Desarrollador de Software, componentes modulares, soldador y conector de cableado.
***

## Maqueta y Montaje 

Agregar imagenes, diseño 3d en solidworks, videos
