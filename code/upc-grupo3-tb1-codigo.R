# ==============================================================================
# 1. CARGA DE DATOS Y LIBRERÍAS
# ==============================================================================
# install.packages(c("corrplot", "lubridate", "ggplot2"))
library(corrplot)
library(lubridate)
library(ggplot2)

setwd("C:/TB1/data/")
df <- read.csv("hotel_bookings.csv", header = TRUE, stringsAsFactors = FALSE)

# ==============================================================================
# 2. CALIDAD DE DATOS: FALTANTES Y DUPLICADOS
# ==============================================================================
total_filas <- nrow(df)
na_counts <- colSums(is.na(df))
na_counts <- na_counts[na_counts > 0]

faltantes_explicitos <- data.frame(
  Variable = names(na_counts),
  Valores_NA = as.numeric(na_counts),
  Porcentaje = round((as.numeric(na_counts) / total_filas) * 100, 4)
)

print("=== VALORES FALTANTES EXPLÍCITOS (NA) ===")
print(faltantes_explicitos)

und_counts <- colSums(df == "Undefined", na.rm = TRUE)
und_counts <- und_counts[und_counts > 0]

faltantes_implicitos <- data.frame(
  Variable = names(und_counts),
  Valores_Undefined = as.numeric(und_counts),
  Porcentaje = round((as.numeric(und_counts) / total_filas) * 100, 4)
)

print("=== VALORES FALTANTES IMPLÍCITOS ('Undefined') ===")
print(faltantes_implicitos)

total_registros <- nrow(df)
registros_duplicados <- sum(duplicated(df))
porcentaje_duplicados <- round((registros_duplicados / total_registros) * 100, 2)

cat("Total de registros:", total_registros, "\n")
cat("Registros duplicados exactos:", registros_duplicados, "\n")
cat("Porcentaje de duplicación:", porcentaje_duplicados, "%\n")

hotel_limpio <- unique(df)
cat("Registros únicos resultantes en hotel_limpio:", nrow(hotel_limpio), "\n")

# ==============================================================================
# 3. TRATAMIENTO DE OUTLIERS Y PREPARACIÓN DE VARIABLES
# ==============================================================================
Q1 <- quantile(hotel_limpio$adr, 0.25)
Q3 <- quantile(hotel_limpio$adr, 0.75)
IQR_val <- Q3 - Q1
limite_inf <- Q1 - 1.5 * IQR_val
limite_sup <- Q3 + 1.5 * IQR_val

outliers_adr <- hotel_limpio[hotel_limpio$adr < limite_inf | hotel_limpio$adr > limite_sup, ]
cat("Outliers en ADR:", nrow(outliers_adr), "\n")
cat("Límite inferior:", limite_inf, "| Límite superior:", limite_sup, "\n")

hotel_limpio <- hotel_limpio[hotel_limpio$adr >= 0 & hotel_limpio$adr <= 5000, ]
cat("Registros después de tratar outliers:", nrow(hotel_limpio), "\n")

meses_orden <- c("January","February","March","April","May","June",
                 "July","August","September","October","November","December")
hotel_limpio$arrival_date_month <- factor(hotel_limpio$arrival_date_month, levels = meses_orden)

# Creación robusta de fecha (independiente del idioma del SO)
hotel_limpio$mes_num <- match(as.character(hotel_limpio$arrival_date_month), meses_orden)
hotel_limpio$fecha_llegada <- as.Date(paste(hotel_limpio$arrival_date_year,
                                            hotel_limpio$mes_num,
                                            hotel_limpio$arrival_date_day_of_month, 
                                            sep = "-"))

hotel_limpio$lead_time_rango <- cut(hotel_limpio$lead_time, 
                                    breaks = c(0, 31, 91, 181, 366, Inf), 
                                    labels = c("0-30 días", "31-90 días", "91-180 días", "181-365 días", "> 365 días"), 
                                    right = FALSE)

# ==============================================================================
# 4. ANÁLISIS UNIVARIADO, BIVARIADO Y PREGUNTAS (RESULTADOS EN CONSOLA)
# ==============================================================================
print("=== RESUMEN VARIABLES NUMÉRICAS CLAVE ===")
summary(hotel_limpio[, c("lead_time", "adr", "stays_in_weekend_nights",
                         "stays_in_week_nights", "adults", "children",
                         "babies", "total_of_special_requests")])

print("=== DISTRIBUCIÓN DE VARIABLES CATEGÓRICAS ===")
table(hotel_limpio$hotel)
table(hotel_limpio$meal)
table(hotel_limpio$market_segment)
table(hotel_limpio$distribution_channel)
table(hotel_limpio$customer_type)
table(hotel_limpio$deposit_type)
table(hotel_limpio$is_canceled)

print("=== CANCELACIÓN Y ADR POR TIPO DE HOTEL ===")
tabla_cancel_hotel <- table(hotel_limpio$hotel, hotel_limpio$is_canceled)
print(prop.table(tabla_cancel_hotel, margin = 1))
print(tapply(hotel_limpio$adr, hotel_limpio$hotel, mean))

print("=== MATRIZ DE CORRELACIONES ===")
num_vars <- hotel_limpio[, c("lead_time", "adr", "stays_in_weekend_nights",
                             "stays_in_week_nights", "total_of_special_requests",
                             "adults", "is_canceled")]
cor_matrix <- cor(num_vars, use = "complete.obs")
print(round(cor_matrix, 2))

print("=== CANCELACIÓN POR SEGMENTO DE MERCADO ===")
tabla_seg <- table(hotel_limpio$market_segment, hotel_limpio$is_canceled)
print(prop.table(tabla_seg, margin = 1))

print("=== RESPUESTAS A LAS PREGUNTAS ANALÍTICAS (Tapply) ===")
cancelacion_mes <- tapply(hotel_limpio$is_canceled, hotel_limpio$arrival_date_month, mean)
print(sort(cancelacion_mes, decreasing = TRUE))
print(tapply(hotel_limpio$is_canceled, hotel_limpio$customer_type, mean))
print(tapply(hotel_limpio$adr, hotel_limpio$distribution_channel, mean))
print(tapply(hotel_limpio$is_canceled, hotel_limpio$is_repeated_guest, mean))
print(tapply(hotel_limpio$lead_time, hotel_limpio$hotel, mean))
print(prop.table(table(hotel_limpio$deposit_type, hotel_limpio$is_canceled), margin = 1))

# ==============================================================================
# 5. ZONA DE GRÁFICOS
# ==============================================================================
dev.off()

# GRÁFICOS UNIVARIADOS (4 en 1)
par(mar = c(3, 3, 2, 1))
par(mfrow = c(2, 2))
hist(hotel_limpio$adr, main = "Distribución ADR", xlab = "Precio por noche", col = "steelblue")
hist(hotel_limpio$lead_time, main = "Lead Time", xlab = "Días de anticipación", col = "salmon")
barplot(table(hotel_limpio$hotel), main = "Tipo de hotel", col = c("steelblue","salmon"))
barplot(table(hotel_limpio$is_canceled), main = "Cancelaciones", names.arg = c("No cancelado","Cancelado"), col = c("green","red"))

# OUTLIERS BOXPLOTS (4 en 1)
par(mfrow = c(2, 2))
boxplot(hotel_limpio$adr, main = "Outliers ADR", col = "steelblue")
boxplot(hotel_limpio$lead_time, main = "Outliers Lead Time", col = "salmon")
boxplot(hotel_limpio$stays_in_week_nights, main = "Noches entre semana", col = "lightgreen")
boxplot(hotel_limpio$adults, main = "Número de adultos", col = "orange")
par(mfrow = c(1, 1))

# GRÁFICOS BIVARIADOS DE HOTEL
par(mfrow = c(1, 2))
barplot(prop.table(tabla_cancel_hotel, margin = 1), beside = TRUE, legend = TRUE,
        col = c("steelblue", "salmon"), main = "Cancelación por tipo de hotel",
        xlab = "Cancelado", ylab = "Proporción")
boxplot(adr ~ is_canceled, data = hotel_limpio, main = "ADR según cancelación",
        names = c("No cancelado", "Cancelado"), col = c("lightgreen", "tomato"))
par(mfrow = c(1, 1))

# MAPA DE CORRELACIONES
num_vars <- hotel_limpio[, c("lead_time", "adr", "stays_in_weekend_nights",
                             "stays_in_week_nights", "total_of_special_requests",
                             "adults", "is_canceled")]
cor_matrix <- cor(num_vars, use = "complete.obs")
corrplot(cor_matrix, method = "color", type = "upper", tl.col = "black", title = "Mapa de correlaciones", mar = c(0,0,1,0))

# GRÁFICO PREGUNTA 1: CANCELACIÓN POR SEGMENTO
tabla_seg <- table(hotel_limpio$market_segment, hotel_limpio$is_canceled)
barplot(tabla_seg, beside = TRUE, col = c("steelblue", "salmon"), 
        main = "Reservas y Cancelaciones por Segmento de Mercado", 
        xlab = "Segmento de Mercado", ylab = "Cantidad de Reservas",
        legend.text = c("No Cancelado (0)", "Cancelado (1)"),
        args.legend = list(x = "topright", bty = "n"))

# GRÁFICO PREGUNTA 2: ADR VS LEAD TIME (RANGOS)
boxplot(adr ~ lead_time_rango, data = hotel_limpio,
        main = "ADR según Rango de Anticipación",
        xlab = "Días de anticipación (Lead Time)",
        ylab = "Tarifa Diaria Promedio (ADR)",
        col = c("#E6F2FF", "#B3D9FF", "#80BFFF", "#4D99FF", "#1A75FF"),
        outline = FALSE)

# GRÁFICOS TEMPORALES (Mes y EVOLUCIÓN)
reservas_mes <- table(hotel_limpio$arrival_date_month)
barplot(reservas_mes, main = "Reservas por mes de llegada", col = "steelblue", las = 2, ylab = "N° reservas")

adr_mes <- tapply(hotel_limpio$adr, hotel_limpio$arrival_date_month, mean)
plot(adr_mes, type = "b", col = "darkred", pch = 19, main = "ADR promedio por mes",
     xlab = "Mes", ylab = "ADR promedio", xaxt = "n")
axis(1, at = 1:12, labels = substr(meses_orden, 1, 3), las = 2)

# HISTOGRAMA TEMPORAL CON GGPLOT2
ggplot(hotel_limpio, aes(x = fecha_llegada)) +
  geom_histogram(binwidth = 30, fill = "steelblue", color = "white") +
  labs(title = "Evolución de reservas en el tiempo", x = "Fecha de llegada", y = "N° reservas") +
  theme_minimal()
# Guardar el dataset hotel_limpio en formato CSV
write.csv(hotel_limpio, "C:/TB1/hotel_limpio.csv", row.names = FALSE)