import { runQuiet, log } from './utils.js';
import { readFileSync, existsSync } from 'node:fs';
import kleur from 'kleur';

export async function showStatus() {
  // Branch
  const { stdout: branch } = await runQuiet('git', ['rev-parse', '--abbrev-ref', 'HEAD']);
  const { stdout: aheadBehind } = await runQuiet('git', [
    'rev-list', '--left-right', '--count', `origin/main...HEAD`,
  ]).catch(() => ({ stdout: '0\t0' }));
  const [behind, ahead] = aheadBehind.trim().split('\t');

  // Uncommitted
  const { stdout: porcelain } = await runQuiet('git', ['status', '--porcelain']);
  const uncommitted = porcelain.trim().split('\n').filter(Boolean).length;

  // PRs
  const { stdout: prs } = await runQuiet('gh', [
    'pr', 'list', '--author', '@me', '--state', 'open',
    '--json', 'number,title,statusCheckRollup',
  ]).catch(() => ({ stdout: '[]' }));
  const prsData = JSON.parse(prs || '[]');

  // Cross-zone incoming
  const { stdout: crossZone } = await runQuiet('gh', [
    'issue', 'list', '--label', 'cross-zone-request', '--assignee', '@me',
    '--json', 'number,title',
  ]).catch(() => ({ stdout: '[]' }));
  const crossZoneData = JSON.parse(crossZone || '[]');

  // Reflexion findings
  const { stdout: reflexion } = await runQuiet('gh', [
    'issue', 'list', '--label', 'reflexion-finding', '--assignee', '@me',
    '--json', 'number,title',
  ]).catch(() => ({ stdout: '[]' }));
  const reflexionData = JSON.parse(reflexion || '[]');

  // Current WP from plan + DEVELOPER.local.md
  let role = '(не определена — запусти claim-developer.sh)';
  if (existsSync('DEVELOPER.local.md')) {
    const dev = readFileSync('DEVELOPER.local.md', 'utf-8');
    const m = dev.match(/^# Я — (Dev #\d+ \(.+\))/m);
    if (m) role = m[1];
  }

  // Output
  console.log();
  console.log(kleur.bold('Status'));
  console.log(`  Роль:           ${role}`);
  console.log(`  Ветка:          ${branch.trim()} (${kleur.green('+' + ahead)}, ${kleur.red('-' + behind)} от main)`);
  console.log(`  Незакоммичено:  ${uncommitted}`);
  console.log(`  Открытых PR:    ${prsData.length}`);
  for (const pr of prsData) {
    console.log(`                  #${pr.number} — ${pr.title}`);
  }
  console.log(`  Cross-zone in:  ${crossZoneData.length}`);
  for (const i of crossZoneData) {
    console.log(`                  #${i.number} — ${i.title}`);
  }
  console.log(`  Reflexion:      ${reflexionData.length}`);
  for (const i of reflexionData) {
    console.log(`                  #${i.number} — ${i.title}`);
  }
  console.log();
}
