-include .env

install:; forge install && pnpm install

build:; forge build

tests:; forge t

anvil-sep:; anvil --fork-url $(SEPOLIA_RPC_URL) --fork-block-number 4742888 --fork-chain-id 31337

anvil-scrollTest:; anvil --fork-url $(SCROLL_RPC_URL)

