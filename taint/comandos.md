### Taints

* Se possivel nao adiciona
    - ``` kubectl taint nodes [nome-do-node] [chave-valor]:PreferNoSchedule ```
* Não adiciona de maneira alguma
    - ``` kubectl taint nodes [nome-do-node] [chave-valor]:NoSchedule ```
* Alem de não adicionar, ele remove os que nao atendem ao taint
    - ``` kubectl taint nodes [nome-do-node] [chave-valor]:NoExecute ```
* Para remover
    - ``` kubectl taint nodes [nome-do-node] [chave-valor]:[taint]- ```