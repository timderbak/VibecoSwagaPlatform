import { run, runQuiet, log } from './utils.js';
import { readFileSync, existsSync } from 'node:fs';

export async function requestCrossZone(filePath, reason) {
  log.step(`vibeco request-cross-zone ${filePath}`);

  // Determine owner from CODEOWNERS
  if (!existsSync('.github/CODEOWNERS')) {
    log.err('.github/CODEOWNERS не найден.');
    process.exit(1);
  }

  const codeowners = readFileSync('.github/CODEOWNERS', 'utf-8');
  const lines = codeowners.split('\n').filter((l) => l.trim() && !l.startsWith('#'));
  let owners = [];
  for (const line of lines) {
    const [pattern, ...handlers] = line.trim().split(/\s+/);
    // Простое сопоставление префикса
    if (filePath.startsWith(pattern.replace(/^\//, '').replace(/\*\*$/, ''))) {
      owners = handlers;
      break;
    }
  }

  if (owners.length === 0) {
    log.warn(`Не нашёл владельца для ${filePath} в CODEOWNERS.`);
    owners = ['@team'];
  }

  // Self
  let me = '';
  if (existsSync('DEVELOPER.local.md')) {
    const dev = readFileSync('DEVELOPER.local.md', 'utf-8');
    const m = dev.match(/^# Я — (Dev #\d+) \((.+)\)/m);
    if (m) me = `${m[1]} (${m[2]})`;
  }

  const title = `[cross-zone] ${me} → ${owners.join(' ')}: ${filePath}`;
  const body = `**Запрос на изменение в чужой/общей зоне.**

Файл: \`${filePath}\`
Причина: ${reason}

Владельцы (CODEOWNERS): ${owners.join(', ')}

---

Когда сделаете — закройте этот issue с упоминанием PR (\`Closes #<этот номер>\`).

🤖 Создано через vibeco request-cross-zone`;

  await run('gh', [
    'issue', 'create',
    '--title', title,
    '--body', body,
    '--label', 'cross-zone-request',
    ...owners.flatMap((o) => ['--assignee', o.replace(/^@/, '')]),
  ]);

  log.ok('Cross-zone request создан.');
}
