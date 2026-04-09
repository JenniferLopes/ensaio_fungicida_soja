# Limpeza e preparacao dos dados para analise
# Autora: Jennifer Luz Lopes

library(tidyverse)

dados_brutos <- read_csv("data/raw/ensaio_fungicida.csv", show_col_types = FALSE)

# Conversao de variaveis categoricas para fator com ordem definida
dados <- dados_brutos |>
  mutate(
    tratamento = factor(tratamento,
                        levels = c("controle", "dose_baixa", "dose_media", "dose_alta")),
    bloco      = factor(bloco),
    local      = factor(local),
    tempo_dias = factor(tempo_dias, levels = c(30, 60, 90)),
    repeticao  = factor(repeticao))

# Verificacao de valores ausentes
n_missing <- sum(is.na(dados))

# Verificacao de valores fora do intervalo esperado
fora_severidade <- dados |>
  filter(severidade < 0 | severidade > 100)

fora_prod <- dados |>
  filter(produtividade < 0)

# Calculo da proporcao de severidade para uso nos modelos beta
dados <- dados |>
  mutate(
    sev_prop = severidade / 100,
    sev_prop = pmax(0.001, pmin(0.999, sev_prop)))

# Resumo descritivo por tratamento e tempo
resumo <- dados |>
  group_by(tratamento, tempo_dias) |>
  summarise(
    n             = n(),
    sev_media     = round(mean(severidade), 2),
    sev_dp        = round(sd(severidade), 2),
    prod_media    = round(mean(produtividade), 1),
    prod_dp       = round(sd(produtividade), 1),
    .groups       = "drop")

print(resumo)

# Exportacao
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write_csv(dados,   "data/processed/dados_limpos.csv")
write_csv(resumo,  "data/processed/resumo_descritivo.csv")
