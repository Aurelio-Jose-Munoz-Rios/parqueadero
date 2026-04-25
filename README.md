# Parqueadero Vertical Automatizado en VHDL

## Introducción

Este proyecto presenta el diseño e implementación de un sistema de parqueadero vertical totalmente automatizado, controlado por una FPGA utilizando VHDL. El sistema gestiona el almacenamiento de hasta 6 vehículos, optimizando el espacio y ofreciendo una interfaz de usuario simple basada en un teclado matricial. Incluye control preciso de motores, gestión individual del tiempo de estacionamiento, cálculo de tarifas y retroalimentación visual mediante 4 displays de 7 segmentos

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
- **Fuente de alimentación de 12 V** (para el motor paso a paso)
- **Alimentación de 5 V** (para lógica y sensores)
- **Protoboard (breadboard)**
- **Cables Dupont** (macho-macho / macho-hembra)

### FPGA CYCLON III
- **Módulos J4 y J5** 

## Notas
- Los módulos *J4 y J5* pertenecen a la tarjeta FPGA CYCLON III.
---

## Diagrama de Conexión

<img width="1014" height="682" alt="imagen" src="https://github.com/user-attachments/assets/b79dd908-4723-46de-b5b7-3f98894f2da5" />

**[diagrama en wokwi](https://wokwi.com/projects/445853958211321857)** 

## Diagrama de Asignación de Pines

<img width="5096" height="4249" alt="Diagrama en blanco(2)" src="https://github.com/user-attachments/assets/f748c9d6-81e5-4dd2-9e6f-af669cc3910a" />


---

## Posibles Extensiones
- Agregar o reducir cabinas al parqueadero, modificaondo unicamente el arreglo que actualmente tiene 6 posiciones.
- Integrar comunicación serial o por radio (Bluetooth / WiFi).
- Moficar el diseño 3D
- Aregar otras interfaces (web, mobil)
- Añadir medios de pagos digitales
- Integrar otras funcionalidad mediante cross platform

---

© 2025 — Parqueadero vertical automático.


## Colaboración y Roles 

**Aurelio Muñoz**

Project Manager y Diseñador 3D
Responsable de la planificación, coordinación general del proyecto y diseño 3D de los componentes estructurales y la maqueta.


**Kelly Bunay**

Desarrolladora de Software y Diseño de Sistema
Encargada del desarrollo del software, integración de componentes modulares, diseño estético, organización y etiquetado de la maqueta.


**Brayan Mosquera**

Desarrollador de Software e Integración de Hardware
Responsable del desarrollo del software, ensamblaje de módulos, soldadura y conexión del cableado del sistema.
***

## Maqueta y Montaje 

<img width="900" height="720" alt="renderizado_final_Elegancia" src="https://github.com/user-attachments/assets/342a8569-a88d-4982-8631-be0fc817f61d" />

![maqueta](https://github.com/user-attachments/assets/9114f3fb-5228-4be3-81fd-ea9000968c2e)

[Mira el video](https://www.youtube.com/shorts/kxcQuZXT7NA)
