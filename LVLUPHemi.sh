# Функция для вывода текста оранжевым цветом (в терминале будет отображаться как желтый)
show() {
    # ANSI код для желтого цвета: \033[33m
    # Сброс цвета: \033[0m
    echo -e "\033[33m$1\033[0m"
}


# Display ASCII Art "LEVEL UP"
show ".-----------------------------------------------."
show "| _     _______     _______ _       _   _ ____  |"
show "|| |   | ____\ \   / / ____| |     | | | |  _ \ |"
show "|| |   |  _|  \ \ / /|  _| | |     | | | | |_) ||"
show "|| |___| |___  \ V / | |___| |___  | |_| |  __/ |"
show "||_____|_____|  \_/  |_____|_____|  \___/|_|    |"
show "| _   _  ___  ____  _____ ____                  |"
show "|| \ | |/ _ \|  _ \| ____/ ___|                 |"
show "||  \| | | | | | | |  _| \___ \                 |"
show "|| |\  | |_| | |_| | |___ ___) |                |"
show "||_| \_|\___/|____/|_____|____/                 |"
show "'-----------------------------------------------'"


# Твоя команда с использованием функции show
show "Создание директории и переход в нее"
mkdir Hemi-Node && cd Hemi-Node

show "Скачивание нужного архива..."
wget https://github.com/hemilabs/heminetwork/releases/download/v0.4.3/heminetwork_v0.4.3_linux_amd64.tar.gz

show "Распаковка архива..."
tar -zxvf heminetwork_v0.4.3_linux_amd64.tar.gz 

show "Удаление архива..."
rm heminetwork_v0.4.3_linux_amd64.tar.gz 

show "Переход в распакованную директорию..."
cd heminetwork_v0.4.3_linux_amd64/

show "Проверка содержимого директории..."
ls

show "Сделать файл popmd исполняемым..."
chmod +x ./popmd

show "Вывод справки..."
./popmd --help

show "Генерация ключей и сохранение в JSON файл..."
./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json

show "Проверка содержимого JSON файла..."
cat ~/popm-address.json

show "Автоматическое присваивание переменных из JSON..."
eval $(jq -r '. | "ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)"' ~/popm-address.json)

show "Вывод переменных..."
echo "Ethereum Address: $ETHEREUM_ADDRESS"
echo "Network: $NETWORK"
echo "Private Key: $PRIVATE_KEY"
echo "Public Key: $PUBLIC_KEY"
echo "Public Key Hash: $PUBKEY_HASH"

show "Экспорт переменных окружения..."
export POPM_BTC_PRIVKEY=PRIVATE_KEY
export POPM_STATIC_FEE=50
export POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public

echo ""
echo ""
echo ""
echo ""


show "1. Заходи в дискорд Hemi 'https://discord.gg/hemixyz' и запроси tBTC в кошельке на этот адрес: $PUBKEY_HASH"
show "2. Проверь здесь что Биточек пришел 'https://mempool.space/testnet/address/$PUBKEY_HASH'"
show "3. Создай новую сессию screen и запусти в ней .popmd"
