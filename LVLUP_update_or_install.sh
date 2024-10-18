#!/bin/bash

# Создание папки Hemi-Node в текущей директории и переход в неё
mkdir -p "$(pwd)/Hemi-Node"
cd "$(pwd)/Hemi-Node" || { echo "Не удалось перейти в директорию Hemi-Node."; exit 1; }

ARCH=$(uname -m)

show() {
    echo -e "\033[1;35m$1\033[0m"
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



if ! command -v jq &> /dev/null; then
    show "jq не найден, установка..."
    sudo apt-get update
    sudo apt-get install -y jq > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        show "Не удалось установить jq. Проверьте ваш менеджер пакетов."
        exit 1
    fi
fi

check_latest_version() {
    for i in {1..3}; do
        LATEST_VERSION=$(curl -s https://api.github.com/repos/hemilabs/heminetwork/releases/latest | jq -r '.tag_name')
        if [ -n "$LATEST_VERSION" ]; then
            show "Доступна последняя версия: $LATEST_VERSION"
            return 0
        fi
        show "Попытка $i: Не удалось получить последнюю версию. Повторная попытка..."
        sleep 2
    done

    show "Не удалось получить последнюю версию после 3 попыток. Проверьте соединение с интернетом или лимиты API GitHub."
    exit 1
}

check_latest_version

download_required=true

if [ "$ARCH" == "x86_64" ]; then
    if [ -d "heminetwork_${LATEST_VERSION}_linux_amd64" ]; then
        show "Последняя версия для x86_64 уже загружена. Пропуск загрузки."
        cd "heminetwork_${LATEST_VERSION}_linux_amd64" || { show "Не удалось перейти в директорию."; exit 1; }
        download_required=false  # Устанавливаем флаг в false
    fi
elif [ "$ARCH" == "arm64" ]; then
    if [ -d "heminetwork_${LATEST_VERSION}_linux_arm64" ]; then
        show "Последняя версия для arm64 уже загружена. Пропуск загрузки."
        cd "heminetwork_${LATEST_VERSION}_linux_arm64" || { show "Не удалось перейти в директорию."; exit 1; }
        download_required=false  # Устанавливаем флаг в false
    fi
fi

if [ "$download_required" = true ]; then
    if [ "$ARCH" == "x86_64" ]; then
        show "Загрузка для архитектуры x86_64..."
        wget --quiet --show-progress "https://github.com/hemilabs/heminetwork/releases/download/$LATEST_VERSION/heminetwork_${LATEST_VERSION}_linux_amd64.tar.gz" -O "heminetwork_${LATEST_VERSION}_linux_amd64.tar.gz"
        tar -xzf "heminetwork_${LATEST_VERSION}_linux_amd64.tar.gz" > /dev/null
        cd "heminetwork_${LATEST_VERSION}_linux_amd64" || { show "Не удалось перейти в директорию."; exit 1; }
    elif [ "$ARCH" == "arm64" ]; then
        show "Загрузка для архитектуры arm64..."
        wget --quiet --show-progress "https://github.com/hemilabs/heminetwork/releases/download/$LATEST_VERSION/heminetwork_${LATEST_VERSION}_linux_arm64.tar.gz" -O "heminetwork_${LATEST_VERSION}_linux_arm64.tar.gz"
        tar -xzf "heminetwork_${LATEST_VERSION}_linux_arm64.tar.gz" > /dev/null
        cd "heminetwork_${LATEST_VERSION}_linux_arm64" || { show "Не удалось перейти в директорию."; exit 1; }
    else
        show "Неподдерживаемая архитектура: $ARCH"
        exit 1
    fi
else
    show "Пропуск загрузки, так как последняя версия уже присутствует."
fi

echo
show "Выберите только один вариант:"
show "1. Использовать новый кошелек для PoP майнинга"
show "2. Использовать существующий кошелек для PoP майнинга"
read -p "Введите ваш выбор (new/old): " choice
echo

if [ "$choice" == "new" ]; then
    show "Создание нового кошелька..."
    ./keygen -secp256k1 -json -net="testnet" > ~/popm-address.json
    if [ $? -ne 0 ]; then
        show "Не удалось создать кошелек."
        exit 1
    fi
    cat ~/popm-address.json
    echo
    read -p "Вы сохранили указанные выше данные? (y/N): " saved
    echo
    if [[ "$saved" =~ ^[Yy]$ ]]; then
        pubkey_hash=$(jq -r '.pubkey_hash' ~/popm-address.json)
        show "Присоединяйтесь: https://discord.gg/hemixyz"
        show "Запросите средства на этот адрес в канале faucet: $pubkey_hash"
        echo
        read -p "Вы запросили средства? (y/N): " faucet_requested
        if [[ "$faucet_requested" =~ ^[Yy]$ ]]; then
            priv_key=$(jq -r '.private_key' ~/popm-address.json)
            read -p "Введите статическую комиссию (только цифры, рекомендуется: 100-200): " static_fee
            echo
        fi
    fi

elif [ "$choice" == "old" ]; then
    read -p "Введите ваш приватный ключ: " priv_key
    read -p "Введите статическую комиссию (только цифры, рекомендуется: 100-200): " static_fee
    echo
fi

if systemctl is-active --quiet hemi.service; then
    show "hemi.service в данный момент запущен. Остановка и отключение..."
    sudo systemctl stop hemi.service
    sudo systemctl disable hemi.service
else
    show "hemi.service не запущен."
fi

cat << EOF | sudo tee /etc/systemd/system/hemi.service > /dev/null
[Unit]
Description=Hemi Network popmd Service
After=network.target

[Service]
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/popmd
Environment="POPM_BFG_REQUEST_TIMEOUT=60s"
Environment="POPM_BTC_PRIVKEY=$priv_key"
Environment="POPM_STATIC_FEE=$static_fee"
Environment="POPM_BFG_URL=wss://testnet.rpc.hemi.network/v1/ws/public"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable hemi.service
sudo systemctl start hemi.service
echo
show "PoP майнинг успешно запущен"
