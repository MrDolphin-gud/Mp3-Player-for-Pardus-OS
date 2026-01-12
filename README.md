# Pardus Oynatıcı 

Pardus Linux için geliştirilmiş, hem grafik hem de terminal arayüzü sunan basit ve kullanışlı bir müzik çalar uygulaması.

## Kılavuz Videosu

Detaylı kullanım kılavuzu için YouTube videomuzu izleyebilirsiniz:

[![Kılavuz Videosu](https://img.youtube.com/vi/UtjYKQscOFg/0.jpg)](https://youtu.be/UtjYKQscOFg)

https://youtu.be/UtjYKQscOFg


## Özellikler

- **Grafik Arayüz (GUI)**: YAD kullanarak modern ve kullanıcı dostu arayüz
- **Terminal Arayüzü (TUI)**: Whiptail ile terminal tabanlı menü sistemi
- **MP3 Desteği**: MP3 formatındaki müzik dosyalarını çalma
- **Çalma Listesi Yönetimi**: Birden fazla şarkı ekleme ve yönetme
- **Oynatma Kontrolleri**: Oynat, duraklat, durdur, sonraki/önceki şarkı
- **Otomatik Döngü**: Şarkı listesi sonuna gelindiğinde başa dönme

## Gereksinimler

Bu scriptin çalışması için aşağıdaki paketlerin yüklü olması gerekmektedir:

- `mpg123` - MP3 dosyalarını çalmak için
- `yad` - Grafik arayüz için (GUI modu için)
- `whiptail` - Terminal arayüzü için (genellikle varsayılan olarak yüklüdür)

### Kurulum 

Gerekli paketleri kurmak için aşağıdaki komutu çalıştırın:

```bash
sudo apt-get update
sudo apt-get install mpg123 yad whiptail
```

![Paket Kurulumu](images/Ekran%20görüntüsü%202026-01-12%20151950.png)

## İndirme ve Kurulum

### 1. Scripti İndirme

Scripti doğrudan indirebilir veya klonlayabilirsiniz:

```bash
# Scripti indirme (wget ile)
wget https://raw.githubusercontent.com/kullaniciadi/repo/pardus_oynatici.sh

# Veya curl ile
curl -O https://raw.githubusercontent.com/kullaniciadi/repo/pardus_oynatici.sh
```

### 2. Çalıştırma İzni Verme

Scripti çalıştırabilmek için çalıştırma izni vermeniz gerekir:

```bash
chmod +x pardus_oynatici.sh
```

![Çalıştırma İzni](images/Ekran%20görüntüsü%202026-01-12%20152036.png)

### 3. Çalıştırma

```bash
./pardus_oynatici.sh
```

## Kullanım

### Başlangıç

Scripti çalıştırdığınızda, önce arayüz seçim menüsü açılır:

![Arayüz Seçim Menüsü](images/Ekran%20görüntüsü%202026-01-12%20152134.png)

### Grafik Arayüz (GUI) Kullanımı

1. Ana menüden **G** seçeneğini seçin
2. Açılan pencerede şu butonlar bulunur:
   - **Önceki**: Önceki şarkıya geç
   - **Oynat/Pause**: Oynatmayı başlat veya duraklat
   - **Stop**: Çalmayı durdur
   - **Sonraki**: Sonraki şarkıya geç
   - **Ekle**: Yeni MP3 dosyaları ekle
   - **Geri**: Ana menüye dön

![GUI Kontrol Paneli](images/Ekran%20görüntüsü%202026-01-12%20152202.png)

3. **Şarkı Ekleme**: "Ekle" butonuna tıklayarak dosya seçici penceresinden MP3 dosyalarınızı seçebilirsiniz.

### Terminal Arayüzü (TUI) Kullanımı

1. Ana menüden **T** seçeneğini seçin
2. Menüden istediğiniz işlemi seçin:
   - **1**: Oynat / Restart
   - **2**: Pause / Resume
   - **3**: Sonraki Şarkı
   - **4**: Önceki Şarkı
   - **5**: Dosya Ekle (Yol Gir)
   - **6**: Durdur
   - **7**: Geri

![TUI Menüsü](images/Ekran%20görüntüsü%202026-01-12%20152256.png)

3. **Şarkı Ekleme**: Seçenek 5'i seçip MP3 dosyasının tam yolunu girin.

![Dosya Yolu Girişi](images/Ekran%20görüntüsü%202026-01-12%20152314.png)

##  Scriptten Kod Bölümleri

### Müzik Başlatma Fonksiyonu

Script, müzik çalmayı başlatmak için `muzik_baslat()` fonksiyonunu kullanır:

```bash
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
```

Bu fonksiyon:
- Önceki çalma işlemini durdurur
- Çalma listesinin boş olup olmadığını kontrol eder
- Seçili şarkıyı `mpg123` ile arka planda çalar
- Durum bilgisini günceller

### Sonraki Şarkıya Geçme

```bash
sonraki_sarki() {
    ((SUAN_INDEX++))
    [ "$SUAN_INDEX" -ge "${#PLAYLIST[@]}" ] && SUAN_INDEX=0
    muzik_baslat
}
```

Bu fonksiyon:
- Mevcut şarkı indeksini artırır
- Liste sonuna gelindiğinde başa döner (döngü)
- Yeni şarkıyı başlatır

### Duraklat/Devam Et Fonksiyonu

```bash
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
```

Bu fonksiyon:
- `mpg123` sürecinin çalışıp çalışmadığını kontrol eder
- Oynatılıyorsa `STOP` sinyali göndererek duraklatır
- Duraklatılmışsa `CONT` sinyali göndererek devam ettirir

### Grafik Arayüz Kontrol Paneli

```bash
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
```

Bu fonksiyon:
- Sürekli bir döngü içinde çalışır
- YAD ile grafik arayüz oluşturur
- Kullanıcı buton seçimlerine göre ilgili fonksiyonları çağırır
- Durum ve şarkı bilgilerini gösterir

### Ana Döngü ve Arayüz Seçimi

```bash
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
```

Bu ana döngü:
- Kullanıcıdan arayüz seçimi alır
- Seçime göre ilgili arayüzü başlatır
- Çıkış yapıldığında tüm müzik çalma işlemlerini sonlandırır

## Değişkenler

Script içinde kullanılan ana değişkenler:

- `PLAYLIST`: Şarkı dosya yollarını tutan dizi
- `SUAN_INDEX`: Çalınan şarkının indeksi
- `DURUM`: Oynatıcının durumu (OYNATILIYOR, DURAKLATILDI, DURDURULDU)
- `SUAN_CALAN`: Şu an çalan şarkının adı
- `SURUCU`: Ses sürücüsü (varsayılan: alsa)
- `BASLANGIC_ZAMANI`: Şarkının başlama zamanı (Unix timestamp)

## Notlar

- Script sadece MP3 formatını destekler
- Ses çıkışı için ALSA sürücüsü kullanılır
- Çalma listesi oturum boyunca bellekte tutulur (script kapatıldığında sıfırlanır)
- Önceki şarkıya geçerken şarkı 5 saniyeden az çalındıysa başa sarılır

## Sorun Giderme

### Ses Çıkmıyor

- ALSA ses sisteminin çalıştığından emin olun: `alsamixer`
- Ses seviyesini kontrol edin
- Farklı bir ses sürücüsü denemek için script içindeki `SURUCU` değişkenini değiştirin

### YAD Kurulu Değil

GUI modu için YAD gereklidir. Kurulum için:
```bash
sudo apt-get install yad
```

### mpg123 Bulunamıyor

MP3 çalar kurulu değilse:
```bash
sudo apt-get install mpg123
```


