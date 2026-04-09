FROM rocker/tidyverse:4.4.1

LABEL maintainer="Jennifer Luz Lopes"
LABEL description="Ensaio de eficacia de fungicida em soja - pipeline reprodutivel"

RUN apt-get update && apt-get install -y \
    libgsl-dev \
    libglpk-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libwebp-dev \
    libnode-dev \
    cmake \
    pandoc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN Rscript -e " \
  options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')); \
  install.packages(c( \
    'glmmTMB', \
    'DHARMa', \
    'emmeans', \
    'multcomp', \
    'broom.mixed', \
    'gt', \
    'DT', \
    'renv' \
  ), Ncpus = 4)"

WORKDIR /project

COPY . /project

RUN mkdir -p output/figuras output/tabelas output/modelos

RUN Rscript R/01_simular_dados.R && \
    Rscript R/02_limpar_dados.R  && \
    Rscript R/03_eda.R           && \
    Rscript R/04_analise_glmm.R

RUN quarto render report/relatorio.qmd --output-dir output/

CMD ["bash"]