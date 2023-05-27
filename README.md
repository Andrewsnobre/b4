# 📝TESTE TÉCNICO B3

O Projeto foi implementado de forma completa!🎉 atendendo todos os requisitos.  <br><br/>
Foi utilizado o Hardhat👷‍♂️ para desenvolvimento do SmartContract.<br/>

## 👨‍💻Contract B3sec Token (B3T)
O contrato foi implantado e seu código foi verificado na Polygon testnet(Mumbai):<br/>
B3 Token address: [0x5472d826fd680ecc589decfacdfd5e88b3ac7b06](https://mumbai.polygonscan.com/address/0x5472d826fd680ecc589decfacdfd5e88b3ac7b06)
<br/>

✅ É fungível: <br/>
 R: Utilizamos a biblioteca ERC20 (openzeppelin) devido o contrato ser fungível e todos o os tokens devem ser mostrados de forma total nas wallets, independentemente do seu certificado.<br/>


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
 
## 🚨Segurança e Testes implantados:<br/>

⚠️**Proteção contra Replay Atack:**</BR>
Em nosso contrato colocamos a proteção que evita que qualquer assinatura seja usada novamente, para isso usamos um nonce para proteção, [veja mais aqui.](https://celo.academy/t/solidity-vulnerabilities-signature-replay-attack/181)<br>

Utilizamos as seguinte ferramentas em nosso contrato abaixo:<br>

[OpenZeppelin Defender:](https://www.openzeppelin.com/defender) Versão grátis<br/>

![op](https://github.com/Andrewsnobre/b4/assets/11564122/c40cb1b4-bf04-4794-939a-c72ba03cb263)<br>
O OpenZeppelin Defender é uma ferramenta importante de segurança para gerenciar e monitorar transações de contratos inteligentes depois de implantados, com uso de Sentinelas, scripts automatizados, agendamentos etc.<br> 

Podemos definir qualquer tipo de regra de monitoramento, abaixo um email que recebemos ao cadastrar um Certificado:<br><img src="https://github.com/Andrewsnobre/b4/assets/11564122/dead9819-37bd-4e4d-b62b-6ed1b828edd7" width="550" height="250">

<br>




[Solhint:](https://protofire.github.io/solhint/)<br/>
![solhint](https://github.com/Andrewsnobre/b4/assets/11564122/8a1909da-9487-4635-8640-e24203f42ea3)<br>
Utilitário de linting para o código Solidity nos ajudar a seguir regras rígidas enquanto desenvolvemos nosso contrato inteligente. Essas regras são úteis tanto para seguir a melhor prática padrão de estilo de código quanto para aderir às melhores abordagens de segurança.<br>


Arquivo de teste unitário usando [Mocha](https://mochajs.org/) (B3secTest.js):<br/>
    ✔️ deve permitir a transferência de tokens<br/>
    ✔️ deve permitir  mint de tokens<br/>
    ✔️ deve permitir a adição e remoção de endereços na lista de permissões<br/>
    ✔️ deve permitir a queima de tokens<br/><br/>
    [Hardhat Gas Reporter:](https://www.npmjs.com/package/hardhat-gas-reporter)<br>
    Monitoramente dos custos em Gas em Matic, com valores pegos via API do site coinmarketcap.com.
<br>
![gas2](https://github.com/Andrewsnobre/b4/assets/11564122/9053f76d-86b1-4627-aada-4563b005faaa)
    
       

Copyright © 2023
MIT licensed

✨ Desenvolvido por Andrews Rodrigues
