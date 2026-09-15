import { User } from '../types/user';
import { mockStore } from '../mock/initialStore';

export interface LoginResponse {
  token: string;
  user: User;
  tenantId: string;
  organizationId: string;
}

export const authService = {
  async login(email: string, _password?: string): Promise<LoginResponse> {
    await new Promise((res) => setTimeout(res, 250)); // realistic network delay
    const user = mockStore.data.users.find((u) => u.email.toLowerCase() === email.toLowerCase());
    
    if (!user) {
      throw new Error('Invalid email or password. Please check your credentials.');
    }

    if (user.status !== 'ACTIVE') {
      throw new Error('Account is suspended or inactive. Contact your administrator.');
    }

    // Simulate JWT token
    const token = `mock-jwt-token-${user.id}-${Date.now()}`;
    return {
      token,
      user,
      tenantId: user.tenantId,
      organizationId: user.organizationId,
    };
  },

  async getCurrentUser(userId: string): Promise<User | null> {
    await new Promise((res) => setTimeout(res, 100));
    const user = mockStore.data.users.find((u) => u.id === userId);
    return user || null;
  },

  async logout(): Promise<void> {
    await new Promise((res) => setTimeout(res, 100));
  },
};
