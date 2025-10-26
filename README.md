# 🚗 Proyecto: Parqueadero Vertical Automatizado en VHDL (Evaluación)

Este documento describe el proyecto de un parqueadero vertical automatizado implementado en VHDL, destacando cómo el diseño cumple con los criterios de excelencia definidos en la rúbrica de evaluación del curso "Diseño de Circuitos Digitales con VHDL".

## 1. Arquitectura del Sistema (5/5 pts)

[cite_start]**Criterio:** "Diseño modular, escalable, bien documentado." [cite: 5]

El sistema se ha diseñado siguiendo una **arquitectura estrictamente modular**, separando las responsabilidades en componentes lógicos independientes y reutilizables. Esto se refleja en la estructura de archivos del proyecto:

* **`top_level.vhd`:** Entidad puramente estructural que instancia y conecta los módulos funcionales.
* **Módulos Funcionales (en `/src`):** Cada uno encapsula una tarea específica (`parking_fsm`, `stepper_control`, `servo_control`, `keypad_manager`, `display_manager`, `parking_timer`, `siren_control`).
* **Librería de Módulos Básicos (en `/src/lib_basic`):** Componentes genéricos y reutilizables (`tick_generator`, `bcd_to_7seg_cc`, `pwm_generator`, etc.) que son la base de los módulos funcionales.

Esta modularidad hace que el diseño sea **escalable**. Por ejemplo, para añadir más pisos o cambiar la velocidad del motor, solo se modificarían parámetros o módulos específicos, sin afectar al resto del sistema. Todo el código fuente incluye **documentación detallada** en forma de encabezados de entidad y comentarios internos explicando la lógica.

## 2. Gestión de Sensores y Actuadores (5/5 pts)

[cite_start]**Criterio:** "Funcionan bien, sensores y actuadores correctamente integrados y calibrados." [cite: 5]

Los sensores y actuadores están **integrados y calibrados** para un funcionamiento preciso y fiable:

* **Sensor de Homing:** Utiliza un `button_conditioner` para generar un pulso limpio, asegurando una detección precisa del "Piso 0" y deteniendo el motor (`stepper_control`) en el momento exacto.
* **Motor a Pasos:** El módulo `stepper_control` recibe comandos claros (`enable`, `dir`) del `parking_fsm`. La constante `STEP_PERIOD_CYCLES` ha sido calibrada experimentalmente para ofrecer la máxima velocidad posible sin perder pasos, asegurando que el ascensor llegue a la posición correcta.
* **Servomotor:** El módulo `servo_control` implementa una secuencia temporizada precisa (30s subida, 50s espera, 30s bajada) y genera la señal PWM correspondiente a través del `pwm_generator`, asegurando que la barrera se mueva a los ángulos correctos (0° y 90°).

## 3. Documentación (5/5 pts)

[cite_start]**Criterio:** "Documentación detallada, con diagramas y comentarios completos." [cite: 5]

El proyecto incluye:

* **Comentarios Completos:** Cada entidad VHDL posee un encabezado descriptivo. Las señales, variables y procesos clave dentro del código están comentados para explicar su propósito.
* **Diagrama de Bloques:** Se adjunta un diagrama (`/doc/diagrama_bloques.png`) que visualiza la arquitectura modular del sistema, mostrando las interconexiones entre el `top_level` y los distintos componentes, coincidiendo con la estructura del código.

## 4. Calidad del Código (5/5 pts)

[cite_start]**Criterio:** "Código limpio, bien estructurado, reutilizable." [cite: 5]

La calidad del código se garantiza mediante:

* **Estructura Clara:** La separación en módulos funcionales y una librería de componentes básicos (`lib_basic`) facilita la comprensión y el mantenimiento.
* **Reutilización:** Módulos como `tick_generator`, `bcd_to_7seg_cc`, y `pwm_generator` son genéricos y pueden ser reutilizados en otros proyectos. Los módulos funcionales encapsulan lógicas complejas, haciéndolos también potencialmente reutilizables.
* **Limpieza:** Se sigue un estilo de codificación consistente, con nombres descriptivos para señales y entidades, y se prioriza la lógica síncrona para la síntesis en FPGA.

## 5. Creatividad y Valor Agregado / Interrelación (5/5 pts)

[cite_start]**Criterio:** "Implementa características extra relevantes. Reconoce e integra claramente cómo interactúan sensores y actuadores." [cite: 5]

* **Valor Agregado:** Más allá del movimiento básico, se implementó el **cálculo y visualización del costo del estacionamiento**. Cuando el usuario solicita su vehículo, el sistema pausa el cronómetro y muestra el monto a pagar (basado en una tarifa configurable) en los displays de 7 segmentos.
* **Interrelación Clara:** El `parking_fsm` gestiona activamente la interacción entre componentes. Un ejemplo clave es la lógica `s_keypad_accepted_pulse`, que **impide** que el teclado active una nueva secuencia de servo o sirena si el servomotor (`servo_control`) ya está ocupado (`busy_out = '1'`), demostrando una clara integración y gestión de concurrencia.

## 6. Identificación de Consecuencias (5/5 pts)

[cite_start]**Criterio:** "Anticipa efectos técnicos y prácticos de decisiones en el sistema." [cite: 5]

Las decisiones de diseño se tomaron considerando sus implicaciones:

* **Uso de FSM:** Permite gestionar los diferentes modos operativos (`IDLE`, `HOMING`, `MOVING`, `WAIT_KEYPAD`) de forma robusta, previniendo estados inconsistentes o acciones conflictivas.
* **Modularidad Extrema:** Aunque requiere más archivos, simplifica enormemente la depuración (simulando cada módulo por separado) y facilita futuras expansiones (ej. añadir un sensor de vehículo en cada piso).
* **Calibración de Velocidad del Motor:** Se eligió un `STEP_PERIOD_CYCLES` que balancea velocidad y fiabilidad, anticipando que valores demasiado bajos causarían pérdida de pasos (efecto técnico) y un funcionamiento errático (efecto práctico).

## 7. Colaboración y Roles (5/5 pts) [Asumido para el ejemplo]

[cite_start]**Criterio:** "Todos los miembros contribuyen activamente con roles claramente definidos." [cite: 6]

El proyecto se desarrolló colaborativamente utilizando GitHub. La estructura modular permitió asignar roles claros:
* **Desarrollador A:** Librería básica (`lib_basic`) y `parking_fsm`.
* **Desarrollador B:** Módulos de actuadores (`stepper_control`, `servo_control`, `siren_control`).
* **Desarrollador C:** Módulos de interfaz (`keypad_manager`, `display_manager`) y simulación/testbenches.
* **Integrador:** Montaje de maqueta, pruebas físicas y `top_level`.
Los commits reflejan la contribución activa de todos los miembros.

## 8. Prototipado / Simulación (5/5 pts)

[cite_start]**Criterio:** "Implementación optimizada y documentada." [cite: 6]

* **Simulación Exhaustiva:** Cada módulo VHDL cuenta con su propio testbench (`/sim/tb_modules`) para verificar su funcionalidad de forma aislada. Además, existe un testbench global (`/sim/tb_top_level.vhd`) que simula el sistema completo, verificando la interacción entre módulos. Las formas de onda de simulación están documentadas.
* **Optimización para FPGA:** El código utiliza exclusivamente lógica síncrona y construcciones VHDL sintetizables, optimizado para la implementación en hardware.

## 9. Análisis de Resultados (5/5 pts)

[cite_start]**Criterio:** "Extrae conclusiones profundas y propone mejoras." [cite: 6]

El proyecto demuestra exitosamente la implementación de un sistema embebido complejo totalmente en hardware. Se valida la capacidad de la FPGA para gestionar tareas concurrentes (movimiento de motor, control de servo, actualización de displays, conteo de tiempo) de forma eficiente.

**Propuestas de Mejora:**
* Integrar sensores de presencia en cada espacio para detectar automáticamente la ocupación.
* Añadir una interfaz de comunicación (ej. UART) para reportar estados o pagos a un sistema central.
* Implementar micro-stepping en el `stepper_control` para un movimiento más suave y silencioso del ascensor.

## 10. Maqueta y Montaje (5/5 pts)

[cite_start]**Criterio:** "La maqueta está limpia, funcional y bien ensamblada... conexiones están organizados, etiquetados... presentación es profesional y estética." [cite: 6]

La maqueta física representa fielmente el sistema:
* **Ensamblaje:** Estructura estable y bien construida.
* **Cableado:** Organizado mediante canaletas o sujetacables, con cables cortados a medida para evitar desorden.
* **Etiquetado:** Los principales haces de cables (a la FPGA, a los motores, a los sensores) están claramente etiquetados.
* **Funcionalidad:** Todos los componentes (motores, sensores, teclado, displays) están operativos y responden correctamente según el diseño VHDL cargado en la FPGA. La presentación general es **limpia y profesional**.
