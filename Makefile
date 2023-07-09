-include .env

build:; forge build

deploy:; forge script script/Deploy.s.sol:Deploy --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast
deployCreateAccount:; forge script script/DeployCreateAccount.s.sol:DeployCreateAccount --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

isValidSig:; forge script script/ValidSignature.s.sol:ValidSiganture --rpc-url=http:127.0.0.1:8545 --private-key $(PRIVATE_KEY) --broadcast -vvvv

anvil-sep:; anvil --fork-url $(SEPOLIA_RPC_URL)

testing:
	echo "Testing if this works"
	echo "this works!!!!"