// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";
import { Vault } from "src/Vault.sol";
import { DeployVault } from "script/DeployVault.s.sol";
import { CreateVault } from "script/CreateVault.s.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";
import { RecoveryManager } from "src/RecoveryManager.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";

error RecoveryManager__NotTokenShieldNft();
error RecoveryManager__AddressCantBeZero();
error RecoveryManager__RecoveryAlreadySet();
error RecoveryManager__RecoveryNotSet();
error RecoveryManager__RecoveryTimeHasntCompleted();
error RecoveryManager__OnlyForwarder();
error RecoveryManager__AddressesCantBeSame();
error RecoveryManager__RecoveryOrUpkeepNotSet();
error RecoveryManager__RecoveryPeriodNotOver();
error RecoveryManager__RecoveryTimeCompleted();
error RecoveryManager__SignatureNotVerified();

contract RecoveryManagerTest is Test, HelpersConfig, CreateVault {
    ChainConfig public config;
    Vault public vault;
    TokenShieldNft tokenShieldNft;
    RecoveryManager recoveryManager;

    bytes32 public TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    address vaultMinter = vm.addr(40);
    address trustee = vm.addr(41);
    address newOwner = vm.addr(42);

    function setUp() external {
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
            address _vaultImpl,
            address _recoveryManager
        ) = deploy.deploy();
        tokenShieldNft = TokenShieldNft(_tokenShieldNft);

        vm.startPrank(config.contractAdmin);
        vm.deal(config.contractAdmin, 100 ether);
        address vaultAddress = createVault(_tokenShieldNft, _registry, _vaultImpl, _recoveryManager);
        tokenShieldNft.grantRole(TRANSFER_ROLE, _recoveryManager);
        vm.stopPrank();
        vault = Vault(payable(vaultAddress));
        recoveryManager = RecoveryManager(_recoveryManager);
    }

    modifier mintVault() {
        hoax(vaultMinter);
        address _vaultAddress = tokenShieldNft.createSubscription{ value: 0.0012 ether }();
        vault = Vault(payable(_vaultAddress));
        _;
    }

    function test_SetRecovery_RevertsIfNotCalledByTokenShieldOrZeroAddress() external mintVault {
        (,, uint256 tokenId) = vault.token();
        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__NotTokenShieldNft.selector);
        recoveryManager.setRecovery(trustee, tokenId);

        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__AddressCantBeZero.selector);
        tokenShieldNft.setRecovery(tokenId, address(0));
    }

    function test_SetRecovery_RecoveryConfigSetCorrectly() external mintVault {
        (,, uint256 tokenId) = vault.token();
        hoax(vaultMinter);
        tokenShieldNft.setRecovery(tokenId, trustee);

        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);
        assertEq(recoveryConfig.isRecoverySet, true);
        assertEq(recoveryConfig.trustee, trustee);
        // recoveryConfig.
    }

    modifier setRecovery() {
        (,, uint256 tokenId) = vault.token();
        hoax(vaultMinter);
        tokenShieldNft.setRecovery(tokenId, trustee);
        _;
    }

    function test_SetRecovery_RevertsIfAlreadySet() external mintVault setRecovery {
        (,, uint256 tokenId) = vault.token();
        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__RecoveryAlreadySet.selector);
        tokenShieldNft.setRecovery(tokenId, trustee);
    }

    function test_StartRecovery_RevertsIfNotTokenShieldOrRecoveryNotSet() external mintVault {
        (,, uint256 tokenId) = vault.token();
        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__NotTokenShieldNft.selector);
        recoveryManager.setRecovery(trustee, tokenId);

        hoax(address(tokenShieldNft));
        vm.expectRevert(RecoveryManager__RecoveryNotSet.selector);
        recoveryManager.startRecovery(tokenId, newOwner);
    }

    function test_StartRecovery_RevertsIfCalledBeforeEndOfPreviousRecovery() external mintVault setRecovery {
        (,, uint256 tokenId) = vault.token();
        hoax(trustee);
        tokenShieldNft.startRecovery(tokenId, trustee);

        hoax(trustee);
        vm.expectRevert(RecoveryManager__RecoveryTimeHasntCompleted.selector);
        tokenShieldNft.startRecovery(tokenId, trustee);
    }

    modifier startRecovery() {
        (,, uint256 tokenId) = vault.token();
        hoax(trustee);
        tokenShieldNft.startRecovery(tokenId, trustee);
        _;
    }

    function test_StartRecovery_RecoveryConfigSetCorrectly() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();
        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        uint48 expectedStartTimeStamp = uint48(block.timestamp);
        uint48 expectedEndTimeStamp = uint48(block.timestamp) + uint48(7 days);
        uint256 expectedUpkeepId = uint256(uint160(address(recoveryManager))); // This is how it is set in the mock
            // contract to return ID
        address expectedUpkeepForwarder = address(uint160(expectedUpkeepId));

        assertEq(recoveryConfig.recoveryStartTimestamp, expectedStartTimeStamp);
        assertEq(recoveryConfig.recoveryEndTimestamp, expectedEndTimeStamp);
        assertEq(recoveryConfig.isUpkeepSet, true);
        assertEq(recoveryConfig.toAddress, trustee);
        assertEq(recoveryConfig.upkeepId, expectedUpkeepId);
        assertEq(recoveryConfig.upkeepForwarder, expectedUpkeepForwarder);
        assertEq(recoveryConfig.isRecoveryPeriod, true);
        assertEq(recoveryConfig.trustee, trustee);
        assertEq(recoveryConfig.isRecoverySet, true);
    }

    function test_stopRecovery_RevertsIfRecoveryNotSet() external mintVault {
        (,, uint256 tokenId) = vault.token();

        vm.expectRevert(RecoveryManager__RecoveryNotSet.selector);
        hoax(vaultMinter);
        tokenShieldNft.stopRecovery(tokenId, "0x");
    }

    function test_stopRecovery_RevertsIfRecoveryCompleted() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();

        skip(7 days + 1);

        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__RecoveryTimeCompleted.selector);
        tokenShieldNft.stopRecovery(tokenId, "0x");
    }

    function test_stopRecovery_RevertsIfSignatureWrong() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();
        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        bytes32 digest = keccak256(abi.encode(tokenId, recoveryConfig.recoveryEndTimestamp + 1));
        address guardianSigner = config.guardianSigner;

        uint256 PRIVATE_KEY = vm.envUint("SEPOLIA_GUARDIAN_SIGNER_PRIVATE_KEY");
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(PRIVATE_KEY, digest);

        bytes memory signature = abi.encode(v1, r1, s1);

        hoax(vaultMinter);
        vm.expectRevert(RecoveryManager__SignatureNotVerified.selector);
        tokenShieldNft.stopRecovery(tokenId, signature);
    }

    function test_stopRecovery_SetsRecoveryConfigCorrectly() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();
        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        bytes32 digest = keccak256(abi.encode(tokenId, recoveryConfig.recoveryEndTimestamp));
        address guardianSigner = config.guardianSigner;

        uint256 PRIVATE_KEY;

        if (chainId == 31_337) {
            PRIVATE_KEY = 2; //Private key for guardian signer for local chain is 2
        }
        if (chainId == 11_155_111) {
            PRIVATE_KEY = vm.envUint("SEPOLIA_GUARDIAN_SIGNER_PRIVATE_KEY");
        }
        (uint8 v1, bytes32 r1, bytes32 s1) = vm.sign(PRIVATE_KEY, digest);

        bytes memory signature = abi.encodePacked(r1, s1, v1);

        hoax(vaultMinter);
        tokenShieldNft.stopRecovery(tokenId, signature);

        RecoveryManager.RecoveryConfig memory postRecoveryConfig = recoveryManager.getRecoveryConfig(tokenId);
        assertEq(postRecoveryConfig.isRecoveryPeriod, false);
        // assertEq(postRecoveryConfig.);
    }

    function test_checkUpkeep_RevertIfForwarderNotSet() external mintVault setRecovery {
        (,, uint256 tokenId) = vault.token();

        vm.expectRevert(RecoveryManager__OnlyForwarder.selector);
        recoveryManager.checkUpkeep(abi.encode(tokenId));
    }

    function test_checkUpkeep_ReturnsCorrectValue() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();

        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        hoax(recoveryConfig.upkeepForwarder);
        (bool isUpkeepNeeded, bytes memory encodedTokenId) = recoveryManager.checkUpkeep(abi.encode(tokenId));
        assertEq(isUpkeepNeeded, false);
        assertEq(encodedTokenId, "");

        skip(7 days + 1);
        hoax(recoveryConfig.upkeepForwarder);
        (bool isUpkeepNeeded2, bytes memory encodedTokenId2) = recoveryManager.checkUpkeep(abi.encode(tokenId));
        assertEq(isUpkeepNeeded2, true);
        assertEq(abi.decode(encodedTokenId2, (uint256)), tokenId);
    }

    function test_performUpkeep_RevertIfUpkeepNotNeeded() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();

        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        hoax(recoveryConfig.upkeepForwarder);
        vm.expectRevert(RecoveryManager__RecoveryPeriodNotOver.selector);
        recoveryManager.performUpkeep(abi.encode(tokenId));
    }

    function test_performUpkeep_RecoveredCorrectly() external mintVault setRecovery startRecovery {
        (,, uint256 tokenId) = vault.token();

        RecoveryManager.RecoveryConfig memory recoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        skip(7 days + 1);
        hoax(recoveryConfig.upkeepForwarder);
        recoveryManager.performUpkeep(abi.encode(tokenId));

        RecoveryManager.RecoveryConfig memory postRecoveryConfig = recoveryManager.getRecoveryConfig(tokenId);

        address postRecoveryOwner = vault.owner();
        assertEq(postRecoveryConfig.isRecoveryPeriod, false);
        assertEq(postRecoveryOwner, trustee);
        // assertEq()
    }
}
