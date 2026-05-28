# Лабораторная работа: Развертывание микросервисного приложения в Kubernetes с использованием GitOps

## Выполнила: Журавлёва Полина Петровна
## Группа: М80-106БВ-25

---

## Цель работы

Развернуть микросервисное приложение "Мессенджер" в Kubernetes-кластере с использованием:
- Kustomize для управления конфигурациями (dev/prod)
- Argo CD для GitOps автоматического деплоя
- S3-совместимого хранилища через CSI
- Node Affinity для контроля размещения подов

---

## Выполненные требования

### 1. Развернутые контейнерные образы

| Компонент | Образ | Статус |

| Frontend | mablinov2704/frontend:latest | Running |
| BFF | mablinov2704/bff:latest | Running |
| User Service | mablinov2704/user-service:latest | Running |
| Message Service | mablinov2704/message-service:latest | Running |
| PostgreSQL | postgres:16-alpine | Running |
| MinIO (S3) | minio/minio:latest | Running |

### 2. Миграции базы данных

| Компонент | Образ | Статус |

| migrate-users | ghcr.io/kukymbr/goose-docker:latest | Completed |
| migrate-messages | ghcr.io/kukymbr/goose-docker:latest | Completed |

### 3. S3-хранилище через CSI

- Развернут MinIO в кластере
- Создан PersistentVolume через CSI драйвер
- Создан PersistentVolumeClaim для message-service
- Message-service монтирует /app/uploads через CSI

### 4. Node Affinity (правила размещения)

| Сервис | Требование | Реализация | Статус |
|--------|-----------|------------|--------|
| postgres | Только workload=system | requiredDuringScheduling | Выполнено |
| minio | Только workload=system | requiredDuringScheduling | Выполнено |
| frontend | Только workload=app | requiredDuringScheduling | Выполнено |
| bff | Только workload=app | requiredDuringScheduling | Выполнено |
| user-service | Только workload=app | requiredDuringScheduling | Выполнено |
| message-service | workload=app + предпочтение disk=fast | required + preferred | Выполнено |

**Проверка меток на нодах:**
```bash
kubectl get nodes --show-labels