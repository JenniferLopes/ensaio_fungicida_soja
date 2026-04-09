# Simulacao de dados: ensaio de eficacia de fungicida em soja
# Delineamento: blocos casualizados completos (RCBD) com medicoes repetidas
# Autora: Jennifer Luz Lopes

# Instalação de pacotes
install.packages(c(
  "tidyverse",
  "glmmTMB",
  "DHARMa",
  "emmeans",
  "multcomp",
  "broom.mixed",
  "gt",
  "DT"))

library(tidyverse)
library(glmmTMB)
library(DHARMa)
library(emmeans)
library(multcomp)
library(broom.mixed)
library(gt)
library(DT)
library(quarto)

set.seed(2024)

# Parametros do experimento
tratamentos  <- c("controle", "dose_baixa", "dose_media", "dose_alta")
blocos       <- paste0("bloco_", 1:6)
localidades  <- paste0("local_", 1:3)
tempos       <- c(30, 60, 90)
repeticoes   <- 1:3

# Efeitos verdadeiros dos tratamentos sobre a severidade (escala logit)
efeito_tratamento <- c(
  controle   =  0.00,
  dose_baixa = -0.60,
  dose_media = -1.20,
  dose_alta  = -2.00)

# Efeito verdadeiro sobre a produtividade (kg/ha adicional ao intercepto)
efeito_prod <- c(
  controle   =    0,
  dose_baixa =  150,
  dose_media =  320,
  dose_alta  =  450)

# Funcao para simular uma unidade experimental
simular_ue <- function(tratamento, bloco, local, tempo, rep) {

  ef_bloco  <- rnorm(1, mean = 0, sd = 0.20)
  ef_local  <- rnorm(1, mean = 0, sd = 0.35)
  umidade   <- runif(1, min = 55, max = 90)
  temp_med  <- runif(1, min = 18, max = 32)

  ef_tempo  <- -0.015 * tempo

  logit_sev <- 0.80 +
    efeito_tratamento[tratamento] +
    ef_bloco +
    ef_local +
    ef_tempo +
    0.008 * (umidade - 70) +
    rnorm(1, mean = 0, sd = 0.15)

  prob_sev  <- plogis(logit_sev)
  severidade <- rbeta(1,
                      shape1 = prob_sev * 8,
                      shape2 = (1 - prob_sev) * 8) * 100

  produtividade <- 3200 +
    efeito_prod[tratamento] +
    ef_bloco * 80 +
    ef_local * 120 +
    0.5 * tempo +
    rnorm(1, mean = 0, sd = 90)

  tibble(
    tratamento    = tratamento,
    bloco         = bloco,
    local         = local,
    tempo_dias    = tempo,
    repeticao     = rep,
    umidade_rel   = round(umidade, 1),
    temp_media    = round(temp_med, 1),
    severidade    = round(pmax(0, pmin(100, severidade)), 2),
    produtividade = round(pmax(1500, produtividade), 1))
}

# Geracao do conjunto de dados completo
dados_brutos <- expand_grid(
  tratamento = tratamentos,
  bloco      = blocos,
  local      = localidades,
  tempo_dias = tempos,
  repeticao  = repeticoes) |>
  pmap_dfr(function(tratamento, bloco, local, tempo_dias, repeticao) {
    simular_ue(tratamento, bloco, local, tempo_dias, repeticao)
  })

# Exportacao
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

write_csv(dados_brutos, "data/raw/ensaio_fungicida.csv")

