#!/bin/bash


PLAYLIST=()
SUAN_INDEX=0
DURUM="DURDURULDU"
SUAN_CALAN="Yok"
SURUCU="alsa"
BASLANGIC_ZAMANI=0


muzik_baslat() {
    pkill -x mpg123 2>/dev/null

    if [ ${#PLAYLIST[@]} -eq 0 ]; then
        yad --error --text="Çalma listesi boş!" --timeout=2
        return
    fi

    DOSYA_YOLU="${PLAYLIST[$SUAN_INDEX]}"
    SUAN_CALAN=$(basename "$DOSYA_YOLU")

    mpg123 -q -o "$SURUCU" "$DOSYA_YOLU" >/dev/null 2>&1 &
    DURUM="OYNATILIYOR"
    BASLANGIC_ZAMANI=$(date +%s)
}

sonraki_sarki() {
    ((SUAN_INDEX++))
    [ "$SUAN_INDEX" -ge "${#PLAYLIST[@]}" ] && SUAN_INDEX=0
    muzik_baslat
}

onceki_sarki() {
    SIMDI=$(date +%s)
    GECEN_SURE=$((SIMDI - BASLANGIC_ZAMANI))

    if [ "$SUAN_INDEX" -eq 0 ] || [ "$GECEN_SURE" -gt 5 ]; then
        muzik_baslat
    else
        ((SUAN_INDEX--))
        muzik_baslat
    fi
}

muzik_duraklat_devam() {
    if pgrep -x mpg123 >/dev/null; then
        if [ "$DURUM" = "OYNATILIYOR" ]; then
            pgrep -x mpg123 | xargs kill -STOP
            DURUM="DURAKLATILDI"
        else
            pgrep -x mpg123 | xargs kill -CONT
            DURUM="OYNATILIYOR"
        fi
    fi
}



gui_listeye_ekle() {
    SECILENLER=$(yad --file-selection --multiple --separator="|" \
        --title="Müzik Ekle" --file-filter="*.mp3")

    if [ -n "$SECILENLER" ]; then
        IFS='|' read -ra ADDR <<< "$SECILENLER"
        for i in "${ADDR[@]}"; do
            PLAYLIST+=("$i")
        done
        yad --info --text="Şarkılar eklendi: ${#PLAYLIST[@]}" --timeout=1 --no-buttons
    fi
}

gui_kontrol_paneli() {
    while true; do
        yad --title="Pardus Oynatıcı" --width=500 --form \
            --text="<b>Durum:</b> $DURUM\n<b>Parça:</b> $SUAN_CALAN ($((SUAN_INDEX+1))/${#PLAYLIST[@]})" \
            --button="Onceki:2" \
            --button="Oynat/Pause:3" \
            --button="Stop:4" \
            --button="Sonraki:5" \
            --button="Ekle:6" \
            --button="Geri:1"

        case $? in
            2) onceki_sarki ;;
            3)
                [ "$DURUM" = "DURDURULDU" ] && muzik_baslat || muzik_duraklat_devam
                ;;
            4)
                pkill -x mpg123
                DURUM="DURDURULDU"
                SUAN_CALAN="Yok"
                ;;
            5) sonraki_sarki ;;
            6) gui_listeye_ekle ;;
            *) break ;;
        esac
    done
}



tui_baslat() {
    while true; do
        SECIM=$(whiptail --title "Pardus TUI Oynatıcı" \
            --menu "Çalan: $SUAN_CALAN" 18 65 7 \
            "1" "Oynat / Restart" \
            "2" "Pause / Resume" \
            "3" "Sonraki Şarkı" \
            "4" "Önceki Şarkı" \
            "5" "Dosya Ekle (Yol Gir)" \
            "6" "Durdur" \
            "7" "Geri" \
            3>&1 1>&2 2>&3)

        case "$SECIM" in
            1) muzik_baslat ;;
            2) muzik_duraklat_devam ;;
            3) sonraki_sarki ;;
            4) onceki_sarki ;;
            5)
                YOL=$(whiptail --inputbox "MP3 dosya yolunu girin:" 10 60 \
                    3>&1 1>&2 2>&3)
                [ -f "$YOL" ] && PLAYLIST+=("$YOL")
                ;;
            6)
                pkill -x mpg123
                DURUM="DURDURULDU"
                SUAN_CALAN="Yok"
                ;;
            *) break ;;
        esac
    done
}



while true; do
    ARAYUZ=$(whiptail --title "PARDUS Linux Projesi" \
        --menu "Arayüz Seçin" 15 60 3 \
        "G" "Grafik Arayüz (YAD)" \
        "T" "Terminal Arayüz (TUI)" \
        "Q" "Çıkış" \
        3>&1 1>&2 2>&3)

    case "$ARAYUZ" in
        G) gui_kontrol_paneli ;;
        T) tui_baslat ;;
        *) pkill -x mpg123; exit 0 ;;
    esac
done
