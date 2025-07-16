# Contribuindo para o Projeto

## Bem-vindo!

Obrigado por seu interesse em contribuir para o Dashboard de KPIs! Este documento fornece diretrizes e informações sobre como contribuir efetivamente para o projeto.

## Como Contribuir

### 1. Reportando Bugs

Se você encontrou um bug, por favor:

1. Verifique se o bug já não foi reportado nas [Issues](https://github.com/company/kpis-dashboard/issues)
2. Crie uma nova issue com o template de bug report
3. Forneça informações detalhadas sobre o problema
4. Inclua passos para reproduzir o bug
5. Adicione logs relevantes e screenshots se possível

### 2. Sugerindo Melhorias

Para sugerir novas funcionalidades:

1. Verifique se a sugestão já não existe nas issues
2. Crie uma nova issue com o template de feature request
3. Descreva claramente o problema que a funcionalidade resolveria
4. Forneça exemplos de uso
5. Considere a implementação e impacto

### 3. Contribuindo com Código

#### Configuração do Ambiente

```bash
# 1. Clone o repositório
git clone https://github.com/company/kpis-dashboard.git
cd kpis-dashboard

# 2. Configure o ambiente
make setup

# 3. Instale dependências
make install

# 4. Inicie os serviços
make start
```

#### Fluxo de Desenvolvimento

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. **Crie** uma branch para sua funcionalidade:
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```
4. **Desenvolva** sua funcionalidade
5. **Teste** suas mudanças:
   ```bash
   make test
   make lint
   ```
6. **Commit** suas mudanças:
   ```bash
   git commit -m "feat: adiciona nova funcionalidade"
   ```
7. **Push** para seu fork:
   ```bash
   git push origin feature/nova-funcionalidade
   ```
8. **Abra** um Pull Request

#### Padrões de Commit

Utilizamos [Conventional Commits](https://conventionalcommits.org/) para padronizar mensagens de commit:

```
<tipo>[escopo opcional]: <descrição>

[corpo opcional]

[rodapé opcional]
```

**Tipos:**
- `feat`: nova funcionalidade
- `fix`: correção de bug
- `docs`: documentação
- `style`: formatação
- `refactor`: refatoração
- `test`: testes
- `chore`: tarefas de manutenção

**Exemplos:**
```
feat(dashboard): adiciona filtro por data
fix(etl): corrige erro na transformação de dados
docs(readme): atualiza instruções de instalação
```

### 4. Padrões de Código

#### Python

```python
# Utilize type hints
def calculate_conversion_rate(leads: int, conversions: int) -> float:
    """
    Calcula taxa de conversão.
    
    Args:
        leads: Número de leads
        conversions: Número de conversões
        
    Returns:
        Taxa de conversão em percentual
    """
    if leads == 0:
        return 0.0
    return (conversions / leads) * 100
```

#### SQL (dbt)

```sql
-- models/marts/fct_conversions.sql
{{ config(materialized='table') }}

with leads as (
    select * from {{ ref('stg_leads') }}
),

conversions as (
    select * from {{ ref('stg_conversions') }}
)

select
    date_key,
    channel,
    count(distinct lead_id) as total_leads,
    count(distinct conversion_id) as total_conversions,
    round(
        (count(distinct conversion_id) * 100.0) / 
        nullif(count(distinct lead_id), 0), 2
    ) as conversion_rate
from leads
left join conversions using (lead_id)
group by 1, 2
```

#### JavaScript

```javascript
// Utilize ES6+ features
const calculateKPI = (data, kpiType) => {
    const config = {
        conversionRate: (d) => (d.conversions / d.leads) * 100,
        cac: (d) => d.adSpend / d.acquisitions,
        mrr: (d) => d.monthlyRevenue
    };
    
    return config[kpiType]?.(data) || 0;
};
```

### 5. Testes

#### Testes Python

```python
# tests/test_kpis.py
import pytest
from src.kpis import calculate_conversion_rate

def test_calculate_conversion_rate():
    """Testa cálculo de taxa de conversão."""
    assert calculate_conversion_rate(100, 10) == 10.0
    assert calculate_conversion_rate(0, 0) == 0.0
    assert calculate_conversion_rate(100, 0) == 0.0
```

#### Testes dbt

```sql
-- tests/test_conversion_rate.sql
select *
from {{ ref('fct_conversions') }}
where conversion_rate < 0 or conversion_rate > 100
```

#### Testes JavaScript

```javascript
// tests/dashboard.test.js
describe('KPI Calculator', () => {
    test('calculates conversion rate correctly', () => {
        const data = { leads: 100, conversions: 10 };
        expect(calculateKPI(data, 'conversionRate')).toBe(10);
    });
});
```

### 6. Documentação

#### Docstrings Python

```python
def extract_data(source: str, config: dict) -> pd.DataFrame:
    """
    Extrai dados de uma fonte específica.
    
    Args:
        source: Nome da fonte de dados
        config: Configurações de conexão
        
    Returns:
        DataFrame com os dados extraídos
        
    Raises:
        ConnectionError: Se não conseguir conectar à fonte
        ValidationError: Se os dados não passarem na validação
        
    Examples:
        >>> config = {'host': 'localhost', 'port': 5432}
        >>> df = extract_data('postgres', config)
        >>> len(df) > 0
        True
    """
```

#### Documentação dbt

```sql
version: 2

models:
  - name: fct_conversions
    description: "Tabela de fatos com métricas de conversão"
    columns:
      - name: date_key
        description: "Chave de data (YYYY-MM-DD)"
        tests:
          - not_null
          - unique
      - name: conversion_rate
        description: "Taxa de conversão em percentual"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100
```

### 7. Revisão de Código

#### Checklist do Autor

- [ ] Código segue os padrões do projeto
- [ ] Testes foram adicionados/atualizados
- [ ] Documentação foi atualizada
- [ ] Não há segredos no código
- [ ] Performance foi considerada
- [ ] Mudanças são backward-compatible

#### Checklist do Revisor

- [ ] Código é legível e bem estruturado
- [ ] Lógica está correta
- [ ] Testes cobrem cenários importantes
- [ ] Documentação está clara
- [ ] Não há vulnerabilidades de segurança
- [ ] Performance é adequada

### 8. Comunicação

#### Canais

- **GitHub Issues**: Para bugs e feature requests
- **GitHub Discussions**: Para discussões gerais
- **Slack**: Para comunicação rápida (#data-team)
- **Email**: Para questões sensíveis (data-team@company.com)

#### Etiqueta

- Seja respeitoso e construtivo
- Forneça contexto suficiente
- Seja específico e objetivo
- Agradeça por contribuições

### 9. Processo de Release

#### Versionamento

Seguimos [Semantic Versioning](https://semver.org/):
- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs

#### Pipeline de Release

1. **Desenvolvimento** → branch `develop`
2. **Staging** → branch `staging`
3. **Produção** → branch `main`

```bash
# Exemplo de release
git checkout main
git merge develop
git tag v1.2.0
git push origin main --tags
```

### 10. Recursos Úteis

#### Ferramentas

- **Make**: `make help` para comandos disponíveis
- **Docker**: Para ambiente consistente
- **Pre-commit**: Para validação automática
- **pytest**: Para testes Python
- **dbt**: Para transformações SQL

#### Documentação

- [Arquitetura](docs/arquitetura-dados.md)
- [Governança](docs/governanca-dados.md)
- [KPIs](docs/kpis-detalhados.md)
- [Implementação](docs/plano-implementacao.md)

#### Links Externos

- [dbt Documentation](https://docs.getdbt.com/)
- [Great Expectations](https://docs.greatexpectations.io/)
- [Apache Airflow](https://airflow.apache.org/docs/)
- [Airbyte](https://docs.airbyte.com/)

## Reconhecimento

Valorizamos todas as contribuições! Contribuidores são listados em:

- [CONTRIBUTORS.md](CONTRIBUTORS.md)
- Release notes
- Documentação do projeto

## Dúvidas?

Se você tem dúvidas sobre como contribuir:

1. Verifique a [documentação existente](docs/)
2. Procure em [issues anteriores](https://github.com/company/kpis-dashboard/issues)
3. Abra uma [nova issue](https://github.com/company/kpis-dashboard/issues/new)
4. Entre em contato no Slack (#data-team)

Obrigado por contribuir! 🚀
