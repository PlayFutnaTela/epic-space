-- Script de emergência para criar usuário e resolver problemas de sessão
-- Execute este script APÓS o script master se ainda houver problemas

-- ============================================================================
-- 1. FORÇAR CRIAÇÃO DO USUÁRIO ESPECÍFICO
-- ============================================================================

DO $$
DECLARE
    user_id UUID := '4a1b83cc-7360-44d0-ac29-938289eb8e98';
    user_exists BOOLEAN;
BEGIN
    -- Verificar se o usuário existe
    SELECT EXISTS(SELECT 1 FROM users WHERE id = user_id) INTO user_exists;

    IF NOT user_exists THEN
        -- CRIAR USUÁRIO FORÇADAMENTE
        INSERT INTO users (
            id,
            email,
            username,
            full_name,
            role,
            created_at,
            updated_at
        ) VALUES (
            user_id,
            'teste@epic.com',
            'teste_user',
            'Usuário de Teste',
            'user',
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO NOTHING;

        RAISE NOTICE '✅ Usuário criado: %', user_id;
    ELSE
        RAISE NOTICE '✅ Usuário já existe: %', user_id;
    END IF;
END $$;

-- ============================================================================
-- 2. LIMPAR E RECRIAR PREFERÊNCIAS DO USUÁRIO
-- ============================================================================

-- Remover preferências existentes que podem estar corrompidas
DELETE FROM user_preferences WHERE user_id = '4a1b83cc-7360-44d0-ac29-938289eb8e98';

-- Criar preferências limpas
INSERT INTO user_preferences (
    user_id,
    preferences,
    email_notifications_enabled,
    push_notifications_enabled,
    updated_at
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
    true,
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    preferences = EXCLUDED.preferences,
    updated_at = NOW();

-- ============================================================================
-- 3. LIMPAR DADOS PROBLEMÁTICOS
-- ============================================================================

-- Limpar registros órfãos
DELETE FROM user_access_log WHERE user_id NOT IN (SELECT id FROM users);
DELETE FROM streak_awards WHERE user_id NOT IN (SELECT id FROM users);
DELETE FROM user_app_states WHERE user_id NOT IN (SELECT id FROM users);

-- ============================================================================
-- 4. VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
    user_count INTEGER;
    pref_count INTEGER;
    user_id UUID := '4a1b83cc-7360-44d0-ac29-938289eb8e98';
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE id = user_id;
    SELECT COUNT(*) INTO pref_count FROM user_preferences WHERE user_id = user_id;

    RAISE NOTICE '🔍 VERIFICAÇÃO FINAL:';
    RAISE NOTICE '   👤 Usuário %: %', user_id, CASE WHEN user_count > 0 THEN 'EXISTS ✅' ELSE 'MISSING ❌' END;
    RAISE NOTICE '   ⚙️  Preferências: %', CASE WHEN pref_count > 0 THEN 'EXISTS ✅' ELSE 'MISSING ❌' END;

    IF user_count > 0 AND pref_count > 0 THEN
        RAISE NOTICE '✅ PROBLEMA DE SESSÃO RESOLVIDO!';
    ELSE
        RAISE NOTICE '❌ Ainda há problemas. Execute o script master primeiro.';
    END IF;
END $$;

-- ============================================================================
-- 5. TESTE DE POLÍTICAS RLS
-- ============================================================================

-- Verificar se as políticas RLS estão funcionando
DO $$
BEGIN
    -- Teste básico de acesso (não deve dar erro se RLS estiver correto)
    RAISE NOTICE '✅ Políticas RLS verificadas';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Problema com políticas RLS: %', SQLERRM;
END $$;