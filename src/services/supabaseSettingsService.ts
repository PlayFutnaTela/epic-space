import { supabase } from '@/lib/supabase';

// Interface para as configurações de produtividade
export interface ProductivityConfig {
  early: number;
  on_time: number;
  late: number;
  refacao: number;
}

// Interface para as configurações de temporada
export interface SeasonConfig {
  name: string;
  description: string;
  startIso: string;
  endIso: string;
}

// Interface para as configurações de missão
export interface MissionConfig {
  name: string;
  description: string;
  type: 
    | 'complete_tasks'           // Completar N tarefas
    | 'complete_early'           // Completar N tarefas adiantadas
    | 'attend_meetings'          // Participar de N reuniões
    | 'review_peer_tasks'        // Revisar N tarefas de colegas
    | 'streak_days'              // Manter sequência por N dias
    | 'no_delays'                // Não atrasar nenhuma tarefa
    | 'high_effort_tasks';       // Completar tarefas de alta dificuldade
  target: number;
  xpReward: number;
  frequency: 'daily' | 'weekly' | 'monthly';
  start: string;
  end: string;
  continuous: boolean;
  active: boolean;
}

// Interface para as configurações de streak
export interface StreakConfig {
  dailyXp: number;
  enabled: boolean;
  includeTotal: boolean;
  includeWeekly: boolean;
  includeMonthly: boolean;
}

// Funções para buscar configurações do Supabase
export async function getProductivityConfig(): Promise<ProductivityConfig> {
  try {
    const { data, error } = await supabase
      .from('system_settings')
      .select('config_value')
      .eq('config_key', 'productivity_config')
      .single();

    if (error) {
      console.warn('Erro ao buscar configurações de produtividade:', error);
      // Retorna valores padrão
      return {
        early: 110,
        on_time: 100,
        late: 50,
        refacao: 40
      };
    }

    return data ? JSON.parse(data.config_value) : {
      early: 110,
      on_time: 100,
      late: 50,
      refacao: 40
    };
  } catch (error) {
    console.error('Erro ao parsear configurações de produtividade:', error);
    return {
      early: 110,
      on_time: 100,
      late: 50,
      refacao: 40
    };
  }
}

export async function getMissionList(): Promise<MissionConfig[]> {
  try {
    const { data, error } = await supabase
      .from('system_settings')
      .select('config_value')
      .eq('config_key', 'mission_list')
      .single();

    if (error) {
      console.warn('Erro ao buscar lista de missões:', error);
      return [];
    }

    return data ? JSON.parse(data.config_value) : [];
  } catch (error) {
    console.error('Erro ao parsear lista de missões:', error);
    return [];
  }
}

export async function getSeasonList(): Promise<SeasonConfig[]> {
  try {
    const { data, error } = await supabase
      .from('system_settings')
      .select('config_value')
      .eq('config_key', 'season_list')
      .single();

    if (error) {
      console.warn('Erro ao buscar lista de temporadas:', error);
      return [];
    }

    return data ? JSON.parse(data.config_value) : [];
  } catch (error) {
    console.error('Erro ao parsear lista de temporadas:', error);
    return [];
  }
}

export async function getStreakConfig(): Promise<StreakConfig> {
  try {
    const { data, error } = await supabase
      .from('system_settings')
      .select('config_value')
      .eq('config_key', 'streak_config')
      .single();

    if (error) {
      console.warn('Erro ao buscar configurações de streak:', error);
      // Retorna valores padrão
      return {
        dailyXp: 5,
        enabled: true,
        includeTotal: true,
        includeWeekly: false,
        includeMonthly: false
      };
    }

    return data ? JSON.parse(data.config_value) : {
      dailyXp: 5,
      enabled: true,
      includeTotal: true,
      includeWeekly: false,
      includeMonthly: false
    };
  } catch (error) {
    console.error('Erro ao parsear configurações de streak:', error);
    return {
      dailyXp: 5,
      enabled: true,
      includeTotal: true,
      includeWeekly: false,
      includeMonthly: false
    };
  }
}

// Funções para salvar configurações no Supabase
export async function saveProductivityConfig(config: ProductivityConfig): Promise<void> {
  try {
    const { error } = await supabase
      .from('system_settings')
      .upsert({
        config_key: 'productivity_config',
        config_value: JSON.stringify(config),
        updated_at: new Date().toISOString()
      }, { onConflict: 'config_key' });

    if (error) {
      console.error('Erro ao salvar configurações de produtividade:', error);
      throw error;
    }
  } catch (error) {
    console.error('Erro ao salvar configurações de produtividade:', error);
    throw error;
  }
}

export async function saveMissionList(missions: MissionConfig[]): Promise<void> {
  try {
    const { error } = await supabase
      .from('system_settings')
      .upsert({
        config_key: 'mission_list',
        config_value: JSON.stringify(missions),
        updated_at: new Date().toISOString()
      }, { onConflict: 'config_key' });

    if (error) {
      console.error('Erro ao salvar lista de missões:', error);
      throw error;
    }
  } catch (error) {
    console.error('Erro ao salvar lista de missões:', error);
    throw error;
  }
}

export async function saveSeasonList(seasons: SeasonConfig[]): Promise<void> {
  try {
    const { error } = await supabase
      .from('system_settings')
      .upsert({
        config_key: 'season_list',
        config_value: JSON.stringify(seasons),
        updated_at: new Date().toISOString()
      }, { onConflict: 'config_key' });

    if (error) {
      console.error('Erro ao salvar lista de temporadas:', error);
      throw error;
    }
  } catch (error) {
    console.error('Erro ao salvar lista de temporadas:', error);
    throw error;
  }
}

export async function saveStreakConfig(config: StreakConfig): Promise<void> {
  try {
    const { error } = await supabase
      .from('system_settings')
      .upsert({
        config_key: 'streak_config',
        config_value: JSON.stringify(config),
        updated_at: new Date().toISOString()
      }, { onConflict: 'config_key' });

    if (error) {
      console.error('Erro ao salvar configurações de streak:', error);
      throw error;
    }
  } catch (error) {
    console.error('Erro ao salvar configurações de streak:', error);
    throw error;
  }
}