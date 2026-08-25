# FITSync UI

Flutter aplikacije za FITSync sistem upravljanja treninzima.

- **fitsync_mobile** — Mobilna aplikacija za klijente (Android/iOS)
- **fitsync_desktop** — Desktop admin aplikacija (Windows/macOS/Linux)

Obje aplikacije se povezuju na [FITSync API](../FitSyncAPI/README.md) i startaju na
**bosanskom** jeziku, uz engleski kao drugu opciju.

| | Mobilna | Desktop |
|---|---|---|
| Ko je koristi | Klijent teretane | Administrator |
| Prijava | Bilo koji aktivan nalog | **Samo administrator** — klijent dobija „Pristup nije dozvoljen" |
| Šta radi | Pregled i pretraga treninga, rezervacije, mjesečni paketi, plaćanje (PayPal ili gotovina), recenzije, kalendar, notifikacije, pomoć i podrška | Treninzi, tipovi treninga, dodatne usluge, rezervacije, klijenti, osoblje (treneri i administratori), recenzije, uplate, mjesečni paketi, PDF izvještaji, uređivanje čestih pitanja i kontakta |

Podaci za prijavu su isti u obje aplikacije:

| Uloga | Email | Lozinka |
|---|---|---|
| Administrator | `fitsync@gmail.com` | `Admin123!` |
| Klijent | `user@fitsync.com` | `User123!` |

Polje za prijavu je `userNameOrEmail`, pa radi i korisničko ime i email.

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

**Testirati i release build, barem jednom.** Debug build je popustljiviji od release
builda: Flutter dodaje `INTERNET` dozvolu samo u debug i profile manifest, Android od
API 28 blokira nešifrovani HTTP, a `url_launcher` od Androida 11 ne vidi preglednik bez
`<queries>` zapisa. Sve troje je riješeno u `android/app/src/main/AndroidManifest.xml` i
`res/xml/network_security_config.xml`, ali se vidi tek u release buildu.

Ako release build javi da ne može doći do servera, a `curl http://localhost:5000/api/Trainings`
radi — problem je u manifestu, ne u API-ju.

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

### Testovi

```bash
flutter test
```

Obje aplikacije imaju testove i oba paketa moraju proći. Pokriveni su formatiranje
iznosa (uvijek KM, nikad `$`) i prevođenje grešaka sa API-ja u jezik korisnika.

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
| Korisničko ime | `fitsync@gmail.com` |
| Lozinka | `Admin123!` |

> Desktop je admin aplikacija. Prijava klijentskim nalogom (`user@fitsync.com`) namjerno
> ne otvara admin shell nego poruku „Pristup nije dozvoljen" — backend svakako odbija
> admin endpointe, ali ni UI ih ne nudi korisniku koji nema tu ulogu.

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
