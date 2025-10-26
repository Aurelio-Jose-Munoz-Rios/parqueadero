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

## Gestión de Sensores y Actuadores 

La integración y **calibración precisa** de sensores y actuadores garantizan un funcionamiento fiable y exacto:

* **Sensor de Homing:** Se utiliza un acondicionador de señal (`button_conditioner`) para asegurar una detección limpia del "Piso 0", permitiendo al `stepper_control` detenerse en la posición correcta.
* **Motor a Pasos:** El control se realiza mediante comandos claros (`enable`, `dir`) desde la FSM principal. La velocidad de operación (`STEP_PERIOD_CYCLES`) ha sido **calibrada experimentalmente** para optimizar el balance entre rapidez y fiabilidad, asegurando el posicionamiento exacto en cada nivel.
* **Servomotor:** El `servo_control` implementa una secuencia temporizada precisa para la apertura y cierre de la barrera, utilizando un `pwm_generator` para alcanzar los ángulos correctos (0° y 90°) de forma consistente.

***

## Documentación 

El proyecto está **ampliamente documentado** para facilitar su comprensión y mantenimiento:

* **Comentarios en Código:** Cada entidad VHDL incluye un encabezado descriptivo. Se han añadido comentarios internos en puntos clave para clarificar la lógica de señales, variables y procesos complejos.
* **Diagrama de Bloques:** Se proporciona un diagrama visual (`/doc/diagrama_bloques.png`) que ilustra la arquitectura modular y las interconexiones entre los componentes, reflejando fielmente la estructura del código VHDL.

***

## Calidad del Código 

Se ha puesto énfasis en la **calidad, estructura y reutilización** del código VHDL:

* **Estructura Clara:** La división en módulos funcionales y una librería básica (`lib_basic`) resulta en un código organizado y fácil de seguir.
* **Reutilización:** Componentes como `tick_generator`, los decodificadores 7-segmentos y `pwm_generator` son genéricos y aplicables a otros proyectos. Los módulos funcionales también encapsulan lógicas complejas de forma reutilizable.
* **Limpieza:** Se mantiene un estilo de codificación consistente, con nombres descriptivos y priorizando la lógica síncrona, adecuada para la síntesis en FPGAs.

***

## Creatividad, Valor Agregado e Interrelación 

El proyecto va más allá de los requisitos básicos, incorporando **funcionalidades adicionales** y demostrando una **gestión inteligente de la interacción** entre componentes:

* **Valor Agregado:** Se implementó el **cálculo y visualización automática del costo** del estacionamiento. Al solicitar el vehículo, el sistema no solo pausa el tiempo, sino que calcula el monto a pagar según una tarifa predefinida y lo muestra al usuario.
* **Interrelación Inteligente:** La FSM principal (`parking_fsm`) coordina activamente los subsistemas. Por ejemplo, la lógica implementada **evita que el usuario pueda activar la barrera (servo) o la sirena si el servo ya está en movimiento**, gestionando así la concurrencia y previniendo comportamientos indeseados.

***

## Identificación de Consecuencias 

Las decisiones clave de diseño se tomaron **analizando sus efectos técnicos y prácticos**:

* **Arquitectura FSM:** Se eligió una Máquina de Estados Finitos para el control central por su robustez en la gestión de modos operativos complejos y la prevención de estados inconsistentes.
* **Modularidad Profunda:** Facilita la depuración individual de componentes y la escalabilidad futura, aunque implique un mayor número de archivos.
* **Velocidad del Motor:** La calibración del `STEP_PERIOD_CYCLES` consideró el impacto técnico (pérdida de pasos) y práctico (funcionamiento errático vs. eficiencia) para encontrar un punto óptimo.

***

## Colaboración y Roles 

El desarrollo se realizó de forma colaborativa, aprovechando la estructura modular para **definir roles claros y facilitar el trabajo en paralelo** utilizando un sistema de control de versiones (GitHub). Las contribuciones de cada miembro del equipo están documentadas a través del historial de commits.

***

## Prototipado y Simulación 

La **validación funcional** se realizó mediante simulación exhaustiva y pruebas en el prototipo físico:

* **Simulación Detallada:** Cada módulo cuenta con un testbench individual (`/sim/tb_modules`) para verificación aislada. Un testbench global (`/sim/tb_top_level.vhd`) valida la interacción del sistema completo.
* **Optimización para Hardware:** El código está escrito utilizando construcciones VHDL sintetizables y sigue las mejores prácticas para implementación en FPGAs.

***

## Análisis de Resultados 

El proyecto valida la viabilidad de implementar sistemas de control embebido complejos **directamente en hardware**, aprovechando el paralelismo inherente de las FPGAs para gestionar múltiples tareas concurrentes (control de motores, temporización, interfaz de usuario) de manera eficiente.

**Propuestas de Mejora:** Se identifican posibles extensiones como la integración de sensores de presencia, la adición de interfaces de comunicación (UART) o la implementación de técnicas de control de motor más avanzadas (micro-stepping).

***

## Maqueta y Montaje 

Se construyó una **maqueta física funcional, limpia y bien ensamblada** que representa el sistema real:

* **Ensamblaje Profesional:** La estructura es estable y estéticamente cuidada.
* **Cableado Organizado:** Se utilizaron técnicas de gestión de cables (canaletas, sujetacables, cables a medida) y etiquetado claro para facilitar la depuración y presentar un aspecto ordenado.
* **Funcionalidad Completa:** Todos los componentes hardware (motores, sensores, teclado, displays) están operativos y responden correctamente al control de la FPGA, demostrando la correcta implementación del diseño VHDL.
