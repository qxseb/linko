# Linko - Community Assistance Platform

<div align="center">

**Conectăm persoane care au nevoie de ajutor cu voluntari din comunitate**

Team: Onyx Solutions

[Demo Video](https://youtu.be/jAjmJudZ0A0) • [Pitch Video](https://youtu.be/wjKUxqIhHrI) • [Business Plan](./livrabile/Business-plan_HE-6.0.pptx)

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](#)

</div>

---

### Mențiune privind participarea

Acest proiect a fost inițial înscris ca echipă formată din doi membri. Pe parcurs, celălalt membru a ales să nu mai continue participarea în cadrul concursului.

Ca urmare, întregul proiect, a fost realizat individual de către mine. Această înscriere reprezintă, prin urmare, munca mea individuală.

---

## 📱 Despre Linko

Linko este o platformă mobilă care rezolvă o problemă reală: **peste 3.5 milioane de persoane în vârstă din România au nevoie de ajutor zilnic** pentru sarcini simple dar critice (cumpărături, medicamente, treburi).

---

## 🏁 Update pentru finală

Versiunea prezentată în finală nu mai este doar un demo local cu date mock. LinkO a fost extinsă cu funcționalitățile esențiale planificate pentru o versiune de producție și rulează cu un backend real.

### Implementat pentru finală

- Backend real cu **Node.js + Express + MongoDB**
- Autentificare și conturi reale pentru requesteri și voluntari
- Sincronizare între aplicația mobilă și server
- WebSocket pentru actualizări în timp real și chat
- GPS și calcul real al distanței dintre voluntar și cerere
- Hartă interactivă pentru cererile disponibile
- Mod sigur de prezentare: **Live Backend** + **Demo Mode / Offline Mode**

### Rămas pentru o etapă viitoare

Singura funcționalitate planificată care nu a fost inclusă în versiunea de finală este verificarea identității prin document/CNP. Aceasta presupune procesarea unor date sensibile și necesită validări suplimentare de securitate, legalitate și protecție a datelor.

---

## 🚀 Quick Start

### Cerințe

- Flutter 3.0 sau mai nou
- Dart 3.0 sau mai nou
- Node.js
- MongoDB connection string

### Rulare locală pe telefon cu backend local

Pentru demo pe iPhone conectat la același Wi-Fi ca laptopul:

```bash
cd /Users/vxmpseb/Desktop/linko
./scripts/run_local_backend_phone.sh 00008110-001C25E9147B801E
```

### Demo Accounts (Pre-configured)

Pentru testare rapidă, am pus la dispoziție aceste conturi:

**Requester (persoană care cere ajutor):**

- Email: `maria.ionescu@demo.linko`
- Password: `parola123`

**Volunteer (persoană care oferă ajutor):**

- Email: `ioana.stan@demo.linko`
- Password: `parola123`

---

## 📊 Demo Mode / Offline Mode

Aplicația include și un mod de siguranță pentru demonstrații live. Dacă backend-ul nu este disponibil, aplicația poate porni în **Demo Mode**, cu date locale realiste.

### Date locale incluse

- 2 requesters (persoane care cer ajutor)
- 3 volunteers (persoane care oferă ajutor)
- Cereri cu statusuri diferite: Open, Accepted, In Progress, Completed
- Mesaje demo pentru chat
- Statistici realiste pentru profil și impact
- Coordonate reale pentru hartă și calculul distanței

---

## 🔎 Clarificare pentru evaluare

Pentru finală, aplicația poate fi prezentată în două moduri:

- **Live Backend**: folosește backend-ul real Node.js + MongoDB, autentificare reală, API și WebSocket.
- **Demo Mode / Offline Mode**: fallback local pentru situații în care internetul, rețeaua sau serverul nu sunt disponibile în timpul prezentării.

Demo Mode nu înlocuiește backend-ul real; este doar o măsură de siguranță pentru stabilitatea prezentării.

---

## 📜 Licență

MIT License

---

<div align="center">

**Construit cu ❤️ pentru Hardcore Entrepreneur 6.0**

_Tema: "Incluziune pentru toți. Viitor durabil pentru fiecare."_

</div>
