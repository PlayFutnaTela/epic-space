-- Script para verificar e corrigir problemas de usuário
-- Execute este script APÓS o script fix_missing_tables.sql

-- ============================================================================
-- 1. VERIFICAR SE O USUÁRIO EXISTE
-- ============================================================================

-- Verificar se o usuário específico existe
DO $$
DECLARE
    user_exists BOOLEAN;
    user_id_to_check UUID := '4a1b83cc-7360-44d0-ac29-938289eb8e98';
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM users WHERE id = user_id_to_check
    ) INTO user_exists;

    IF NOT user_exists THEN
        RAISE NOTICE '❌ Usuário % não encontrado na tabela users', user_id_to_check;
        RAISE NOTICE '💡 Você precisa criar este usuário ou verificar o ID correto';
    ELSE
        RAISE NOTICE '✅ Usuário % encontrado na tabela users', user_id_to_check;
    END IF;
END $$;

-- ============================================================================
-- 2. CRIAR USUÁRIO DE TESTE (APENAS PARA DESENVOLVIMENTO)
-- ============================================================================

-- ⚠️  ATENÇÃO: Este bloco é apenas para desenvolvimento/teste
-- Em produção, os usuários devem ser criados pelo sistema de auth do Supabase

/*
-- DESCOMENTE ESTAS LINHAS APENAS SE ESTIVER EM AMBIENTE DE DESENVOLVIMENTO

INSERT INTO users (
    id,
    email,
    username,
    full_name,
    role,
    created_at,
    updated_at
) VALUES (
    '4a1b83cc-7360-44d0-ac29-938289eb8e98',
    'teste@epic.com',
    'teste_user',
    'Usuário de Teste',
    'user',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Criar preferências padrão para o usuário
INSERT INTO user_preferences (
    user_id,
    preferences,
    email_notifications_enabled,
    push_notifications_enabled
) VALUES (
    '4a1b83cc-7360-44d0-ac29-938289eb8e98',
    '{
        "userPreferences": {
            "enableRealTimeUpdates": true,
            "kpiRefreshInterval": 30000,
            "theme": "dark",
            "language": "pt-BR"
        },
        "navigationContext": {
            "currentPage": "dashboard",
            "timestamp": "' || NOW()::text || '"
        },
        "lastUpdate": "' || NOW()::text || '"
    }'::jsonb,
    true,
    true
) ON CONFLICT (user_id) DO NOTHING;

RAISE NOTICE '✅ Usuário de teste criado com sucesso!';

*/

-- ============================================================================
-- 3. VERIFICAR E CORREÇÃO DE PROBLEMAS DE RLS
-- ============================================================================

-- Verificar se as políticas RLS estão ativas
DO $$
DECLARE
    table_record RECORD;
BEGIN
    FOR table_record IN
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename IN ('user_preferences', 'user_access_log', 'streak_config', 'streak_awards', 'season_config', 'user_app_states')
    LOOP
        -- Verificar se RLS está habilitado
        IF NOT EXISTS (
            SELECT 1 FROM pg_class c
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE c.relname = table_record.tablename
            AND n.nspname = 'public'
            AND c.relrowsecurity = true
        ) THEN
            RAISE NOTICE '❌ RLS não habilitado para tabela: %', table_record.tablename;
        ELSE
            RAISE NOTICE '✅ RLS habilitado para tabela: %', table_record.tablename;
        END IF;
    END LOOP;
END $$;

-- ============================================================================
-- 4. LIMPAR DADOS PROBLEMÁTICOS (se necessário)
-- ============================================================================

-- Limpar registros órfãos em user_preferences (se existirem)
DELETE FROM user_preferences
WHERE user_id NOT IN (SELECT id FROM users);

-- Verificar se há registros órfãos
DO $$
DECLARE
    orphan_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO orphan_count
    FROM user_preferences
    WHERE user_id NOT IN (SELECT id FROM users);

    IF orphan_count > 0 THEN
        RAISE NOTICE '❌ Encontrados % registros órfãos em user_preferences', orphan_count;
    ELSE
        RAISE NOTICE '✅ Nenhum registro órfão encontrado em user_preferences';
    END IF;
END $$;

-- ============================================================================
-- 5. DIAGNÓSTICO FINAL
-- ============================================================================

-- Verificar status geral do banco
DO $$
DECLARE
    user_count INTEGER;
    pref_count INTEGER;
    streak_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users;
    SELECT COUNT(*) INTO pref_count FROM user_preferences;
    SELECT COUNT(*) INTO streak_count FROM streak_awards;

    RAISE NOTICE '📊 STATUS DO BANCO:';
    RAISE NOTICE '   👥 Usuários: %', user_count;
    RAISE NOTICE '   ⚙️  Preferências: %', pref_count;
    RAISE NOTICE '   🔥 Prêmios de Streak: %', streak_count;
    RAISE NOTICE '✅ Diagnóstico concluído!';
END $$;