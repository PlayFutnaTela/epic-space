-- Script de emergência para corrigir erro da coluna state_key
-- Execute este script APÓS o script principal se ainda houver erro

-- ============================================================================
-- 1. VERIFICAR E RECRIAR TABELA user_app_states
-- ============================================================================

-- Primeiro, vamos dropar a tabela se ela existir com estrutura incorreta
DROP TABLE IF EXISTS user_app_states CASCADE;

-- Recriar a tabela com a estrutura correta
CREATE TABLE user_app_states (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    state_key TEXT NOT NULL,
    state_value JSONB,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, state_key)
);

-- ============================================================================
-- 2. CRIAR ÍNDICE PARA PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_user_app_states_user_key ON user_app_states(user_id, state_key);

-- ============================================================================
-- 3. HABILITAR RLS E CRIAR POLÍTICA
-- ============================================================================

ALTER TABLE user_app_states ENABLE ROW LEVEL SECURITY;

-- Política de segurança
CREATE POLICY "Users can manage own app states" ON user_app_states
FOR ALL USING (auth.uid() = user_id);

-- ============================================================================
-- 4. CRIAR TRIGGER PARA UPDATED_AT
-- ============================================================================

-- Função para atualizar updated_at (se não existir)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para user_app_states
CREATE TRIGGER update_user_app_states_updated_at
    BEFORE UPDATE ON user_app_states
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 5. VERIFICAÇÃO
-- ============================================================================

-- Verificar se a tabela foi criada corretamente
DO $$
BEGIN
    -- Verificar se a tabela existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = 'public'
        AND table_name = 'user_app_states'
    ) THEN
        RAISE EXCEPTION 'Tabela user_app_states não foi criada!';
    END IF;

    -- Verificar se a coluna state_key existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'user_app_states'
        AND column_name = 'state_key'
    ) THEN
        RAISE EXCEPTION 'Coluna state_key não foi criada!';
    END IF;

    RAISE NOTICE '✅ Tabela user_app_states criada com sucesso!';
    RAISE NOTICE '✅ Coluna state_key criada corretamente!';
END $$;

-- ============================================================================
-- 6. TESTE DE INSERÇÃO (opcional)
-- ============================================================================

-- Teste básico (descomente se quiser testar)
-- INSERT INTO user_app_states (user_id, state_key, state_value)
-- VALUES ('00000000-0000-0000-0000-000000000000', 'test_key', '{"test": "value"}'::jsonb)
-- ON CONFLICT DO NOTHING;

-- SELECT * FROM user_app_states WHERE state_key = 'test_key';

-- ============================================================================
-- FIM DO SCRIPT DE EMERGÊNCIA
-- ============================================================================

COMMENT ON TABLE user_app_states IS 'Estados da aplicação salvos por usuário para sincronização';