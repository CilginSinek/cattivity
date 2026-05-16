# Cattivity

Cattivity, Express ve MongoDB kullanan basit bir oyun/harita yönetim sunucusudur. 42 OAuth ile oturum açma, harita listeleme/inceleme, profil ve skor tablosu gibi sayfaları sunar.

## Özellikler
- 42 OAuth ile giriş/çıkış
- Harita listeleme ve detay görüntüleme
- Skor tablosu ve profil sayfaları
- Dosya yükleme (harita yükleme)

## Gereksinimler
- Node.js (önerilen: LTS)
- MongoDB

## Kurulum
```bash
cd server
npm install
```

## Ortam Değişkenleri
`.env` dosyasını, `.env.example` üzerinden oluşturun:
```bash
cp .env.example .env
```

| Değişken | Açıklama |
| --- | --- |
| `MONGOURL` | MongoDB bağlantı URL'i |
| `PORT` | (Kullanılmıyor) Sunucu portu. Uygulama 3000 portuna sabitlenmiştir. |
| `LOCALHOST` | CORS için izin verilen origin (örn. `http://localhost:3000`) |
| `SECRET` | Session secret |
| `FORTYTWO_CLIENT_ID` | 42 OAuth Client ID |
| `FORTYTWO_CLIENT_SECRET` | 42 OAuth Client Secret |
| `FORTYTWO_CALLBACK_URL` | 42 OAuth callback URL |

## Çalıştırma
Geliştirme:
```bash
cd server
npm run dev
```

Prod:
```bash
cd server
npm start
```

Uygulama varsayılan olarak `http://localhost:3000` üzerinde çalışır.

## API Rotaları (özet)
### Sayfa Rotaları
- `GET /` — ana sayfa
- `GET /leaderboard` — skor tablosu
- `GET /maps` — harita listesi
- `GET /maps/:id` — harita detayı
- `GET /profile/:id` — kullanıcı profili

### Kimlik Doğrulama
- `POST /auth/login` — giriş
- `GET /auth/42/callback` — OAuth callback
- `GET /auth/logout` — çıkış

### Oyun Etkinlikleri
> Not: Router dosyası mevcut; eklenmesi gerekiyorsa `index.js` içine mount edilmelidir.
- `POST /play` — oyun sonucu kaydetme
- `POST /upload` — harita yükleme
- `DELETE /delete/:id` — harita silme

## Notlar
- `PORT` değişkeni şu an kullanılmıyor; port 3000'e sabitlenmiştir.
- CORS origin ayarı için `LOCALHOST` değişkenini doğru doldurun.