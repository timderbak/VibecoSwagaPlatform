import { execa } from 'execa';
import kleur from 'kleur';

export const log = {
  info: (msg) => console.log(kleur.cyan('→') + ' ' + msg),
  ok: (msg) => console.log(kleur.green('✓') + ' ' + msg),
  warn: (msg) => console.log(kleur.yellow('⚠') + ' ' + msg),
  err: (msg) => console.error(kleur.red('✗') + ' ' + msg),
  step: (msg) => console.log('\n' + kleur.bold(msg)),
};

export async function run(cmd, args, options = {}) {
  return execa(cmd, args, { stdio: 'inherit', ...options });
}

export async function runQuiet(cmd, args, options = {}) {
  return execa(cmd, args, { stdio: 'pipe', ...options });
}

export async function checkPrerequisites() {
  const checks = [
    { cmd: 'git', args: ['--version'], name: 'git' },
    { cmd: 'gh', args: ['--version'], name: 'gh (GitHub CLI)' },
    { cmd: 'docker', args: ['--version'], name: 'docker' },
    { cmd: 'node', args: ['--version'], name: 'node (>=20)' },
  ];
  const missing = [];
  for (const { cmd, args, name } of checks) {
    try {
      await execa(cmd, args, { stdio: 'pipe' });
    } catch {
      missing.push(name);
    }
  }
  if (missing.length > 0) {
    log.err(`Не установлены: ${missing.join(', ')}`);
    log.info('См. docs/onboarding/install.md для инструкций.');
    process.exit(1);
  }

  // gh auth
  try {
    await execa('gh', ['auth', 'status'], { stdio: 'pipe' });
  } catch {
    log.err('gh не авторизован. Запусти: gh auth login');
    process.exit(1);
  }
}
