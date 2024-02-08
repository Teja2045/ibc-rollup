# ibc-rollup

A Mock rollup with ibc integrations and relayer setup

NOTE: go mod uses a local rollkit repo. Remove that replace line for rollkit

- init-testnet-1.sh is the script for chain 1
- init-testnet-2.sh is the script for chain 2
- go-relayer-setup.sh is the script for relayer setup (prerequisite is being installation of go relayer)
- A DA chain should keep running (use this docker image)
     sudo docker run -it  -p 26650:26650 -p 26657:26657 -p 26658:26658 -p 26659:26659 -p 9090:9090  ghcr.io/rollkit/local-celestia-devnet:v0.12.7

