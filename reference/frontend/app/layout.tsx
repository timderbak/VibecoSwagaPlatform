import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'VibecoSwaga',
  description: 'Reference Next.js app',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ru">
      <body className="antialiased">{children}</body>
    </html>
  );
}
