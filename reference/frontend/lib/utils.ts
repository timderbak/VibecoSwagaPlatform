/**
 * cn — утилита для условных Tailwind-классов. Стандарт shadcn/ui.
 * Все компоненты в components/ui/ её используют.
 */
import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
