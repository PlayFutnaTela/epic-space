-- Script para corrigir a tabela user_preferences
-- Adiciona a coluna 'preferences' que está faltando

-- Adicionar coluna preferences do tipo JSONB para armazenar configurações complexas
ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS preferences JSONB DEFAULT '{}'::jsonb;

-- Adicionar coluna updated_at se não existir
ALTER TABLE user_preferences
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Atualizar a política RLS para permitir acesso à nova coluna
-- (A política existente já cobre isso, mas vamos garantir)
DROP POLICY IF EXISTS "Users can manage own preferences" ON user_preferences;
CREATE POLICY "Users can manage own preferences" ON user_preferences
FOR ALL USING (auth.uid() = user_id);

-- Adicionar comentário explicativo
COMMENT ON COLUMN user_preferences.preferences IS 'Configurações complexas do usuário armazenadas como JSONB';
COMMENT ON COLUMN user_preferences.updated_at IS 'Última atualização das preferências';