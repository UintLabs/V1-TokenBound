// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Deploy } from "script/Deploy.s.sol";
import { ERC6551Registry } from "src/registry/ERC6551Registry.sol";
import { EntryPoint } from "src/EntryPoint.sol";
import { IABGuardian } from "src/IABGuardian.sol";
import { InsureaBag as InsureaBagNft } from "src/InsureaBag.sol";
import { IABAccount } from "src/IABAccount.sol";
import { console } from "forge-std/console.sol";
import { ERC1967Proxy } from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Strings } from "lib/openzeppelin-contracts/contracts/utils/Strings.sol";
import { Vm, VmSafe } from "forge-std/Vm.sol";
import { HelpersConfig } from "script/helpers/HelpersConfig.s.sol";

contract DeployCreateAccount is Script, HelpersConfig {
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

    address user1 = vm.addr(4);

    function run() external {
        // Deploy deployer = new Deploy();
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
            IABGuardian guardian,
            InsureaBagNft nftPolicy,
            IABAccount accountImpl
        ) = deploy();
        address tbAccount = create(nftPolicy, accountImpl, registry);
        writeLatestFile(registry, entryPoint, guardian, nftPolicy, accountImpl, tbAccount);
        console.log("Finishing transaction.....");
        vm.stopBroadcast();
    }

    function deploy() public returns (ERC6551Registry, EntryPoint, IABGuardian, InsureaBagNft, IABAccount) {
        ChainConfig memory config = getConfig();
        address owner = config.contractAdmin;
        address guardianSigner = config.guardianSigner;
        address guardianSetter = config.guardianSetter;
        ERC6551Registry registry;
        if (chainId == 11_155_111) {
            registry = ERC6551Registry(0x02101dfB77FDE026414827Fdc604ddAF224F0921);
        } else {
            registry = new ERC6551Registry{salt:"65516551"}();
        }
        EntryPoint entryPoint = new EntryPoint{salt:"65516551"}();
        IABGuardian iabGuardian = new IABGuardian{salt:"65516551"}(owner,guardianSigner,guardianSetter);

        InsureaBagNft insureNftImpl = new InsureaBagNft{salt:"65516551"}();
        ERC1967Proxy insureNftProxy = new ERC1967Proxy{salt:"6551"}(address(insureNftImpl), 
                                        abi.encodeWithSelector(insureNftImpl.initialize.selector, 
                                        "InusreABag","IAB", owner));
        IABAccount accountImpl = new IABAccount{salt:"65516551"}(address(iabGuardian),address(entryPoint));
        InsureaBagNft nftPolicy = InsureaBagNft(address(insureNftProxy));
        return (registry, entryPoint, iabGuardian, nftPolicy, accountImpl);
    }

    function create(
        InsureaBagNft nftPolicy,
        IABAccount accountImpl,
        ERC6551Registry registry
    )
        public
        returns (address)
    {
        ChainConfig memory config = getConfig();
        string memory domainName = config.domainName;
        string memory domainVersion = config.domainVersion;
        nftPolicy.toggleMint();
        nftPolicy.setImplementationAddress(address(accountImpl));
        nftPolicy.setRegistryAddress(address(registry));
        vm.recordLogs();
        nftPolicy.createInsurance();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        address tbAccount = abi.decode(entries[1].data, (address));
        IABAccount account = IABAccount(payable(tbAccount));
        // account.setDomainSeperator(domainName, domainVersion);
        console.log(tbAccount);
        return tbAccount;
    }

    function writeLatestFile(
        ERC6551Registry registry,
        EntryPoint entryPoint,
        IABGuardian iabGuardian,
        InsureaBagNft nftPolicy,
        IABAccount accountImpl,
        address tbAccount
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
        string memory tbAccountTxt =
            string.concat('"tbAccount"', ":", '"', Strings.toHexString(address(tbAccount)), '"');
        vm.writeFile(
            string.concat(root, "/deployments/latestWithAccount.json"),
            string.concat(
                "{",
                registryTxt,
                ",",
                entryPointTxt,
                ",",
                iabGuardianTxt,
                ",",
                nftPolicyTxt,
                ",",
                accountImplTxt,
                ",",
                tbAccountTxt,
                "}"
            )
        );
        /* solhint-enable */
    }
}
