# Установка инструментов

Если что-то не работает после клона шаблона — проверь, что у тебя стоит всё нужное.

## Prerequisites

Проверь:

```bash
git --version     # >= 2.40
gh --version      # >= 2.40
docker --version  # >= 24
node --version    # >= 20 (нужен для frontend и Claude Code)
```

### Если чего-то нет

- **Node.js**: https://nodejs.org/ или `nvm install 22`
- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
- **GitHub CLI** (`gh`): `brew install gh` (macOS) / `apt install gh` (Linux)
- **Git**: обычно уже есть; если нет — `brew install git`

### Авторизация в GitHub CLI

```bash
gh auth login
```

Выбери: GitHub.com → HTTPS (или SSH) → авторизация через браузер.

## Claude Code

```bash
npm i -g @anthropic-ai/claude-code
```

Запусти `claude` в любой папке — попросит API-ключ при первом запуске.

## Плагины Claude Code

Список нужных — в `.claude-plugins.json`. Установить:

```bash
claude plugin install superpowers
claude plugin install claude-mem
claude plugin install context7
claude plugin install reflexion
claude plugin install github
```

Или через UI:
1. Запусти `claude`.
2. `/plugin marketplace browse`.
3. Выбери из списка → Install.

Onboarding-агент шаблона **сам предложит** установить недостающие при первом запуске Claude в проекте — но если хочешь заранее, ставь руками.

## MCP-серверы

Обычно подтягиваются с плагином. Если нет:

```bash
claude mcp add context7
claude mcp add github
```

Проверка: `claude mcp list`.

## Проверка работы

```bash
mkdir test-project && cd test-project
git init
claude
```

В Claude:
```
> /plugin
```

Должен показать список установленных плагинов. Если `superpowers` есть — поехали.

## Ничего не помогает

Открой issue в репозитории шаблона: https://github.com/timderbak/VibecoSwagaPlatform/issues
