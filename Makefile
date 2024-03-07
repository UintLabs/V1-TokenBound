-include .env

build:; forge build

deployVault:; forge script script/DeployVault.s.sol:DeployVault --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

createVault:; forge script script/CreateVault.s.sol:CreateVault --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

anvil-sep:; anvil --fork-url $(SEPOLIA_RPC_URL) --fork-block-number 4742888 --fork-chain-id 31337

signature-test:; forge test --match-path test/unit/VaultSignatureVerifier.t.sol --match-contract VaultSignatureVerifierTest

deploy-mock-nft:; forge script script/DeployMocks.s.sol:DeployERC721 --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

deploy-mock-erc20:; forge script script/DeployMocks.s.sol:DeployERC20 --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv