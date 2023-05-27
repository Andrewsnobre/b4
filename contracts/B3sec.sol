// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

contract B3sec is ERC20 {
    address public owner;
    mapping(address => bool) public whitelistMintTransfer;
    mapping(address => bool) public whitelistBurn;
    mapping(address => bool) public whitelistRecipient;
    mapping(bytes => bool) private usedNonces;

    struct TokenLot {
        uint256 amount;
        string certificateJson;
    }

    TokenLot[] private tokenLots;
    string[] public certificates;
    uint256[] private lotes;

    mapping(address => mapping(uint256 => uint256)) private walletTokenBalances;

    // Declaring  modifiers
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

    // Declaring  events
    event NewCertificate(address sender, string certificateName);

    constructor() ERC20("B3 Token", "B3T") {
        owner = msg.sender;
        whitelistMintTransfer[msg.sender] = true;
        whitelistBurn[msg.sender] = true;
        whitelistRecipient[msg.sender] = true;
        lotes.push(0);
        certificates.push("");
        tokenLots.push(TokenLot(0, ""));
    }

    function mint(
        address recipient,
        uint256 amount,
        uint256 certificateID
    ) external onlyWhitelistedRecipient(recipient) onlyWhitelistedMintTransfer {
        require(amount > 0, "Must be greater than zero");
        require(certificateID < certificates.length, "Invalid certificateID");
        //uint256 lotId = certificateID;

        string
            memory svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 450 250'><style>.base { fill: white; font-family: serif; font-size: 30px; }</style><rect width='100%' height='100%' fill='darkslategray'/> <text x='50%' y='30%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        string
            memory svgPartTwo = "</text><text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>";

        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                "Lote:",
                Strings.toString(lotes.length),
                " Certificado:",
                certificates[certificateID],
                svgPartTwo,
                " Quantidade:",
                Strings.toString(amount),
                "</text></svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"Lote":"',
                        Strings.toString(lotes.length),
                        '"Certificado":"',
                        certificates[certificateID],
                        '","Quantidade":"',
                        Strings.toString(amount),
                        '","image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        tokenLots.push(TokenLot(amount, finalTokenUri));
        _mint(recipient, amount);

        walletTokenBalances[recipient][certificateID] += amount;
        lotes.push(tokenLots.length - 1);
    }

    function burn(
        uint256 amount,
        bytes32 _ethSignedMessageHash,
        bytes32 _ethSignedMessageHashd,
        bytes memory _signature,
        bytes memory _signaturedemand
    ) external onlyWhitelistedBurn {
        require(amount > 0, "Must be greater than zero");
        require(!usedNonces[_signature], "Signature already used");
        require(!usedNonces[_signaturedemand], "Signature already used");
        require(
            signers(
                _ethSignedMessageHash,
                _ethSignedMessageHashd,
                _signature,
                _signaturedemand
            ),
            "Invalid signature"
        );

        usedNonces[_signature] = true;
        usedNonces[_signaturedemand] = true;
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

        // require(remainingAmount == 0, "Insufficient balance to burn");
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
        uint256 certificadeID
    ) public view returns (uint256) {
        return walletTokenBalances[account][certificadeID];
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

    function addtocertificate(string memory newValue) public onlyOwner {
        certificates.push(newValue);
        tokenLots.push(TokenLot(0, newValue));
        emit NewCertificate(msg.sender, newValue);
    }

    function loteMintDetails(
        uint256 lotId
    ) public view returns (uint256, string memory) {
        require(lotId < lotes.length, "Invalid LoteMintID");
        uint256 counter = lotes[lotId];
        TokenLot storage lot = tokenLots[counter];
        return (lot.amount, lot.certificateJson);
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

    function signers(
        bytes32 _ethSignedMessageHash,
        bytes32 _ethSignedMessageHashd,
        bytes memory _signature,
        bytes memory _signaturedemand
    ) public view returns (bool) {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        (bytes32 rd, bytes32 sd, uint8 vd) = splitSignature(_signaturedemand);

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, _ethSignedMessageHash)
        );
        bytes32 prefixedHashMessaged = keccak256(
            abi.encodePacked(prefix, _ethSignedMessageHashd)
        );
        address signer = ecrecover(prefixedHashMessage, v, r, s);
        address signerd = ecrecover(prefixedHashMessaged, vd, rd, sd);

        // if the signature is signed by the owner and sender
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
