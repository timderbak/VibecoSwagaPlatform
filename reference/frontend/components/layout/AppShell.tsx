/**
 * AppShell — общий каркас всех страниц.
 *
 * Это общая зона. Менять навигацию (добавлять модули, переименовывать)
 * только через RFC-PR с аппрувом всех CODEOWNERS.
 *
 * Структура:
 *   ┌──────────────────────────────────────────┐
 *   │   Header (бренд + user-menu)             │
 *   ├─────────┬────────────────────────────────┤
 *   │ Sidebar │   <main>                       │
 *   │ (nav)   │   children                     │
 *   │         │                                │
 *   └─────────┴────────────────────────────────┘
 */

import Link from 'next/link';
import { type ReactNode } from 'react';

const NAV_ITEMS = [
  { href: '/projects', label: 'Проекты', module: 'projects' },
  { href: '/finances', label: 'Финансы', module: 'finances' },
  { href: '/profile', label: 'Профиль', module: 'profile' },
  // Добавляются на module-init нового модуля через RFC-PR
];

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen flex flex-col">
      <header className="border-b bg-card">
        <div className="container flex h-16 items-center justify-between px-6">
          <Link href="/" className="text-lg font-semibold">
            VibecoSwaga
          </Link>
          <nav className="text-sm text-muted-foreground">
            <Link href="/profile" className="hover:text-foreground">
              Account
            </Link>
          </nav>
        </div>
      </header>

      <div className="flex flex-1">
        <aside className="w-56 border-r bg-card">
          <nav className="p-4 space-y-1">
            {NAV_ITEMS.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="block rounded-md px-3 py-2 text-sm hover:bg-accent hover:text-accent-foreground"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </aside>

        <main className="flex-1 p-8">{children}</main>
      </div>
    </div>
  );
}
