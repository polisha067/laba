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

### Развернутые контейнерные образы

| Компонент | Образ | Статус |

| Frontend | mablinov2704/frontend:latest | Running |
| BFF | mablinov2704/bff:latest | Running |
| User Service | mablinov2704/user-service:latest | Running |
| Message Service | mablinov2704/message-service:latest | Running |
| PostgreSQL | postgres:16-alpine | Running |
| MinIO (S3) | minio/minio:latest | Running |

### Миграции базы данных

| Компонент | Образ | Статус |

| migrate-users | ghcr.io/kukymbr/goose-docker:latest | Completed |
| migrate-messages | ghcr.io/kukymbr/goose-docker:latest | Completed |

### S3-хранилище через CSI

- Развернут MinIO в кластере
- Создан PersistentVolume через CSI драйвер
- Создан PersistentVolumeClaim для message-service
- Message-service монтирует /app/uploads через CSI

### Node Affinity (правила размещения)

| Сервис | Требование | Реализация | Статус |
|--------|-----------|------------|--------|
| postgres | Только workload=system | requiredDuringScheduling | Выполнено |
| minio | Только workload=system | requiredDuringScheduling | Выполнено |
| frontend | Только workload=app | requiredDuringScheduling | Выполнено |
| bff | Только workload=app | requiredDuringScheduling | Выполнено |
| user-service | Только workload=app | requiredDuringScheduling | Выполнено |
| message-service | workload=app + предпочтение disk=fast | required + preferred | Выполнено |

## скрины работы в папке screenshots

## Структура 
k8s/
    base/
        kustomization.yaml
        namespace.yaml
        configmap.yaml
        secret.yaml
        postgres-pvc.yaml
        postgres.yaml
        migrate-users-job.yaml
        migrate-messages-job.yaml
        user-service.yaml
        message-service.yaml
        bff.yaml
        frontend.yaml
    overlays/
        dev/
            kustomization.yaml
            minio.yaml
            s3-pv.yaml
            patches/
                replicas.yaml
                resources.yaml
                affinity.yaml
        prod/
            kustomization.yaml
            s3-pv.yaml
            patches/
                replicas.yaml
                resources.yaml
                affinity.yaml
argocd/
    app-dev.yaml
screenshots/
    pods.png
    frontend.png
    argocd.png
    node-affinity.png
    s3-pvc.png

### Argo CD (GitOps)
Argo CD установлен в namespace argocd
Создан Application для DEV окружения
Настроена автоматическая синхронизация (automated)
Включен prune (удаление лишних ресурсов)
Включен selfHeal (восстановление при рассинхроне)

### Вывод
В ходе выполнения лабораторной работы были успешно решены следующие задачи:
Развертывание приложения: Все 5 микросервисов запущены и работают в Kubernetes-кластере.
Управление конфигурациями: Создана Kustomize-структура с базовой конфигурацией и окружениями dev/prod.
S3 хранилище: Развернут MinIO, настроен CSI-драйвер, создан PersistentVolumeClaim.
Node Affinity: Реализованы все правила размещения подов согласно заданию.
GitOps: Установлен Argo CD, настроен Application с автоматической синхронизацией.
Все требования лабораторной работы выполнены в полном объеме.


**Проверка меток на нодах:**
```bash
kubectl get nodes --show-labels

**Проверка размещения подов:**
```bash
kubectl get pods -n messager-dev -o wide

**Проверки:**
# Проверка всех подов
kubectl get pods -n messager-dev

# Проверка сервисов
kubectl get svc -n messager-dev

# Проверка PVC
kubectl get pvc -n messager-dev

# Доступ к приложению
kubectl port-forward -n messager-dev svc/frontend 8080:80

