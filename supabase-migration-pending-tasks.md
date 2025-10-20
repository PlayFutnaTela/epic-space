# Pendências Críticas para Migração 100% ao Supabase

## Status Atual: Não Pronto para Implementação Completa

Após análise completa do sistema, identificamos que ainda existem dependências críticas no localStorage que impedem uma migração 100% segura para o Supabase. Embora dados mock tenham sido removidos e a estrutura básica esteja definida, as seguintes pendências precisam ser resolvidas.

## Lista de Tarefas por Categoria

### 1. Dados de Usuários e Autenticação
- [ ] **Migrar perfis de usuário**: Substituir localStorage (`epic_users_db`, `epic_user_data`) por tabela `users` no Supabase com Supabase Auth
- [ ] **Implementar sincronização de avatares**: Garantir que avatares sejam armazenados e recuperados do Supabase Storage
- [ ] **Migrar permissões e roles**: Mover controle de acesso para RLS (Row Level Security) no Supabase
- [ ] **Atualizar `src/services/authService.ts`**: Remover fallbacks locais e usar exclusivamente Supabase Auth
- [ ] **Testar autenticação multi-dispositivo**: Verificar se sessões são sincronizadas corretamente

### 2. Tarefas e Métricas de Projeto
- [ ] **Migrar dados de tarefas**: Substituir `epic_tasks_data_v1` por tabela `tasks` no Supabase
- [ ] **Implementar métricas calculadas**: Mover `epic_project_metrics_v1` para tabela `project_metrics` com cálculos automáticos
- [ ] **Configurar RLS para tarefas**: Garantir que usuários só vejam tarefas autorizadas
- [ ] **Atualizar `src/services/localStorageData.ts`**: Remover funções locais e usar apenas Supabase
- [ ] **Implementar real-time updates**: Usar Supabase Realtime para sincronização automática

### 3. Sistema de Gamificação
- [ ] **Migrar regras de produtividade**: Mover percentuais (early: 100%, on_time: 90%, etc.) para tabela global no Supabase
- [ ] **Implementar perfis de jogador**: Usar tabela `player_profiles` para XP, níveis e rankings
- [ ] **Migrar histórico de XP**: Mover dados para tabela `xp_history` com auditoria
- [ ] **Configurar rankings dinâmicos**: Implementar tabela `user_rankings` com cálculos automáticos
- [ ] **Atualizar `src/services/gamificationService.ts`**: Remover dependências locais

### 4. Missões e Temporadas
- [ ] **Migrar configurações de missões**: Mover dados para tabela `missions` no Supabase
- [ ] **Implementar temporadas ativas**: Usar tabela `player_seasons` para controle de períodos
- [ ] **Configurar preferências de usuário**: Integrar com tabela `user_preferences` para missões
- [ ] **Atualizar `src/services/missionService.ts`**: Remover localStorage e usar Supabase
- [ ] **Atualizar `src/config/season.ts`**: Migrar configurações para banco

### 5. Preferências e Estado Global
- [ ] **Migrar configurações de usuário**: Mover tema, notificações e outras prefs para `user_preferences`
- [ ] **Implementar sincronização de estado**: Garantir que estado global seja persistido no Supabase
- [ ] **Configurar streak e bonus**: Mover dados de streak para tabela dedicada
- [ ] **Atualizar `src/services/appStateManager.ts`**: Remover localStorage completamente
- [ ] **Testar multi-dispositivo**: Verificar sincronização entre diferentes dispositivos

### 6. Cache e KPIs Calculados
- [ ] **Implementar cache de analytics**: Criar tabela `analytics_cache` no Supabase
- [ ] **Migrar cache de dashboard**: Usar tabela `dashboard_cache` para KPIs
- [ ] **Configurar invalidação automática**: Implementar TTL e limpeza de cache antigo
- [ ] **Atualizar hooks de cache**: Modificar `src/hooks/useKPIs.ts` para usar Supabase
- [ ] **Otimizar performance**: Garantir que cache reduza carga no banco

### 7. Outros (Notificações, Histórico)
- [ ] **Migrar notificações**: Implementar tabela `user_notifications` para status de leitura
- [ ] **Implementar histórico de tarefas**: Usar tabela `task_history` para auditoria
- [ ] **Migrar histórico de XP**: Garantir que `xp_history` tenha todos os dados
- [ ] **Atualizar `src/pages/PlayerProfilePage.tsx`**: Remover localStorage de notificações
- [ ] **Atualizar `src/services/xpHistoryService.ts`**: Usar Supabase exclusivamente

## Tarefas de Infraestrutura e Testes

### 8. APIs e Servidor
- [ ] **Implementar endpoints reais**: Atualizar `server/index.js` com APIs Supabase
- [ ] **Configurar middlewares**: Implementar autenticação e validação
- [ ] **Testar integração**: Criar testes E2E para endpoints
- [ ] **Documentar APIs**: Atualizar documentação com novos endpoints

### 9. Testes e Qualidade
- [ ] **Corrigir testes restantes**: Resolver erros em `src/__tests__/integration-e2e.test.tsx`
- [ ] **Criar testes de migração**: Testes para validar transição localStorage → Supabase
- [ ] **Implementar testes de carga**: Verificar performance com dados reais
- [ ] **Configurar CI/CD**: Pipeline para deploy com Supabase

### 10. Segurança e Monitoramento
- [ ] **Configurar RLS**: Políticas de segurança em todas as tabelas
- [ ] **Implementar auditoria**: Logs de acesso e modificações
- [ ] **Configurar backups**: Estratégia de backup do Supabase
- [ ] **Monitorar performance**: Dashboards de uso e latência

## Riscos e Considerações

### Riscos Identificados
- **Perda de dados locais**: Configurações podem ser perdidas durante migração
- **Inconsistências**: Estados diferentes entre dispositivos durante transição
- **Quebra de funcionalidade**: Gamificação e missões podem falhar se regras não migradas
- **Performance**: Cache inadequado pode causar lentidão

### Plano de Mitigação
- **Dry-run obrigatório**: Testar migração em ambiente de staging
- **Backup completo**: Fazer backup de todos os dados locais antes
- **Rollback plan**: Seguir `dashi-touch/plan/docs/MIGRATION_AND_ROLLBACK.md`
- **Deploy gradual**: Migrar por módulos, não tudo de uma vez

## Priorização Recomendada

1. **Alta Prioridade** (Semanas 1-2):
   - Usuários e autenticação
   - Tarefas básicas
   - APIs essenciais

2. **Média Prioridade** (Semanas 3-4):
   - Gamificação
   - Preferências
   - Cache básico

3. **Baixa Prioridade** (Semanas 5-6):
   - Missões avançadas
   - Histórico completo
   - Otimizações

## Métricas de Sucesso

- [ ] Zero dependências no localStorage
- [ ] Todos os testes passando
- [ ] Performance mantida ou melhorada
- [ ] Sincronização multi-dispositivo funcionando
- [ ] Backup e recovery testados

---

**Status**: ❌ Não Pronto | **Próximo Passo**: Seguir priorização para migração gradual e segura.