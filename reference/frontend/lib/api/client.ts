/**
 * API-клиент. Использует автогенерённые типы из ./types.ts.
 * Перегенерация: ../../scripts/gen-types.sh из корня проекта.
 */

const API_BASE = process.env.NEXT_PUBLIC_API_URL || '/api';

export class ApiError extends Error {
  constructor(public status: number, public code: string, message: string) {
    super(message);
    this.name = 'ApiError';
  }
}

export async function api<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers || {}),
    },
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ code: 'unknown', message: response.statusText }));
    throw new ApiError(response.status, error.code || 'unknown', error.message || response.statusText);
  }

  if (response.status === 204) return undefined as T;
  return response.json();
}
