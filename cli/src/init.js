import { log, run, runQuiet, checkPrerequisites } from './utils.js';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';

const TEMPLATE_REPO = process.env.VIBECO_TEMPLATE_REPO || 'timderbak/VibecoSwagaPlatform';

export async function initProject(name, options) {
  log.step(`vibeco init ${name}`);

  await checkPrerequisites();

  const targetDir = resolve(process.cwd(), name);
  if (existsSync(targetDir)) {
    log.err(`Папка ${name} уже существует.`);
    process.exit(1);
  }

  // 1. Create GitHub repo from template
  log.info('Создаю GitHub-репозиторий из шаблона...');
  const visibility = options.public ? '--public' : '--private';
  await run('gh', [
    'repo', 'create', name,
    '--template', TEMPLATE_REPO,
    visibility,
    '--clone',
  ]);

  // 2. cd into project
  process.chdir(targetDir);
  log.ok(`Репо создан и склонирован в ${targetDir}`);

  // 3. Run init-project.sh
  log.info(`Распаковка reference (stack: ${options.stack})...`);
  await run('bash', ['./scripts/init-project.sh', options.stack]);

  // 4. Install Claude Code if missing
  try {
    await runQuiet('claude', ['--version']);
  } catch {
    log.info('Устанавливаю Claude Code...');
    await run('npm', ['i', '-g', '@anthropic-ai/claude-code']);
  }

  // 5. Install plugins
  log.info('Установка плагинов из .claude-plugins.json...');
  const plugins = ['superpowers', 'claude-mem', 'context7', 'reflexion', 'github'];
  for (const plugin of plugins) {
    try {
      await run('claude', ['plugin', 'install', plugin]);
    } catch {
      log.warn(`Не удалось автоматически поставить ${plugin}. См. docs/onboarding/install.md.`);
    }
  }

  // 6. First commit (init-project.sh внёс изменения)
  log.info('Первый коммит...');
  await run('git', ['add', '.']);
  await run('git', ['commit', '-m', 'chore: bootstrap from VibecoSwaga template']);
  await run('git', ['push']);

  // 7. Branch protection (best effort)
  log.info('Настраиваю branch protection (требует Code Owners review)...');
  try {
    await runQuiet('gh', [
      'api',
      `repos/{owner}/{repo}/branches/main/protection`,
      '-X', 'PUT',
      '-F', 'required_status_checks[strict]=true',
      '-F', 'required_status_checks[contexts][]=backend',
      '-F', 'required_status_checks[contexts][]=frontend',
      '-F', 'enforce_admins=false',
      '-F', 'required_pull_request_reviews[required_approving_review_count]=1',
      '-F', 'required_pull_request_reviews[require_code_owner_reviews]=true',
      '-F', 'restrictions=',
    ]);
    log.ok('Branch protection включён.');
  } catch {
    log.warn('Не удалось включить branch protection автоматически. Включи вручную в Settings → Branches.');
  }

  log.step('Готово!');
  log.ok(`Проект ${name} создан.`);
  log.info(`cd ${name} && claude`);
  log.info('В Claude скажи: «погнали».');
}
