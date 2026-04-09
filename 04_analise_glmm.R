# Modelagem: GLMM para severidade e LMM para produtividade
# Autora: Jennifer Luz Lopes

library(tidyverse)
library(glmmTMB)
library(DHARMa)
library(emmeans)
library(multcomp)
library(broom.mixed)

cores_cafe <- c(
  azul_escuro = "#224573",
  marrom      = "#6B4F4F",
  azul_claro  = "#4A6FA5",
  bege        = "#E5D3B3")

dados <- read_csv("data/processed/dados_limpos.csv", show_col_types = FALSE) |>
  mutate(
    tratamento = factor(tratamento,
                        levels = c("controle", "dose_baixa", "dose_media", "dose_alta")),
    bloco      = factor(bloco),
    local      = factor(local),
    tempo_dias = factor(tempo_dias, levels = c(30, 60, 90)),
    repeticao  = factor(repeticao),
    sev_prop   = pmax(0.001, pmin(0.999, severidade / 100)))

dir.create("output/figuras",  recursive = TRUE, showWarnings = FALSE)
dir.create("output/tabelas",  recursive = TRUE, showWarnings = FALSE)
dir.create("output/modelos",  recursive = TRUE, showWarnings = FALSE)

# Modelo GLMM para severidade (distribuicao beta)
# Efeitos fixos:  tratamento, tempo, umidade, temperatura
# Efeitos aleatorios: bloco e local

mod_sev <- glmmTMB(
  sev_prop ~ tratamento * tempo_dias + umidade_rel + temp_media +
    (1 | bloco) + (1 | local),
  data   = dados,
  family = beta_family(link = "logit"))

summary(mod_sev)

# Diagnostico de residuos (DHARMa)
sim_sev <- simulateResiduals(mod_sev, n = 500)

png("output/figuras/diagnostico_severidade.png",
    width = 900, height = 500, res = 120)
plot(sim_sev, main = "Diagnostico de residuos - severidade")
dev.off()

# Modelo LMM para produtividade (gaussiano)
mod_prod <- glmmTMB(
  produtividade ~ tratamento + tempo_dias + umidade_rel + temp_media +
    (1 | bloco) + (1 | local),
  data   = dados,
  family = gaussian())

summary(mod_prod)

sim_prod <- simulateResiduals(mod_prod, n = 500)

png("output/figuras/diagnostico_produtividade.png",
    width = 900, height = 500, res = 120)
plot(sim_prod, main = "Diagnostico de residuos - produtividade")
dev.off()

# Comparacao de modelos: com e sem interacao tratamento x tempo
mod_sev_sem_int <- glmmTMB(
  sev_prop ~ tratamento + tempo_dias + umidade_rel + temp_media +
    (1 | bloco) + (1 | local),
  data   = dados,
  family = beta_family(link = "logit"))

comp_modelos <- AIC(mod_sev_sem_int, mod_sev) |>
  as.data.frame() |>
  rownames_to_column("modelo") |>
  mutate(delta_AIC = AIC - min(AIC))

write_csv(comp_modelos, "output/tabelas/comparacao_modelos.csv")
print(comp_modelos)

# Medias marginais por tratamento (severidade, escala original)
emm_sev <- emmeans(mod_sev,
                   specs  = ~ tratamento | tempo_dias,
                   type   = "response")

emm_sev_df <- as.data.frame(emm_sev) |>
  (\(df) {
    nms      <- names(df)
    mean_col <- grep("response|emmean", nms, value = TRUE)[1]
    lcl_col  <- grep("LCL|lower", nms, value = TRUE, ignore.case = TRUE)[1]
    ucl_col  <- grep("UCL|upper", nms, value = TRUE, ignore.case = TRUE)[1]
    df |> rename(media  = all_of(mean_col),
                 ic_inf = all_of(lcl_col),
                 ic_sup = all_of(ucl_col))
  })()
write_csv(emm_sev_df, "output/tabelas/medias_marginais_severidade.csv")

# Comparacoes multiplas entre tratamentos
cont_sev <- contrast(emm_sev, method = "pairwise", adjust = "tukey")
cont_sev_df <- as.data.frame(cont_sev)
write_csv(cont_sev_df, "output/tabelas/contrastes_severidade.csv")

# Medias marginais para produtividade
emm_prod <- emmeans(mod_prod,
                    specs = ~ tratamento,
                    type  = "response")

emm_prod_df <- as.data.frame(emm_prod) |>
  (\(df) {
    nms  <- names(df)
    mean_col <- grep("emmean|response", nms, value = TRUE)[1]
    lcl_col  <- grep("LCL|lower", nms, value = TRUE, ignore.case = TRUE)[1]
    ucl_col  <- grep("UCL|upper", nms, value = TRUE, ignore.case = TRUE)[1]
    df |> rename(media = all_of(mean_col),
                 ic_inf = all_of(lcl_col),
                 ic_sup = all_of(ucl_col))
  })()

write_csv(emm_prod_df, "output/tabelas/medias_marginais_produtividade.csv")

# Grafico de medias marginais - severidade
p_emm_sev <- ggplot(emm_sev_df,
                    aes(x = tratamento, y = media * 100,
                        color = tratamento, shape = tempo_dias)) +
  geom_point(size = 3.5, position = position_dodge(width = 0.4)) +
  geom_errorbar(
    aes(ymin = ic_inf * 100, ymax = ic_sup * 100),
    width    = 0.2,
    linewidth = 0.7,
    position = position_dodge(width = 0.4)) +
  scale_color_manual(values = unname(cores_cafe)) +
  labs(
    title    = "Medias marginais estimadas - severidade",
    subtitle = "Intervalos de confianca de 95% (escala original)",
    x        = "Tratamento",
    y        = "Severidade estimada (%)",
    color    = "Tratamento",
    shape    = "Dias apos aplicacao") +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 20, hjust = 1))

ggsave("output/figuras/medias_marginais_severidade.png",
       plot = p_emm_sev, width = 9, height = 5, dpi = 150)

# Grafico de medias marginais - produtividade
p_emm_prod <- ggplot(emm_prod_df,
                     aes(x = tratamento, y = media,
                         fill = tratamento)) +
  geom_col(alpha = 0.85, width = 0.6) +
  geom_errorbar(
    aes(ymin = ic_inf, ymax = ic_sup),
    width    = 0.2,
    linewidth = 0.7) +
  scale_fill_manual(values = unname(cores_cafe)) +
  labs(
    title    = "Produtividade media estimada por tratamento",
    subtitle = "Medias marginais do modelo LMM com IC de 95%",
    x        = "Tratamento",
    y        = "Produtividade estimada (kg/ha)",
    fill     = "Tratamento") +
  theme_minimal(base_size = 13) +
  theme(
    legend.position  = "none",
    panel.grid.minor = element_blank(),
    axis.text.x      = element_text(angle = 20, hjust = 1))

ggsave("output/figuras/medias_marginais_produtividade.png",
       plot = p_emm_prod, width = 8, height = 5, dpi = 150)

# Componentes de variancia dos efeitos aleatorios
var_sev <- tibble(
  grupo     = names(VarCorr(mod_sev)$cond),
  variancia = sapply(VarCorr(mod_sev)$cond, function(x) as.numeric(x)),
  dp        = sapply(VarCorr(mod_sev)$cond, function(x) attr(x, "stddev"))) |>
  mutate(across(where(is.numeric), ~ round(., 6)))

write_csv(var_sev, "output/tabelas/variancia_efeitos_aleatorios.csv")
print(var_sev)

# Salvar objetos dos modelos para uso no relatorio
saveRDS(mod_sev,      "output/modelos/mod_severidade.rds")
saveRDS(mod_prod,     "output/modelos/mod_produtividade.rds")
saveRDS(emm_sev_df,   "output/modelos/emm_severidade.rds")
saveRDS(emm_prod_df,  "output/modelos/emm_produtividade.rds")
saveRDS(cont_sev_df,  "output/modelos/contrastes_severidade.rds")
saveRDS(var_sev,      "output/modelos/variancia_aleatorios.rds")
