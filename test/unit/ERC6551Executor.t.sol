// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vault } from "src/Vault.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import {MockNFT} from "src/mock/MockNFT.sol";
import { CreateVault } from "script/CreateVault.s.sol";
import { DeployVault } from "script/DeployVault.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { ERC6551Registry } from "@erc6551/ERC6551Registry.sol";


error NotAuthorizedExecutor();
error Executor__OnlyCallOpAllowed();

contract ERC6551ExecutorTest is Test, HelpersConfig, CreateVault {
    Vault vault;
    ERC6551Registry registry;
    TokenShieldNft tokenShieldNft;

    ChainConfig config;

    address vaultMinter = vm.addr(1);
    address nonMinter = vm.addr(5);

    string domainName = "TokenShield";
    string domainVersion = "1";
    bytes32 DOMAIN_SEPARATOR;

    MockNFT nft;

    constructor() { }

    function setUp() public {
        // Getting the config from helpersConfig for the chain
        config = getConfig();

        // Initializing the Deply Scripts
        DeployVault deploy = new DeployVault();

        // Deploying and creating Vaults, TokenShieldNFT etc.
        (
            address _registry,
            /**
             * address _guardian
             */
            ,
            address _tokenShieldNft,
            address _vaultImpl
        ) = deploy.deploy();
        vm.startPrank(config.contractAdmin);
        vm.deal(config.contractAdmin, 100 ether);
        address vaultAddress = createVault(_tokenShieldNft, _registry, _vaultImpl);
        vm.stopPrank();
        // Defining the deployed contracts
        vault = Vault(payable(vaultAddress));
        tokenShieldNft = TokenShieldNft(_tokenShieldNft);
    }

    modifier mintVault() {
        hoax(vaultMinter, 100 ether);
        address _vault = _createVault(tokenShieldNft);
        vault = Vault(payable(_vault));
        _;
    }

    function testStateIsVisible() public mintVault {
        uint256 currentState = vault.state();

        assertEq(currentState, 0); // Since there has been no transactions in this vault the state should be 0.
    }

    function testCheckSignature() public mintVault {
        uint256 state = vault.state();
        Tx memory transaction = Tx({ to: nonMinter, value: 1 ether, nonce: state, data: "" });
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(transactionHash, address(vault));

        // Since the private key of the vaultMinter is 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

        // Since the private key of the guardianSigner is 2 from HelpersConfig
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

        bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);

        bytes memory data = abi.encode(transaction, signature);
        (bool isValid, ) = vault.checkSignature(data, nonMinter, 1 ether);

        assertEq(isValid, true);
    }

    function testRevertsWhenExecutorNotAuthorised() public mintVault {
        uint256 state = vault.state();
        Tx memory transaction = Tx({ to: nonMinter, value: 1 ether, nonce: state, data: "" });
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(transactionHash, address(vault));

        // Since the private key of the vaultMinter is 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

        // Since the private key of the guardianSigner is 2 from HelpersConfig
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

        bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);

        bytes memory data = abi.encode(transaction, signature);
        vm.expectRevert(NotAuthorizedExecutor.selector);
        vault.execute(nonMinter,1 ether,data, 0);

     }

     function testRevertsWhenOpNotCall() public mintVault {
        uint256 state = vault.state();
        Tx memory transaction = Tx({ to: nonMinter, value: 1 ether, nonce: state, data: "" });
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(transactionHash, address(vault));

        // Since the private key of the vaultMinter is 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

        // Since the private key of the guardianSigner is 2 from HelpersConfig
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

        bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);

        bytes memory data = abi.encode(transaction, signature);
        hoax(vaultMinter, 10 ether);
        vm.expectRevert(Executor__OnlyCallOpAllowed.selector);
        vault.execute(nonMinter,1 ether,data, 1);

     }

    function testSendEther()  public mintVault {
        uint256 state = vault.state();
        Tx memory transaction = Tx({ to: nonMinter, value: 1 ether, nonce: state, data: "" });
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(transactionHash, address(vault));

        // Since the private key of the vaultMinter is 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

        // Since the private key of the guardianSigner is 2 from HelpersConfig
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

        bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);

        bytes memory data = abi.encode(transaction, signature);
        uint priorBalance = nonMinter.balance;
        vm.deal(address(vault), 100 ether);
        hoax(vaultMinter, 10 ether);
        vault.execute(nonMinter,1 ether,data, 0);
        uint postBalance = nonMinter.balance;

        assertEq(postBalance, priorBalance + 1 ether);
    }

    modifier nftDeploy() {
        nft = new MockNFT();
        nft.safeMint(address(vault), 1);
        _;
    }

    function testSendERC721()  public mintVault nftDeploy {
        uint256 state = vault.state();
        bytes memory message =
            abi.encodeWithSignature("safeTransferFrom(address,address,uint256)", address(vault), nonMinter, 1);
        
        Tx memory transaction = Tx({ to: address(nft), value: 0, nonce: state, data: message });
        
        bytes32 transactionHash = getTransactionHash(transaction);
        bytes32 digest = getTransactionHashWithDomainSeperator(transactionHash, address(vault));

        // Since the private key of the vaultMinter is 1
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(1, digest);

        // Since the private key of the guardianSigner is 2 from HelpersConfig
        (uint8 v2, bytes32 r2, bytes32 s2) = vm.sign(2, digest);

        bytes memory signature = abi.encode(v1, r1, s1, v2, r2, s2);

        bytes memory data = abi.encode(transaction, signature);
        
        address priorOwnerOfNft = nft.ownerOf(1);

        vm.deal(address(vault), 100 ether);
        hoax(vaultMinter, 10 ether);
        vault.execute(address(nft), 0, data, 0);
        
        address postOwnerOfNft = nft.ownerOf(1);

        assertEq(priorOwnerOfNft, address(vault));
        assertEq(postOwnerOfNft, nonMinter);

    }

    function domainSeparator(address verifyingContract) internal view returns (bytes32 domainSeperator) {
        domainSeperator = getDomainHash(
            EIP712Domain({
                name: domainName,
                version: domainVersion,
                chainId: block.chainid,
                verifyingContract: verifyingContract
            })
        );
    }

    function getDomainHash(EIP712Domain memory domain) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(domain.name)),
                keccak256(bytes(domain.version)),
                domain.chainId,
                domain.verifyingContract
            )
        );
    }

    function getTransactionHash(Tx memory _transaction) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("Tx(address to,uint256 value,uint256 nonce,bytes data)"),
                _transaction.to,
                _transaction.value,
                _transaction.nonce,
                keccak256(bytes(_transaction.data))
            )
        );
    }

    function getTransactionHashWithDomainSeperator(
        bytes32 transactionHash,
        address verifyingContract
    )
        internal
        view
        returns (bytes32)
    {
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator(verifyingContract), transactionHash));
        return digest;
    }
}
