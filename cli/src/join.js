import { log, run, runQuiet, checkPrerequisites } from './utils.js';
import prompts from 'prompts';
import { readFileSync, existsSync } from 'node:fs';
import { resolve, basename } from 'node:path';

export async function joinProject(repoUrl) {
  log.step(`vibeco join ${repoUrl}`);

  await checkPrerequisites();

  // 1. Clone
  const repoName = basename(repoUrl, '.git');
  const targetDir = resolve(process.cwd(), repoName);

  if (!existsSync(targetDir)) {
    log.info('Клонирование репозитория...');
    await run('git', ['clone', repoUrl, repoName]);
  } else {
    log.warn(`Папка ${repoName} уже есть, пропускаю клонирование.`);
  }
  process.chdir(targetDir);

  // 2. Install Claude if missing
  try {
    await runQuiet('claude', ['--version']);
  } catch {
    log.info('Устанавливаю Claude Code...');
    await run('npm', ['i', '-g', '@anthropic-ai/claude-code']);
  }

  // 3. Install plugins
  log.info('Установка плагинов...');
  const plugins = ['superpowers', 'claude-mem', 'context7', 'reflexion', 'github'];
  for (const plugin of plugins) {
    try {
      await run('claude', ['plugin', 'install', plugin]);
    } catch {
      log.warn(`Не удалось автоматически поставить ${plugin}.`);
    }
  }

  // 4. Read docs/plan.md, find devs
  if (!existsSync('docs/plan.md')) {
    log.err('docs/plan.md не найден. Возможно, этот репо ещё не прошёл /decompose.');
    log.info('Запусти Claude и пройдись по конвейеру intake → spec → decompose.');
    process.exit(1);
  }

  const planContent = readFileSync('docs/plan.md', 'utf-8');
  const devs = [...planContent.matchAll(/^### Dev #(\d+) — (\S+)/gm)].map(([, n, name]) => ({
    n: parseInt(n, 10),
    name,
  }));

  if (devs.length === 0) {
    log.err('Не нашёл секций "### Dev #N — name" в docs/plan.md.');
    process.exit(1);
  }

  // 5. Prompt: who are you?
  const response = await prompts({
    type: 'select',
    name: 'dev',
    message: 'Кто из них ты?',
    choices: devs.map((d) => ({
      title: `Dev #${d.n} — ${d.name}`,
      value: d,
    })),
  });

  if (!response.dev) {
    log.err('Отменено.');
    process.exit(1);
  }

  // 6. Run claim-developer.sh
  log.info(`Заявляю себя как Dev #${response.dev.n} (${response.dev.name})...`);
  await run('bash', ['./scripts/claim-developer.sh', String(response.dev.n), response.dev.name]);

  log.step('Готово!');
  log.ok(`Ты Dev #${response.dev.n}.`);
  log.info('Запусти claude и скажи «погнали».');
}
