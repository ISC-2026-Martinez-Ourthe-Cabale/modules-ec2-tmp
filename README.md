# 🖥️ modules-ec2-tmp

**Repositorio:** `ISC-2026-Martinez-Ourthe-Cabale/modules-ec2-tmp`
**Lenguaje:** HCL (Terraform)

## Descripción

Este módulo aprovisiona instancias Amazon EC2 temporales destinadas a tareas de desarrollo, validación y pruebas de la infraestructura.

Su principal objetivo es permitir la verificación de:

* Conectividad entre componentes de la infraestructura.
* Configuración de redes y Security Groups.
* Acceso a la base de datos RDS.
* Despliegue y funcionamiento de la aplicación antes de habilitar el Auto Scaling Group definitivo.

## Caso de Uso

Este módulo está pensado para ser utilizado únicamente durante las etapas iniciales de desarrollo y pruebas.

Una vez validada la infraestructura, las instancias de aplicación en ambientes productivos son gestionadas por el módulo `module-asg`, encargado del aprovisionamiento automático y escalado de las instancias EC2.

## Recomendaciones

> **Importante:** Se recomienda destruir los recursos creados por este módulo una vez finalizada la fase de pruebas, con el fin de evitar costos innecesarios en AWS.

## Flujo Recomendado

1. Desplegar la infraestructura base.
2. Crear instancias temporales mediante `modules-ec2-tmp`.
3. Validar conectividad y funcionamiento de la aplicación.
4. Destruir las instancias temporales.
5. Habilitar el despliegue definitivo mediante `module-asg`.
