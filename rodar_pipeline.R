# Execucao local do pipeline completo
# Autora: Jennifer Luz Lopes
# Use este script para rodar toda a analise sem Docker.
# Certifique-se de que o ambiente foi restaurado com renv::restore() antes de executar.

source("R/01_simular_dados.R")
source("R/02_limpar_dados.R")
source("R/03_eda.R")
source("R/04_analise_glmm.R")

quarto::quarto_render(
  input      = "report/relatorio.qmd",
  output_dir = "output")

