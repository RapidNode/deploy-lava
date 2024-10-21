#! /bin/bash


# Variables
PROJECT=lava
EXECUTE=lavad
SYSTEM_FOLDER=.lava
PORT=26

#fast sync with snapshot
# wget -q -O - https://polkachu.com/testnets/${PROJECT}/snapshots > webpage.html
# SNAPSHOT=$(grep -o "https://snapshots.polkachu.com/testnet-snapshots/${PROJECT}/${PROJECT}_[0-9]*.tar.lz4" webpage.html | head -n 1)
#SNAPSHOT=https://snapshots.kjnodes.com/lava-testnet/snapshot_latest.tar.lz4

wget -q -O /root/webpage_lava.html https://server-4.itrocket.net/testnet/lava/
SNAPSHOT=https://server-4.itrocket.net/testnet/lava/$(grep -o "lava_[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}_[0-9]*_snap\.tar\.lz4" /root/webpage_lava.html | tail -n 1)

cp $HOME/$SYSTEM_FOLDER/data/priv_validator_state.json $HOME/$SYSTEM_FOLDER/priv_validator_state.json.backup
cp $HOME/$SYSTEM_FOLDER/config/priv_validator_key.json $HOME/$SYSTEM_FOLDER/priv_validator_key.json.backup

lavad tendermint unsafe-reset-all --home /root/.lava --keep-addr-book
curl -L $SNAPSHOT | tar -I lz4 -xf - -C $HOME/$SYSTEM_FOLDER

mv $HOME/$SYSTEM_FOLDER/priv_validator_state.json.backup $HOME/$SYSTEM_FOLDER/data/priv_validator_state.json
mv $HOME/$SYSTEM_FOLDER/priv_validator_key.json.backup $HOME/$SYSTEM_FOLDER/config/priv_validator_key.json

# Upgrade info
[[ -f $HOME/$SYSTEM_FOLDER/data/upgrade-info.json ]] && cp $HOME/$SYSTEM_FOLDER/data/upgrade-info.json $HOME/$SYSTEM_FOLDER/cosmovisor/genesis/upgrade-info.json

PEERS="a0e6000a402bfffdb4d953fc2e7913c4473a8b22@138.201.195.237:26676,99327e5cf0f31ac3bb1ca8e39cc9f17c823b7ec1@65.109.25.104:26656,58c9655482c7dbd3dc30221f8742c4f6d2e963f1@65.109.25.109:56656,05a256658f0400777c24829021a9927cda6bc29e@51.222.241.155:26656,17a580accb1050271e1c377958c70e1286a0ba8f@65.109.115.104:56656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@lava-testnet.rpc.kjnodes.com:14456,290d562781dd46eaa66eb88f87b60e888550ae44@65.109.92.148:61356,424a2078e7719b0f50d06913e91fb221a9c19149@168.119.5.125:14456,8a85cdaa219445ab9680fa1b7b53453a01f935bb@5.9.142.147:14456,3693ea5a8a9c0590440a7d6c9a98a022ce3b2455@lava-testnet-rpc.itrocket.net:20656,706fc0f682c33ab8deb0aa84c797dc2d1d0119b4@rpc.nodejumper.io:26656,3693ea5a8a9c0590440a7d6c9a98a022ce3b2455@65.109.92.79:20656,655e66e1287f483d14754746309be535c57537de@176.9.28.41:26656,67f214e3aac9aa30e1ded487033c3e67a7060edd@65.108.72.233:16656,1377a4d43745a650fe21cc87641818854e9fbdcf@95.217.148.179:35656,325a6922ac5fa5803f312e07a3894fbc525c4285@69.67.149.175:30656,7df67ee9624ba99cda739b22b68dce20a873982b@138.201.227.119:14556,5b305148d0ad48113d5d4a1203b9b8be28b15c91@149.50.110.220:56656,df05175604b7b63d7913ac3a999c4a3b97d75a42@149.50.116.108:56656,b1806dfabc9bb5fb721b3f82628a3fb23a2ad786@lava-testnet-rpc.stake-town.com:30656"
sed -i -e "/^\[p2p\]/,/^\[/{s/^[[:space:]]*persistent_peers *=.*/persistent_peers = \"$PEERS\"/}" $HOME/.lava/config/config.toml

wget -O $HOME/.lava/config/addrbook.json https://server-4.itrocket.net/testnet/lava/addrbook.json
wget -O $HOME/.lava/config/genesis.json https://server-4.itrocket.net/testnet/lava/genesis.json

sudo systemctl daemon-reload
sudo systemctl enable $EXECUTE
sudo systemctl restart $EXECUTE

echo "export NODE_PROPERLY_INSTALLED=true" >> $HOME/.bash_profile

echo '=============== SETUP IS FINISHED ==================='
echo -e "CHECK OUT YOUR LOGS : \e[1m\e[32mjournalctl -fu ${EXECUTE} -o cat\e[0m"
echo -e "CHECK SYNC: \e[1m\e[32mcurl -s localhost:${PORT}657/status | jq .result.sync_info\e[0m"
source $HOME/.bash_profile

