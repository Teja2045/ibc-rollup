#!/bin/bash

RELAYER_PATH="/home/vitwit/.relayer"
CONFIG_FILE="$RELAYER_PATH/config/config.yaml"

CHAIN_ID_1="testnet-1"
KEY_1="t1-key-1"
RPC_1="http://localhost:36657"
PREFIX_1="gm"
GAS_PRICES_1="1000stake"
MNEMONIC_1="park enroll tower sad cattle major firm egg word pyramid island wave again melt behind laptop bronze cream title service upper betray very bitter"

CHAIN_ID_2="testnet-2"
KEY_2="t2-key-1"
RPC_2="http://localhost:16657"
PREFIX_2="gm"
GAS_PRICES_2="1000stake"
MNEMONIC_2="egg drill elevator shaft rose engage holiday hire weekend evidence muffin home force copper fluid fee cable smile topple earth accident parent wreck wet"

# Remove existing config.yaml
rm -f "$CONFIG_FILE"

# Run rly config init to generate a new config.yaml
rly config init

# Define the new chains information
NEW_CHAINS=$(cat <<EOF
chains:
    $CHAIN_ID_1:
        type: cosmos
        value:
            key-directory: $RELAYER_PATH/keys/$CHAIN_ID_1
            key: $KEY_1
            chain-id: $CHAIN_ID_1
            rpc-addr: $RPC_1
            account-prefix: $PREFIX_1
            keyring-backend: test
            gas-adjustment: 2
            gas-prices: $GAS_PRICES_1
            min-gas-amount: 0
            max-gas-amount: 1000000000
            debug: false
            timeout: 20s
            block-timeout: ""
            output-format: json
            sign-mode: direct
            extra-codecs: []
            coin-type: 118
            signing-algorithm: ""
            broadcast-mode: batch
            min-loop-duration: 0s
            extension-options: []
            feegrants: null
    $CHAIN_ID_2:
        type: cosmos
        value:
            key-directory: $RELAYER_PATH/keys/$CHAIN_ID_2
            key: $KEY_2
            chain-id: $CHAIN_ID_2
            rpc-addr: $RPC_2
            account-prefix: $PREFIX_2
            keyring-backend: test
            gas-adjustment: 2
            gas-prices: $GAS_PRICES_2
            min-gas-amount: 0
            max-gas-amount: 100000000
            debug: false
            timeout: 20s
            block-timeout: ""
            output-format: json
            sign-mode: direct
            extra-codecs: []
            coin-type: 118
            signing-algorithm: ""
            broadcast-mode: batch
            min-loop-duration: 0s
            extension-options: []
            feegrants: null
paths:
EOF
)

# Update the chains section in the configuration file
sed '/^chains:/,/^[a-zA-Z]*:/d' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
echo "$NEW_CHAINS" >> "$CONFIG_FILE.tmp"
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo "Configuration file updated successfully."

rly keys restore $CHAIN_ID_1 $KEY_1 "$MNEMONIC_1"
rly keys restore $CHAIN_ID_2 $KEY_2 "$MNEMONIC_2"

rly paths new testnet-1 testnet-2 transfer-path
rly tx link transfer-path --src-port transfer --dst-port transfer
rly start
