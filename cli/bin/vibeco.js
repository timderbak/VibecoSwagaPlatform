#!/usr/bin/env node
import { Command } from 'commander';
import { initProject } from '../src/init.js';
import { joinProject } from '../src/join.js';
import { showStatus } from '../src/status.js';
import { createPR } from '../src/pr.js';
import { requestCrossZone } from '../src/request-cross-zone.js';
import { syncSummary } from '../src/sync-summary.js';
import { reflect } from '../src/reflect.js';

const program = new Command();

program
  .name('vibeco')
  .description('CLI для VibecoSwaga template')
  .version('0.1.0');

program
  .command('init')
  .description('Создать новый проект из шаблона')
  .argument('<name>', 'Имя проекта (станет именем GitHub-репо)')
  .option('--stack <stack>', 'Стек: fastapi | blank', 'fastapi')
  .option('--private', 'Создать приватный репозиторий', true)
  .option('--public', 'Создать публичный репозиторий')
  .action(initProject);

program
  .command('join')
  .description('Подключиться к существующему проекту как Dev #N')
  .argument('<repo-url>', 'URL GitHub-репозитория (SSH или HTTPS)')
  .action(joinProject);

program
  .command('status')
  .description('Показать сводный статус: ветка, PR, входящие cross-zone, reflexion')
  .action(showStatus);

program
  .command('pr')
  .description('Pre-PR check + push + создать PR + auto-merge')
  .action(createPR);

program
  .command('request-cross-zone')
  .description('Запросить изменение в чужой зоне через GitHub-issue')
  .argument('<path>', 'Путь файла, который нужно изменить')
  .argument('<reason>', 'Причина — что и зачем менять')
  .action(requestCrossZone);

program
  .command('sync-summary')
  .description('Агрегат статуса по всем разработчикам для еженедельного созвона')
  .action(syncSummary);

program
  .command('reflect')
  .description('Запустить reflexion на коммите (вызывается из GitHub Action)')
  .argument('<commit-sha>', 'SHA коммита для анализа')
  .action(reflect);

program.parseAsync(process.argv);
