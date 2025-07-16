# Makefile para automação de tarefas
# Makefile

.PHONY: help setup install start stop restart logs clean test lint format docs deploy health

# Configurações
DOCKER_COMPOSE = docker-compose
PYTHON = python3
PIP = pip3
DBT = dbt
GREAT_EXPECTATIONS = great_expectations

# Cores para output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[0;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

# Help
help: ## Mostra esta mensagem de ajuda
	@echo "$(GREEN)Dashboard de KPIs - Comandos Disponíveis$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

# Setup e Instalação
setup: ## Configura o ambiente inicial
	@echo "$(YELLOW)Configurando ambiente...$(NC)"
	@chmod +x scripts/setup.sh
	@./scripts/setup.sh

install: ## Instala dependências
	@echo "$(YELLOW)Instalando dependências...$(NC)"
	@$(PIP) install -r requirements.txt
	@$(PIP) install dbt-snowflake great-expectations

# Docker
start: ## Inicia todos os serviços
	@echo "$(YELLOW)Iniciando serviços...$(NC)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Serviços iniciados com sucesso!$(NC)"
	@make health

stop: ## Para todos os serviços
	@echo "$(YELLOW)Parando serviços...$(NC)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Serviços parados com sucesso!$(NC)"

restart: ## Reinicia todos os serviços
	@echo "$(YELLOW)Reiniciando serviços...$(NC)"
	@$(DOCKER_COMPOSE) restart
	@echo "$(GREEN)Serviços reiniciados com sucesso!$(NC)"

logs: ## Mostra logs dos serviços
	@$(DOCKER_COMPOSE) logs -f

# Desenvolvimento
test: ## Executa testes
	@echo "$(YELLOW)Executando testes...$(NC)"
	@$(DBT) test --profiles-dir config/dbt/
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ suite run
	@echo "$(GREEN)Testes executados com sucesso!$(NC)"

lint: ## Executa linting
	@echo "$(YELLOW)Executando linting...$(NC)"
	@$(PYTHON) -m flake8 dags/ tests/
	@$(PYTHON) -m pylint dags/ tests/
	@$(DBT) debug --profiles-dir config/dbt/
	@echo "$(GREEN)Linting executado com sucesso!$(NC)"

format: ## Formata código
	@echo "$(YELLOW)Formatando código...$(NC)"
	@$(PYTHON) -m black dags/ tests/
	@$(PYTHON) -m isort dags/ tests/
	@echo "$(GREEN)Código formatado com sucesso!$(NC)"

# DBT
dbt-deps: ## Instala dependências do dbt
	@echo "$(YELLOW)Instalando dependências do dbt...$(NC)"
	@$(DBT) deps --profiles-dir config/dbt/

dbt-compile: ## Compila modelos dbt
	@echo "$(YELLOW)Compilando modelos dbt...$(NC)"
	@$(DBT) compile --profiles-dir config/dbt/

dbt-run: ## Executa modelos dbt
	@echo "$(YELLOW)Executando modelos dbt...$(NC)"
	@$(DBT) run --profiles-dir config/dbt/

dbt-test: ## Executa testes dbt
	@echo "$(YELLOW)Executando testes dbt...$(NC)"
	@$(DBT) test --profiles-dir config/dbt/

dbt-docs: ## Gera documentação dbt
	@echo "$(YELLOW)Gerando documentação dbt...$(NC)"
	@$(DBT) docs generate --profiles-dir config/dbt/
	@$(DBT) docs serve --profiles-dir config/dbt/

# Great Expectations
ge-init: ## Inicializa Great Expectations
	@echo "$(YELLOW)Inicializando Great Expectations...$(NC)"
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ init

ge-suite: ## Cria suíte de expectativas
	@echo "$(YELLOW)Criando suíte de expectativas...$(NC)"
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ suite new

ge-checkpoint: ## Cria checkpoint
	@echo "$(YELLOW)Criando checkpoint...$(NC)"
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ checkpoint new

ge-run: ## Executa validações
	@echo "$(YELLOW)Executando validações...$(NC)"
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ checkpoint run

ge-docs: ## Gera documentação
	@echo "$(YELLOW)Gerando documentação...$(NC)"
	@$(GREAT_EXPECTATIONS) --config config/great-expectations/ docs build

# Airflow
airflow-init: ## Inicializa Airflow
	@echo "$(YELLOW)Inicializando Airflow...$(NC)"
	@$(DOCKER_COMPOSE) exec airflow-webserver airflow db init
	@$(DOCKER_COMPOSE) exec airflow-webserver airflow users create \
		--username admin \
		--firstname Admin \
		--lastname User \
		--role Admin \
		--email admin@company.com \
		--password admin

airflow-dag-list: ## Lista DAGs
	@$(DOCKER_COMPOSE) exec airflow-webserver airflow dags list

airflow-dag-trigger: ## Triggera DAG
	@$(DOCKER_COMPOSE) exec airflow-webserver airflow dags trigger $(DAG_ID)

# Limpeza
clean: ## Limpa arquivos temporários
	@echo "$(YELLOW)Limpando arquivos temporários...$(NC)"
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@rm -rf .pytest_cache/
	@rm -rf target/
	@rm -rf dbt_packages/
	@echo "$(GREEN)Limpeza concluída!$(NC)"

clean-docker: ## Limpa containers e volumes Docker
	@echo "$(YELLOW)Limpando containers Docker...$(NC)"
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	@docker system prune -f
	@echo "$(GREEN)Limpeza Docker concluída!$(NC)"

# Documentação
docs: ## Gera documentação completa
	@echo "$(YELLOW)Gerando documentação...$(NC)"
	@make dbt-docs
	@make ge-docs
	@echo "$(GREEN)Documentação gerada com sucesso!$(NC)"

# Deploy
deploy-dev: ## Deploy para desenvolvimento
	@echo "$(YELLOW)Fazendo deploy para desenvolvimento...$(NC)"
	@$(DBT) run --profiles-dir config/dbt/ --target dev
	@echo "$(GREEN)Deploy para desenvolvimento concluído!$(NC)"

deploy-staging: ## Deploy para staging
	@echo "$(YELLOW)Fazendo deploy para staging...$(NC)"
	@$(DBT) run --profiles-dir config/dbt/ --target staging
	@make test
	@echo "$(GREEN)Deploy para staging concluído!$(NC)"

deploy-prod: ## Deploy para produção
	@echo "$(YELLOW)Fazendo deploy para produção...$(NC)"
	@$(DBT) run --profiles-dir config/dbt/ --target prod
	@make test
	@echo "$(GREEN)Deploy para produção concluído!$(NC)"

# Saúde do sistema
health: ## Verifica saúde dos serviços
	@echo "$(YELLOW)Verificando saúde dos serviços...$(NC)"
	@echo "$(BLUE)Airbyte:$(NC) http://localhost:8000"
	@echo "$(BLUE)Airflow:$(NC) http://localhost:8080"
	@echo "$(BLUE)Flower:$(NC) http://localhost:5555"
	@echo "$(BLUE)Grafana:$(NC) http://localhost:3000"
	@echo "$(BLUE)Prometheus:$(NC) http://localhost:9090"
	@echo "$(BLUE)Jupyter:$(NC) http://localhost:8888"
	@echo "$(BLUE)Dashboard:$(NC) Abra dashboard/index.html"

# Backup
backup: ## Cria backup dos dados
	@echo "$(YELLOW)Criando backup...$(NC)"
	@mkdir -p backups/$(shell date +%Y%m%d_%H%M%S)
	@$(DOCKER_COMPOSE) exec postgres pg_dump -U airflow airflow > backups/$(shell date +%Y%m%d_%H%M%S)/airflow_backup.sql
	@echo "$(GREEN)Backup criado com sucesso!$(NC)"

# Monitoramento
monitor: ## Abre ferramentas de monitoramento
	@echo "$(YELLOW)Abrindo ferramentas de monitoramento...$(NC)"
	@echo "$(BLUE)Abrindo Grafana...$(NC)"
	@open http://localhost:3000 || xdg-open http://localhost:3000 || start http://localhost:3000
	@echo "$(BLUE)Abrindo Prometheus...$(NC)"
	@open http://localhost:9090 || xdg-open http://localhost:9090 || start http://localhost:9090

# Shortcuts
dev: setup install start ## Configura ambiente completo de desenvolvimento
ci: lint test ## Executa pipeline de CI
cd: deploy-prod ## Executa pipeline de CD
