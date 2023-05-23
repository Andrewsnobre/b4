// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Lock is ERC20 {
    address private owner;
    mapping(address => bool) public whitelistMintTransfer;
    mapping(address => bool) public whitelistBurn;
    mapping(address => bool) public whitelistRecipient;

    struct TokenLot {
        uint256 amount;
        string certificateIPFSHash;
    }

    TokenLot[] private tokenLots;
    mapping(address => mapping(uint256 => uint256)) private walletTokenBalances;
    uint256 private currentLotId;
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call");
        _;
    }

    modifier onlyWhitelistedMintTransfer() {
        require(
            whitelistMintTransfer[msg.sender],
            "Only whitelisted wallets call"
        );
        _;
    }

    modifier onlyWhitelistedBurn() {
        require(whitelistBurn[msg.sender], "Only whitelisted wallets call");
        _;
    }

    modifier onlyWhitelistedRecipient(address recipient) {
        require(whitelistRecipient[recipient], "Recipient not whitelisted");
        _;
    }

    constructor() ERC20("MyToken", "MTK") {
        owner = msg.sender;
        whitelistMintTransfer[msg.sender] = true;
        whitelistBurn[msg.sender] = true;
        whitelistRecipient[msg.sender] = true;
    }

    function mint(
        address recipient,
        uint256 amount,
        string calldata certificateIPFSHash
    ) external onlyWhitelistedRecipient(recipient) onlyWhitelistedMintTransfer {
        uint256 lotId = currentLotId;
        currentLotId++;

        tokenLots.push(TokenLot(amount, certificateIPFSHash));
        _mint(recipient, amount);

        walletTokenBalances[recipient][lotId] += amount;
    }

    function burn(
        uint256 amount,
        bytes32 _ethSignedMessageHash,
        bytes memory _signature,
        bytes memory _signaturedemand
    ) external onlyWhitelistedBurn {
        require(
            signers(_ethSignedMessageHash, _signature, _signaturedemand),
            "invalid signature"
        );
        uint256 remainingAmount = amount;
        uint256[] memory lotIds = getSortedLotIds(msg.sender);

        for (uint256 i = lotIds.length; i > 0 && remainingAmount > 0; i--) {
            uint256 lotId = lotIds[i - 1];
            uint256 balance = walletTokenBalances[msg.sender][lotId];

            if (balance > 0) {
                uint256 burnAmount = (balance >= remainingAmount)
                    ? remainingAmount
                    : balance;
                walletTokenBalances[msg.sender][lotId] -= burnAmount;
                remainingAmount -= burnAmount;
                _burn(msg.sender, burnAmount);
            }
        }

        require(remainingAmount == 0, "Insufficient balance to burn");
    }

    function transfer(
        address recipient,
        uint256 amount
    )
        public
        override
        onlyWhitelistedRecipient(recipient)
        onlyWhitelistedMintTransfer
        returns (bool)
    {
        require(recipient != address(0), "Transfer to zero address");
        require(amount > 0, "Must be greater than zero");

        uint256[] memory senderLotIds = getSortedLotIds(msg.sender);

        //   uint256[] memory recipientLotIds = getSortedLotIds(recipient);
        uint256[] memory recipientLotIds;
        if (getLotCount(recipient) > 0) {
            recipientLotIds = getSortedLotIds(recipient);
        }

        uint256 remainingAmount = amount;

        for (
            uint256 i = senderLotIds.length;
            i > 0 && remainingAmount > 0;
            i--
        ) {
            uint256 lotId = senderLotIds[i - 1];
            uint256 senderBalance = walletTokenBalances[msg.sender][lotId];

            if (senderBalance > 0) {
                uint256 transferAmount = (senderBalance >= remainingAmount)
                    ? remainingAmount
                    : senderBalance;
                walletTokenBalances[msg.sender][lotId] -= transferAmount;
                walletTokenBalances[recipient][lotId] += transferAmount;
                remainingAmount -= transferAmount;
            }
        }

        // If there are remaining tokens to transfer, distribute them among recipient's lots
        for (
            uint256 i = recipientLotIds.length;
            i > 0 && remainingAmount > 0;
            i--
        ) {
            uint256 lotId = recipientLotIds[i - 1];
            uint256 recipientBalance = walletTokenBalances[recipient][lotId];

            if (recipientBalance > 0) {
                uint256 transferAmount = (recipientBalance >= remainingAmount)
                    ? remainingAmount
                    : recipientBalance;
                walletTokenBalances[recipient][lotId] -= transferAmount;
                walletTokenBalances[msg.sender][lotId] += transferAmount;
                remainingAmount -= transferAmount;
            }
        }

        require(remainingAmount == 0, "Insufficient balance to transfer");

        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function totalSupply() public view override returns (uint256) {
        return ERC20.totalSupply();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return ERC20.balanceOf(account);
    }

    function balanceOfCertificate(
        address account,
        uint256 lotId
    ) public view returns (uint256) {
        return walletTokenBalances[account][lotId];
    }

    function addWhitelistedMintTransfer(address wallet) external onlyOwner {
        whitelistMintTransfer[wallet] = true;
    }

    function removeWhitelistedMintTransfer(address wallet) external onlyOwner {
        whitelistMintTransfer[wallet] = false;
    }

    function addWhitelistedBurn(address wallet) external onlyOwner {
        whitelistBurn[wallet] = true;
    }

    function removeWhitelistedBurn(address wallet) external onlyOwner {
        whitelistBurn[wallet] = false;
    }

    function addToWhitelistRecipient(address wallet) external onlyOwner {
        whitelistRecipient[wallet] = true;
    }

    function removeFromWhitelistRecipient(address wallet) external onlyOwner {
        whitelistRecipient[wallet] = false;
    }

    function getLotDetails(
        uint256 lotId
    ) public view returns (uint256, string memory) {
        require(lotId < tokenLots.length, "Invalid lot ID");
        TokenLot storage lot = tokenLots[lotId];
        return (lot.amount, lot.certificateIPFSHash);
    }

    function getSortedLotIds(
        address wallet
    ) private view returns (uint256[] memory) {
        uint256[] memory lotIds = new uint256[](getLotCount(wallet));

        uint256 index = 0;
        for (uint256 i = tokenLots.length; i > 0; i--) {
            if (walletTokenBalances[wallet][i - 1] > 0) {
                lotIds[index] = i - 1;
                index++;
            }
        }

        // Sort lotIds based on the balance of each certificate in descending order
        for (uint256 i = 0; i < lotIds.length - 1; i++) {
            for (uint256 j = i + 1; j < lotIds.length; j++) {
                uint256 balance1 = walletTokenBalances[wallet][lotIds[i]];
                uint256 balance2 = walletTokenBalances[wallet][lotIds[j]];

                if (balance1 < balance2) {
                    (lotIds[i], lotIds[j]) = (lotIds[j], lotIds[i]);
                }
            }
        }

        return lotIds;
    }

    function getLotCount(address wallet) private view returns (uint256 count) {
        for (uint256 i = 0; i < tokenLots.length; i++) {
            if (walletTokenBalances[wallet][i] > 0) {
                count++;
            }
        }
    }

    function verifysign(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public view returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _hashedMessage)
        );
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);

        // if the signature is signed by the owner
        if (signer == owner) {
            // give player (msg.sender) a prize
            return true;
        }

        return false;
    }

    function signers(
        bytes32 _ethSignedMessageHash,
        bytes memory _signature,
        bytes memory _signaturedemand
    ) public view returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        (bytes32 rd, bytes32 sd, uint8 vd) = splitSignature(_signaturedemand);

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _ethSignedMessageHash)
        );
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        address signerd = ecrecover(prefixedHashMessage, vd, rd, sd);

        // if the signature is signed by the owner
        if (signer == owner && signerd == msg.sender) {
            return true;
        }

        return false;
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature
            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature
            mload(p) loads next 32 bytes starting at the memory address p into memory
            */
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        // implicitly return (r, s, v)
    }
}
