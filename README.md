# Админ-панель для управления парковками

Веб-приложение на Flutter для администрирования системы умных парковок. Позволяет управлять парковочными зонами, камерами наблюдения и парковочными местами.

## Основные функции

- 🔐 Авторизация администраторов
- 🗺️ Интерактивная карта парковочных зон
- 📍 Создание и редактирование парковочных зон
- 📸 Управление камерами наблюдения
- 🅿️ Управление парковочными местами
- 🔍 Поиск по адресам
- 📊 Мониторинг состояния парковок

## Технологии

- Flutter Web
- Clean Architecture
- Dependency Injection (get_it)
- REST API (retrofit)
- OpenStreetMap
- Docker

## Требования

- Docker
- Docker Compose

## Запуск с помощью Docker

1. Клонируйте репозиторий:
```bash
git clone https://github.com/your-username/admin_panel.git
cd admin_panel
```

2. Запустите приложение через Docker Compose:
```bash
docker-compose up --build
```

3. Откройте приложение в браузере:
```
http://localhost:8084
```

## Разработка

### Требования для локальной разработки

- Flutter SDK (версия ^3.7.2)
- Dart SDK
- IDE (рекомендуется VS Code или Android Studio)

### Установка зависимостей

```bash
flutter pub get
```

### Запуск в режиме разработки

```bash
flutter run -d chrome
```

### Сборка релиза

```bash
flutter build web --release
```

## Структура проекта

```
lib/
├── data/           # Слой данных
│   ├── models/     # Модели данных
│   ├── repositories/ # Репозитории
│   └── services/   # Сервисы API
├── domain/         # Бизнес-логика
│   └── usecases/   # Use cases
├── presentation/   # UI слой
│   ├── pages/      # Страницы
│   ├── presenters/ # Презентеры
│   └── widgets/    # Виджеты
└── di/             # Внедрение зависимостей
```

## Особенности архитектуры

- Clean Architecture для четкого разделения слоев
- Repository Pattern для работы с данными
- Presenter Pattern для управления UI логикой
- Dependency Injection для управления зависимостями

## API Endpoints

Приложение взаимодействует с backend API для следующих операций:
- Аутентификация
- Управление зонами
- Управление камерами
- Управление парковочными местами

## Безопасность

- Защищенное хранение токенов (flutter_secure_storage)
- Аутентификация для всех операций
- Валидация данных на клиенте

## Лицензия

MIT License
