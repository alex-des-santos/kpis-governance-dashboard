# Script de setup inicial
#!/bin/bash

# setup.sh - Script para configurar o ambiente inicial

set -e

echo "🚀 Iniciando configuração do ambiente..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logs
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    error "Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    error "Python 3 não está instalado. Por favor, instale o Python 3 primeiro."
    exit 1
fi

# Criar diretórios necessários
log "Criando diretórios necessários..."
mkdir -p logs
mkdir -p dags
mkdir -p plugins
mkdir -p data
mkdir -p notebooks
mkdir -p backups
mkdir -p config/prometheus
mkdir -p config/grafana
mkdir -p tests

success "Diretórios criados com sucesso!"

# Criar arquivo .env se não existir
if [ ! -f .env ]; then
    log "Criando arquivo .env..."
    cat > .env << EOF
# Configurações do Airflow
FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
AIRFLOW_UID=$(id -u)
AIRFLOW_GID=0

# Configurações do Snowflake
SNOWFLAKE_ACCOUNT=your_account.snowflakecomputing.com
SNOWFLAKE_USER=your_user
SNOWFLAKE_PASSWORD=your_password
SNOWFLAKE_DATABASE=ANALYTICS
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_ROLE=ANALYST_ROLE

# Configurações de notificações
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
SMTP_ADDRESS=smtp.company.com
SENDER_LOGIN=data-team@company.com
SENDER_PASSWORD=your_password

# Configurações de armazenamento
DATA_DOCS_BUCKET=your-data-docs-bucket
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_DEFAULT_REGION=us-east-1

# Configurações de desenvolvimento
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
EOF
    success "Arquivo .env criado com sucesso!"
else
    warn "Arquivo .env já existe, pulando criação..."
fi

# Criar configuração do Prometheus
log "Criando configuração do Prometheus..."
cat > config/prometheus/prometheus.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'airflow'
    static_configs:
      - targets: ['airflow-webserver:8080']
  
  - job_name: 'airbyte'
    static_configs:
      - targets: ['airbyte-server:8001']

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093
EOF

success "Configuração do Prometheus criada!"

# Criar ambiente virtual Python
if [ ! -d "venv" ]; then
    log "Criando ambiente virtual Python..."
    python3 -m venv venv
    success "Ambiente virtual criado!"
else
    warn "Ambiente virtual já existe, pulando criação..."
fi

# Ativar ambiente virtual e instalar dependências
log "Ativando ambiente virtual e instalando dependências..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
success "Dependências instaladas com sucesso!"

# Configurar pre-commit hooks
log "Configurando pre-commit hooks..."
pre-commit install
success "Pre-commit hooks configurados!"

# Criar DAG de exemplo
if [ ! -f "dags/example_dag.py" ]; then
    log "Criando DAG de exemplo..."
    cat > dags/example_dag.py << 'EOF'
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

default_args = {
    'owner': 'data-team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'example_kpis_pipeline',
    default_args=default_args,
    description='Pipeline de exemplo para KPIs',
    schedule_interval=timedelta(hours=1),
    catchup=False,
    tags=['example', 'kpis'],
)

def hello_world():
    print("Hello from KPIs Dashboard!")
    return "success"

hello_task = PythonOperator(
    task_id='hello_world',
    python_callable=hello_world,
    dag=dag,
)

echo_task = BashOperator(
    task_id='echo_task',
    bash_command='echo "Pipeline executado com sucesso!"',
    dag=dag,
)

hello_task >> echo_task
EOF
    success "DAG de exemplo criado!"
else
    warn "DAG de exemplo já existe, pulando criação..."
fi

# Criar arquivo de configuração do Git
log "Configurando Git..."
cat > .gitignore << EOF
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
venv/
env/
ENV/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
logs/
*.log

# Environment variables
.env
.env.local
.env.*.local

# Database
*.db
*.sqlite3

# Airflow
airflow.cfg
webserver_config.py

# dbt
target/
dbt_packages/
profiles.yml

# Great Expectations
uncommitted/

# Docker
.dockerignore

# Backup
backups/

# Data
data/
*.csv
*.json
*.parquet

# Jupyter
.ipynb_checkpoints/

# Pytest
.pytest_cache/
.coverage
htmlcov/

# MyPy
.mypy_cache/
.dmypy.json
dmypy.json
EOF

success "Arquivo .gitignore criado!"

# Verificar se tudo está funcionando
log "Verificando se Docker está funcionando..."
if docker --version > /dev/null 2>&1; then
    success "Docker está funcionando!"
else
    error "Problema com Docker!"
    exit 1
fi

log "Verificando se Docker Compose está funcionando..."
if docker-compose --version > /dev/null 2>&1; then
    success "Docker Compose está funcionando!"
else
    error "Problema com Docker Compose!"
    exit 1
fi

# Inicializar banco de dados do Airflow
log "Inicializando banco de dados do Airflow..."
docker-compose up -d postgres redis
sleep 10
docker-compose run --rm airflow-webserver airflow db init
docker-compose run --rm airflow-webserver airflow users create \
    --username admin \
    --firstname Admin \
    --lastname User \
    --role Admin \
    --email admin@company.com \
    --password admin

success "Banco de dados do Airflow inicializado!"

# Mensagem final
echo ""
echo "🎉 Configuração concluída com sucesso!"
echo ""
echo "Para começar a usar:"
echo "1. Ative o ambiente virtual: source venv/bin/activate"
echo "2. Inicie os serviços: make start"
echo "3. Acesse o dashboard: abra dashboard/index.html"
echo "4. Acesse o Airflow: http://localhost:8080 (admin/admin)"
echo "5. Acesse o Airbyte: http://localhost:8000"
echo ""
echo "Para mais comandos disponíveis, execute: make help"
echo ""
success "Ambiente pronto para uso!"
EOF
