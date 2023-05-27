# TESTE TÉCNICO B3

O Projeto foi implementado de forma completa!🎉 atendendo todos os requisitos.  <br><br/>
Foi utilizado o Hardhat👷‍♂️ para desenvolvimento do SmartContract.<br/>

## 👨‍💻Contract B3sec Token (B3T)
O contrato foi implantado e seu código foi verificado na Polygon testnet(Mumbai):<br/>
B3 Token address: [0x5472d826fd680ecc589decfacdfd5e88b3ac7b06](https://mumbai.polygonscan.com/address/0x5472d826fd680ecc589decfacdfd5e88b3ac7b06)
<br/>

✅ É fungível: <br/>
 R: Utilizamos a biblioteca ERC20 (openzeppelin) devido o contrato ser fungível e todos o os tokens devem ser mostrados de forma total nas wallets, independentemente doseu certificado.<br/>


✅ Depende de uma entidade certificadora  que emite lotes de quantidades desse token, onde cadalote aponta para um certificado específico, para o qual essa quantidade precisa fazer link que contenha uma versão (imagem) do certificado que representa a quantidade<br/>
R: Foi implantado as bibliotecas Strings e Base64 para gerarmos a imagem do Certificado que representa a quantidade de forma dinâmica em formato SVG.<br/>

🏆PLUS:Imagens dos Certificados gerados dinamicamente e armazenados OnChain:<br/>
Cada lote mintado aponta para um certificado específico, que possui um link(JSON) que possui nele uma versão (imagem SVG) do certificado que representa a quantidade, ou seja, a imagem do certificado (SVG) com a quantidade e seu tipo é gerado dinamicamente e armazenado tudo OnChain.

✅ Para quem detém o token, na sua wallet a visão é somente da quantidade total, independente do(s) certificado(s) que ela representa<br/>
R: Corretamente exibido sempre o total na wallet, e para saber quanto possui de cada certificado criamos uma função (balanceOfCertificate).

✅ O processo de mint deve levar em conta o certificado do regulador<br/>
R: O processo de mint solicita o certificado(ID) do regulador.<br/>
Foi feito uma lista de certificados usados para "mintar os lotes".<br/>
Também foi criada uma função(loteMintDetails) onde podemos consultar os detalhes de cada lote mintado</br>

✅ O processo de burn deve levar em conta o saldo total, independente do(s) certificado(s) que ela representa mas tentando sempre queimar o salto total de um certificado quando possível. Dessa forma, se uma wallet tiver 100 tokens de um certificado A e 10 tokens de um certificado B e for solicitado um burn de 10 tokens, privilegiar queimar os 10 do certificado B.<br/>
R: Feito, o processo de burn leva em conta o saldo total, independente do(s) certificado(s) que ela representa e sempre tenta queimar o saldo total de um certificado antes.<br/>

🏆PLUS: Transfer também tenta usar saldo total de um certificado para transferir:<br/>
O processo de transfer também leva em conta o saldo total, independente do(s) certificado(s) que ela representa e sempre tenta transferir o saldo total de um certificado.<br/><br/>

## 📚Características do Smart Contract:<br/>

🔹 Deve ter um proprietário<br/>
 R: Feito no método constructor o owner.<br/>

🔹 Wallets devem ser white-listed<br/>
 R: Feito através do modificador whitelistRecipient. <br/>

🔹 Uma só wallet pode ter o acesso global a todas as funções<br/>
 R: Feito através do modificador onlyOwner.<br/>

🔹 Um conjunto de wallets podem invocar os métodos Mint e Transfer<br/>
 R: Feito através do modificador whitelistMintTransfer. <br/>

🔹 Um outro conjunto (pode ser sobreposto) pode invocar o método Burn<br/>
 R: Feito através do modificador whitelistBurn. <br/>

🔹 O método Burn precisa da assinatura do demandante e do proprietário, sempre.<br/>
 R: Feito através da função signers, onde verificamos as 2 assinaturas (demandante e do proprietário).<br/>

 🏆PLUS: Linguagem baixo nível YUL (Assembly):<br/>
Usamos a linguagem YUL(assembly) para extrair o r,s,v, e checar as assinaturas. Criamos um frontend para realizar assinaturas (signsec.html).

 ⚠️Proteção contra Replay Atack:</BR>
Em nosso contrato colocamos a proteção que evita que qualquer assinatura seja usada novamente, para isso usamos um nonce para serem únicos, [veja mais aqui.](https://celo.academy/t/solidity-vulnerabilities-signature-replay-attack/181)


## 🚨Testes implantados:<br/>

Linter: Solhint<br/>
Arquivo de teste:<br/>
    ✔️ deve permitir a transferência de tokens<br/>
    ✔️ deve permitir a mint de tokens<br/>
    ✔️ deve permitir a adição e remoção de endereços na lista de permissões<br/>
    ✔️ deve permitir a queima de tokens<br/><br/><br/>   ![test](https://github.com/Andrewsnobre/b4/assets/11564122/421e87da-fa23-4a90-a58b-3c81fc7c8e9d)
   

Copyright © 2023
MIT licensed

✨ Desenvolvido por Andrews Rodrigues
