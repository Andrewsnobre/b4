# B3 Project


O Projeto foi implementado de forma completa utilizando o Hardhat como IDE. 


## Contract Addresses
O contrato foi implantado e verificado da rede polygon testnet(mumbai):<br/>
B3 Token address: [0xce917084bd38ad325c319c6c111baf09f6652eda](https://mumbai.polygonscan.com/address/0xce917084bd38ad325c319c6c111baf09f6652eda)
<br/>


• É fungível: <br/>
 R:Utilizamosa biblioteca ERC20(openzeppelin) abaixo devido o contrato ser fungível.<br/>
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";<br/>

• Depende de uma entidade certificadora (reguladora) externa, que emite lotes de quantidades desse token onde Cada lote aponta para um certificado específico, para o qual essa quantidade precisa fazer link (utilizar IPFS ou outro definido pelo candidato) que contenha uma versão (imagem) do certificado que representa a quantidade<br/>
R:Foi implantado as bibliotecas Strings e Base64 para gerarmos a imagem do Certificado de forma dinâmica em SVG- OnChain:<br/>
import "@openzeppelin/contracts/utils/Strings.sol";<br/>
import "./Base64.sol";<br/>

Assim, cada lote aponta para um certificado específico, para o qual essa quantidade precisa fazer link(JSON) que possui uma versão (imagem SVG) do certificado que representa a quantidade. Tudo OnChain.

• Para quem detém o token, na sua wallet a visão é somente da quantidade total, independente do(s) certificado(s) que ela representa<br/>
R:Correto

• O processo de mint deve levar em conta o certificado do regulador<br/>
R: O processo de mint solicita o certificado(ID) do regulador.

• O processo de burn deve levar em conta o saldo total, independente do(s) certificado(s) que ela representa mas tentando sempre queimar o salto total de um certificado quando possível. Dessa forma, se uma wallet tiver 100 tokens de um certificado A e 10 tokens de um certificado B e for solicitado um burn de 10 tokens, privilegiar queimar os 10 do certificado B.<br/>
R: Feito, o processo de burn leva em conta o saldo total, independente do(s) certificado(s) que ela representa e sempre tenta queimar o salto total de um certificado antes.<br/>

O processo de transfer também leva em conta o saldo total, independente do(s) certificado(s) que ela representa e sempre tenta trasnferir o salto total de um certificado.<br/>

Características do Smart Contract:<br/>
• Deve ter um proprietário<br/>
R:Owner<br/>

• Wallets devem ser white-listed<br/>
R: Modificador whitelistRecipient <br/>

• Uma só wallet pode ter o acesso global a todas as funções<br/>
R Owner Wallet<br/>

• Um conjunto de wallets podem invocar os métodos Mint e Transfer<br/>
R: modificador whitelistMintTransfer; <br/>

• Um outro conjunto (pode ser sobreposto) pode invocar o método Burn<br/>
R: modificador whitelistBurn; <br/>

• O método Burn precisa da assinatura do demandante e do proprietário, sempre.<br/>
R: Função Signers, onde solicita as 2 assinaturas (demandante e do proprietário)<br/>
Usamos a linguagem YUL(assembly) para extrair o r,s,v, para checar a assinatura.

Testes implantados:<br/>
Linter: Solhint<br/>
Arquivo de teste:<br/>
    √ deve permitir a transferência de tokens<br/>
    √ deve permitir a mint de tokens<br/>
    √ deve permitir a adição e remoção de endereços na lista de permissões<br/>
    √ deve permitir a queima de tokens<br/>
```shell

```
