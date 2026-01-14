termux_bootstrap_setup() {
    command -v dialog >/dev/null 2>&1 || pkg install dialog -y

    BOOTSTRAP="$HOME/.bootstrap"
    touch "$BOOTSTRAP"

    DISTROS=(
        Kali Solus MX Garuda Elementary Alpine Void Slackware Gentoo
        openSUSE RedHat CentOS Rocky AlmaLinux Fedora Debian Ubuntu
        Kubuntu Xubuntu Lubuntu LinuxMint PopOS EndeavourOS ArcoLinux
        Manjaro Arch Zorin LinuxLite
    )

    menu_items=()
    for i in "${!DISTROS[@]}"; do
        menu_items+=("$i" "${DISTROS[$i]}")
    done

    choice=$(dialog \
        --clear \
        --title "FASTFETCH BOOTSTRAP SETUP" \
        --menu "Select distro logo for Fastfetch:" 20 55 12 \
        "${menu_items[@]}" \
        3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && { clear; return; }

    chosen_distro="${DISTROS[$choice]}"

    cat > "$BOOTSTRAP" <<EOF
clear
fastfetch --logo $chosen_distro
EOF

    dialog --msgbox "Fastfetch logo set to:\n\n$chosen_distro\n\nBootstrap updated." 8 45

    clear
    source "$BOOTSTRAP" 2>/dev/null
}

alias termux-bootstrap='termux_bootstrap_setup'
