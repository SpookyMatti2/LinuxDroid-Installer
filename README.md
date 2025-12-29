# LinuxDroid Installer v1.2
One-File Edition — by SpookyMatti2

LinuxDroid Installer è uno script avanzato che permette di installare Ubuntu con ambiente grafico XFCE su Termux in modo semplice, veloce e completamente automatizzato.  
Questa versione è **One-File Edition**, quindi tutto il codice è contenuto in un unico file: `installer.sh`.

---

## ✨ Funzionalità principali

- Installazione automatica di Ubuntu tramite proot-distro
- Desktop Environment XFCE completo e pronto all’uso
- Avvio rapido tramite VNC (startvnc / stopvnc)
- Script di accesso rapido: `ubuntu`, `startvnc`, `stopvnc`
- Controlli avanzati:
  - Spazio libero
  - Connessione Internet
  - Accesso allo storage
  - Dipendenze mancanti
- Menu interattivo tramite `dialog`
- Rimozione completa di Ubuntu con un click

---

## 📦 Installazione

1. Scarica la cartella `LinuxDroid-Installer` sul tuo dispositivo Android
2. Apri Termux e vai nella cartella:cd /sdcard/Download/LinuxDroid-Installer
3. Dai i permessi di esecuzione:chmod +x installer.sh
4. Avvia l’installer:./installer.sh

---

## 🖥️ Comandi disponibili dopo l’installazione

| Comando     | Descrizione                         |
|-------------|-------------------------------------|
| `ubuntu`    | Entra nella shell Ubuntu            |
| `startvnc`  | Avvia XFCE tramite VNC              |
| `stopvnc`   | Ferma il server VNC                 |

---

## 🌐 Connessione VNC

- Indirizzo: `localhost:5901`
- Risoluzione predefinita: `1280x720`
- Password: richiesta al primo avvio

Consigliati:
- RealVNC Viewer (Android)
- AVNC (open source)

---

## 🗑️ Rimozione Ubuntu

Dal menu principale seleziona: 🗑️  Rimuovi Ubuntu

Lo script rimuoverà:
- Ubuntu
- Script startvnc / stopvnc / ubuntu
- Configurazioni VNC

---

## 📝 Licenza

Progetto creato da **SpookyMatti2**.  
Distribuzione consentita solo con autorizzazione.
## 💸 Acquista LinuxDroid Installer (3€)
👉 https://ko-fi.com/s/b1de9b66d6


