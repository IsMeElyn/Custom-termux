termux_cmd() {
    command -v dialog >/dev/null 2>&1 || pkg install dialog -y

    ALIAS_FILE="$HOME/.alias-cmd"
    touch "$ALIAS_FILE"

    reload_alias() {
        source "$ALIAS_FILE" 2>/dev/null
    }

    while true; do
        choice=$(dialog \
            --clear \
            --title "TERMUX ALIAS MANAGER" \
            --menu "Choose an option:" 15 55 6 \
            1 "Create new alias" \
            2 "List existing aliases" \
            3 "Delete alias" \
            3>&1 1>&2 2>&3)

        [ $? -ne 0 ] && break

        case "$choice" in
            1)
                alias_name=$(dialog --inputbox "Alias name:" 8 40 3>&1 1>&2 2>&3)
                [ $? -ne 0 ] && { reload_alias; continue; }

                alias_cmd=$(dialog --inputbox "Command for alias '$alias_name':" 8 60 3>&1 1>&2 2>&3)
                [ $? -ne 0 ] && { reload_alias; continue; }

                if grep -q "^alias $alias_name=" "$ALIAS_FILE"; then
                    dialog --yesno "Alias already exists.\nReplace it?" 7 40
                    [ $? -ne 0 ] && { reload_alias; continue; }
                    sed -i "/^alias $alias_name=/d" "$ALIAS_FILE"
                fi

                echo "alias $alias_name='$alias_cmd'" >> "$ALIAS_FILE"
                reload_alias
                dialog --msgbox "Alias '$alias_name' created successfully." 6 45
                ;;
            2)
                mapfile -t aliases < <(alias | grep -v "^alias termux-")

                if [ ${#aliases[@]} -eq 0 ]; then
                    dialog --msgbox "No aliases found." 6 30
                    continue
                fi

                tmpfile=$(mktemp)

                {
                    printf "%-15s %-60s\n" "ALIAS" "COMMAND"
                    printf "%-15s %-60s\n" "-----" "------------------------------------------------------------"
                    for line in "${aliases[@]}"; do
                        name=$(echo "$line" | awk -F'[ =]' '{print $2}')
                        cmd=$(echo "$line" | cut -d"'" -f2)
                        printf "%-15s %-60s\n" "$name" "$cmd"
                    done
                } > "$tmpfile"

                dialog --title "ALIAS LIST" --textbox "$tmpfile" 20 80
                rm -f "$tmpfile"
                ;;
            3)
                mapfile -t aliases < <(alias | grep -v "^alias termux-")

                if [ ${#aliases[@]} -eq 0 ]; then
                    dialog --msgbox "No aliases to delete." 6 35
                    continue
                fi

                menu_items=()
                for i in "${!aliases[@]}"; do
                    name=$(echo "${aliases[i]}" | awk -F'[ =]' '{print $2}')
                    menu_items+=("$i" "$name")
                done

                idx=$(dialog \
                    --menu "Select alias to delete:" 15 50 6 \
                    "${menu_items[@]}" \
                    3>&1 1>&2 2>&3) || continue

                del_alias=$(echo "${aliases[idx]}" | awk -F'[ =]' '{print $2}')

                dialog --yesno "Delete alias '$del_alias'?" 7 40
                [ $? -ne 0 ] && continue

                sed -i "/^alias $del_alias=/d" "$ALIAS_FILE"
                unalias "$del_alias" 2>/dev/null
                reload_alias
                dialog --msgbox "Alias '$del_alias' deleted." 6 40
                ;;
        esac
    done

    clear
}

alias termux-cmd='termux_cmd'
