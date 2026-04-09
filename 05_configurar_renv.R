# Gerenciamento do ambiente R com renv
# Autora: Jennifer Luz Lopes

# O pacote renv registra as versoes exatas de todos os pacotes utilizados
# no projeto. Isso garante que qualquer pessoa que abrir este projeto no
# futuro consiga reproduzir exatamente os mesmos resultados, mesmo que
# os pacotes tenham sido atualizados desde entao.

# Execute este script UMA VEZ ao configurar o projeto pela primeira vez.
# Nas proximas vezes, use apenas renv::restore() para restaurar o ambiente.


# Instalar o renv caso ainda nao esteja instalado
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}


# Inicializar o renv no projeto
# Isso cria a pasta renv/ e o arquivo renv.lock na raiz do projeto.
# O arquivo .Rprofile tambem e criado automaticamente para ativar
# o ambiente isolado toda vez que o projeto for aberto no RStudio.
renv::init()


# Verificar o status do ambiente
# Mostra quais pacotes estao instalados, quais estao faltando e
# quais foram instalados mas ainda nao foram registrados no renv.lock.
renv::status()


# Registrar o ambiente atual no renv.lock
# Execute este comando sempre que instalar ou atualizar um pacote.
# O renv.lock e o arquivo que outras pessoas usarao para restaurar
# o ambiente identico ao seu.
renv::snapshot()


# Atualizar um pacote especifico (quando necessario)
# Apos atualizar, rode renv::snapshot() para registrar a nova versao.
# renv::update("glmmTMB")


# Restaurar o ambiente a partir do renv.lock
# Use este comando em uma maquina nova ou apos clonar o repositorio
# do GitHub. Ele reinstala todos os pacotes nas versoes exatas
# registradas no renv.lock.
# renv::restore()


# Remover pacotes que nao sao mais usados no projeto
# renv::clean()


# Verificar quais arquivos devem ser incluidos no GitHub
# O renv cria automaticamente um .gitignore dentro da pasta renv/
# que exclui a biblioteca local (renv/library/) do versionamento.
# Apenas os arquivos abaixo precisam ser versionados:
#
#   renv.lock        versoes exatas de todos os pacotes
#   renv/activate.R  script que ativa o ambiente ao abrir o projeto
#   .Rprofile        ativa o renv automaticamente no RStudio
#
# A pasta renv/library/ NAO deve ser versionada pois e grande e
# sera recriada automaticamente pelo renv::restore().