// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { AccountGuardian } from "src/AccountGuardian.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Create2 } from "openzeppelin-contracts/utils/Create2.sol";
import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import { console } from "forge-std/console.sol";
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

    function run() external returns (ERC6551Registry, EntryPoint, IABGuardian, InsureaBagNft, IABAccount) {
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
            InsureaBagNft insureNft,
            IABAccount accountImpl
        ) = deploy();
        vm.stopBroadcast();
        writeLatestFile(registry, entryPoint, iabGuardian, insureNft, accountImpl);
        return (registry, entryPoint, iabGuardian, insureNft, accountImpl);
    }

    function deploy() public returns (ERC6551Registry, EntryPoint, IABGuardian, InsureaBagNft, IABAccount) {
        ChainConfig memory config = getConfig();
        address owner = config.contractAdmin;
        address guardianSigner = config.guardianSigner;
        address guardianSetter = config.guardianSetter;
        // string memory domainName = config.domainName;
        // string memory domainVersion = config.domainVersion;
        ERC6551Registry registry;
        if (chainId == 11_155_111) {
            registry = ERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921);
        } else {
            registry = new ERC6551Registry{salt:"6551"}();
        }
        // address registry = Create2.deploy(0,bytes32("0x6551"),keccak256(code));
        EntryPoint entryPoint = new EntryPoint{salt:"6551"}();
        IABGuardian iabGuardian = new IABGuardian{salt:"6551"}(owner,guardianSigner,guardianSetter);
        // ERC1967Proxy guardianProxy =
        // new ERC1967Proxy{salt:"6551"}(address(iabGuardian),
        // abi.encodeWithSelector(accountGuardianImpl.initialize.selector, guardians,2));
        InsureaBagNft insureNftImpl = new InsureaBagNft{salt:"6551"}();
        ERC1967Proxy insureNftProxy =
        new ERC1967Proxy{salt:"6551"}(address(insureNftImpl), abi.encodeWithSelector(insureNftImpl.initialize.selector, "InusreABag","IAB", owner));
        IABAccount accountImpl = new IABAccount{salt:"6551"}(address(iabGuardian),address(entryPoint));
        InsureaBagNft nftPolicy = InsureaBagNft(address(insureNftProxy));
        return (registry, entryPoint, iabGuardian, nftPolicy, accountImpl);
    }

    function writeLatestFile(
        ERC6551Registry registry,
        EntryPoint entryPoint,
        IABGuardian iabGuardian,
        InsureaBagNft nftPolicy,
        IABAccount accountImpl
    )
        public
    {
        string memory root = vm.projectRoot();
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
    }
}
