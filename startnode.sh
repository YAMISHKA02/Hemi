cd Hemi-Node/heminetwork_v0.4.3_linux_amd64/

screen -S Hemi_node

# Экспорт переменных из JSON
eval $(jq -r '. | "ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)"' ~/popm-address.json)

# Экспорт ключей для popmd
export POPM_BTC_PRIVKEY=$PRIVATE_KEY
export POPM_STATIC_FEE=50
export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public



# Запуск popmd
./popmd
