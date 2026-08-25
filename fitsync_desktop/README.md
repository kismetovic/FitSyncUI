# fitsync_desktop

Desktop administratorska aplikacija za FITSync (Windows/macOS/Linux). Osoblje kroz nju
vodi katalog, rezervacije, klijente, uplate i izvještaje.

Aplikacija se povezuje na [FITSync API](../../FitSyncAPI/README.md). Postavljanje, `.env`
varijable i buildovi opisani su u [zajedničkom README-u](../README.md) — ovdje je samo ono
što je specifično za desktop aplikaciju.

---

## Brzi početak

```bash
cp .env.example .env    # Windows: copy .env.example .env
flutter pub get
flutter run -d windows
```

Podrazumijevani `.env` pokazuje na `http://localhost:5000/api` i ne treba ga mijenjati za
lokalni razvoj.

**Prijava:** `fitsync@gmail.com` / `Admin123!`

> Ovo je admin aplikacija. Prijava klijentskim nalogom namjerno ne otvara admin shell nego
> poruku „Pristup nije dozvoljen". Backend svakako odbija admin endpointe, ali ni UI ih ne
> nudi korisniku koji nema tu ulogu.

---

## Ekrani

| Ekran | Sadržaj |
|---|---|
| Nadzorna ploča | Broj korisnika, treninga, rezervacija i ukupan prihod |
| Treninzi | CRUD, pretraga u SQL-u, paginacija |
| Vrste treninga | CRUD |
| Dodatne usluge | CRUD kataloga usluga i cijena |
| Rezervacije | Sve rezervacije, dozvoljeni prelazi statusa, dodatne usluge po rezervaciji |
| Klijenti | **Samo nalozi sa ulogom klijenta**, kreiranje i izmjena |
| Osoblje | Dvije kartice: **Treneri** (dostupnost, doplata van rasporeda) i **Administratori** |
| Recenzije | Pregled i brisanje |
| Uplate | Sve uplate, za rezervacije i za pakete, sažetak prihoda, potvrda gotovine |
| Mjesečni paketi | Katalog paketa koje klijenti mogu kupiti |
| Izvještaji | Dva PDF izvještaja: rezervacije po periodu i prihod po treningu i paketu |
| Pomoć i podrška | Uređivanje čestih pitanja i kontakt podataka koje vidi mobilna aplikacija |

---

## Arhitektura

Ista struktura kao u mobilnoj aplikaciji — čista arhitektura, jedna mapa po
funkcionalnosti:

```
lib/
├── core/            # config, error, pagination, presentation (shell)
├── features/<ime>/
│   ├── data/        # datasources → models → repositories
│   ├── domain/      # entities → repositories (apstrakcije) → usecases
│   └── presentation/# providers → pages
├── l10n/            # app_bs.arb, app_en.arb
└── injection_container.dart
```

---

## PDF izvještaji

Izvještaji se generišu iz podataka koje vraća API (`/api/Reports/reservations` i
`/api/Reports/revenue`), preuzimaju se i mogu se odštampati.

Fontovi su bitni: paket `pdf` podrazumijevano koristi Helveticu, koja nema znakove `č ć ž
š đ`, pa su se imena i statusi ispisivali kao `▯`. Zato je Roboto uključen kao asset u
`assets/fonts/` i postavljen kao tema dokumenta. Ako se dodaje novi izvještaj, koristiti
istu temu.

---

## Lokalizacija

Podrazumijevani jezik je **bosanski**, engleski je druga opcija. Prevodi su u
`lib/l10n/app_bs.arb` i `app_en.arb`; nakon izmjene pokrenuti `flutter gen-l10n`.

Poruke o prekršenim poslovnim pravilima prevode se u aplikaciji, ne na serveru: API vraća
stabilan kod i englesku rečenicu, a `core/error/api_error_messages.dart` preslikava kod u
jezik korisnika. Odgovor API-ja se raspakuje kroz `core/error/dio_failure.dart`, koji
zadržava i poruku i kod — ranije se cijeli omot odgovora ispisivao korisniku.

---

## Testovi

```bash
flutter test
flutter analyze
```

---

## Windows build

```bash
flutter build windows --release
# Izlaz: build/windows/x64/runner/Release/fitsync_desktop.exe
```

Potreban je Visual Studio 2022 sa workloadom **Desktop development with C++**;
`flutter doctor` provjerava konfiguraciju.

**Ako se aplikacija ne pokrene sa greškom o `printing_plugin.dll`:** to je Smart App
Control u Windowsu 11, koji blokira svježe kompajlirane nepotpisane DLL-ove. Nije greška u
projektu. Opcije su, redom: pokrenuti na mašini bez Smart App Controla, potpisati DLL, ili
za demonstraciju koristiti web build:

```bash
flutter run -d web-server --web-port 4200 --web-hostname localhost --release
```

Web build vrti isti Dart kod prema istom API-ju. Ako se nakon ponovnog builda čini da se
ništa nije promijenilo, provjeriti da neki stariji server već ne drži port:
`Get-NetTCPConnection -LocalPort 4200`.
