// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Base64.sol";

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

    constructor() ERC20("B3 Token", "B3T") {
        owner = msg.sender;
        whitelistMintTransfer[msg.sender] = true;
        whitelistBurn[msg.sender] = true;
        whitelistRecipient[msg.sender] = true;
        tokenLots.push(TokenLot(0, ""));
        currentLotId++;
    }

    function mint(
        address recipient,
        uint256 amount,
        string calldata certificateIPFSHash
    ) external onlyWhitelistedRecipient(recipient) onlyWhitelistedMintTransfer {
        uint256 lotId = currentLotId;
        currentLotId++;

        //string memory svg0 ='<g id="Certificate_Approved"><g><path d="M30.538,25.184l-6.115-6.115C26.089,17.094,27,14.621,27,12c0-0.286-0.011-0.584-0.033-0.859    c-0.044-0.551-0.541-0.975-1.076-0.917c-0.551,0.044-0.961,0.526-0.917,1.076C24.991,11.524,25,11.767,25,12    c0,2.421-0.946,4.69-2.662,6.388c-1.309,1.29-2.947,2.144-4.748,2.47c-0.954,0.185-2.122,0.197-3.241-0.012    c-1.783-0.325-3.413-1.184-4.712-2.483C7.937,16.662,7,14.402,7,12c0-4.962,4.038-9,9-9c2.421,0,4.694,0.949,6.399,2.673    c0.388,0.392,1.022,0.396,1.414,0.008c0.393-0.388,0.396-1.021,0.008-1.414C21.737,2.16,18.959,1,16,1C9.935,1,5,5.935,5,12    c0,2.601,0.901,5.063,2.55,7.036l-6.257,6.257c-0.286,0.286-0.372,0.716-0.217,1.09C1.231,26.756,1.596,27,2,27h3v3    c0,0.404,0.244,0.769,0.617,0.924C5.741,30.975,5.871,31,6,31c0.26,0,0.516-0.102,0.707-0.293l7.819-7.819    C15.017,22.955,15.509,23,16,23c0.499,0,0.971-0.042,1.424-0.102l7.809,7.809C25.424,30.898,25.68,31,25.94,31    c0.129,0,0.259-0.025,0.383-0.076c0.374-0.155,0.617-0.52,0.617-0.924v-3h3c0.003,0,0.007,0,0.01,0c0.595-0.028,1.01-0.444,1.01-1    C30.96,25.663,30.793,25.365,30.538,25.184z M7,27.586V26c0-0.552-0.448-1-1-1H4.414l4.547-4.547    c0.062,0.051,0.128,0.096,0.19,0.146c0.154,0.124,0.31,0.245,0.47,0.359c0.092,0.066,0.186,0.128,0.28,0.191    c0.157,0.105,0.315,0.207,0.477,0.303c0.098,0.059,0.197,0.116,0.297,0.171c0.166,0.092,0.334,0.179,0.504,0.262    c0.099,0.048,0.197,0.097,0.297,0.142c0.186,0.084,0.375,0.16,0.565,0.233c0.068,0.026,0.133,0.058,0.202,0.083L7,27.586z     M25.94,25c-0.552,0-1,0.448-1,1v1.586l-5.23-5.231c0.076-0.027,0.149-0.063,0.225-0.092c0.179-0.069,0.357-0.139,0.533-0.217    c0.109-0.049,0.216-0.102,0.324-0.153c0.162-0.079,0.322-0.16,0.479-0.247c0.107-0.059,0.213-0.119,0.318-0.181    c0.156-0.092,0.308-0.188,0.459-0.288c0.1-0.066,0.199-0.131,0.296-0.2c0.158-0.112,0.312-0.23,0.464-0.351    c0.064-0.051,0.132-0.096,0.195-0.148L27.526,25H25.94z"/><path d="M11.376,10.299c-0.402-0.377-1.036-0.356-1.413,0.047c-0.377,0.403-0.356,1.036,0.047,1.413l5.313,4.971    C15.514,16.91,15.76,17,16.005,17s0.491-0.09,0.683-0.27l10.688-10c0.403-0.377,0.424-1.01,0.047-1.413    c-0.378-0.404-1.011-0.424-1.413-0.047l-10.004,9.36L11.376,10.299z"/></g></g>';
        //string memory svg0 = "";

        string
            memory svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 750 350'><style>.base { fill: white; font-family: serif; font-size: 30px; }</style><rect width='100%' height='100%' fill='black'/>";
        string
            memory svgPartTwo = "<text x='50%' y='30%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        string
            memory svgPartThree = "</text><text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>";
        string memory finalSvg = string(
            abi.encodePacked(
                svgPartOne,
                svgPartTwo,
                "Lote:",
                Strings.toString(lotId),
                " Certificado:",
                certificateIPFSHash,
                svgPartThree,
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
                        Strings.toString(lotId),
                        '"Certificado":"',
                        certificateIPFSHash,
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

    /*   function verifysign(
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
    } */

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
