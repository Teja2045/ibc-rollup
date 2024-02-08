#!/bin/sh

# set variables for the chain
VALIDATOR_NAME=t2validator-1
CHAIN_ID=testnet-2
KEY_NAME=t2-key-1
KEY_2_NAME=t2-key-2
CHAINFLAG="--chain-id ${CHAIN_ID}"
TOKEN_AMOUNT="10000000000000000000000000stake"
STAKING_AMOUNT="1000000000stake"
MNEMONIC_1="egg drill elevator shaft rose engage holiday hire weekend evidence muffin home force copper fluid fee cable smile topple earth accident parent wreck wet"
MNEMONIC_2="pet badge stomach spare lounge mammal produce dance tooth helmet rural horror sun blade build settle puzzle include walk harbor radio awesome luggage multiply"

# query the DA Layer start height, in this case we are querying
# our local devnet at port 26657, the RPC. The RPC endpoint is
# to allow users to interact with Celestia's nodes by querying
# the node's state and broadcasting transactions on the Celestia
# network. The default port is 26657.
DA_BLOCK_HEIGHT=$(curl http://0.0.0.0:26657/block | jq -r '.result.block.header.height')
# DA_BLOCK_HEIGHT=$(curl http://localhost:8000/v1/latest_block | jq -r '.latest_block')

# rollkit logo
cat <<'EOF'
                 :=+++=.                
              -++-    .-++:             
          .=+=.           :++-.         
       -++-                  .=+=: .    
   .=+=:                        -%@@@*  
  +%-                       .=#@@@@@@*  
    -++-                 -*%@@@@@@%+:   
       .=*=.         .=#@@@@@@@%=.      
      -++-.-++:    =*#@@@@@%+:.-++-=-   
  .=+=.       :=+=.-: @@#=.   .-*@@@@%  
  =*=:           .-==+-    :+#@@@@@@%-  
     :++-               -*@@@@@@@#=:    
        =%+=.       .=#@@@@@@@#%:       
     -++:   -++-   *+=@@@@%+:   =#*##-  
  =*=.         :=+=---@*=.   .=*@@@@@%  
  .-+=:            :-:    :+%@@@@@@%+.  
      :=+-             -*@@@@@@@#=.     
         .=+=:     .=#@@@@@@%*-         
             -++-  *=.@@@#+:            
                .====+*-.  
   ______         _  _  _     _  _   
   | ___ \       | || || |   (_)| |  
   | |_/ /  ___  | || || | __ _ | |_ 
   |    /  / _ \ | || || |/ /| || __|
   | |\ \ | (_) || || ||   < | || |_ 
   \_| \_| \___/ |_||_||_|\_\|_| \__|
EOF

# echo variables for the chain
echo -e "\n Your DA_BLOCK_HEIGHT is $DA_BLOCK_HEIGHT \n"

# build the gm chain with Rollkit
# ignite chain build

# # reset any existing genesis/chain data
gmd tendermint unsafe-reset-all --home /home/vitwit/.gm1

# # initialize the validator with the chain ID you set
gmd init $VALIDATOR_NAME --chain-id $CHAIN_ID --home /home/vitwit/.gm1

# # add keys for key 1 and key 2 to keyring-backend test
echo $MNEMONIC_1 | gmd keys add $KEY_NAME --recover --keyring-backend=test --home /home/vitwit/.gm1
echo $MNEMONIC_2 | gmd keys add $KEY_2_NAME --recover --keyring-backend=test --home /home/vitwit/.gm1

# # add these as genesis accounts
gmd genesis add-genesis-account $KEY_NAME $TOKEN_AMOUNT --keyring-backend test --home /home/vitwit/.gm1
gmd genesis add-genesis-account $KEY_2_NAME $TOKEN_AMOUNT --keyring-backend test --home /home/vitwit/.gm1

echo "----------update config--------------"
GRPC="9092"
sed -i 's#localhost:9090#localhost:'${GRPC}'#g' ~/.gm1/config/app.toml
sed -i 's/laddr = \"tcp:\/\/127.0.0.1:26657\"/laddr = \"tcp:\/\/0.0.0.0:16657\"/' ~/.gm1/config/config.toml
sed -i 's/laddr = \"tcp:\/\/127.0.0.1:26656\"/laddr = \"tcp:\/\/0.0.0.0:16656\"/' ~/.gm1/config/config.toml
sed -i 's/"max_expected_time_per_block": "30000000000"/"max_expected_time_per_block": "75000000000"/' ~/.gm1/config/genesis.json

# # set the staking amounts in the genesis transaction
gmd genesis gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID --keyring-backend test --home /home/vitwit/.gm1

# collect genesis transactions
gmd genesis collect-gentxs --home /home/vitwit/.gm1

# # copy centralized sequencer address into genesis.json
# # Note: validator and sequencer are used interchangeably here
ADDRESS=$(jq -r '.address' ~/.gm1/config/priv_validator_key.json)
PUB_KEY=$(jq -r '.pub_key' ~/.gm1/config/priv_validator_key.json)
jq --argjson pubKey "$PUB_KEY" '.consensus["validators"]=[{"address": "'$ADDRESS'", "pub_key": $pubKey, "power": "1000", "name": "Rollkit Sequencer"}]' ~/.gm1/config/genesis.json > temp.json && mv temp.json ~/.gm1/config/genesis.json

# # create a restart-local.sh file to restart the chain later
# [ -f restart-local.sh ] && rm restart-local.sh
echo "DA_BLOCK_HEIGHT=$DA_BLOCK_HEIGHT" >> restart2-local.sh

echo "gmd start --rollkit.aggregator true --rollkit.da_address=":26650" --rollkit.da_start_height \$DA_BLOCK_HEIGHT --rpc.laddr tcp://127.0.0.1:36657 --p2p.laddr \"0.0.0.0:36656\" --minimum-gas-prices="0.025stake"" >> restart-local.sh

# start the chain
gmd start --home /home/vitwit/.gm1 --rollkit.aggregator true --rollkit.da_address=":26650" --rollkit.da_start_height $DA_BLOCK_HEIGHT --rpc.laddr tcp://127.0.0.1:16657 --p2p.laddr "0.0.0.0:16656" --minimum-gas-prices="0.0stake"
# gmd start --home /home/chandini/.gmchain1 start --rollkit.aggregator true --rollkit.da_address="127.0.0.1:3000" --rollkit.da_start_height $DA_BLOCK_HEIGHT