import { run, runQuiet, log } from './utils.js';

/**
 * Запускает Claude Code в headless-режиме со skill reflexion:critique.
 * Вызывается из GitHub Action `.github/workflows/reflexion.yml`.
 */
export async function reflect(commitSha) {
  log.step(`vibeco reflect ${commitSha}`);

  // Контекст: diff + последний коммит + спека (если есть)
  const { stdout: diff } = await runQuiet('git', ['show', '--stat', commitSha]);
  const { stdout: message } = await runQuiet('git', ['log', '-1', '--format=%s', commitSha]);

  // Запускаем headless Claude. ANTHROPIC_API_KEY должен быть в env.
  // Plugin reflexion обеспечивает скилл reflexion:critique.
  const prompt = `Запусти skill reflexion:critique на следующем коммите:

Commit: ${commitSha}
Message: ${message.trim()}

Diff:
${diff.trim()}

После анализа создай GitHub issues для каждой находки через 'gh issue create' с label 'reflexion-finding' и priority:critical/major/minor. Ассайн на автора коммита.`;

  await run('claude', ['--print', prompt], {
    env: {
      ...process.env,
      CLAUDE_HEADLESS: '1',
    },
  });

  log.ok('Reflexion завершён.');
}
