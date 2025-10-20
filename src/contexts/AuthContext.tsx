/**
 * Context de Autenticação
 * Gerencia o estado de autenticação da aplicação
 */

import React, { createContext, useContext, useEffect, useState } from 'react';
import { authService, User, AuthResponse } from '@/services/authService';
import { useToast } from '@/hooks/use-toast';
import { addStreakAwardIfNeeded } from '@/config/streak';
import { supabase } from '@/lib/supabase';
import { addSimpleXpHistory } from '@/services/xpHistoryService';

interface AuthContextValue {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<AuthResponse>;
  logout: () => Promise<void>;
  register: (email: string, password: string, name: string) => Promise<AuthResponse>;
  updateProfile: (updates: Partial<User>) => Promise<AuthResponse>;
  refreshUser: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

interface AuthProviderProps {
  children: React.ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const { toast } = useToast();

  // Verifica autenticação ao carregar
  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Verifica se o usuário está autenticado usando método síncrono
        if (authService.isAuthenticatedSync()) {
          // Tenta obter o usuário atual usando método síncrono
          const currentUser = authService.getCurrentUserSync();
          if (currentUser) {
            setUser(currentUser);
          }
        }
      } catch (error) {
        console.error('❌ Erro ao verificar autenticação:', error);
        // Não lança erro, apenas continua com user = null
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();

    // Listener para mudanças de autenticação do Supabase (para sincronizar dados entre abas)
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_OUT') {
        setUser(null);
      } else if (event === 'TOKEN_REFRESHED' && session && session.user) {
        // Atualiza o usuário quando o token for atualizado
        const updatedUser = {
          id: session.user.id,
          email: session.user.email || '',
          name: session.user.user_metadata?.name || session.user.email || '',
          role: session.user.user_metadata?.role || 'user',
          firstName: session.user.user_metadata?.firstName,
          lastName: session.user.user_metadata?.lastName,
          position: session.user.user_metadata?.position,
          avatar: session.user.user_metadata?.avatar
        };
        setUser(updatedUser);
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  const login = async (email: string, password: string): Promise<AuthResponse> => {
    setIsLoading(true);
    
    try {
      const response = await authService.login(email, password);
      
      if (response.success && response.user) {
        setUser(response.user);
        toast({
          title: "✅ Login realizado com sucesso!",
          description: `Bem-vindo, ${response.user.name}!`,
          className:
            "bg-gradient-to-r from-[#6A0DAD] to-[#FF0066] border-none text-white rounded-md shadow-lg",
          duration: 3000,
        });

        // Bônus diário de streak (uma vez por dia)
        try {
          const res = await addStreakAwardIfNeeded(response.user.id);
          if (res.awarded && res.xp > 0) {
            // Registrar no histórico de XP
            try {
              await addSimpleXpHistory(response.user.id, res.xp, 'streak', 'Bônus diário de login (streak)');
            } catch {}
            toast({
              title: "🔥 Streak diário!",
              description: `Você ganhou +${res.xp} XP por seu login de hoje.`,
              className:
                "bg-gradient-to-r from-[#6A0DAD] to-[#FF0066] border-none text-white rounded-md shadow-lg",
              duration: 3000,
            });
          }
        } catch {}
      } else {
        toast({
          title: "Erro no login",
          description: response.error || "Erro desconhecido",
          variant: "destructive",
        });
      }
      
      return response;
    } catch (error) {
      const errorMessage = "Erro interno do servidor";
      toast({
        title: "Erro no login",
        description: errorMessage,
        variant: "destructive",
      });
      
      return {
        success: false,
        error: errorMessage
      };
    } finally {
      setIsLoading(false);
    }
  };

  const logout = async () => {
    await authService.logout();
    setUser(null);
    toast({
      title: "Logout realizado",
      description: "Você foi desconectado com sucesso.",
    });
  };

  const register = async (email: string, password: string, name: string): Promise<AuthResponse> => {
    setIsLoading(true);
    
    try {
      const response = await authService.register(email, password, name);
      
      if (response.success && response.user) {
        setUser(response.user);
        toast({
          title: "Cadastro realizado com sucesso!",
          description: `Bem-vindo, ${response.user.name}!`,
        });
      } else {
        toast({
          title: "Erro no cadastro",
          description: response.error || "Erro desconhecido",
          variant: "destructive",
        });
      }
      
      return response;
    } catch (error) {
      const errorMessage = "Erro interno do servidor";
      toast({
        title: "Erro no cadastro",
        description: errorMessage,
        variant: "destructive",
      });
      
      return {
        success: false,
        error: errorMessage
      };
    } finally {
      setIsLoading(false);
    }
  };

  const updateProfile = async (updates: Partial<User>): Promise<AuthResponse> => {
    if (!user) {
      return {
        success: false,
        error: 'Usuário não autenticado'
      };
    }

    setIsLoading(true);
    
    try {
      const response = await authService.updateProfile(user.id, updates);
      
      if (response.success && response.user) {
        setUser(response.user);
        toast({
          title: "✅ Perfil atualizado",
          description: "Suas informações foram atualizadas com sucesso.",
          className:
            "bg-gradient-to-r from-[#6A0DAD] to-[#FF0066] border-none text-white rounded-md shadow-lg",
          duration: 3000,
        });
      } else {
        toast({
          title: "Erro ao atualizar perfil",
          description: response.error || "Ocorreu um erro inesperado.",
          variant: "destructive",
        });
      }
      
      return response;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Erro desconhecido';
      toast({
        title: "Erro ao atualizar perfil",
        description: errorMessage,
        variant: "destructive",
      });
      
      return {
        success: false,
        error: errorMessage
      };
    } finally {
      setIsLoading(false);
    }
  };

  // Método para recarregar dados do usuário do Supabase
  const refreshUser = async () => {
    if (authService.isAuthenticated()) {
      const currentUser = await authService.getCurrentUserAsync();
      setUser(currentUser);
    }
  };

  const value: AuthContextValue = {
    user,
    isAuthenticated: !!user,
    isLoading,
    login,
    logout,
    register,
    updateProfile,
    refreshUser
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
};