# Analise exploratoria dos dados do ensaio
# Autora: Jennifer Luz Lopes

library(tidyverse)

cores_cafe <- c(
  azul_escuro = "#224573",
  marrom      = "#6B4F4F",
  azul_claro  = "#4A6FA5",
  bege        = "#E5D3B3")

dados <- read_csv("data/processed/dados_limpos.csv", show_col_types = FALSE) |>
  mutate(
    tratamento = factor(tratamento,
                        levels = c("controle", "dose_baixa", "dose_media", "dose_alta")),
    tempo_dias = factor(tempo_dias, levels = c(30, 60, 90)))

dir.create("output/figuras", recursive = TRUE, showWarnings = FALSE)

# Distribuicao da severidade por tratamento
p1 <- ggplot(dados, aes(x = tratamento, y = severidade, fill = tratamento)) +
  geom_boxplot(alpha = 0.8, outlier.size = 1.5, outlier.alpha = 0.5) +
  scale_fill_manual(values = unname(cores_cafe)) +
  labs(
    title    = "Severidade da doenca por tratamento",
    subtitle = "Percentual de área foliar afetada, todas as avaliações.",
    x        = "Tratamento",
    y        = "Severidade (%)",
    fill     = "Tratamento", caption = "Jennifer Lopes.") +
  theme_classic(base_size = 13) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 20, hjust = 1))

ggsave("output/figuras/eda_severidade_tratamento.png",
       plot = p1, width = 8, height = 5, dpi = 150)

# Severidade ao longo do tempo por tratamento
resumo_tempo <- dados |>
  group_by(tratamento, tempo_dias) |>
  summarise(
    media = mean(severidade),
    ep    = sd(severidade) / sqrt(n()),
    .groups = "drop")

p2 <- ggplot(resumo_tempo,
             aes(x = tempo_dias, y = media,
                 color = tratamento, group = tratamento)) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = media - ep, ymax = media + ep),
                width = 0.15, linewidth = 0.6) +
  scale_color_manual(values = unname(cores_cafe)) +
  labs(
    title    = "Evolução da severidade ao longo do tempo",
    subtitle = "Média e erro padrão por tratamento.",
    x        = "Dias após aplicação",
    y        = "Severidade média (%)",
    color    = "Tratamento", caption = "Jennifer Lopes.") +
  theme_classic(base_size = 13) +
  theme(panel.grid.minor = element_blank())

ggsave("output/figuras/eda_evolucao_temporal.png",
       plot = p2, width = 8, height = 5, dpi = 150)

# Produtividade por tratamento
p3 <- ggplot(dados, aes(x = tratamento, y = produtividade, fill = tratamento)) +
  geom_violin(alpha = 0.7, trim = FALSE) +
  geom_boxplot(width = 0.15, fill = "white", outlier.size = 1) +
  scale_fill_manual(values = unname(cores_cafe)) +
  labs(
    title    = "Produtividade por tratamento",
    subtitle = "kg/ha, todas as avaliações e localidades.",
    x        = "Tratamento",
    y        = "Produtividade (kg/ha)",
    fill     = "Tratamento", caption = "Jennifer Lopes.") +
  theme_classic(base_size = 13) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 20, hjust = 1))

ggsave("output/figuras/eda_produtividade_tratamento.png",
       plot = p3, width = 8, height = 5, dpi = 150)

# Relacao entre covariáveis ambientais e severidade
p4 <- ggplot(dados, aes(x = umidade_rel, y = severidade, color = tratamento)) +
  geom_point(alpha = 0.4, size = 1.8) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.8) +
  scale_color_manual(values = unname(cores_cafe)) +
  facet_wrap(~tempo_dias, labeller = label_both) +
  labs(
    title  = "Relação entre umidade relativa e severidade",
    x      = "Umidade relativa (%)",
    y      = "Severidade (%)",
    color  = "Tratamento", caption = "Jennifer Lopes.") +
  theme_classic(base_size = 12) +
  theme(panel.grid.minor = element_blank())

ggsave("output/figuras/eda_umidade_severidade.png",
       plot = p4, width = 10, height = 5, dpi = 150)
