# Дорожная карта проекта: stray (SDD Roadmap)

Этот документ фиксирует декомпозицию проекта на этапы и фичи в соответствии с принципами **Spec-Driven Development (SDD)**. Каждая функциональность развивается по строгому циклу: `Спецификация` $\rightarrow$ `Согласование` $\rightarrow$ `Тесты (Red)` $\rightarrow$ `Реализация (Green)` $\rightarrow$ `Рефакторинг`.

---

## Этап 0. Архитектурный фундамент и MVP Core (✅ Завершено)

- [x] **0.1. Конституция и стандарты проекта:**
  - Созданы правила архитектуры и качества: [docs/constitution.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/constitution.md) / [docs/constitution.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/constitution.ru.md).
  - Настроен строгий режим компилятора и линтера в [analysis_options.yaml](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/analysis_options.yaml).
  - Подготовлен гайдлайн для автономных AI-агентов [AGENTS.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/AGENTS.md).
- [x] **0.2. Продуктовое видение (Бриф):**
  - Зафиксированы ценности, целевая аудитория (терминальные энтузиасты, пользователи Conky) и границы проекта в [docs/brief.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/brief.md) / [docs/brief.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/docs/brief.ru.md).
- [x] **0.3. Спецификация базовой версии (MVP):**
  - Описаны 12 BDD-сценариев: [spec/mvp.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/mvp.spec.md) / [spec/mvp.spec.ru.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/mvp.spec.ru.md).
- [x] **0.4. Реализация по TDD (Фаза Red $\rightarrow$ Green):**
  - Реализована чистая гексагональная архитектура: `core/`, `domain/`, `infrastructure/`, `cli/`.
  - Покрыты тестами все сценарии: 30 тестов (100% pass rate).
  - Проверена нативная компиляция в автономный бинарник (`dart compile exe`).

---

## Этап 1. Подготовка первого официального релиза: v0.1.0 (🎯 В работе)

Цель: подготовить проект к публичному использованию и распространению.

- [ ] **1.1. Пользовательская документация ([README.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/README.md)):**
  - Подробное описание утилиты, быстрый старт, таблица флагов.
  - Рецепт интеграции в `.bashrc` / `.zshrc` / `config.fish` (цитата при старте сессии).
  - Рецепт интеграции в виджет Conky (периодическое обновление с жестким форматированием).
- [ ] **1.2. Метаданные пакета:**
  - Настройка [pubspec.yaml](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/pubspec.yaml) (секция `executables`, репозиторий, теги).
  - Ведение [CHANGELOG.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/CHANGELOG.md).
- [ ] **1.3. Автоматизация сборки и релизов (GitHub Actions CI/CD):**
  - `ci.yml`: проверка форматирования, линтинга и тестов на каждом PR/коммите.
  - `release.yml`: матричная компиляция автономных бинарников под **macOS (arm64/x64)**, **Linux (x64)** и **Windows (x64)** с публикацией архивов в GitHub Releases.

---

## Этап 2. Архитектурная оптимизация ядра: v0.2.0 (⏳ Запланировано)

Цель: переход на чтение файлов любого объема при $O(1)$ потреблении памяти.

- [ ] **2.1. Спецификация потокового чтения ([spec/streaming_reader.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/streaming_reader.spec.md)):**
  - Использование алгоритма резервуарной выборки (*Reservoir Sampling*).
  - Ограничение по памяти: <15 МБ даже на файлах в несколько гигабайт.
- [ ] **2.2. TDD (Red):** тесты на потоковое чтение и равномерность вероятностного распределения.
- [ ] **2.3. Реализация (Green):** адаптер `StreamingLineReader` с подменой в Composition Root без изменения доменного слоя.

---

## Этап 3. Расширение функциональности CLI: v0.3.0+ (💡 Бэклог)

Фичи, расширяющие сценарии использования в терминале и конвейерах:

- [ ] **3.1. Поддержка стандартного потока ввода (`stdin`):**
  - Спецификация: [spec/stdin_support.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/stdin_support.spec.md)
  - Сценарий: чтение из конвейера (`cat file.txt | stray -` или `curl -s URL | stray -`).
- [ ] **3.2. Множественная выборка строк (`-n, --count`):**
  - Спецификация: [spec/multiple_selection.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/multiple_selection.spec.md)
  - Сценарий: выборка $N$ случайных уникальных строк из файла (аналог `shuf -n`).
- [ ] **3.3. Сохранение ANSI-цветов при форматировании:**
  - Спецификация: [spec/ansi_formatting.spec.md](file:///Users/alexanderniki/Projects/coding-exercises/dart/stray-dart/spec/ansi_formatting.spec.md)
  - Сценарий: корректный расчет видимой ширины строки при наличии цветовых escape-последовательностей терминала.
