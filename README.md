# Сопроводительная документация к системе анализа КТГ (Cardiotocography Monitoring System)

---

## 1. Техническая документация

### 1.1 README (установка и запуск)

```bash
# Клонирование репозитория
git clone https://github.com/<org>/<repo>.git
cd lct2025

# Установка backend
cd backend
poetry install

# Запуск backend (FastAPI)
poetry run uvicorn src.main:app --reload

# Запуск миграций базы данных
poetry run alembic upgrade head

# Установка frontend
cd ../lct2025-front
npm install

# Запуск frontend (React + Vite/CRA)
npm run dev
```

**По умолчанию:**

* Backend доступен на: `http://127.0.0.1:8000`
* Frontend доступен на: `http://127.0.0.1:5173`
* Swagger-дока API: `http://127.0.0.1:8000/docs`

---

### 1.2 Архитектурная диаграмма

```mermaid
flowchart LR
    subgraph Devices[Медицинские устройства]
        CTG[CTG Аппарат]
    end

    subgraph Backend[Backend (FastAPI)]
        API[REST API + WebSocket]
        DB[(PostgreSQL/SQLite)]
        ML[ML Engine (PyTorch, Sklearn)]
        MIGR[Alembic]
    end

    subgraph Frontend[Frontend (React + Redux Toolkit)]
        UI[UI Dashboard]
        WebsocketClient[WS Client]
        State[Redux Store]
    end

    CTG -->|Сигналы FHR/UC| API
    API --> DB
    API --> ML
    API --> Frontend
    WebsocketClient --> API
    UI --> State
```

**Описание компонентов:**

* **Frontend** — визуализация графиков КТГ, панель врача, настройки.
* **Backend** — FastAPI-сервис:

    * REST API (CRUD пациенты, истории).
    * WebSocket (поток сигналов).
    * ML-модуль (анализ сигналов).
* **DB** — PostgreSQL (прод) или SQLite (dev).
* **Alembic** — управление миграциями.
* **ML Engine** — прогноз FIGO, вероятность гипоксии.

---

### 1.3 Документация API

#### Пациенты

`GET /http/crud/patients`
Ответ:

```json
{
  "data": [
    {"id": 1, "fio": "Иванова А.А.", "additional_info": null}
  ]
}
```

`GET /http/crud/patients/{id}`
Ответ:

```json
{
  "id": 1,
  "fio": "Иванова А.А.",
  "additional_info": {"diagnosis": "Анемия"}
}
```

#### История КТГ

`GET /http/crud/ctg_histories?patient={id}`
Ответ:

```json
{
  "data": [
    {"id": 10, "file_path": "ctg_10.json", "result": {"figo": "Норма"}}
  ]
}
```

#### Поток данных

`WS /ws/streaming/`
Сообщение от сервера:

```json
{
  "bpm": 140,
  "uc": 12,
  "timestamp": 1696252000,
  "process": {
    "figo_situation": "Нормальное",
    "stv": 3.2,
    "hypoxia_proba": 0.12
  }
}
```

---

### 1.4 Интеграция с оборудованием

* Поддержка **CTG-аппаратов** через:

    * USB/COM (Raw данные).
    * HL7/FHIR API (клинические системы).
    * Wi-Fi / локальную сеть (стриминг JSON).
* Сигналы конвертируются в `StreamData` и подаются в WebSocket.

---

## 2. Алгоритмы

### 2.1 Обработка сигналов

* Сглаживание скользящим окном (5–10 сек).
* Фильтрация выбросов по z-score.
* Downsampling (ограничение точек на фронте).

### 2.2 Выявление аномалий

* **FHR**: <110 или >160 уд/мин.
* **UC**: >60%.
* **STV**: <2.6 мс → высокий риск гипоксии.

### 2.3 ML-модели

* CatBoost / XGBoost → прогноз FIGO.
* LSTM → анализ временных рядов STV.
* Обоснование: высокая интерпретируемость + онлайн-инференс.

### 2.4 Метрики качества

* Accuracy по FIGO ≈ 0.84.
* AUROC прогноза гипоксии ≈ 0.89.
* MSE прогноза STV < 0.5 мс.

---

## 3. Пользовательская документация

### 3.1 Руководство врача

1. Выбрать пациента.
2. Нажать «Старт» для подключения к устройству.
3. Следить за графиками FHR/UC.
4. Сохранять или экспортировать отчёты.

### 3.2 Интерфейс

* Панель показателей (ЧСС, STV, UC).
* История КТГ.
* Настройки (цвета, звуки).
* Экспорт PDF/JPG.

### 3.3 Интерпретация

* **Зелёный** — норма.
* **Оранжевый** — сомнительно.
* **Красный** — патологически.
* **Фиолетовый** — претерминально.

### 3.4 Рекомендации

* Использовать в связке с клиническим протоколом FIGO.
* Экспортировать результаты в медицинскую карту.

---

## 4. Техническое описание

### 4.1 Технологический стек

* **Frontend**: React, Redux Toolkit, TypeScript, VisX/D3.
* **Backend**: FastAPI, SQLAlchemy, Alembic.
* **ML**: PyTorch, scikit-learn.
* **БД**: PostgreSQL (prod), SQLite (dev).
* **Контейнеризация**: Docker, docker-compose.

### 4.2 Оптимизации под edge

* Ограничение точек (4000) → smooth rendering.
* IndexedDB для звуков.
* WebSocket → бинарные пакеты.

### 4.3 Схема развертывания

* Docker Compose:

    * `frontend` (React).
    * `backend` (FastAPI).
    * `db` (Postgres).
    * `nginx` (reverse-proxy).

### 4.4 Аппаратные требования

* Минимум: 2 CPU, 4GB RAM, SSD 10GB.
* Рекомендуется: GPU (для обучения).

---

## 5. Исходный код

* Фронт: `lct2025-front/src`
* Бэк: `backend/src`
* Миграции: `backend/src/migrations/`
* Тесты: `tests/`
* Контейнеризация: `Dockerfile`, `docker-compose.yml`
