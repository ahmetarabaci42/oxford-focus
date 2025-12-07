---
description: Firebase Projesi Kurulum Kılavuzu
---

# Firebase Kurulum Adımları

Uygulamanın çalışması için Firebase konsolunda bir proje oluşturup gerekli servisleri aktif etmeniz gerekmektedir.

## 1. Proje Oluşturma
1. [Firebase Console](https://console.firebase.google.com/) adresine gidin.
2. **"Proje Ekle"** (Add project) butonuna tıklayın.
3. Proje adı olarak `OxfordFocus` (veya istediğiniz bir isim) girin.
4. Google Analytics'i kapatabilirsiniz (bu proje için zorunlu değil).
5. "Proje Oluştur" diyerek tamamlayın.

## 2. Android Uygulaması Ekleme
1. Proje ana sayfasında ortadaki **Android ikonuna** (küçük yeşil robot) tıklayın.
2. **Paket Adı** (Package Name) kısmına aynen şunu yazın:
   `com.bsh.oxford.oxford_focus`
3. "Uygulamayı Kaydet" (Register app) butonuna tıklayın.
4. **"google-services.json indir"** butonuna basarak dosyayı bilgisayarınıza indirin.
5. İndirdiğiniz dosyayı projenizin `android/app/` klasörünün içine kopyalayın.

## 3. Servisleri Aktif Etme

### A. Authentication (Kimlik Doğrulama)
1. Sol menüden **Build > Authentication** seçeneğine gidin.
2. "Get Started" (Başla) diyerek servisi açın.
3. **Sign-in method** sekmesinde **Anonymous** (Anonim) seçeneğini bulun.
4. "Enable" anahtarını açın ve kaydedin.

### B. Firestore Database (Veritabanı)
1. Sol menüden **Build > Firestore Database** seçeneğine gidin.
2. "Create Database" butonuna tıklayın.
3. Konum olarak size en yakın bölgeyi seçin (örn: `eur3` europe-west).
4. Güvenlik Kuralları adımında **"Start in Test Mode"** (Test modunda başlat) seçeneğini seçin.
   > **Dikkat:** Test modu 30 gün boyunca herkese açık erişim verir. Geliştirme için bu yeterlidir.
5. "Create" diyerek tamamlayın.

## 4. Sonuç
Artık `google-services.json` dosyasını `android/app/` klasörüne koyup `flutter run` komutunu çalıştırabilirsiniz.
