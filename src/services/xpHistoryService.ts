// src/services/xpHistoryService.ts
// Serviço para registrar e recuperar histórico de XP por usuário no Supabase

import type { XpHistory } from '@/types/player';
import { supabase } from '@/lib/supabase';

// Função para obter o histórico de XP de um usuário do Supabase
export async function getUserXpHistory(userId: string): Promise<XpHistory[]> {
  try {
    const { data, error } = await supabase
      .from('xp_history')
      .select('*')
      .eq('playerId', userId)
      .order('date', { ascending: false });
    
    if (error) {
      console.error('Erro ao buscar histórico de XP:', error);
      throw error;
    }
    
    return data as XpHistory[];
  } catch {
    return [];
  }
}

// Função para adicionar um registro de XP ao Supabase
export async function addXpHistory(entry: XpHistory): Promise<void> {
  try {
    const { error } = await supabase
      .from('xp_history')
      .insert([entry]);
    
    if (error) throw error;
  } catch (error) {
    console.error('Erro ao adicionar histórico de XP:', error);
    throw error;
  }
}

// Função para adicionar um registro simples de XP
export async function addSimpleXpHistory(
  userId: string,
  xp: number,
  source: XpHistory['source'],
  description: string,
  opts?: { taskId?: string; missionId?: string; dateIso?: string }
): Promise<void> {
  const entry: XpHistory = {
    id: `xph_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`,
    playerId: userId,
    date: opts?.dateIso || new Date().toISOString(),
    xp,
    source,
    description,
    taskId: opts?.taskId,
    missionId: opts?.missionId,
  };
  
  await addXpHistory(entry);
}