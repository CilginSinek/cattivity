# Cattivity Backend Server

Bu dizin (`server/`), Cattivity ritim oyununun Express.js ve MongoDB kullanılarak geliştirilmiş arka uç (backend) sunucusudur. Oyun içindeki haritaları (beatmap), oyuncu skorlarını, liderlik tablolarını ve kullanıcı kimlik doğrulamalarını (42 OAuth) yönetir.

## 📁 Dizin Yapısı

- **`controller/`**: Gelen HTTP isteklerini işleyen ve iş mantığını barındıran fonksiyonları içerir (örn. kullanıcı girişi, skor kaydetme).
- **`models/`**: MongoDB veritabanı şemalarını (Mongoose Models) tanımlar.
  - `User`: Oyuncu profil bilgileri ve OAuth verileri.
  - `Map`: Harita metadataları, BPM, süre, ses ve JSON dosya yolları.
  - `Score`: Kullanıcıların hangi haritada ne kadar skor ve kombo yaptığına dair veriler.
- **`router/`**: API endpoint'lerini (rotalarını) tanımlar ve istekleri ilgili controller'lara yönlendirir.
- **`middlewares/`**: İstekler controller'a ulaşmadan önce araya giren ara katmanlardır (örneğin oturum kontrolü, yetki doğrulama).
- **`public/`**: Yüklenen harita dosyalarını (JSON) ve ses dosyalarını (MP3) barındıran statik dosya dizinidir. Express tarafından statik olarak dışarı açılır.

## ⚙️ Ortam Değişkenleri (.env)

Sunucunun çalışabilmesi için bir `.env` dosyası gereklidir. Örnek bir `.env.example` dosyası dizinde bulunmaktadır:
```bash
cp .env.example .env
```

| Değişken | Açıklama |
| --- | --- |
| `MONGOURL` | MongoDB veritabanı bağlantı dizgisi (Connection String). **(Zorunlu)** |
| `PORT` | Sunucu portu (Şu anda kod içinde varsayılan olarak 3000 portuna sabitlenmiştir). |
| `LOCALHOST` | CORS için izin verilen kök adres (Örn: `http://localhost:3000` veya Godot'un çalıştığı port). |
| `SECRET` | Çerezleri (cookies) ve JSON Web Token (JWT) gibi verileri imzalamak için kullanılan gizli anahtar. |
| `FORTYTWO_CLIENT_ID` | 42 API'sinden (Intra) alınan OAuth Uygulama ID'si. |
| `FORTYTWO_CLIENT_SECRET` | 42 API'sinden alınan OAuth Gizli Anahtarı. |
| `FORTYTWO_CALLBACK_URL` | 42 API'sinden dönüş yapıldığında yönlendirilecek adres (Örn: `http://localhost:3000/auth/42/callback`). |

## 🚀 Çalıştırma

1. Tüm bağımlılıkları yükleyin:
   ```bash
   npm install
   ```
2. Geliştirme (Development) modunda çalıştırmak için (nodemon ile kod değiştiğinde otomatik yenilenir):
   ```bash
   npm run dev
   ```
3. Canlı (Production) ortamda çalıştırmak için:
   ```bash
   npm start
   ```

## 🔗 Temel API Rotaları

**Görünümler ve Sayfalar (Eğer SSR kullanılıyorsa):**
- `GET /` : Ana sayfa
- `GET /leaderboard` : Global skor tablosu
- `GET /maps` : Tüm haritaların listesi
- `GET /maps/:id` : Belirli bir haritanın detay sayfası
- `GET /profile/:id` : Belirli bir kullanıcının profili

**Kimlik Doğrulama (Auth):**
- `POST /auth/login` : Kullanıcı girişi başlatır
- `GET /auth/42/callback` : 42 OAuth doğrulamasından dönen kodun işlendiği rota
- `GET /auth/logout` : Kullanıcının oturumunu sonlandırır

**Oyun İçi İstekler:**
- `POST /play` : Oyun bittiğinde skoru ve komboyu kaydeder
- `POST /upload` : Yeni bir harita (ses dosyası + JSON) yükler
- `DELETE /delete/:id` : Haritayı sunucudan siler

## 🛠 Kullanılan Teknolojiler

- **Express.js:** Web sunucusu altyapısı.
- **Mongoose:** MongoDB veritabanı işlemleri ve şema modellemesi.
- **Bcrypt:** Şifre hash'leme (OAuth dışı kullanımlar veya token'lar için).
- **JSON Web Token (JWT):** Oturum yönetimi ve API güvenliği.
- **Express-FileUpload:** Sunucuya harita ve müzik dosyalarını yüklemek için.
