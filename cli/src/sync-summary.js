import { runQuiet, log } from './utils.js';
import { readFileSync, existsSync } from 'node:fs';

export async function syncSummary() {
  log.step('vibeco sync-summary');

  if (!existsSync('docs/plan.md')) {
    log.err('docs/plan.md не найден.');
    process.exit(1);
  }

  const plan = readFileSync('docs/plan.md', 'utf-8');
  const devs = [...plan.matchAll(/^### Dev #(\d+) — (\S+)\s*\(@(\S+)\)/gm)].map(([, n, name, handle]) => ({
    n: parseInt(n, 10),
    name,
    handle,
  }));

  console.log('\n## Sync — ' + new Date().toISOString().slice(0, 10) + '\n');
  console.log('| Dev | Slice | Last commit | Open PRs | WPs done | WPs in flight |');
  console.log('|-----|-------|-------------|----------|----------|---------------|');

  for (const dev of devs) {
    // Find slice
    const sliceMatch = plan.match(new RegExp(`### Dev #${dev.n}[^]+?\\*\\*Slice: (\\S+)\\*\\*`));
    const slice = sliceMatch ? sliceMatch[1] : '?';

    // PRs
    const { stdout: prJson } = await runQuiet('gh', [
      'pr', 'list', '--author', dev.handle, '--state', 'open', '--json', 'number',
    ]).catch(() => ({ stdout: '[]' }));
    const openPRs = JSON.parse(prJson || '[]').length;

    // Last commit
    let lastCommit = '?';
    try {
      const { stdout } = await runQuiet('git', [
        'log', `dev/${dev.n}/${slice}`, '-1', '--format=%cr',
      ]);
      lastCommit = stdout.trim();
    } catch {
      lastCommit = 'no branch yet';
    }

    console.log(`| #${dev.n} ${dev.name} | ${slice} | ${lastCommit} | ${openPRs} | ? | ? |`);
  }

  console.log('\nСкопируй в общий чат.');
}
