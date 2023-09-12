1. Crie e aplique a versão 1: ``` kubectl apply -f deploy/blue-green/deployment-v1.yml -f deploy/blue-green/ingress.yml -f deploy/blue-green/service.yml ```
2. Aplique a versão 2: ``` kubectl apply -f deploy/blue-green/deployment-v2.yml ```
3. Faça a troca de versão no service: ``` kubectl patch service api-versao-service -p '{"spec":{"selector":{"version":"v2"}}}' ```
4. Exclua a versão 1: ``` kubectl delete -f deploy/blue-green/deployment-v1.yml ```