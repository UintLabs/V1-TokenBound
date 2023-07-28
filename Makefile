-include .env

build:; forge build

deploy:; forge script script/Deploy.s.sol:Deploy --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv
deployCreateAccount:; forge script script/DeployCreateAccount.s.sol:DeployCreateAccount --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

isValidSig:; forge script script/ValidSignature.s.sol:ValidSignature --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) -vvvv

anvil-sep:; anvil --fork-url $(SEPOLIA_RPC_URL) --fork-block-number 3960841 --fork-chain-id 31337

account-test:; forge test --match-path test/IABAccount.t.sol --match-contract IABAccountTest

testing:
	echo "Testing if this works"
	echo "this works!!!!"