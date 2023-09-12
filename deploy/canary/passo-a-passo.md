1. Crie um Deployment para a versão atual:
    - Este deployment será a versão "estável" da sua aplicação.
2. Crie um Deployment para a versão canary:
    - Este deployment terá a nova versão da sua aplicação.
    - Configure este deployment para ter um número menor de replicas do que o deployment estável.
3. Use um Service para expor os dois Deployments:
    - O Service direcionará tráfego tanto para o deployment estável quanto para o deployment canary.
    - Com base na proporção de replicas entre os deployments, um subconjunto do tráfego será direcionado para o canary.
4. Monitore o Deployment Canary:
    - Use métricas, logs e feedback dos usuários para avaliar a estabilidade e funcionalidade da versão canary.

5. Aumente gradualmente o tráfego para o Canary:
    - Se o canary estiver estável, aumente o número de replicas no deployment canary.
    - Reduza correspondente o número de replicas no deployment estável.

6. Lançamento Completo:
    - Quando estiver confiante de que a versão canary é estável, você pode escalá-la para receber todo o tráfego, eliminando o deployment estável, ou simplesmente atualize o deployment estável para usar a nova versão.

7. Rollback se Necessário:
    - Se encontrar problemas com o canary, é fácil reverter para a versão estável reduzindo o número de replicas do canary ou interrompendo-o completamente.