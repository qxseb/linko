# Linko - Community Assistance Platform

<div align="center">

**Conectăm persoane care au nevoie de ajutor cu voluntari din comunitate**

[Demo Video](#) • [Pitch Video](#)

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

## 📱 Despre Linko

Linko este o platformă mobilă care rezolvă o problemă reală: **peste 3.5 milioane de persoane în vârstă din România au nevoie de ajutor zilnic** pentru sarcini simple dar critice (cumpărături, medicamente, treburi).

---

## 🚀 Quick Start

### Cerințe
- Flutter 3.0 sau mai nou
- Dart 3.0 sau mai nou

**Aplicația va porni INSTANT cu date mock pentru demonstrație.**  
**NU necesită Firebase, backend sau internet.**

### Demo Accounts (Pre-configured)

Pentru testare rapidă, am pus la dispoziție aceste conturi:

**Requester (persoană care cere ajutor):**
- Email: `maria.popescu@email.com`
- Password: any

**Volunteer (persoană care oferă ajutor):**
- Email: `andrei.ionescu@email.com`
- Password: any

---

## 📊 Date Mock (Demo Mode)

Aplicația include date mock pentru demonstrație completă:

### Utilizatori Mock
- 2 requesters (persoane care cer ajutor)
- 3 volunteers (persoane care oferă ajutor)
- Toți cu trust levels și statistici realiste

### Cereri Mock
- 3 cereri deschise (Open)
- 2 cereri acceptate (Accepted)
- 2 cereri în desfășurare (InProgress)
- 1 cerere finalizată (Completed)

---

## 🚧 Limitări Demo (Mock Data)

⚠️ **Versiunea curentă folosește date mock pentru demonstrație:**

- Datele sunt locale (SharedPreferences)
- Nu există sincronizare între device-uri
- Notificările sunt simulate (nu push notifications)
- Distanța este mock (0.8km, 1.2km hardcoded)
- Verificarea utilizatorilor este mock

🚀 **Versiunea de producție va include:**

- Backend real (Firebase/Node.js + MongoDB)
- Notificări push reale (Firebase Cloud Messaging)
- GPS pentru distanță reală
- Verificare identitate (upload ID + validare CNP)
- Sync real-time între device-uri
- WebSocket pentru chat instant

---

## 📜 Licență

MIT License

---

<div align="center">

**Construit cu ❤️ pentru Hardcore Entrepreneur 6.0**

*Tema: "Incluziune pentru toți. Viitor durabil pentru fiecare."*

</div>
