# ✅ CHECKLIST DE VERIFICAÇÃO - CORREÇÕES SUPABASE

## 1️⃣ Verificação de Ambiente

- [ ] `.env` contém `VITE_SUPABASE_URL`
- [ ] `.env` contém `VITE_SUPABASE_ANON_KEY`
- [ ] Dev server reiniciado após mudanças em `.env`
- [ ] Cache do navegador limpo (Ctrl+Shift+Delete)

## 2️⃣ Verificação de Imports

**Centralizados em `src/lib/supabase.ts`:**
- [ ] `src/services/authService.ts` importa de `@/lib/supabase`
- [ ] `src/services/localStorageData.ts` importa de `@/lib/supabase`
- [ ] `src/services/appStateManager.ts` importa de `@/lib/supabase`
- [ ] Nenhum arquivo importa `createClient` de `@supabase/supabase-js`

## 3️⃣ Verificação de Compilação

```bash
# Execute na raiz do projeto:
npm run build
```

- [ ] Build concluída sem erros
- [ ] Sem avisos de tipos TypeScript
- [ ] Todos os imports resolvidos

## 4️⃣ Testes Funcionais

### Login/Autenticação
- [ ] Página de login carrega sem erros
- [ ] Login com usuário válido funciona
- [ ] Redirecionamento após login funciona
- [ ] Logout funciona
- [ ] Refresh mantém sessão

### Console do Navegador (F12 → Console)
- [ ] ✅ **NÃO** há aviso: "Multiple GoTrueClient instances detected"
- [ ] ✅ **NÃO** há erro: "Cannot read properties of undefined (reading 'session')"
- [ ] ✅ Mensagens de erro claras se houver problemas

### Sincronização Entre Abas
- [ ] Abra a aplicação em 2 abas diferentes
- [ ] Faça login em uma aba
- [ ] Outra aba deve sincronizar automaticamente
- [ ] Logout em uma aba atualiza a outra

### Error Boundary
- [ ] Error Boundary está visível em `<App>`
- [ ] Página de erro aparece se houver crash
- [ ] Botão "Tentar Novamente" funciona
- [ ] Modo desenvolvimento mostra stack trace

## 5️⃣ Verificação de Funcionalidade

### Gamificação
- [ ] XP calcula corretamente
- [ ] Ranking atualiza
- [ ] Missions disparam
- [ ] Streaks registram

### DataContext
- [ ] Tarefas carregam do Supabase
- [ ] Tarefas podem ser criadas
- [ ] Tarefas podem ser editadas
- [ ] Tarefas podem ser deletadas

### Settings
- [ ] Configurações carregam
- [ ] Configurações salvam
- [ ] Tabela de usuários exibe dados
- [ ] Sem erros async/await

## 6️⃣ Performance

```javascript
// No console, execute:
performance.getEntriesByType("resource")
  .filter(r => r.name.includes("supabase"))
  .forEach(r => console.log(r.name, r.duration + "ms"))
```

- [ ] Uma única instância do cliente supabase
- [ ] Sem requisições duplicadas
- [ ] Tempos de resposta razoáveis

## 7️⃣ Segurança

- [ ] Chave anônima está em variáveis de ambiente
- [ ] Sem keys expostas no código
- [ ] RLS policies ativadas no Supabase
- [ ] Service role key não está no `.env`

## 8️⃣ Logs

**O projeto deve exibir:**
- ✅ Logs claros de erro em caso de problema
- ✅ Recuperação graceful em caso de falha
- ✅ Sem crashes inesperados

## ✅ STATUS FINAL

- [ ] Todos os itens acima verificados
- [ ] Aplicação funcionando sem erros
- [ ] Pronto para produção

---

## 🆘 Problemas Comuns

### "Multiple GoTrueClient instances detected"
```
Solução: 
1. Limpe cache: Ctrl+Shift+Delete
2. Reinicie dev server: npm run dev
3. Verifique que todos imports usam @/lib/supabase
```

### "Cannot read properties of undefined (reading 'session')"
```
Solução:
1. Verifique .env tem VITE_SUPABASE_URL
2. Reinicie dev server
3. Limpe console e reload
```

### "Configuração do Supabase incompleta"
```
Solução:
1. Adicione variáveis em .env
2. Use .env.example como referência
3. Reinicie dev server
```

### Error Boundary mostrando erro
```
Solução:
1. Verifique console para stack trace
2. Se em DEV, mostra detalhes
3. Clique "Tentar Novamente" para reload
```

---

## 📞 Suporte

Se o problema persistir:
1. Verifique logs do Supabase: app.supabase.com → Logs
2. Verifique RLS policies estão ativas
3. Teste conexão com curl:
```bash
curl -H "Authorization: Bearer TOKEN" \
  https://seu-projeto.supabase.co/rest/v1/users
```

✅ **Quando tudo estiver verificado, o sistema está pronto para uso!**
