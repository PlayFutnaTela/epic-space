// src/config/season.ts
// Configuração de Temporadas (Nome, Descrição, Período)

import { supabase } from '@/lib/supabase';

export type SeasonConfig = {
  name: string;
  description: string;
  startIso: string; // ISO string (inclusive)
  endIso: string;   // ISO string (inclusive)
};

const SEASON_TABLE = 'season_config';

function startOfCurrentMonth(): Date {
  const d = new Date();
  return new Date(d.getFullYear(), d.getMonth(), 1, 0, 0, 0, 0);
}

function endOfCurrentMonth(): Date {
  const d = new Date();
  return new Date(d.getFullYear(), d.getMonth() + 1, 0, 23, 59, 59, 999);
}

export function getDefaultSeason(): SeasonConfig {
  const start = startOfCurrentMonth();
  const end = endOfCurrentMonth();
  return {
    name: `Temporada ${start.toLocaleDateString('pt-BR', { month: 'long', year: 'numeric' })}`,
    description: 'Temporada padrão (mês vigente) gerada automaticamente.',
    startIso: start.toISOString(),
    endIso: end.toISOString(),
  };
}

function isValidSeason(cfg: SeasonConfig): boolean {
  if (!cfg?.name || !cfg.startIso || !cfg.endIso) return false;
  const s = new Date(cfg.startIso).getTime();
  const e = new Date(cfg.endIso).getTime();
  return Number.isFinite(s) && Number.isFinite(e) && s <= e;
}

export async function getSeasonConfig(): Promise<SeasonConfig> {
  try {
    const { data, error } = await supabase
      .from(SEASON_TABLE)
      .select('*')
      .single();
    
    if (error) {
      console.warn('Erro ao carregar configuração de temporada, usando padrões:', error);
      return getDefaultSeason();
    }
    
    if (!data) {
      // Configuração não encontrada, retornar padrões
      return getDefaultSeason();
    }
    
    const config: SeasonConfig = {
      name: data.name,
      description: data.description,
      startIso: data.startIso,
      endIso: data.endIso,
    };
    
    return isValidSeason(config) ? config : getDefaultSeason();
  } catch (error) {
    console.error('Erro inesperado ao carregar configuração de temporada:', error);
    return getDefaultSeason();
  }
}

export async function setSeasonConfig(cfg: SeasonConfig) {
  if (!isValidSeason(cfg)) {
    throw new Error('Configuração de temporada inválida. Verifique as datas e o nome.');
  }
  
  try {
    const { error } = await supabase
      .from(SEASON_TABLE)
      .upsert({ id: 1, ...cfg }, { onConflict: 'id' }); // Assuming id=1 for the main config
    
    if (error) {
      console.error('Erro ao salvar configuração de temporada:', error);
      throw error;
    }
  } catch (error) {
    console.error('Erro inesperado ao salvar configuração de temporada:', error);
    throw error;
  }
}

export async function isInSeason(dateString?: string): Promise<boolean> {
  if (!dateString) return false;
  const cfg = await getSeasonConfig();
  const t = new Date(dateString).getTime();
  const s = new Date(cfg.startIso).getTime();
  const e = new Date(cfg.endIso).getTime();
  if (!Number.isFinite(t) || !Number.isFinite(s) || !Number.isFinite(e)) return false;
  return t >= s && t <= e;
}
