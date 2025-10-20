import { describe, it, expect, beforeEach } from 'vitest';
import { saveTasksData, getGamificationTasks } from '@/services/localStorageData';
import { getUserXpHistory } from '@/services/xpHistoryService';
import { getSystemUsers } from '@/services/supabaseUserService';
import type { TaskData } from '@/data/projectData';

describe('XP History delta on task completion', () => {
  beforeEach(async () => {
    // Reset relevant storage between tests
    // No longer using localStorage - data comes from Supabase
    // Ensure test user exists in Supabase for tests
    // In a real scenario, we would seed test data for each test
  });

  it('records positive XP delta when a task becomes completed', async () => {
    // Obter o ID real do usuário do Supabase
    const users = await getSystemUsers();
    const testUser = users.find(u => u.name === 'Gabriel') || users[0] || { id: 'u1', name: 'Test User', email: 'test@example.com' };
    const userId = testUser.id;

    const base: TaskData = {
      id: 1,
      tarefa: 'Implementar feature X',
      responsavel: testUser.name,
      descricao: 'Teste de conclusão',
      inicio: '2025-01-01',
      prazo: '2025-01-10',
      fim: '',
      duracaoDiasUteis: 0,
      atrasoDiasUteis: 0,
      atendeuPrazo: true,
      status: 'in-progress',
      prioridade: 'media',
    };

    // First save: not completed yet -> no XP history
    saveTasksData([base]);
    expect(getUserXpHistory(userId).length).toBe(0);

    // Second save: mark as completed before the deadline
    const completed: TaskData = {
      ...base,
      fim: '2025-01-09',
      atendeuPrazo: true,
      status: 'completed',
      duracaoDiasUteis: 7,
      atrasoDiasUteis: 0,
    };
    saveTasksData([completed]);

    const hist = getUserXpHistory(userId);
    expect(hist.length).toBe(1);
    expect(hist[0].xp).toBeGreaterThan(0);
    expect(hist[0].source).toBe('task');
    // Friendly description should include a completion hint
    expect(hist[0].description.toLowerCase()).toContain('tarefa');

    // Gamification tasks should reflect completion
    const gamTasks = getGamificationTasks();
    expect(gamTasks.length).toBe(1);
    expect(gamTasks[0].status).toBe('completed');
    expect(gamTasks[0].assignedTo).toBe(userId);

    // Idempotency: saving again without changes should not add a new entry
    saveTasksData([completed]);
    const hist2 = getUserXpHistory(userId);
    expect(hist2.length).toBe(1);
  });
});
