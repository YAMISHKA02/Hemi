#!/bin/bash

# Функция для вывода текста оранжевым цветом
show() {
    echo -e "\033[33m$1\033[0m"
}

# Вывод текста построчно
show " ____   _   _  ___  ____   _   _  _  __    _    "
show "/ ___| | | | ||_ _|/ ___| | | | || |/ /   / \   "
show "\___ \ | |_| | | | \___ \ | |_| || ' /   / _ \  "
show " ___) ||  _  | | |  ___) ||  _  || . \  / ___ \ "
show "|____/ |_| |_||___||____/ |_| |_||_|\_\/_/   \_\ "
show "  ____  ____ __   __ ____  _____  ___           "
show " / ___||  _ \\ \ / /|  _ \|_   _|/ _ \          "
show "| |    | |_) |\ V / | |_) | | | | | | |         "
show "| |___ |  _ <  | |  |  __/  | | | |_| |         "
show " \____||_| \_\ |_|  |_|     |_|  \___/          "
show " _   _   ___   ____   _____  ____               "
show "| \ | | / _ \ |  _ \ | ____|/ ___|              "
show "|  \| || | | || | | ||  _|  \___ \              "
show "| |\  || |_| || |_| || |___  ___) |             "
show "|_| \_| \___/ |____/ |_____||____/              "


# Step 0: Установка nvm и Node.js, если они еще не установлены
if ! command -v npm &> /dev/null; then
    show "Устанавливаем nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    source ~/.bashrc

    show "Устанавливаем Node.js 22..."
    nvm install 22

    show "Проверка версий Node.js и npm..."
    node -v
    npm -v
else
    # Проверка версии npm
    REQUIRED_NPM_VERSION="10.8.3"
    CURRENT_NPM_VERSION=$(npm -v)

    if [ "$(printf '%s\n' "$REQUIRED_NPM_VERSION" "$CURRENT_NPM_VERSION" | sort -V | head -n1)" != "$REQUIRED_NPM_VERSION" ]; then
        show "Версия npm устарела. Обновляем до версии $REQUIRED_NPM_VERSION..."
        npm install -g npm@$REQUIRED_NPM_VERSION
    else
        show "Версия npm $CURRENT_NPM_VERSION актуальна."
    fi
fi

# Step 1: Переход в директорию Hemi-Node
show "Переход в директорию Hemi-Node..."
cd ~/Hemi-Node || exit

# Step 2: Автоматическое присваивание переменных из JSON
show "Автоматическое присваивание переменных из JSON..."
eval $(jq -r '. | "ETHEREUM_ADDRESS=\(.ethereum_address)\nNETWORK=\(.network)\nPRIVATE_KEY=\(.private_key)\nPUBLIC_KEY=\(.public_key)\nPUBKEY_HASH=\(.pubkey_hash)"' ~/popm-address.json)

show "Вывод переменных..."
echo "Ethereum Address: $ETHEREUM_ADDRESS"
echo "Network: $NETWORK"
echo "Private Key: $PRIVATE_KEY"
echo "Public Key: $PUBLIC_KEY"
echo "Public Key Hash: $PUBKEY_HASH"

# Step 3: Создание папки для проекта
show "Создание папки для проекта ERC-20..."
mkdir TestToken && cd TestToken

# Step 4: Инициализация npm и установка зависимостей
show "Инициализация npm проекта и установка зависимостей..."
npm init -y
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts

# Step 5: Инициализация Hardhat проекта
show "Инициализация Hardhat проекта..."
npx hardhat init

# Step 6: Создание пустого файла hardhat.config.js
show "Создание файла hardhat.config.js..."
cat <<EOL > hardhat.config.js
/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    hemi: {
      url: "https://testnet.rpc.hemi.network/rpc",
      chainId: 743111,
      accounts: [\`0x$PRIVATE_KEY\`],
    },
  }
};
EOL

# Step 7: Создание папок contracts и scripts
show "Создание папок contracts и scripts..."
mkdir contracts scripts

# Step 8: Создание контракта MyToken.sol
show "Создание контракта MyToken.sol..."
cat <<EOL > contracts/MyToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("MyToken", "MTK") {
        _mint(msg.sender, initialSupply);
    }
}
EOL

# Step 9: Компиляция контракта
show "Компиляция контракта..."
npx hardhat compile

# Step 10: Установка dotenv для работы с приватным ключом
show "Установка dotenv для управления переменными окружения..."
npm install dotenv

# Step 11: Создание deploy.js для деплоя токена
show "Создание скрипта deploy.js..."
cat <<EOL > scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    const initialSupply = ethers.utils.parseUnits("1000", "ether");

    const Token = await ethers.getContractFactory("MyToken");
    const token = await Token.deploy(initialSupply);

    console.log("Token deployed to:", token.address);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
EOL

# Step 12: Деплой контракта в сеть Hemi
show "Деплой контракта в сеть Hemi..."
npx hardhat run scripts/deploy.js --network hemi

show "Контракт удачно установлен, не забудь подписаться https://t.me/shishka_crypto"
