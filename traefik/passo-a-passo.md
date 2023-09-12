1. Criar o cluster: `kind create cluster --name k8s --config=./traefik/cluster-config.yml`
2. Instalar o WaveNet: ` kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml `
3. Configurar o Metrics-server

   3.1. Baixar o
   manifesto: ` wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml `

   3.2. Remomeie o manifesto ` mv components.yaml metrics-server.yml `

   3.3. Altere o manifesto metrics-server.yml. Adicione ao manifesto do Deployment no container.args a linha:

   #### metrics-server.yml
      ```yml
      ...
      containers:
        - args:
          - --kubelet-insecure-tls
      ...
      ``` 
   3.4. Aplique o manifesto ` kubectl apply -f ./traefik/metrics-server.yml `

4. Instale o Traefik via Helm: https://artifacthub.io/packages/helm/traefik/traefik
    
    4.1. adicionar o repositorio: ` helm repo add traefik https://traefik.github.io/charts `

    4.2. atualizar o repositório: ` helm repo update `

    4.3. Pegar o values do chart para customizar: ` helm show values traefik/traefik > ./traefik/values.yml `

    4.4. Criar um namespace: ` kubectl create namespace traefik-system `

    4.5. Instalar o traefik: ` helm upgrade --install traefik traefik/traefik --namespace=traefik-system `</br>
        - **Obs:** Utilizando o `upgrade --install ` ele instala ou atualiza caso ja tenha instalado.

    --- 
    ## Apenas Local
    4.6. Baixe o serviço do traefik: ` kubectl get svc traefik -n traefik-system -o yaml > ./traefik/traefik-service.yml `

    4.7. Altere o nodeport para 30000

    4.8. Aplique o serviço: ` kubectl apply -f traefik/traefik-service.yml -n traefik-system `
    
    ---