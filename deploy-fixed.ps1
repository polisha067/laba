# deploy-fixed.ps1
Write-Host "Deleting old namespace..." -ForegroundColor Yellow
kubectl delete namespace messager-dev --ignore-not-found
Start-Sleep -Seconds 10

Write-Host "Creating namespace..." -ForegroundColor Green
kubectl create namespace messager-dev

Write-Host "Applying ConfigMap and Secrets..." -ForegroundColor Green
kubectl apply -f k8s/base/configmap.yaml -n messager-dev
kubectl apply -f k8s/base/secret.yaml -n messager-dev

Write-Host "Applying PostgreSQL..." -ForegroundColor Green
kubectl apply -f k8s/base/postgres-pvc.yaml -n messager-dev
kubectl apply -f k8s/base/postgres.yaml -n messager-dev

Write-Host "Waiting for PostgreSQL..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Creating databases..." -ForegroundColor Green
kubectl exec -n messager-dev deployment/postgres -- psql -U messager_user -d postgres -c "CREATE DATABASE messager_users;" 2>$null
kubectl exec -n messager-dev deployment/postgres -- psql -U messager_user -d postgres -c "CREATE DATABASE messager_messages;" 2>$null

Write-Host "Applying migrations..." -ForegroundColor Green
kubectl apply -f k8s/base/migrate-users-job.yaml -n messager-dev
kubectl apply -f k8s/base/migrate-messages-job.yaml -n messager-dev

Write-Host "Waiting for migrations..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "Applying services..." -ForegroundColor Green
kubectl apply -f k8s/base/user-service.yaml -n messager-dev
kubectl apply -f k8s/base/message-service.yaml -n messager-dev
kubectl apply -f k8s/base/bff.yaml -n messager-dev
kubectl apply -f k8s/base/frontend.yaml -n messager-dev

Write-Host "Applying MinIO..." -ForegroundColor Green
kubectl apply -f k8s/overlays/dev/minio.yaml -n messager-dev

Write-Host "Adding node labels..." -ForegroundColor Green
kubectl label node docker-desktop workload=system --overwrite=true
kubectl label node docker-desktop workload=app --overwrite=true
kubectl label node docker-desktop disk=fast --overwrite=true

Write-Host "Final status..." -ForegroundColor Green
kubectl get pods -n messager-dev

Write-Host "`nPort forwarding..." -ForegroundColor Yellow
Write-Host "Run in another terminal: kubectl port-forward -n messager-dev svc/frontend 8080:80"