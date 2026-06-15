# 📚 Sistema de Gestión y Automatización de Biblioteca (PostgreSQL)

Arquitectura de base de datos relacional y automatización transaccional para la Universidad Puls-ar. Este proyecto implementa un flujo completo de DDL, DML y automatización mediante Procedimientos Almacenados y Triggers para la gestión de préstamos, devoluciones y auditoría.

## 🏗️ Arquitectura y Linaje de Datos

El sistema está diseñado en PostgreSQL y estructurado para escalabilidad hacia modelos de transformación analítica.

*   **Fuentes Base:** `lectores`, `libros`.
*   **Capa Transaccional:** `prestamos` (Tabla relacional).
*   **Capa de Auditoría:** `log_devoluciones` (Historial automatizado).
*   **Capa de Negocio (Marts):** Vista `libros_prestados`.

## ⚙️ Configuración y Despliegue

1. Clonar el repositorio.
2. Configurar las variables de entorno para la conexión a la base de datos local (evitar credenciales en texto plano).
3. Ejecutar el script `biblioteca.sql` en la herramienta de consulta (Query Tool) de pgAdmin para inicializar las tablas, funciones y disparadores.

## 🔄 Automatización Destacada

*   **Stored Procedures:** Ejecución atómica de devoluciones (`devolver_libro`).
*   **Triggers:** Registro inmutable de transacciones de eliminación (`trigger_log_devolucion`).
