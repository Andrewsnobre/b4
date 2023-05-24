const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("B3 Token", function () {
  let myToken;
  let owner;
  let recipient;

  beforeEach(async function () {
    // Deploy do contrato antes de cada teste
    const MyToken = await ethers.getContractFactory("Lock");
    myToken = await MyToken.deploy();
    await myToken.deployed();

    [owner, recipient] = await ethers.getSigners();
  });

  it("deve permitir a transferência de tokens", async function () {
    const amount = 100;

    // Mint tokens para a conta do remetente
    await myToken.mint(owner.address, amount, "hash123");

    // Adicione o endereço do destinatário à lista de permissões
    await myToken.addToWhitelistRecipient(recipient.address);

    // Chame a função "transfer" para transferir tokens
    await myToken.connect(owner).transfer(recipient.address, amount);

    // Verifique o saldo do remetente após a transferência
    const senderBalance = await myToken.balanceOf(owner.address);
    expect(senderBalance.toNumber()).to.equal(0);

    // Verifique o saldo do destinatário após a transferência
    const recipientBalance = await myToken.balanceOf(recipient.address);
    expect(recipientBalance.toNumber()).to.equal(amount);
  });

  it("deve permitir a mint de tokens", async function () {
    const recipientAddress = recipient.address;
    const amount = 100;
    const certificateIPFSHash = "hash123";

    // Adicione o endereço do destinatário à lista de permissões
    await myToken.addToWhitelistRecipient(recipientAddress);

    // Chame a função "mint" para criar novos tokens
    await myToken
      .connect(owner)
      .mint(recipientAddress, amount, certificateIPFSHash);

    // Verifique o saldo do destinatário após a mint
    const recipientBalance = await myToken.balanceOf(recipientAddress);
    expect(recipientBalance.toNumber()).to.equal(amount);

    // Verifique os detalhes do lote de tokens
    const lotId = 1;
    const [lotAmount, lotCertificateIPFSHash] = await myToken.getLotDetails(
      lotId
    );
    expect(lotAmount.toNumber()).to.equal(amount);
    // expect(lotCertificateIPFSHash).to.equal(certificateIPFSHash);
  });

  it("deve permitir a adição e remoção de endereços na lista de permissões", async function () {
    const wallet1 = ethers.Wallet.createRandom().address;
    const wallet2 = ethers.Wallet.createRandom().address;

    // Adicione o endereço à lista de permissões
    await myToken.addToWhitelistRecipient(wallet1);

    // Verifique se o endereço está na lista
    const isRecipientWhitelisted = await myToken.whitelistRecipient(wallet1);
    expect(isRecipientWhitelisted).to.equal(true);

    // Remova o endereço da lista de permissões
    await myToken.removeFromWhitelistRecipient(wallet1);

    // Verifique se o endereço foi removido da lista
    const isRecipientWhitelistedAfterRemoval = await myToken.whitelistRecipient(
      wallet1
    );
    expect(isRecipientWhitelistedAfterRemoval).to.equal(false);

    // Verifique se outros endereços não relacionados não foram afetados
    const isRecipientWhitelistedWallet2 = await myToken.whitelistRecipient(
      wallet2
    );
    expect(isRecipientWhitelistedWallet2).to.equal(false);
  });

  it("deve permitir a queima de tokens", async function () {
    const amount = 100;

    // Mint tokens para a conta do remetente
    await myToken.mint(owner.address, amount, "hash123");

    // Chame a função "burn" para queimar tokens
    const messsage =
      "0x1c8aff950685c2ed4bc3174f3472287b56d9517b9c948127319a09a7a36deac8";
    const signature =
      "0x9cf91eb63e92e23c57dbe15972449890b2f0bf7b22a1460ba942a6fca22def4a574e400f7273d6ec8f074736ff8a25e68cb9ec423027dbe0b7ffd0554e7404f41b";
    await myToken.connect(owner).burn(amount, messsage, signature, signature);

    // Verifique o saldo da conta do remetente após a queima
    const balance = await myToken.balanceOf(owner.address);
    expect(balance.toNumber()).to.equal(0);
  });
});
