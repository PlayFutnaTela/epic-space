-- Script ultra-simples para corrigir erro da coluna state_key
-- Execute este script se o erro persistir

-- Verificar se a tabela existe e tem a estrutura correta
DO $$
BEGIN
    -- Se a tabela não existe, criar ela
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'user_app_states'
    ) THEN
        -- Criar tabela
        CREATE TABLE user_app_states (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            state_key TEXT NOT NULL,
            state_value JSONB,
            last_updated TIMESTAMPTZ DEFAULT NOW(),
            UNIQUE(user_id, state_key)
        );

        -- Criar índice
        CREATE INDEX idx_user_app_states_user_key ON user_app_states(user_id, state_key);

        -- Habilitar RLS
        ALTER TABLE user_app_states ENABLE ROW LEVEL SECURITY;

        -- Criar política
        CREATE POLICY "Users can manage own app states" ON user_app_states
        FOR ALL USING (auth.uid() = user_id);

        RAISE NOTICE '✅ Tabela user_app_states criada com sucesso!';

    ELSE
        -- Se a tabela existe, verificar se tem a coluna state_key
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_name = 'user_app_states'
            AND column_name = 'state_key'
        ) THEN
            -- Adicionar coluna faltante
            ALTER TABLE user_app_states ADD COLUMN state_key TEXT NOT NULL DEFAULT 'default';
            ALTER TABLE user_app_states ADD CONSTRAINT unique_user_state_key UNIQUE(user_id, state_key);

            RAISE NOTICE '✅ Coluna state_key adicionada com sucesso!';
        ELSE
            RAISE NOTICE '✅ Tabela user_app_states já está correta!';
        END IF;
    END IF;
END $$;

-- Verificação final
SELECT
    'user_app_states' as table_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public' AND table_name = 'user_app_states'
    ) THEN 'EXISTS' ELSE 'MISSING' END as table_status,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_app_states' AND column_name = 'state_key'
    ) THEN 'EXISTS' ELSE 'MISSING' END as state_key_column,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_app_states' AND column_name = 'user_id'
    ) THEN 'EXISTS' ELSE 'MISSING' END as user_id_column;