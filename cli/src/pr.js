import { run, runQuiet, log } from './utils.js';

export async function createPR() {
  log.step('vibeco pr');

  // 1. Pre-checks
  log.info('1. Проверяю незакоммиченные изменения...');
  const { stdout: porcelain } = await runQuiet('git', ['status', '--porcelain']);
  if (porcelain.trim()) {
    log.err('Есть несохранённые изменения. Закоммить или stash перед PR.');
    process.exit(1);
  }

  log.info('2. Прогон тестов в Docker...');
  try {
    await run('docker', ['compose', '-f', 'docker-compose.test.yml', 'up', '-d']);
    await run('docker', ['compose', '-f', 'docker-compose.test.yml', 'exec', '-T', 'backend', 'alembic', 'upgrade', 'head']);
    await run('docker', ['compose', '-f', 'docker-compose.test.yml', 'exec', '-T', 'backend', 'pytest', '-v']);
    await run('docker', ['compose', '-f', 'docker-compose.test.yml', 'exec', '-T', 'frontend', 'npm', 'test']);
  } catch {
    log.err('Тесты не прошли. PR не создан. Чини и попробуй снова.');
    process.exit(1);
  }

  log.info('3. Линтер...');
  try {
    await run('docker', ['compose', 'exec', '-T', 'backend', 'ruff', 'check', '.']);
    await run('docker', ['compose', 'exec', '-T', 'frontend', 'npm', 'run', 'lint']);
  } catch {
    log.err('Линтер ругается. Зайди и исправь.');
    process.exit(1);
  }

  log.info('4. Rebase на main...');
  await run('git', ['fetch', 'origin', 'main']);
  try {
    await run('git', ['rebase', 'origin/main']);
  } catch {
    log.err('Конфликт при rebase. См. playbooks/08-merge-conflict.md.');
    process.exit(1);
  }

  log.info('5. Push...');
  const { stdout: branch } = await runQuiet('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  await run('git', ['push', '--force-with-lease', 'origin', branch.trim()]);

  log.info('6. Создаю PR...');
  const { stdout: log_out } = await runQuiet('git', [
    'log', 'origin/main..HEAD', '--format=- %s',
  ]);
  const body = `## Что сделано\n${log_out.trim()}\n\n🤖 Auto-generated PR via vibeco pr`;
  await run('gh', ['pr', 'create', '--title', `feat: ${branch.trim()}`, '--body', body]);

  log.info('7. Включаю auto-merge...');
  const { stdout: prNumber } = await runQuiet('gh', ['pr', 'view', '--json', 'number', '-q', '.number']);
  await run('gh', ['pr', 'merge', '--auto', '--squash', prNumber.trim()]);

  log.step('Готово!');
  log.ok(`PR #${prNumber.trim()} создан, auto-merge включён.`);
  log.info('Замержится сам, как CI зелёный + аппрувы CODEOWNERS (если требуются).');
}
