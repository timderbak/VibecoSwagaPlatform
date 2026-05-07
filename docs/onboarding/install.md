# Установка плагинов и инструментов вручную

Если `vibeco init` не смог автоматически поставить какой-то плагин — вот как руками.

## Prerequisites

Проверь, что у тебя установлено:

```bash
node --version    # >= 20
docker --version  # >= 24
gh --version      # >= 2.40
git --version     # >= 2.40
```

### Если чего-то нет

- **Node.js**: https://nodejs.org/ или `nvm install 20`
- **Docker Desktop**: https://www.docker.com/products/docker-desktop/
- **GitHub CLI** (`gh`): `brew install gh` (macOS) / `apt install gh` (Linux)
- **Git**: обычно уже есть; если нет — `brew install git`

### Авторизация в GitHub CLI

```bash
gh auth login
```

Выбери: GitHub.com → HTTPS (или SSH) → авторизуйся через браузер.

## Claude Code

```bash
npm i -g @anthropic-ai/claude-code
```

Запусти `claude` в любой папке — попросит API-ключ при первом запуске.

## Плагины Claude Code

Список нужных — в `.claude-plugins.json`:

- `superpowers` — brainstorming, writing-plans, executing-plans, TDD, debugging, verification
- `claude-mem` — память между сессиями
- `context7` — актуальные доки библиотек
- `reflexion` — критика после крупных фич
- `github` — интеграция с gh

### Установка через CLI

```bash
claude plugin install superpowers
claude plugin install claude-mem
claude plugin install context7
claude plugin install reflexion
claude plugin install github
```

### Установка через UI

1. Запусти `claude`.
2. Команда `/plugin marketplace browse`.
3. Выбери плагин из списка → Install.

## vibeco CLI

```bash
npm i -g @vibecoswaga/cli
```

Проверка: `vibeco --version`.

## MCP-серверы (опционально, но рекомендуется)

Эти MCP-серверы используются плагинами выше. Обычно они подтягиваются автоматически с плагином, но если нет:

```bash
# Context7
claude mcp add context7

# GitHub
claude mcp add github

# claude-mem (часть плагина)
```

Проверка: `claude mcp list`.

## Проверка работы

```bash
mkdir test-project && cd test-project
git init
claude
```

В Claude скажи:

```
> /plugin
```

Должен показать список установленных плагинов. Если `superpowers` есть — поехали.

## Ничего не помогает

Открой issue в репозитории шаблона: https://github.com/<org>/VibecoSwagaTemplate/issues
