# fitsync_mobile

Mobilna aplikacija za klijente FITSync teretane (Android/iOS). Klijent pretražuje treninge,
rezerviše termine, kupuje i plaća mjesečne pakete, ostavlja recenzije i prati svoje uplate.

Aplikacija se povezuje na [FITSync API](../../FitSyncAPI/README.md). Postavljanje, `.env`
varijable i buildovi opisani su u [zajedničkom README-u](../README.md) — ovdje je samo ono
što je specifično za mobilnu aplikaciju.

---

## Brzi početak

```bash
cp .env.example .env    # Windows: copy .env.example .env
flutter pub get
flutter run
```

Podrazumijevani `.env` koristi `http://10.0.2.2:5000/api`, što je adresa host mašine
gledano iz Android emulatora. Za fizički uređaj upisati LAN IP računara.

**Prijava:** `user@fitsync.com` / `User123!`

---

## Ekrani

| Ekran | Sadržaj |
|---|---|
| Početna | Pretraga i filtriranje treninga, preporuke sa obrazloženjem zašto je trening predložen |
| Detalj treninga | Opis, trener, cijena, recenzije, pokretanje rezervacije |
| Zakaži trening | Datum i vrijeme, dostupnost po danima, jednokratna ili mjesečna rezervacija, dodatne usluge, zahtjev van rasporeda |
| Potvrdi rezervaciju | Pregled i konačna cijena koju je izračunao server |
| Plaćanje | PayPal ili gotovina na recepciji. Preskače se kada paket pokriva trening |
| Moje rezervacije | Svi statusi, otkazivanje uz razlog |
| Kalendar | Mjesečni pregled termina po statusu |
| Mjesečni paketi | Kupovina, plaćanje i otkazivanje paketa, pregled iskorištenih termina |
| Moje uplate | Uplate za rezervacije i za pakete, sa nazivom onoga što je plaćeno |
| Notifikacije | Lista sa označavanjem pročitanog, osvježavanje kroz SignalR |
| Profil | Podaci, promjena lozinke, jezik, pomoć i podrška |

---

## Arhitektura

Čista arhitektura, jedna mapa po funkcionalnosti:

```
lib/
├── core/            # config, error (mapiranje grešaka API-ja), pagination, utils, providers
├── features/<ime>/
│   ├── data/        # datasources → models → repositories
│   ├── domain/      # entities → repositories (apstrakcije) → usecases
│   └── presentation/# providers → pages
├── l10n/            # app_bs.arb, app_en.arb
└── injection_container.dart
```

Tok podataka je uvijek isti: `datasource → repository → usecase → provider → page`.
Stanje se drži kroz `provider`, greške se prenose kao `Either<Failure, T>` (`dartz`).

---

## Lokalizacija

Podrazumijevani jezik je **bosanski**, engleski je druga opcija. Prevodi su u
`lib/l10n/app_bs.arb` i `app_en.arb`; nakon izmjene pokrenuti `flutter gen-l10n`.

Poruke o prekršenim poslovnim pravilima **ne prevode se na serveru**. API vraća stabilan
kod (`TIME_CONFLICT`, `CAPACITY_FULL`, `MEMBERSHIP_OVERLAP` …) i englesku rečenicu, a
`core/error/api_error_messages.dart` preslikava taj kod u jezik korisnika. Nepoznat kod
pada nazad na serverovu rečenicu, tako da novo pravilo daje engleski tekst umjesto
praznog okvira.

---

## Plaćanje

Aplikacija nikada ne traži PayPal lozinku i nikada sama ne tvrdi da je uplata prošla.

1. Server otvara PayPal narudžbu i vraća zvanični `approvalUrl`.
2. Aplikacija otvara taj URL u sistemskom pregledniku.
3. Povratak u aplikaciju je signal da je korisnik gotov — provjera kreće sama
   (`AppLifecycleState.resumed`), a capture i verifikaciju radi server.

Cijene su u **KM (BAM)**. PayPal ne podržava tu valutu, pa server konvertuje u eure po
fiksnom kursu (1 EUR = 1.95583 KM) i prije otvaranja PayPal-a prikaže koliko će stvarno
biti naplaćeno.

---

## Testovi

```bash
flutter test
flutter analyze
```

---

## Release build

```bash
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Release build testirati barem jednom prije predaje — vidi napomenu o `AndroidManifest.xml`
u [zajedničkom README-u](../README.md).
