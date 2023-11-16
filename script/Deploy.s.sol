// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { TokenShieldSubscription as TokenShieldNft } from "src/TokenShieldSubscription.sol";
import { IABAccount } from "src/IABAccount.sol";
import { MockAggregatorV3 } from "src/mock/MockPriceFeeds.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";

contract Deploy is Script, HelpersConfig {
    using Strings for string;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    struct Tx {
        address to;
        uint256 value;
        uint256 nonce;
        bytes data;
    }

    function run() external returns (ERC6551Registry, EntryPoint, IABGuardian, TokenShieldNft, IABAccount) {
        // bytes memory code = registryBytecode;
        uint256 privateKey;
        if (chainId == 11_155_111) {
            privateKey = vm.envUint("SEPOLIA_PRIVATE_KEY");
        } else {
            privateKey = vm.envUint("PRIVATE_KEY");
        }
        vm.startBroadcast(privateKey);
        (
            ERC6551Registry registry,
            EntryPoint entryPoint,
            IABGuardian iabGuardian,
            TokenShieldNft insureNft,
            IABAccount accountImpl
        ) = deploy();
        vm.stopBroadcast();
        writeLatestFile(registry, entryPoint, iabGuardian, insureNft, accountImpl);
        return (registry, entryPoint, iabGuardian, insureNft, accountImpl);
    }

    function deploy() public returns (ERC6551Registry, EntryPoint, IABGuardian, TokenShieldNft, IABAccount) {
        ChainConfig memory config = getConfig();
        address owner = config.contractAdmin;
        address guardianSigner = config.guardianSigner;
        address guardianSetter = config.guardianSetter;
        // address ethPriceFeed = config.ethPriceFeed;
        // string memory domainName = config.domainName;
        // string memory domainVersion = config.domainVersion;
        ERC6551Registry registry;
        if (chainId == 11_155_111) {
            registry = ERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921);
        } else {
            registry = new ERC6551Registry{salt:"655165516551"}();
            MockAggregatorV3 mockPriceFeed = new MockAggregatorV3();
            config.ethPriceFeed = address(mockPriceFeed);
        }
        // address registry = Create2.deploy(0,bytes32("0x6551"),keccak256(code));
        EntryPoint entryPoint = new EntryPoint{salt:"655165516551"}();
        IABGuardian iabGuardian = new IABGuardian{salt:"655165516551"}(owner,guardianSigner,guardianSetter);
        // ERC1967Proxy guardianProxy =
        // new ERC1967Proxy{salt:"6551"}(address(iabGuardian),
        // abi.encodeWithSelector(accountGuardianImpl.initialize.selector, guardians,2));
        TokenShieldNft insureNftImpl = new TokenShieldNft{salt:"655165516551"}();
        ERC1967Proxy insureNftProxy = new ERC1967Proxy{salt:"655165516551"}(address(insureNftImpl), 
                                        abi.encodeWithSelector(insureNftImpl.initialize.selector, 
                                            "InusreABag","IAB", owner, config.ethPriceFeed));
        IABAccount accountImpl = new IABAccount{salt:"655165516551"}(address(iabGuardian),address(entryPoint));
        TokenShieldNft nftPolicy = TokenShieldNft(address(insureNftProxy));
        return (registry, entryPoint, iabGuardian, nftPolicy, accountImpl);
    }

    function writeLatestFile(
        ERC6551Registry registry,
        EntryPoint entryPoint,
        IABGuardian iabGuardian,
        TokenShieldNft nftPolicy,
        IABAccount accountImpl
    )
        public
    {
        string memory root = vm.projectRoot();
        /* solhint-disable */
        string memory registryTxt = string.concat('"registry"', ":", '"', Strings.toHexString(address(registry)), '"');
        string memory entryPointTxt =
            string.concat('"entryPoint"', ":", '"', Strings.toHexString(address(entryPoint)), '"');
        string memory iabGuardianTxt =
            string.concat('"iabGuardian"', ":", '"', Strings.toHexString(address(iabGuardian)), '"');
        string memory nftPolicyTxt =
            string.concat('"nftPolicy"', ":", '"', Strings.toHexString(address(nftPolicy)), '"');
        string memory accountImplTxt =
            string.concat('"accountImpl"', ":", '"', Strings.toHexString(address(accountImpl)), '"');
        vm.writeFile(
            string.concat(root, "/deployments/latest.json"),
            string.concat(
                "{", registryTxt, ",", entryPointTxt, ",", iabGuardianTxt, ",", nftPolicyTxt, ",", accountImplTxt, "}"
            )
        );
        /* solhint-enable */
    }
}
