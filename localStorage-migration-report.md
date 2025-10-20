# Relatório de Migração: localStorage para Supabase

## Resumo dos Problemas Encontrados

Com base na análise completa do projeto, identifiquei várias configurações armazenadas no localStorage que, segundo a documentação e arquitetura (migração para Supabase), deveriam ser gerenciadas pelo banco de dados para garantir consistência, segurança e escalabilidade. O sistema atualmente usa localStorage para simulação, mas há planos explícitos de migração para Supabase. Abaixo, listo as principais categorias e exemplos específicos:

### 1. Dados de Usuários e Autenticação
- **Arquivos afetados**: `src/services/authService.ts`, `src/services/localStorageData.ts` (chaves como `epic_users_db`, `epic_user_data`).
- **Problema**: Usuários são entidades centrais; no Supabase, há tabelas como `users` com autenticação integrada (Supabase Auth). Configurações como perfil, avatar e permissões devem ser persistidas no DB para evitar inconsistências locais.
- **Referências**: `dashi-touch/database/database-1v1.md` (tabela `users`).

### 2. Tarefas e Dados de Projeto
- **Arquivos afetados**: `src/services/localStorageData.ts` (chaves como `epic_tasks_data_v1`, `epic_project_metrics_v1`).
- **Problema**: Tarefas são compartilhadas; tabelas como `tasks` e `projects` no Supabase suportam RLS (Row Level Security) e real-time. Métricas calculadas também deveriam ser cacheadas no DB.
- **Referências**: `dashi-touch/database/preparo-db.md` (tabelas `tasks` e `projects`).

### 3. Sistema de Gamificação (XP, Níveis, Rankings)
- **Arquivos afetados**: `src/services/gamificationService.ts`, `src/services/localStorageData.ts` (regras de níveis, XP por tarefa).
- **Problema**: Configurações como percentuais de produtividade e regras de níveis são globais; tabelas como `player_profiles`, `user_rankings` e `xp_history` no Supabase garantem consistência.
- **Referências**: `dashi-touch/plan/todo-balanceamento1v1.md`.

### 4. Missões e Configurações de Temporada
- **Arquivos afetados**: `src/services/missionService.ts`, `src/config/season.ts` (chaves como `epic_mission_list_v1`, `epic_season_config_v1`).
- **Problema**: Missões e temporadas são administrativas; tabelas como `missions`, `player_seasons` e `user_preferences` no Supabase permitem controle centralizado.
- **Referências**: `dashi-touch/database/database-1v1.md`.

### 5. Preferências do Usuário e Estado Global
- **Arquivos afetados**: `src/services/appStateManager.ts`, `src/config/streak.ts` (preferências como tema, notificações, streak bonus).
- **Problema**: Preferências são por usuário; tabela `user_preferences` no Supabase é ideal para isso.
- **Referências**: Estado global deveria ser sincronizado via DB para múltiplos dispositivos.

### 6. Cache e Métricas Calculadas
- **Arquivos afetados**: `src/services/appStateManager.ts`, `src/services/localStorageData.ts` (cache de KPIs, métricas de projeto).
- **Problema**: Caches como `analytics_cache` e `dashboard_cache` no Supabase evitam recalculações desnecessárias e suportam real-time.
- **Referências**: `dashi-touch/database/sqlcomando.sql` (tabelas de cache).

### 7. Outros (Notificações, Histórico, etc.)
- **Arquivos afetados**: `src/pages/PlayerProfilePage.tsx`, `src/services/xpHistoryService.ts` (status de leitura de notificações, histórico de XP).
- **Problema**: Tabelas como `user_notifications`, `xp_history` e `task_history` garantem persistência e auditoria.
- **Referências**: Migração necessária para evitar perda de dados locais.

**Status Atual**: Tudo está no localStorage para desenvolvimento/simulação, conforme `dashi-touch/plan/MockLocalization.md`.
**Riscos**: Dados locais podem ser perdidos; configurações globais (como percentuais de produtividade) precisam de sincronização.

## Lista de Tarefas para Migração

- [ ] **Revisar e validar tabelas no Supabase**: Verificar se todas as tabelas mencionadas (users, tasks, projects, player_profiles, etc.) estão criadas e configuradas corretamente no Supabase, incluindo RLS e políticas de acesso.
- [ ] **Migrar dados de usuários e autenticação**: Substituir localStorage em `src/services/authService.ts` e `src/services/localStorageData.ts` por chamadas Supabase Auth e tabela `users`. Implementar sincronização de perfil e permissões.
- [ ] **Migrar tarefas e dados de projeto**: Atualizar `src/services/localStorageData.ts` para usar tabelas `tasks` e `projects` no Supabase. Garantir que métricas sejam calculadas e armazenadas no DB.
- [ ] **Migrar sistema de gamificação**: Modificar `src/services/gamificationService.ts` e `src/services/localStorageData.ts` para persistir XP, níveis e rankings nas tabelas `player_profiles`, `user_rankings` e `xp_history`.
- [ ] **Migrar missões e configurações de temporada**: Atualizar `src/services/missionService.ts` e `src/config/season.ts` para usar tabelas `missions`, `player_seasons` e `user_preferences` no Supabase.
- [ ] **Migrar preferências do usuário e estado global**: Refatorar `src/services/appStateManager.ts` e `src/config/streak.ts` para armazenar preferências na tabela `user_preferences` e sincronizar estado via DB.
- [ ] **Migrar cache e métricas calculadas**: Implementar cache em tabelas `analytics_cache` e `dashboard_cache` no Supabase, substituindo localStorage em `src/services/appStateManager.ts`.
- [ ] **Migrar notificações e histórico**: Atualizar `src/pages/PlayerProfilePage.tsx` e `src/services/xpHistoryService.ts` para usar tabelas `user_notifications`, `xp_history` e `task_history`.
- [ ] **Implementar APIs no servidor**: Modificar `server/index.js` para adicionar endpoints reais que interajam com Supabase, substituindo simulações locais.
- [ ] **Testar migração**: Executar testes unitários e de integração (`src/__tests__/`) para garantir que a migração não quebre funcionalidades. Incluir testes de performance e e2e.
- [ ] **Atualizar documentação**: Revisar e atualizar arquivos como `dashi-touch/plan/docs/MIGRATION_AND_ROLLBACK.md` com os passos realizados e possíveis rollbacks.
- [ ] **Limpar código legado**: Remover todas as referências a localStorage após migração completa, incluindo chaves obsoletas e funções de simulação.
- [ ] **Monitorar e ajustar**: Após deploy, monitorar uso de DB e ajustar políticas de RLS ou índices conforme necessário para otimizar performance.

Este documento serve como guia para a migração gradual e segura do localStorage para Supabase.