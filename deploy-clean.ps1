# deploy-clean.ps1
Write-Host "Deleting old namespace..." -ForegroundColor Yellow
kubectl delete namespace messager-dev --ignore-not-found

Write-Host "Waiting for cleanup..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "Creating namespace..." -ForegroundColor Green
kubectl create namespace messager-dev

Write-Host "Applying all manifests..." -ForegroundColor Green
kubectl apply -k k8s/overlays/dev

Write-Host "Waiting for postgres..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Creating databases..." -ForegroundColor Green
kubectl exec -n messager-dev deployment/postgres -- psql -U messager_user -d postgres -c "CREATE DATABASE messager_users;" 2>$null
kubectl exec -n messager-dev deployment/postgres -- psql -U messager_user -d postgres -c "CREATE DATABASE messager_messages;" 2>$null

Write-Host "Waiting for migrations..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

Write-Host "Restarting services..." -ForegroundColor Green
kubectl rollout restart deployment user-service -n messager-dev
kubectl rollout restart deployment message-service -n messager-dev

Write-Host "Final status:" -ForegroundColor Green
kubectl get pods -n messager-dev

Write-Host "Port forwarding frontend..." -ForegroundColor Green
Write-Host "Open http://localhost:8080 in browser"
kubectl port-forward -n messager-dev svc/frontend 8080:80