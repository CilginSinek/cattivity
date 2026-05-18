# Cattivity

Cattivity, ritim tabanlı (Dance of Fire and Ice benzeri) bir Godot oyunu ve bu oyunun haritalarını, skorlarını ve kullanıcı profillerini yöneten bir Node.js arka uç (backend) sunucusundan oluşan tam kapsamlı bir projedir. 42 OAuth entegrasyonu ile güvenli giriş sağlar.

## 📂 Proje Yapısı

Proje temel olarak iki ana bölümden oluşur:

- **`godot/`**: Oyunun istemci (client) tarafıdır. Godot Engine kullanılarak geliştirilmiştir. İçerisinde oyun sahneleri, mekanikler, notalar ve arayüz bulunur. Oyun web üzerinden oynanacak şekilde dışa aktarılmaya (Web Export) uygundur.
- **`server/`**: Oyunun arka yüzüdür (backend). Express.js ve MongoDB kullanılarak yazılmıştır. API rotalarını, kullanıcı oturum yönetimini, harita sunumunu ve skor tablolarını içerir. Daha fazla detay için [server/README.md](./server/README.md) dosyasına göz atabilirsiniz.
- **`quicksetup.sh`**: Sunucu bağımlılıklarını kuran ve test edebilmeniz için veritabanına varsayılan bir başlangıç haritası yükleyen hızlı kurulum betiğidir.

## 🚀 Özellikler

- **Ritim Odaklı Oynanış:** Gelen notalara doğru zamanda basarak engelleri aşın.
- **Harita Yönetimi:** Sunucu üzerinden yeni haritalar ve ses dosyaları yükleyin, listeleyin.
- **Global Skor Tablosu:** Her harita için en yüksek skorları ve komboları kaydedin, liderlik tablosunu görüntüleyin.
- **42 OAuth Kimlik Doğrulaması:** 42 (Intra) hesabı ile güvenli giriş ve çıkış.

## ⚙️ Gereksinimler

Projenin tamamını yerel ortamınızda çalıştırabilmek için aşağıdakilere ihtiyacınız vardır:

- **Node.js** (LTS sürümü önerilir) - Sunucu için
- **MongoDB** - Veritabanı için (Yerel veya Atlas)
- **Godot Engine 4.x** - Oyunu düzenlemek ve build almak için

## 🛠 Hızlı Kurulum

Projenizi ayağa kaldırmanın en kolay yolu `quicksetup.sh` betiğini kullanmaktır. Bu betik:
1. Gerekli NPM paketlerini kurar.
2. MongoDB'ye bağlanıp varsayılan haritayı (`running`) veritabanınıza ekler.

**Adımlar:**

1. Sunucu yapılandırması için `server/` klasörüne gidin ve çevresel değişkenleri oluşturun:
   ```bash
   cd server
   cp .env.example .env
   ```
2. Oluşturduğunuz `.env` dosyasını bir metin editörüyle açın ve **`MONGOURL`** ile diğer 42 OAuth ayarlarınızı doldurun.
3. Kök dizine dönün ve kurulum betiğini çalıştırın:
   ```bash
   cd ..
   chmod +x quicksetup.sh
   ./quicksetup.sh
   ```

## 🎮 Oyunu Çalıştırma

**Sunucuyu Başlatmak İçin:**
```bash
cd server
npm run dev   # Geliştirme modu (nodemon)
# VEYA
npm start     # Canlı ortam (prod)
```
Sunucu varsayılan olarak `http://localhost:3000` adresinde çalışacaktır.

**Godot İstemcisini Çalıştırmak İçin:**
Godot uygulamasını isterseniz Godot Engine üzerinden açıp test edebilir, isterseniz web'e (HTML5) export alıp sunucuyla birlikte çalıştırabilirsiniz.
Web build alındıktan sonra export edilen klasörün içinde yerel bir web sunucusu başlatabilirsiniz:
```bash
python3 -m http.server 9080
```
Oyun içi ayarların backend isteklerini `http://localhost:3000` adresine (CORS kurallarına uygun olarak) yaptığından emin olun.

## 📜 Lisans

Bu proje MIT lisansı altında sunulmaktadır.