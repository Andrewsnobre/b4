# B3 Project

Escopo
Escrever, compilar e demonstrar um Smart Contract que melhor represente um token do ativo descrito
abaixo:
Características do instrumento:
• É fungível
• Depende de uma entidade certificadora (reguladora) externa, que emite lotes de quantidades
desse token
• Cada lote aponta para um certificado específico, para o qual essa quantidade precisa fazer link
(utilizar IPFS ou outro definido pelo candidato) que contenha uma versão (imagem) do
certificado que representa a quantidade
• Para quem detém o token, na sua wallet a visão é somente da quantidade total, independente
do(s) certificado(s) que ela representa
• O processo de mint deve levar em conta o certificado do regulador
• O processo de burn deve levar em conta o saldo total, independente do(s) certificado(s) que ela
representa mas tentando sempre queimar o salto total de um certificado quando possível. Dessa
forma, se uma wallet tiver 100 tokens de um certificado A e 10 tokens de um certificado B e for
solicitado um burn de 10 tokens, privilegiar queimar os 10 do certificado B.
Características do Smart Contract:
• Deve ter um proprietário
• Wallets devem ser white-listed
• Uma só wallet pode ter o acesso global a todas as funções
• Um conjunto de wallets podem invocar os métodos Mint e Transfer
• Um outro conjunto (pode ser sobreposto) pode invocar o método Burn
• O método Burn precisa da assinatura do demandante e do proprietário, sempre
Outros:
• Escolher a especificação ERC mais adequada e justificar
• Deve ser implementado teste unitário e scan de segurança
• Utilizar a rede Polygon (preferencial) ou outra EVM-compatible

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/deploy.js
```
