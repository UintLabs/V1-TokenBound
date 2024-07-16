-include .env

install:; forge install && pnpm install

build:; forge build

deployVault:; forge script script/DeployVault.s.sol:DeployVault --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv
deploy:; forge script script/Deploy.s.sol:Deploy --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv
deployCreateAccount:; forge script script/DeployCreateAccount.s.sol:DeployCreateAccount --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

createVault:; forge script script/CreateVault.s.sol:CreateVault --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

isValidSig:; forge script script/ValidSignature.s.sol:ValidSignature --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) -vvvv

anvil-sep:; anvil --fork-url $(SEPOLIA_RPC_URL) --fork-block-number 4742888 --fork-chain-id 31337

anvil-scrollTest:; anvil --fork-url $(SCROLL_RPC_URL)

signature-test:; forge test --match-path test/unit/VaultSignatureVerifier.t.sol --match-contract VaultSignatureVerifierTest

test-account:; forge test --match-path test/IABAccount.t.sol --match-contract IABAccountTest

deploy-mock-nft:; forge script script/DeployMocks.s.sol:DeployERC721 --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

deploy-mock-erc20:; forge script script/DeployMocks.s.sol:DeployERC20 --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv