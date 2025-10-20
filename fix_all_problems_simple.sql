-- Script SIMPLIFICADO para resolver TODOS os problemas
-- Execute este script COMPLETO no SQL Editor do Supabase

-- ============================================================================
-- 1. CRIAR USUÁRIO ESPECÍFICO
-- ============================================================================

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
    'usuario@epic.com',
    'usuario_epic',
    'Usuário EPIC',
    'user',
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- ============================================================================
-- 2. CORREÇÃO DA TABELA USER_PREFERENCES
-- ============================================================================

ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}'::jsonb;

ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================================================
-- 3. CRIAR TABELAS FALTANTES
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_access_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    access_type TEXT NOT NULL DEFAULT 'login',
    ip_address INET,
    user_agent TEXT,
    device_info JSONB,
    location_info JSONB,
    accessed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS streak_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS streak_awards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    xp INTEGER NOT NULL DEFAULT 0,
    streak_days INTEGER NOT NULL DEFAULT 0,
    award_type TEXT DEFAULT 'daily_login',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE TABLE IF NOT EXISTS season_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    season_name TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT false,
    xp_multiplier DECIMAL(3,2) DEFAULT 1.0,
    config_data JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

DROP TABLE IF EXISTS user_app_states CASCADE;
CREATE TABLE user_app_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    state_key TEXT NOT NULL,
    state_value JSONB,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, state_key)
);

-- ============================================================================
-- 4. CRIAR ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_user_access_log_user_id ON user_access_log(user_id);
CREATE INDEX IF NOT EXISTS idx_streak_config_key ON streak_config(config_key);
CREATE INDEX IF NOT EXISTS idx_streak_awards_user_id ON streak_awards(user_id);
CREATE INDEX IF NOT EXISTS idx_season_config_active ON season_config(is_active);
CREATE INDEX IF NOT EXISTS idx_user_app_states_user_key ON user_app_states(user_id, state_key);

-- ============================================================================
-- 5. HABILITAR RLS
-- ============================================================================

ALTER TABLE user_access_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_awards ENABLE ROW LEVEL SECURITY;
ALTER TABLE season_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_app_states ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. CRIAR POLÍTICAS RLS
-- ============================================================================

DROP POLICY IF EXISTS "Users can view own access log" ON user_access_log;
CREATE POLICY "Users can view own access log" ON user_access_log
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own access log" ON user_access_log;
CREATE POLICY "Users can insert own access log" ON user_access_log
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Streak config is viewable by authenticated users" ON streak_config;
CREATE POLICY "Streak config is viewable by authenticated users" ON streak_config
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Users can view own streak awards" ON streak_awards;
CREATE POLICY "Users can view own streak awards" ON streak_awards
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own streak awards" ON streak_awards;
CREATE POLICY "Users can insert own streak awards" ON streak_awards
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Season config is viewable by authenticated users" ON season_config;
CREATE POLICY "Season config is viewable by authenticated users" ON season_config
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Users can manage own app states" ON user_app_states;
CREATE POLICY "Users can manage own app states" ON user_app_states
FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- 7. INSERIR DADOS PADRÃO
-- ============================================================================

INSERT INTO streak_config (config_key, config_value, description)
VALUES
    ('daily_login_xp', '10', 'XP por login diário'),
    ('streak_multiplier', '1.5', 'Multiplicador de XP para streaks'),
    ('max_streak_bonus', '50', 'Bônus máximo de XP para streak'),
    ('streak_reset_days', '1', 'Dias sem login para resetar streak')
ON CONFLICT (config_key) DO NOTHING;

INSERT INTO season_config (season_name, start_date, end_date, is_active, xp_multiplier)
VALUES
    ('Temporada 2025', '2025-01-01', '2025-12-31', true, 1.0)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. CRIAR PREFERÊNCIAS SIMPLES PARA O USUÁRIO
-- ============================================================================

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
            "currentPage": "dashboard"
        }
    }'::jsonb,
    true,
    true
) ON CONFLICT (user_id) DO NOTHING;

-- ============================================================================
-- 9. VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
    user_count INTEGER;
    pref_count INTEGER;
    tables_exist INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE id = '4a1b83cc-7360-44d0-ac29-938289eb8e98';
    SELECT COUNT(*) INTO pref_count FROM user_preferences WHERE user_id = '4a1b83cc-7360-44d0-ac29-938289eb8e98';

    -- Verificar se as tabelas existem
    SELECT COUNT(*) INTO tables_exist
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN ('user_access_log', 'streak_config', 'streak_awards', 'season_config', 'user_app_states');

    RAISE NOTICE '📊 STATUS FINAL:';
    RAISE NOTICE '   👤 Usuário específico: %', CASE WHEN user_count > 0 THEN 'EXISTS ✅' ELSE 'MISSING ❌' END;
    RAISE NOTICE '   ⚙️  Preferências: %', CASE WHEN pref_count > 0 THEN 'EXISTS ✅' ELSE 'MISSING ❌' END;
    RAISE NOTICE '   📋 Tabelas criadas: %/5', tables_exist;
    RAISE NOTICE '✅ SCRIPT SIMPLIFICADO EXECUTADO COM SUCESSO!';
END $$;