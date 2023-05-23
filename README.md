# B3 Project

Escopo<br/><br/>
Escrever, compilar e demonstrar um Smart Contract que melhor represente um token do ativo descrito
abaixo:<br/><br/>
Características do instrumento:<br/>
• É fungível<br/>
• Depende de uma entidade certificadora (reguladora) externa, que emite lotes de quantidades
desse token<br/>
• Cada lote aponta para um certificado específico, para o qual essa quantidade precisa fazer link
(utilizar IPFS ou outro definido pelo candidato) que contenha uma versão (imagem) do
certificado que representa a quantidade<br/>
• Para quem detém o token, na sua wallet a visão é somente da quantidade total, independente
do(s) certificado(s) que ela representa<br/>
• O processo de mint deve levar em conta o certificado do regulador<br/>
• O processo de burn deve levar em conta o saldo total, independente do(s) certificado(s) que ela
representa mas tentando sempre queimar o salto total de um certificado quando possível. Dessa
forma, se uma wallet tiver 100 tokens de um certificado A e 10 tokens de um certificado B e for
solicitado um burn de 10 tokens, privilegiar queimar os 10 do certificado B.<br/><br/>
Características do Smart Contract:<br/>
• Deve ter um proprietário<br/>
• Wallets devem ser white-listed<br/>
• Uma só wallet pode ter o acesso global a todas as funções<br/>
• Um conjunto de wallets podem invocar os métodos Mint e Transfer<br/>
• Um outro conjunto (pode ser sobreposto) pode invocar o método Burn<br/>
• O método Burn precisa da assinatura do demandante e do proprietário, sempre<br/><br/>
Outros:<br/>
• Escolher a especificação ERC mais adequada e justificar<br/>
• Deve ser implementado teste unitário e scan de segurança<br/>
• Utilizar a rede Polygon (preferencial) ou outra EVM-compatible<br/>
<br/><br/>
Try running some of the following tasks:

```shell

```
