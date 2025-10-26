# Parqueadero Vertical Automatizado en VHDL

## Introducción

Este proyecto presenta el diseño e implementación de un sistema de parqueadero vertical totalmente automatizado, controlado por una FPGA utilizando VHDL. El sistema gestiona el almacenamiento de hasta 6 vehículos, optimizando el espacio y ofreciendo una interfaz de usuario simple basada en un teclado matricial. Incluye control preciso de motores, gestión individual del tiempo de estacionamiento, cálculo de tarifas y retroalimentación visual mediante 4 displays de 7 segmentos.

***

## Arquitectura del Sistema 

El diseño se basa en una **arquitectura estrictamente modular**, dividiendo el sistema en componentes lógicos.

* **`top_level.vhd`:** Actúa como la entidad principal, puramente estructural, encargada de instanciar y conectar todos los submódulos.
* **Módulos Funcionales (`/src`):** Encapsulan tareas completas como la lógica de control principal (`parking_fsm`), el manejo de actuadores (`stepper_control`, `servo_control`, `siren_control`), la interfaz de usuario (`keypad_manager`, `display_manager`) y la gestión del tiempo (`parking_timer`).
* **Librería Básica (`/src/lib`):** Contiene componentes genéricos y reutilizables (`tick_generator`, decodificadores 7-segmentos, `pwm_generator`, etc.), que forman los bloques de construcción fundamentales.

Esta separación promueve la **escalabilidad**; por ejemplo, ajustar el número de espacios o la velocidad del motor implicaría modificar parámetros o módulos específicos sin alterar el resto del sistema.

***

## Sensores y Actuadores 
***
* **Sensores:**
    * **Referencia Posicional (Homing):** Se utiliza un **Sensor Tracker seguidor de línea** en la base del sistema. Su señal digital se procesa mediante un acondicionador (`button_conditioner`) para generar un pulso limpio que indica al `parking_fsm` que se ha alcanzado la posición "Piso 0", deteniendo el motor (`stepper_control`) con precisión.
    * **Monederos:** Se utiliza un sensor **HTC5000 IR** para detectar la inserción de monedas. La señal de este sensor también se acondiciona para interactuar con la FSM principal y gestionar el pago.
    * **Botón de Inicio/Inicialización:** Un pulsador estándar cuya señal es acondicionada (`button_conditioner`) para generar el pulso `start_btn_tick`, iniciando la secuencia de *homing* en la FSM.
    * **Botón de Emergencia (Reset):** Conectado a la entrada `boton_reset`, proporciona un reset asíncrono a todos los módulos, deteniendo actuadores y devolviendo la FSM al estado inicial (`S_IDLE`) de forma inmediata.

* **Actuadores:**
    * **Movimiento del sistema:** Un **Motor Paso a Paso NEMA 17**, controlado por un driver **A4988**, es el responsable del movimiento. El módulo `stepper_control` recibe comandos simples (`enable`, `dir`) del `parking_fsm` y genera la secuencia de pulsos `step` necesaria. La velocidad (`STEP_PERIOD_CYCLES`) se ha calibrado para un equilibrio óptimo entre rapidez y fiabilidad, evitando la pérdida de pasos.
    * **Barrera de Acceso:** Un **Servomotor** estándar controla la apertura y cierre de la puerta. El módulo `servo_control`, a través de su submódulo `pwm_generator`, genera la señal PWM precisa para mover el servo a las posiciones calibradas (ej., 0° y 90°) durante la secuencia temporizada.
    * **Indicador Acústico:** Una **Sirena de 12V** (manejada a través de una interfaz de potencia adecuada, como un relé o transistor) es activada por el módulo `siren_control` para proporcionar retroalimentación al usuario.
    * **Indicador Visual:** Una **Torre de LEDs (Rojo, Amarillo, Verde)** indica el estado general del sistema. El LED Rojo indica una falla o el estado de *homing*, el Amarillo el movimiento del ascensor o la barrera, y el Verde el estado de reposo (`S_WAIT_KEYPAD`) o disponibilidad.

***

# Proyecto Electrónico - Control con Teclado y Motores

Este proyecto integra varios componentes electrónicos conectados mediante una placa de pruebas (breadboard) y módulos de expansión (breakouts). Incluye control mediante teclado matricial, indicadores LED, sensores y motores.

## 🧩 Componentes de Hardware

### 🔢 Entrada / Interfaz de usuario
- **Teclado matricial 4x4** (16 teclas)
- **Botón pulsador rojo** (función: emergencia)
- **Botón pulsador azul** (función: inicio o entrada)

### 💡 Indicadores y señalización
- **LED rojo**
- **LED verde**
- **LED amarillo**
- **Resistencias limitadoras de corriente** (para los LED, típicamente 220 Ω o 330 Ω)

### ⚙️ Actuadores
- **Motor paso a paso NEMA 17**
- **Driver A4988** (control del motor paso a paso)
- **Servomotor SG90 o similar**
- **Zumbador (buzzer)**

### ⚡ Sensores
- **2 Sensores infrarrojos (IR)** tipo módulo seguidor de línea (digitales)

### 🔌 Alimentación y conexión
- **Fuente de alimentación de 9 V** (para el motor paso a paso)
- **Alimentación de 5 V** (para lógica y sensores)
- **Protoboard (breadboard)**
- **Cables Dupont** (macho-macho / macho-hembra)

### 🔧 Módulos de expansión
- **Módulos “Breakout” J4 y J5** (expansión de pines para microcontrolador o tarjeta principal)

##Notas
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

© 2025 — Proyecto electrónico con control por teclado, sensores y actuadores.


## Colaboración y Roles 

Aurelio Muñoz: Project Manager y diseño 3D.

Kelly Bunay: Desarrollador de Softaware, componentes modulares, estetica, organización y etiquetado de maqueta.

Brayan Mosquera: Desarrollador de Software, componentes modulares, soldador de headers y medición de cableado.
***

## Maqueta y Montaje 

Agregar imagenes, diseño 3d en solidworks, videos
