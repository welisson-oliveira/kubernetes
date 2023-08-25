1. Clonar repositorio do GIT: ```git clone git@github.com:KubeDev/pedelogo-catalogo.git```

    1.1. Criar Dockerfile na raiz do projeto: 
    ```docker 
    FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
    WORKDIR /src
    COPY src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj src/PedeLogo.Catalogo.Api
    RUN dotnet restore src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj
    COPY . .
    WORKDIR /src/src/PedeLogo.Catalogo.Api
    RUN dotnet build PedeLogo.Catalogo.Api.csproj -c Release -o /app/build
    ...
    ```
    1.2. Gerar publisher:
    ```docker
    ...
    FROM build AS publish
    RUN dotnet publish PedeLogo.Catalogo.Api.csproj -c Release -o /app/publish
    ...
    ```
    1.3. Gerar imagem de publicação
    ```docker
    ...
    FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS final
    WORKDIR /app
    EXPOSE 80
    EXPOSE 443
    COPY --from=publish /app/publish .
    ENTRYPOINT [ "dotnet", "PedeLogo.Catalogo.Api.dll" ]
    ```

    ### Arquivo Dockerfile Completo:
    #### Dockerfile
    ```docker 
    FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
    WORKDIR /src
    COPY src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj src/PedeLogo.Catalogo.Api
    RUN dotnet restore src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj
    COPY . .
    WORKDIR /src/src/PedeLogo.Catalogo.Api
    RUN dotnet build PedeLogo.Catalogo.Api.csproj -c Release -o /app/build
    
    FROM build AS publish
    RUN dotnet publish PedeLogo.Catalogo.Api.csproj -c Release -o /app/publish
    
    FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS final
    WORKDIR /app
    EXPOSE 80
    EXPOSE 443
    COPY --from=publish /app/publish .
    ENTRYPOINT [ "dotnet", "PedeLogo.Catalogo.Api.dll" ]
    ...
    ```
    
2. Agora vamos buildar o projeto:                              ``` docker build -t welissonoliveira/pedelogo-catalogo:v1.0.0 . ```
3. Verifique se foi gerada a imagem:                           ``` docker images ```
4. Suba para o dockerhub:                                      ``` docker push welissonoliveira/pedelogo-catalogo:v1.0.0 ```
5. Certifique-se de que o projeto esta publico no docker hub
6. Criar os manifestos para subir no kubernetes:

    6.1. Codifique as strings necessarias em base64 utilizando o terminal: ``` echo -n "string" | base64 ```

    6.2. Primeiro criaremos o Secret para o mongo: ``` kubectl apply -f ./k8s/mongodb/mongodb-secret.yml ```
    #### mongodb-secret.yml
    ```yml
    apiVersion: v1
    kind: Secret
    metadata:
      name: mongodb-secret
    type: Opaque
    data:
      MONGO_INITDB_ROOT_USERNAME: bW9uZ291c2Vy
      MONGO_INITDB_ROOT_PASSWORD: bW9uZ29wd2Q=
    ```

    6.3. Agora criaremos o deployment para o mongo: ``` kubectl apply -f ./k8s/mongodb/deployment.yml ```
    #### deployment.yml
    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: mongo-deployment
    spec:
      selector:
        matchLabels:
          app: mongodb
      template:
        metadata:
          labels:
            app: mongodb
        spec:
          containers:
          - name: mongodb-pod
            image: mongo:4.2.8
            resources:
              limits:
                memory: "128Mi"
                cpu: "500m"
            ports:
              - containerPort: 27017
            envFrom:
              - secretRef:
                  name: mongodb-secret
    ```

    6.4. Agora criaremos o ClusterIp para o mongodb, ja que ele só vai ser acessado internamente ``` kubectl apply -f ./k8s/mongodb/clusterip.yml ```
    #### clusterip.yml
    ```yml
    apiVersion: v1
    kind: Service
    metadata:
      name: mongo-service
    spec:
      selector:
        app: mongodb
      ports:
      - port: 27017
        targetPort: 27017
      type: ClusterIP
    ```

    6.5. Agora criaremos o ConfigMap para a API: ``` kubectl apply -f ./k8s/api/api-configmap.yml ```
    #### api-configmap.yml
    ```yml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: api-configmap
    data:
      Mongo__Host: mongo-service
      Mongo__Port: "27017"
      Mongo__Database: admin
    ```

    6.6. Agora nosso deployment para nossa API: ``` kubectl apply -f ./k8s/api/deployment.yml ```
    #### deployment.yml
    ```yml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: api-deployment
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: api
      template:
        metadata:
          labels:
            app: api
        spec:
          containers:
          - name: api
            startupProbe:
              httpGet:
                path: /health
                port: 80
                scheme: HTTP
              initialDelaySeconds: 3
              periodSeconds: 3
              timeoutSeconds: 1
              failureThreshold: 30
            readinessProbe:
              httpGet:
                path: /read
                port: 80
                scheme: HTTP
              initialDelaySeconds: 3
              periodSeconds: 3
              timeoutSeconds: 1
              failureThreshold: 1
            livenessProbe:
              httpGet:
                # host: localhost
                path: /health
                port: 80
                scheme: HTTP
              initialDelaySeconds: 3
              periodSeconds: 3
              timeoutSeconds: 1
              failureThreshold: 1
            image: welissonoliveira/pedelogo-catalogo:v1.0.0
            resources:
              limits:
                memory: "128Mi"
                cpu: "500m"
            ports:
            - containerPort: 80
              name: http
            - containerPort: 443
              name: https
            imagePullPolicy: Always
            envFrom:
              - configMapRef:
                  name: api-configmap
            env:
              - name: Mongo__User
                valueFrom:
                  secretKeyRef:
                    name: mongodb-secret
                    key: MONGO_INITDB_ROOT_USERNAME
              - name: Mongo__Password
                valueFrom:
                  secretKeyRef:
                    name: mongodb-secret
                    key: MONGO_INITDB_ROOT_PASSWORD


    ```

    6.7. E nosso NodePort da api: ``` kubectl apply -f ./k8s/api/nodeport.yml ```
    #### nodeport.yml
    ```yml
    apiVersion: v1
    kind: Service
    metadata:
      name: api-service
    spec:
      selector:
        app: api
      ports:
      - port: 80
        targetPort: 80
        name: http
        nodePort: 30000
      - port: 443
        targetPort: 443
        name: https
        nodePort: 30001
      type: NodePort
    ```














