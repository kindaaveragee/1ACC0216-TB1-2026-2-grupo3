# Proyecto TB1: Análisis de Demanda de Reservas de Hotel (Grupo 3)

## Objetivo del trabajo

Realizar la preparación, limpieza y análisis exploratorio de datos (EDA) del conjunto `hotel_bookings.csv` mediante R, con el fin de evaluar la calidad de la información y extraer *insights* que respondan a dos preguntas clave de negocio:

1. Identificar qué segmentos de mercado y tipos de cliente concentran la mayor cantidad de reservas y cancelaciones.
2. Analizar la relación entre la anticipación de la reserva (*lead time*) y la tarifa diaria promedio (*ADR*).

## Nombre de los alumnos participantes

* Nicole Abigail Sánchez Martínez (u202419766)
* Iyari Maryuri Karin Alejandro Zelada (u202321351)
* Cielo Anahí Mitma Ayala (u20242007)

## Breve descripción del dataset

El conjunto de datos contiene 119,390 registros y 32 variables extraídas del sistema PMS (Property Management System) de dos hoteles en Portugal (un hotel de ciudad y un hotel turístico). Incluye información estructurada sobre el comportamiento de las reservas, tiempos de anticipación, precios diarios (ADR), canales de distribución, tipos de huéspedes y el estado final de la reserva (cancelada o ejecutada).

*(Nota: Para mayor detalle sobre las variables y tipos de datos, revisar el documento PDF adjunto en este repositorio).*

## Conclusiones

1. **Riesgo en el canal principal:** El segmento de mercado *Online TA* (agencias online) y los clientes tipo *Transient* son el motor comercial del hotel, pero concentran las tasas de cancelación más altas (35.35% y 30.10% respectivamente).
2. **Estabilidad en clientes corporativos:** Los perfiles de negocio (*Corporate*) y grupos organizados (*Group* o *Contract*) son segmentos sumamente seguros, con tasas de cancelación muy bajas (entre el 9% y el 16%).
3. **Curva de precios no lineal:** No existe una relación lineal directa entre la anticipación de la compra y el precio pagado (correlación débil de r = 0.025).
4. **Ventana de máxima rentabilidad:** Las reservas no son más caras a "último minuto". El hotel obtiene las tarifas diarias promedio (ADR) más altas en la ventana de reserva de 90 a 180 días de anticipación (ADR de 114.03), mientras que las reservas de más de un año consiguen los precios más baratos (ADR de 80.69).

## Licencia

Este proyecto es de carácter académico, desarrollado para la Universidad Peruana de Ciencias Aplicadas (UPC). Los datos originales operan bajo licencia abierta (Creative Commons). El código y análisis de este repositorio se distribuyen bajo la **Licencia MIT**.
