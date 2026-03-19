# 1. Constrói a imagem localmente
docker build -t blog-edson-app:latest .

# 2. Testa a imagem localmente em "detached mode" (background)
docker run -d -p 80:80 blog-edson-app:latest

# 3. Faz login no Azure (vai abrir o navegador)
az login

# 4. Cria o Resource Group
az group create --name containerappslab03 --location eastus

# 5. Cria o Container Registry (ACR)
az acr create --resource-group containerappslab03 --name blogedsonacr --sku Basic

# 6. Faz login no ACR recém-criado
az acr login --name blogedsonacr

# 7. Prepara (Tag) a imagem para o repositório do Azure
docker tag blog-edson-app:latest blogedsonacr.azurecr.io/blog-edson-app:latest

# 8. Envia (Push) a imagem para o ACR
docker push blogedsonacr.azurecr.io/blog-edson-app:latest

# 9. Cria o ambiente do Container App
az containerapp env create --name blog-edson-env --resource-group containerappslab03 --location eastus 

# -------------------------------------------------------------------
# CARREGAMENTO DE VARIÁVEIS SEGURAS ANTES DO ÚLTIMO PASSO
# -------------------------------------------------------------------
if (Test-Path .env) {
    Get-Content .env | ForEach-Object {
        if ($_ -match '^(.*?)=(.*)$') {
            Set-Item -Path "Env:\$($matches[1])" -Value $matches[2]
        }
    }
    Write-Host "Variáveis de ambiente carregadas com sucesso!" -ForegroundColor Green
} else {
    Write-Host "Arquivo .env não encontrado. Interrompendo o script." -ForegroundColor Red
    exit
}

# 10. Cria o Container App usando a imagem do ACR e as credenciais do .env
az containerapp create `
  --name blog-edson-app `
  --resource-group containerappslab03 `
  --image blogedsonacr.azurecr.io/blog-edson-app:latest `
  --environment blog-edson-env `
  --target-port 80 `
  --ingress external `
  --registry-username $env:ACR_USERNAME `
  --registry-password $env:ACR_PASSWORD `
  --registry-server blogedsonacr.azurecr.io

Write-Host "Deploy finalizado!" -ForegroundColor Cyan