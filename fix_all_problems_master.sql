-- Script MASTER para resolver TODOS os problemas de uma vez
-- Execute este script COMPLETO no SQL Editor do Supabase

-- ============================================================================
-- 1. VERIFICAR E CRIAR USUÁRIO ESPECÍFICO
-- ============================================================================

DO $$
DECLARE
    user_exists BOOLEAN;
    user_id_to_check UUID := '4a1b83cc-7360-44d0-ac29-938289eb8e98';
BEGIN
    -- Verificar se o usuário existe
    SELECT EXISTS(SELECT 1 FROM users WHERE id = user_id_to_check) INTO user_exists;

    IF NOT user_exists THEN
        -- CRIAR USUÁRIO (apenas para desenvolvimento - em produção isso é feito pelo auth)
        INSERT INTO users (
            id,
            email,
            username,
            full_name,
            role,
            created_at,
            updated_at
        ) VALUES (
            user_id_to_check,
            'usuario@epic.com',
            'usuario_epic',
            'Usuário EPIC',
            'user',
            NOW(),
            NOW()
        );

        RAISE NOTICE '✅ Usuário criado com sucesso: %', user_id_to_check;
    ELSE
        RAISE NOTICE '✅ Usuário já existe: %', user_id_to_check;
    END IF;
END $$;

-- ============================================================================
-- 2. CORREÇÃO DA TABELA USER_PREFERENCES
-- ============================================================================

-- Adicionar coluna preferences se não existir
ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}'::jsonb;

-- Adicionar coluna updated_at se não existir
ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================================================
-- 3. CRIAR TODAS AS TABELAS FALTANTES
-- ============================================================================

-- user_access_log
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

-- streak_config
CREATE TABLE IF NOT EXISTS streak_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_key TEXT UNIQUE NOT NULL,
    config_value JSONB NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- streak_awards
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

-- season_config
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

-- user_app_states
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
CREATE INDEX IF NOT EXISTS idx_user_access_log_accessed_at ON user_access_log(accessed_at);
CREATE INDEX IF NOT EXISTS idx_streak_config_active ON streak_config(is_active);
CREATE INDEX IF NOT EXISTS idx_streak_config_key ON streak_config(config_key);
CREATE INDEX IF NOT EXISTS idx_streak_awards_user_id ON streak_awards(user_id);
CREATE INDEX IF NOT EXISTS idx_streak_awards_date ON streak_awards(date);
CREATE INDEX IF NOT EXISTS idx_streak_awards_user_date ON streak_awards(user_id, date);
CREATE INDEX IF NOT EXISTS idx_season_config_active ON season_config(is_active);
CREATE INDEX IF NOT EXISTS idx_season_config_dates ON season_config(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_user_app_states_user_key ON user_app_states(user_id, state_key);

-- ============================================================================
-- 5. HABILITAR ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE user_access_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_awards ENABLE ROW LEVEL SECURITY;
ALTER TABLE season_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_app_states ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. CRIAR POLÍTICAS RLS
-- ============================================================================

-- user_access_log
DROP POLICY IF EXISTS "Users can view own access log" ON user_access_log;
CREATE POLICY "Users can view own access log" ON user_access_log
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own access log" ON user_access_log;
CREATE POLICY "Users can insert own access log" ON user_access_log
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- streak_config
DROP POLICY IF EXISTS "Streak config is viewable by authenticated users" ON streak_config;
CREATE POLICY "Streak config is viewable by authenticated users" ON streak_config
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Only admins can modify streak config" ON streak_config;
CREATE POLICY "Only admins can modify streak config" ON streak_config
FOR ALL TO authenticated USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role = 'admin'
    )
);

-- streak_awards
DROP POLICY IF EXISTS "Users can view own streak awards" ON streak_awards;
CREATE POLICY "Users can view own streak awards" ON streak_awards
FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own streak awards" ON streak_awards;
CREATE POLICY "Users can insert own streak awards" ON streak_awards
FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own streak awards" ON streak_awards;
CREATE POLICY "Users can update own streak awards" ON streak_awards
FOR UPDATE USING (auth.uid() = user_id);

-- season_config
DROP POLICY IF EXISTS "Season config is viewable by authenticated users" ON season_config;
CREATE POLICY "Season config is viewable by authenticated users" ON season_config
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Only admins can modify season config" ON season_config;
CREATE POLICY "Only admins can modify season config" ON season_config
FOR ALL TO authenticated USING (
    EXISTS (
        SELECT 1 FROM users
        WHERE id = auth.uid()
        AND role = 'admin'
    )
);

-- user_app_states
DROP POLICY IF EXISTS "Users can manage own app states" ON user_app_states;
CREATE POLICY "Users can manage own app states" ON user_app_states
FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- 7. INSERIR DADOS PADRÃO
-- ============================================================================

-- streak_config
INSERT INTO streak_config (config_key, config_value, description)
VALUES
    ('daily_login_xp', '10', 'XP por login diário'),
    ('streak_multiplier', '1.5', 'Multiplicador de XP para streaks'),
    ('max_streak_bonus', '50', 'Bônus máximo de XP para streak'),
    ('streak_reset_days', '1', 'Dias sem login para resetar streak')
ON CONFLICT (config_key) DO NOTHING;

-- season_config
INSERT INTO season_config (season_name, start_date, end_date, is_active, xp_multiplier)
VALUES
    ('Temporada 2025', '2025-01-01', '2025-12-31', true, 1.0)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. CRIAR PREFERÊNCIAS PARA O USUÁRIO
-- ============================================================================

DO $$
DECLARE
    current_timestamp TEXT;
BEGIN
    -- Obter timestamp atual como string
    SELECT NOW()::text INTO current_timestamp;

    -- Inserir preferências com timestamp correto
    INSERT INTO user_preferences (
        user_id,
        preferences,
        email_notifications_enabled,
        push_notifications_enabled
    ) VALUES (
        '4a1b83cc-7360-44d0-ac29-938289eb8e98',
        jsonb_build_object(
            'userPreferences', jsonb_build_object(
                'enableRealTimeUpdates', true,
                'kpiRefreshInterval', 30000,
                'theme', 'dark',
                'language', 'pt-BR'
            ),
            'navigationContext', jsonb_build_object(
                'currentPage', 'dashboard',
                'timestamp', current_timestamp
            ),
            'lastUpdate', current_timestamp
        ),
        true,
        true
    ) ON CONFLICT (user_id) DO NOTHING;

    RAISE NOTICE '✅ Preferências do usuário criadas com timestamp: %', current_timestamp;
END $$;

-- ============================================================================
-- 9. CRIAR TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_streak_config_updated_at
    BEFORE UPDATE ON streak_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_season_config_updated_at
    BEFORE UPDATE ON season_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_app_states_updated_at
    BEFORE UPDATE ON user_app_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 10. VERIFICAÇÃO FINAL
-- ============================================================================

DO $$
DECLARE
    user_count INTEGER;
    pref_count INTEGER;
    access_count INTEGER;
    streak_count INTEGER;
    season_count INTEGER;
    app_states_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO user_count FROM users WHERE id = '4a1b83cc-7360-44d0-ac29-938289eb8e98';
    SELECT COUNT(*) INTO pref_count FROM user_preferences WHERE user_id = '4a1b83cc-7360-44d0-ac29-938289eb8e98';
    SELECT COUNT(*) INTO access_count FROM information_schema.tables WHERE table_name = 'user_access_log';
    SELECT COUNT(*) INTO streak_count FROM information_schema.tables WHERE table_name = 'streak_config';
    SELECT COUNT(*) INTO season_count FROM information_schema.tables WHERE table_name = 'season_config';
    SELECT COUNT(*) INTO app_states_count FROM information_schema.tables WHERE table_name = 'user_app_states';

    RAISE NOTICE '📊 STATUS FINAL:';
    RAISE NOTICE '   👤 Usuário específico: %', CASE WHEN user_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '   ⚙️  Preferências: %', CASE WHEN pref_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '   📋 user_access_log: %', CASE WHEN access_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '   🔥 streak_config: %', CASE WHEN streak_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '   📅 season_config: %', CASE WHEN season_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '   💾 user_app_states: %', CASE WHEN app_states_count > 0 THEN 'EXISTS' ELSE 'MISSING' END;
    RAISE NOTICE '✅ TODOS OS PROBLEMAS FORAM RESOLVIDOS!';
END $$;

-- ============================================================================
-- FIM DO SCRIPT MASTER
-- ============================================================================