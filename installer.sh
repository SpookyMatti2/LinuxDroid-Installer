#!/data/data/com.termux/files/usr/bin/bash
# ══════════════════════════════════════════════════════════════
# LinuxDroid Installer v1.2
# Installazione Ubuntu con XFCE Desktop su Termux
# Autore: Walter
# Data: 29/12/2025
# ══════════════════════════════════════════════════════════════

# ═══════════════════════════════════════════════
# CONTROLLI INIZIALI
# ═══════════════════════════════════════════════
clear
echo "╔══════════════════════════════════════╗"
echo "║      LinuxDroid Installer v1.2       ║"
echo "║         Controllo sistema...         ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Installa dialog se manca
if ! command -v dialog >/dev/null 2>&1; then
    echo "[INFO] Installazione dialog..."
    pkg install dialog -y || {
        echo "❌ Errore installazione dialog"
        exit 1
    }
fi

# Controlla spazio su disco (minimo 1.5GB)
FREE=$(df $PREFIX | awk 'NR==2 {print $4}')
if [ "$FREE" -lt 1500000 ]; then
    dialog --msgbox "❌ Spazio insufficiente!\n\nServono almeno 1.5GB liberi.\nLiberi ora: $(df -h $PREFIX | awk 'NR==2{print $4}')" 9 50
    exit 1
fi

# Controlla connessione Internet
if ! ping -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
    dialog --msgbox "❌ Nessuna connessione Internet rilevata.\n\nVerifica la tua connessione e riprova." 8 50
    exit 1
fi

# Installa proot-distro se manca
if ! command -v proot-distro >/dev/null 2>&1; then
    echo "[INFO] Installazione proot-distro..."
    pkg install proot-distro -y || {
        dialog --msgbox "❌ Errore installazione proot-distro" 6 40
        exit 1
    }
fi

# Controlla accesso storage
if [ ! -d /storage/emulated/0 ]; then
    dialog --msgbox "❌ Termux non ha accesso allo storage.\n\nEsegui prima:\ntermux-setup-storage\n\nPoi riavvia lo script." 10 50
    exit 1
fi

# ═══════════════════════════════════════════════
# FUNZIONE: Installa Ubuntu
# ═══════════════════════════════════════════════
install_ubuntu() {
    # Controlla se Ubuntu è già installato
    if proot-distro list 2>/dev/null | grep -q "ubuntu"; then
        dialog --msgbox "⚠️ Ubuntu è già installato!\n\nUsa l'opzione di rimozione prima di reinstallare." 8 50
        return
    fi

    dialog --infobox "🔧 Aggiornamento pacchetti Termux..." 5 50
    if ! pkg update -y && pkg upgrade -y; then
        dialog --msgbox "❌ Errore aggiornamento pacchetti Termux" 6 40
        return
    fi

    dialog --infobox "📦 Installazione Ubuntu (può richiedere diversi minuti)..." 5 60
    if ! proot-distro install ubuntu; then
        dialog --msgbox "❌ Errore installazione Ubuntu.\n\nVerifica spazio e connessione." 8 50
        return
    fi

    dialog --infobox "⚙️ Installazione ambiente grafico XFCE (5-10 min)..." 5 60
    if ! proot-distro login ubuntu -- bash -c "apt update -y && apt upgrade -y"; then
        dialog --msgbox "❌ Errore aggiornamento Ubuntu" 6 40
        return
    fi

    if ! proot-distro login ubuntu -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y \
        sudo wget curl git nano vim \
        xfce4 xfce4-goodies tightvncserver dbus-x11 \
        xfce4-terminal firefox-esr"; then
        dialog --msgbox "⚠️ Installazione parzialmente fallita.\n\nAlcuni pacchetti potrebbero mancare." 8 50
    fi

    # Configura VNC
    dialog --infobox "🖥️ Configurazione VNC Server..." 5 50
    proot-distro login ubuntu -- bash -c 'mkdir -p ~/.vnc'
    proot-distro login ubuntu -- bash -c 'echo "#!/bin/bash
xrdb \$HOME/.Xresources
startxfce4 &" > ~/.vnc/xstartup'
    proot-distro login ubuntu -- bash -c 'chmod +x ~/.vnc/xstartup'

    # Crea script di avvio
    mkdir -p $HOME/.local/bin
    
    cat > $HOME/.local/bin/startvnc << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🚀 Avvio VNC Server..."
proot-distro login ubuntu -- tightvncserver :1 -geometry 1280x720 -depth 24
echo ""
echo "✅ VNC avviato su localhost:5901"
echo "🔐 Password richiesta al primo avvio!"
echo ""
echo "📱 Apri un VNC Viewer e connettiti a:"
echo "   localhost:5901"
EOF

    cat > $HOME/.local/bin/stopvnc << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🛑 Arresto VNC Server..."
proot-distro login ubuntu -- tightvncserver -kill :1
echo "✅ VNC arrestato"
EOF

    cat > $HOME/.local/bin/ubuntu << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
echo "🐧 Accesso a Ubuntu..."
proot-distro login ubuntu
EOF

    chmod +x $HOME/.local/bin/startvnc $HOME/.local/bin/stopvnc $HOME/.local/bin/ubuntu

    # Aggiungi al PATH se necessario
    if ! grep -q ".local/bin" $HOME/.bashrc 2>/dev/null; then
        echo 'export PATH=$HOME/.local/bin:$PATH' >> $HOME/.bashrc
    fi

    dialog --msgbox "✅ Installazione completata con successo!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 COMANDI DISPONIBILI:

   ubuntu     → Accedi alla shell Ubuntu
   startvnc   → Avvia il desktop XFCE
   stopvnc    → Ferma il desktop

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🌐 CONNESSIONE VNC:

   Indirizzo: localhost:5901
   Risoluzione: 1280x720

🔐 Al primo avvio verrà richiesta
   una password per VNC (6-8 caratteri)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" 22 60
}

# ═══════════════════════════════════════════════
# FUNZIONE: Rimuovi Ubuntu
# ═══════════════════════════════════════════════
remove_ubuntu() {
    # Controlla se Ubuntu è installato
    if ! proot-distro list 2>/dev/null | grep -q "ubuntu"; then
        dialog --msgbox "ℹ️ Ubuntu non è installato." 6 40
        return
    fi

    dialog --yesno "⚠️ ATTENZIONE!\n\nQuesta operazione rimuoverà:\n• Ubuntu e tutti i suoi dati\n• Gli script: startvnc, stopvnc, ubuntu\n\nContinuare?" 12 50
    
    if [ $? -eq 0 ]; then
        dialog --infobox "🗑️ Rimozione Ubuntu in corso..." 5 50
        
        # Ferma VNC se attivo
        proot-distro login ubuntu -- tightvncserver -kill :1 2>/dev/null || true
        
        sleep 1
        proot-distro remove ubuntu
        rm -f $HOME/.local/bin/startvnc
        rm -f $HOME/.local/bin/stopvnc
        rm -f $HOME/.local/bin/ubuntu

        dialog --msgbox "✔️ Ubuntu rimosso completamente!" 6 40
    fi
}

# ═══════════════════════════════════════════════
# FUNZIONE: Info Sistema
# ═══════════════════════════════════════════════
show_system_info() {
    UBUNTU_STATUS=$(proot-distro list 2>/dev/null | grep -q ubuntu && echo '✅ Installato' || echo '❌ Non installato')
    SPACE_FREE=$(df -h $PREFIX | awk 'NR==2{print $4}')
    ARCH=$(uname -m)
    TERMUX_VER=$(termux-info 2>/dev/null | grep "TERMUX_VERSION" | cut -d'"' -f2 || echo 'N/A')
    
    INFO="━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 INFORMAZIONI SISTEMA
━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 Architettura: $ARCH
💾 Spazio libero: $SPACE_FREE
📦 Termux: $TERMUX_VER
🐧 Ubuntu: $UBUNTU_STATUS

━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    dialog --msgbox "$INFO" 16 50
}

# ═══════════════════════════════════════════════
# FUNZIONE: Guida VNC
# ═══════════════════════════════════════════════
show_vnc_guide() {
    dialog --msgbox "━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 GUIDA VNC CLIENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣ Scarica un VNC Viewer:
   • Android: RealVNC Viewer
   • Android: AVNC (open source)

2️⃣ Avvia Ubuntu:
   $ startvnc

3️⃣ Connetti il VNC:
   Indirizzo: localhost:5901
   Porta: 5901

4️⃣ Inserisci la password VNC
   (impostata al primo avvio)

5️⃣ Per fermare:
   $ stopvnc

━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 NOTA: La password VNC deve
   essere di 6-8 caratteri
━━━━━━━━━━━━━━━━━━━━━━━━━━━" 26 50
}

# ═══════════════════════════════════════════════
# MENU PRINCIPALE
# ═══════════════════════════════════════════════
show_main_menu() {
    TEMP_FILE=$(mktemp)
    
    while true; do
        dialog --clear \
        --title "🖥️ LinuxDroid Installer v1.2" \
        --menu "Seleziona un'opzione:" 17 55 5 \
        1 "📦 Installa Ubuntu (XFCE + VNC)" \
        2 "🗑️  Rimuovi Ubuntu" \
        3 "📊 Info Sistema" \
        4 "🔧 Guida VNC" \
        5 "🚪 Esci" 2>$TEMP_FILE

        choice=$(<$TEMP_FILE)

        case $choice in
            1) install_ubuntu ;;
            2) remove_ubuntu ;;
            3) show_system_info ;;
            4) show_vnc_guide ;;
            5|"") 
                rm -f $TEMP_FILE
                clear
                echo "👋 Grazie per aver usato LinuxDroid Installer!"
                echo ""
                exit 0
                ;;
            *) dialog --msgbox "❌ Scelta non valida." 5 40 ;;
        esac
    done
}

# ═══════════════════════════════════════════════
# AVVIO PRINCIPALE
# ═══════════════════════════════════════════════
main() {
    clear
    echo "╔══════════════════════════════════════╗"
    echo "║      LinuxDroid Installer v1.2       ║"
    echo "║            One-File Edition          ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    sleep 1
    show_main_menu
}

# Avvia il programma
main