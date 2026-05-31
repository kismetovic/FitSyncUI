# FITSync UI

Flutter aplikacije za FITSync sistem upravljanja treninzima.

- **fitsync_mobile** — Mobilna aplikacija za klijente (Android/iOS)
- **fitsync_desktop** — Desktop admin aplikacija (Windows/macOS/Linux)

Obje aplikacije se povezuju na [FITSync API](../FitSyncAPI/README.md).

---

## Preduvjeti

| Alat | Verzija |
|------|---------|
| Flutter SDK | ≥ 3.10.7 |
| Dart SDK | ≥ 3.10.7 |
| Android Studio / Xcode | Za mobilne buildove |
| FITSync API | Pokrenuto na `localhost:5000` (pogledaj API README) |

Instalacija Fluttera: https://docs.flutter.dev/get-started/install

---

## Struktura projekta

```
FitSyncUI/
├── fitsync_mobile/     # Mobilna aplikacija za klijente
└── fitsync_desktop/    # Admin desktop aplikacija

builds folder for zipped build files.
```

---

## Mobilna aplikacija (fitsync_mobile)

### Postavljanje

```bash
cd fitsync_mobile

# 1. Kreiraj .env fajl iz primjera (extractovati iz zip foldera)
copy .env.example .env   # Windows
cp .env.example .env     # Mac/Linux

# 2. Uredi .env i postavi URL do API-ja:
#    Android emulator  → API_BASE_URL=http://10.0.2.2:5000/api
#    Fizički uređaj    → API_BASE_URL=http://<TVOJA_LAN_IP>:5000/api
#    iOS / macOS       → API_BASE_URL=http://localhost:5000/api

# 3. Instaliraj zavisnosti
flutter pub get

# 4. Pokrni aplikaciju
flutter run
```

### .env varijable

| Varijabla | Opis | Podrazumijevana vrijednost |
|-----------|------|---------------------------|
| `API_BASE_URL` | FITSync API bazni URL | `http://10.0.2.2:5000/api` |

### Pokretanje na Android emulatoru

```bash
# Pokreni AVD iz Android Studija, zatim:
flutter run
# Podrazumijevani .env koristi 10.0.2.2 koji preusmjerava na host mašinu
```

### Pokretanje na fizičkom Android uređaju

1. Pronađi LAN IP adresu računara (`ipconfig` na Windowsu, `ifconfig` na Mac/Linux)
2. Uredi `.env`: `API_BASE_URL=http://192.168.x.x:5000/api`
3. Osiguraj da su uređaj i računar na istoj Wi-Fi mreži
4. `flutter run`

### Pokretanje na iOS simulatoru

```bash
# Prvo otvori iOS Simulator, zatim:
flutter run
# Uredi .env: API_BASE_URL=http://localhost:5000/api
```

### Build APK-a (Release)

```bash
flutter build apk --release
# Izlaz: build/app/outputs/flutter-apk/app-release.apk
```

### Lokalizacija

Aplikacija podržava **engleski (en)** i **bosanski (bs)** jezik. Podrazumijevani jezik je bosanski.

ARB fajlovi za prevode nalaze se u `lib/l10n/`:
- `app_en.arb` — Engleski
- `app_bs.arb` — Bosanski

Dodavanje novog jezika:
1. Kreiraj `lib/l10n/app_<lokalizacija>.arb` sa istim ključevima kao `app_en.arb`
2. Dodaj `Locale('<lokalizacija>')` u `supportedLocales` u `lib/main.dart`

Regenerisanje Dart koda za lokalizaciju nakon izmjene ARB fajlova:
```bash
flutter gen-l10n
# ili jednostavno:
flutter pub get
```

---

## Desktop aplikacija (fitsync_desktop)

### Postavljanje

```bash
cd fitsync_desktop

# 1. Kreiraj .env fajl
copy .env.example .env   # Windows
cp .env.example .env     # Mac/Linux

# Podrazumijevani .env ukazuje na http://localhost:5000/api — nije potrebna izmjena za lokalni razvoj

# 2. Instaliraj zavisnosti
flutter pub get

# 3. Pokrni aplikaciju (Windows)
flutter run -d windows
```

### .env varijable

| Varijabla | Opis | Podrazumijevana vrijednost |
|-----------|------|---------------------------|
| `API_BASE_URL` | FITSync API bazni URL | `http://localhost:5000/api` |

### Build Windows izvršne datoteke

```bash
flutter build windows --release
# Izlaz: build/windows/x64/runner/Release/fitsync_desktop.exe
```

### Podrazumijevani podaci za prijavu

| Polje | Vrijednost |
|-------|------------|
| Korisničko ime | `user@fitsync.com` |
| Lozinka | `User123!` |

### Lokalizacija

Ista konfiguracija kao kod mobilne aplikacije. ARB fajlovi se nalaze u `lib/l10n/`.

---

## Ikone

Ikone aplikacija koriste FITSync branding (narandžasti krug sa bijelim slovom "F" na tamnoj pozadini).

- **Mobilna**: Android mipmap PNG fajlovi u `android/app/src/main/res/mipmap-*/`
- **Desktop**: Windows `.ico` u `windows/runner/resources/app_icon.ico`
- **Izvorni fajl**: `assets/icons/fitsync_icon.png`

---

## Česti problemi

**`flutter pub get` ne radi zbog mrežne greške**
```bash
flutter pub get --no-example
```

**Aplikacija ne može da dosegne API na Android emulatoru**
- Provjeri da API radi: `docker-compose up` u direktoriju API-ja
- `.env` mora sadržavati `API_BASE_URL=http://10.0.2.2:5000/api`

**`package:flutter_gen/gen_l10n/app_localizations.dart` nije pronađen**
```bash
flutter gen-l10n
```

**Build za Windows ne radi (desktop)**
- Instaliraj Visual Studio 2022 sa workloadom **Desktop development with C++**
- Pokreni `flutter doctor` za provjeru Windows konfiguracije
