# @vibecoswaga/cli

CLI-обёртка для VibecoSwaga template. Автоматизирует init проектов, подключение разработчиков и автопилот git/gh-операций.

## Установка

```bash
npm i -g @vibecoswaga/cli
```

## Команды

| Команда | Описание |
|---|---|
| `vibeco init <name>` | Создать новый проект из шаблона: GitHub repo + clone + reference + plugins + Claude. |
| `vibeco join <repo-url>` | Подключиться к существующему проекту как Dev #N. |
| `vibeco status` | Сводный статус — ветка, PR, входящие cross-zone, reflexion findings. |
| `vibeco pr` | Pre-PR check + push + PR + auto-merge. |
| `vibeco request-cross-zone <path> <reason>` | Создать GitHub-issue с просьбой к овнеру чужой зоны. |
| `vibeco sync-summary` | Сводка по всем разработчикам для еженедельного созвона. |
| `vibeco reflect <sha>` | Запустить reflexion на коммите (вызывается из GitHub Action). |

## Prerequisites

- Node.js >= 20
- Docker
- gh (GitHub CLI), авторизован
- git

При первом запуске `vibeco init` всё проверит и подскажет, если чего-то не хватает.

## Лицензия

MIT.
