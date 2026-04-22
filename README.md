# MedCycle 💊
### Smart Medicine Disposal App — Helping India Fight Antibiotic Resistance

MedCycle helps you **safely throw away leftover antibiotics** instead of flushing them down the drain. You earn points and badges for every medicine you dispose safely. Pharmacies verify your drop-offs. The government can see live data to track where antibiotic misuse is a problem.

---

## What Can You Do With This App?

| Who Are You? | What You Can Do |
|---|---|
| 👤 **Regular Person** | Dispose old antibiotics safely, get a QR code, earn reward points & badges |
| 🏪 **Pharmacy** | Scan QR codes from citizens, verify their medicine drop-offs |
| 🏛️ **Government / Researcher** | See live charts and maps of disposal activity across India |

---

## What's Inside This Project?

```
MedCycle/
├── backend/        ← The server (Django + Python) — handles all data
├── frontend/       ← Web app (works in any browser, no install needed)
│   ├── index.html      → Citizen App
│   ├── pharmacy.html   → Pharmacy Portal
│   └── dashboard.html  → Government Dashboard
└── flutter_app/    ← Mobile App (Flutter) — for Android & iOS
```

---

## Part 1 — Run the Backend (Server)

The backend is the brain of the app. You need to run it first.

### Step 1 — Make sure Python is installed
Download Python from https://python.org (version 3.10 or higher)

### Step 2 — Open a terminal and go to the backend folder
```bash
cd MedCycle/backend
```

### Step 3 — Create a virtual environment (a safe space for Python packages)
```bash
python -m venv venv
```

### Step 4 — Activate the virtual environment

**On Windows:**
```bash
venv\Scripts\activate
```
**On Mac/Linux:**
```bash
source venv/bin/activate
```
You'll see `(venv)` appear at the start of the line. That means it worked.

### Step 5 — Install all required packages
```bash
pip install -r requirements.txt
```

### Step 6 — Set up your API key
Copy the example settings file:
```bash
copy .env.example .env
```
Open the `.env` file in Notepad and add your Gemini API key:
```
GEMINI_API_KEY=paste-your-key-here
```
> Get a free Gemini API key at https://makersuite.google.com/app/apikey

### Step 7 — Set up the database
```bash
python manage.py migrate
```

### Step 8 — Load sample data (pharmacies, medicines, test citizens)
```bash
python manage.py seed_data
```

### Step 9 — Start the server
```bash
python manage.py runserver
```

The server is now running! Open your browser and go to:
> 🌐 **http://localhost:8000**

You'll see the MedCycle home page with links to all three apps.

---

## Part 2 — Use the Web App (No Install Needed)

Once the server is running, open these links in your browser:

| App | Link | Who Uses It |
|---|---|---|
| Citizen App | http://localhost:8000/citizen | Anyone who wants to dispose medicines |
| Pharmacy Portal | http://localhost:8000/pharmacy | Pharmacy staff |
| Government Dashboard | http://localhost:8000/dashboard | Officials / researchers |

> **No server? No problem.** All three pages work in **Demo Mode** even without the backend running. Just open the HTML files directly in your browser.

---

## Part 3 — Use the Mobile App (Flutter)

The mobile app is in the `flutter_app/` folder. It connects to the same Django backend.

### Step 1 — Install Flutter
Download from https://docs.flutter.dev/get-started/install/windows
Follow the installation steps on that page.

### Step 2 — Go to the flutter_app folder
```bash
cd MedCycle/flutter_app
```

### Step 3 — Download Flutter packages
```bash
flutter pub get
```

### Step 4 — Make sure your backend server is running (from Part 1 above)

### Step 5 — Run the app

**On Android phone/emulator:**
```bash
flutter run
```

**In Chrome browser:**
```bash
flutter run -d chrome
```

> **Tip:** If using an Android emulator, the app talks to your computer's server automatically. If using a real phone, replace `10.0.2.2` with your computer's IP address in `lib/constants/api.dart`.

---

## Features

### Citizen App
- Register anonymously — no name or email needed
- Fill in medicine details (name, type, quantity, expiry date)
- Get a QR code to show at a pharmacy
- Earn points for every safe disposal
- Unlock badges as you do more disposals
- Chat with **MedBot** (AI assistant) for advice
- Find nearby pharmacies on a map
- Supports **4 languages**: English, हिंदी, मराठी, தமிழ்

### Pharmacy Portal
- Log in with your Pharmacy ID
- Scan or enter the citizen's QR code
- Verify the disposal — the citizen gets their points automatically
- See today's log and your pharmacy's stats

### Government Dashboard
- Live map showing where disposals are happening (heatmap)
- Charts: disposals over time, antibiotic types, AMR risk zones
- State-wise breakdown
- Pharmacy performance ranking
- Auto-refreshes every 30 seconds

---

## How Does a Disposal Work? (Step by Step)

```
1. Citizen opens the app
2. Enters the medicine name, quantity, and expiry date
3. App gives a unique QR code
4. Citizen goes to the nearest pharmacy
5. Pharmacy scans the QR code
6. App marks the disposal as "Verified"
7. Citizen earns points and possibly a new badge
8. Government dashboard updates automatically
```

---

## Reward Points & Badges

Every time you safely dispose a medicine, you earn points:

| Action | Points Earned |
|---|---|
| Any disposal | +10 points |
| High-risk antibiotic (e.g. fluoroquinolone) | +20 points |
| Critical antibiotic (e.g. carbapenem) | +30 points |
| Pharmacy verifies your disposal | +5 bonus points |

### Badges You Can Earn

| Badge | How to Get It |
|---|---|
| 🌱 First Disposal | Do your very first safe disposal |
| 🦸 AMR Hero | 10 verified disposals |
| 🏅 Safe Champion | 25 verified disposals |
| 🌟 Community Leader | 50 verified disposals |
| 🌍 Eco Warrior | 100 verified disposals |
| 🛡️ Health Guardian | 200 verified disposals |

---

## Technology Used

| Part | Technology |
|---|---|
| Mobile App | Flutter (works on Android, iOS, Web) |
| Web Frontend | HTML + Tailwind CSS + JavaScript |
| Backend/Server | Python + Django |
| Database | SQLite (for testing) |
| AI Chatbot | Google Gemini API |
| Maps | OpenStreetMap + Leaflet.js / Flutter Map |
| Charts | Chart.js |
| QR Codes | Python qrcode library + qr_flutter |

---

## Common Problems & Fixes

**"Server not found" or blank page**
- Make sure the backend server is running (`python manage.py runserver`)
- Check that you see `http://localhost:8000` in the terminal

**"pip is not recognized"**
- Make sure Python is installed and added to PATH
- Try `python -m pip install -r requirements.txt`

**Flutter app shows "Connection error"**
- Make sure Django server is running
- On Android emulator: server address is `10.0.2.2:8000` (already set)
- On real device: change the address in `flutter_app/lib/constants/api.dart`

**Gemini chatbot not working**
- Check your `.env` file has the correct `GEMINI_API_KEY`
- The app will fall back to basic answers if the key is missing

**"No module named X" error**
- Run `pip install -r requirements.txt` again
- Make sure your virtual environment is activated (you see `(venv)` in terminal)

---

## Privacy

- You don't need to give your name, email, or any personal information
- Each user gets a random ID (no one can trace it back to you)
- If you enter a phone number, it is stored encrypted (hashed)
- Your location is only stored at city/district level — not your exact address

---

## Admin Panel

To manage the app data (add pharmacies, view all disposals, manage users):

1. Create an admin account:
```bash
python manage.py createsuperuser
```
2. Open http://localhost:8000/admin/
3. Log in with the username and password you just created

---

## Need Help?

- Check the error message carefully — it usually tells you what's wrong
- Make sure you followed every step in order
- Make sure the virtual environment is activated before running any Python command

---

*MedCycle — Every antibiotic you safely dispose protects your community.*
