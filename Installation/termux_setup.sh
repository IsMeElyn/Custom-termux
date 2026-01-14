termux_setup() {
    CRIMSON="\033[1;38;5;160m"
    WHITE="\033[1;37m"
    RESET="\033[0m"

    command_exists() {
        command -v "$1" >/dev/null 2>&1
    }

    echo -e "${WHITE}Checking Node.js version...${RESET}"

    SKIP_UPDATE=false
    if command_exists node; then
        NODE_VER="$(node -v | sed 's/^v//')"
        NODE_URL="https://nodejs.org/id/download/archive/v${NODE_VER}/"

        if curl -s --head --fail "$NODE_URL" >/dev/null; then
            echo -e "${CRIMSON}Node v${NODE_VER} found and archive exists. Skipping pkg update & upgrade.${RESET}"
            SKIP_UPDATE=true
        else
            echo -e "${WHITE}Node detected, but archive not found. Proceeding with update.${RESET}"
        fi
    fi

    if [ "$SKIP_UPDATE" = false ]; then
        echo -e "${WHITE}Running package update & upgrade...${RESET}"
        pkg update && pkg upgrade -y
    fi

    echo -e "${WHITE}Checking core utilities...${RESET}"
    for pkgname in apt grep gawk findutils dpkg coreutils; do
        if ! command_exists "$pkgname"; then
            echo -e "${WHITE}Installing ${pkgname}...${RESET}"
            pkg install "$pkgname" -y
        fi
    done

    echo -e "${WHITE}Checking Python...${RESET}"
    if ! command_exists python3; then
        pkg install python python3 -y
    fi

    echo -e "${WHITE}Checking FFmpeg...${RESET}"
    if ! command_exists ffmpeg; then
        pkg install ffmpeg -y
    fi

    echo -e "${WHITE}Checking Node.js...${RESET}"
    if ! command_exists node; then
        pkg install nodejs -y
    fi

    echo -e "${WHITE}Checking PM2...${RESET}"
    if ! command_exists pm2; then
        npm install -g pm2
    fi

    echo -e "${WHITE}Checking Golang...${RESET}"
    if ! command_exists go; then
        pkg install golang -y
    fi

    echo -e "${WHITE}Checking C/C++ toolchain...${RESET}"
    if ! command_exists clang; then
        pkg install clang make -y
    fi

    echo -e "${WHITE}Checking Fastfetch...${RESET}"
    if ! command_exists fastfetch; then
        pkg install fastfetch -y
    fi

    echo -e "${CRIMSON}Setup finished. Nothing redundant, nothing broken.${RESET}"
    clear
}
