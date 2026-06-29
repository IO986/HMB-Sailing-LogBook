# Privacy Policy – HMB Sailing Log

**Last updated: 2026-06-29**
**App name:** HMB Sailing Log
**Developer:** LacoSte© / IO986
**Contact:** steclaco@gmail.com

---

## 1. Introduction

HMB Sailing Log ("the App") is a personal sailing logbook for Android. This Privacy Policy explains what data the App collects, how it is used, and what rights you have as a user.

---

## 2. Data Collected and Why

### 2.1 Location (GPS)
- **What:** Device GPS coordinates (latitude, longitude, speed, course)
- **Why:** To record your sailing route, create logbook entries automatically during tracking, and display your position on the map
- **Storage:** Stored locally on your device only. Location data is never sent to third-party servers without your explicit action.
- **When:** Only while you actively start a Tracking session. The App does not track location in the background between sessions unless a tracking session is running.

### 2.2 Online Account (Optional)
- **What:** Email address and display name
- **Why:** To synchronize your logbook to the HMB sailing log cloud service (logbook.hmba.boats)
- **Storage:** Stored on the HMB cloud server. Your email is used only for authentication and is never sold or shared with third parties.
- **Optional:** The online account feature is entirely optional. The App is fully functional without creating an account.

### 2.3 User Profile Data (Skipper Card, Vessel ID)
- **What:** Skipper name, sailing license details, VHF/SRC license, vessel call sign, MMSI
- **Why:** To autofill the Mayday card and PDF voyage export
- **Storage:** Stored locally on your device using Android SharedPreferences. This data is never transmitted automatically.

### 2.4 Logbook Entries, Photos, Tracks
- **What:** Text notes, photos attached to logbook entries, GPS track points
- **Why:** To form your personal sailing logbook
- **Storage:** Stored in a local SQLite database on your device. Synced to HMB cloud only if you are logged in and initiate sync.

### 2.5 App Preferences
- **What:** Language setting, unit preferences (temperature, wind, depth), marine instrument connection settings
- **Why:** To remember your preferences across sessions
- **Storage:** Stored locally using Android SharedPreferences

---

## 3. Third-Party Services

The App uses the following third-party services:

| Service | Purpose | Privacy Policy |
|---------|---------|---------------|
| **Open-Meteo** | Marine weather forecast (no account required, open API) | https://open-meteo.com/en/terms |
| **OpenStreetMap / OpenSeaMap** | Nautical map tiles (no account required) | https://wiki.openstreetmap.org/wiki/Privacy_Policy |
| **Esri ArcGIS** | Satellite map tiles | https://www.esri.com/en-us/privacy/privacy-statements/privacy-statement |

The App does **not** use:
- Advertising networks
- Analytics SDKs (Firebase, Crashlytics, etc.)
- Social login providers

---

## 4. Data Sharing

We do **not** sell, rent, or share your personal data with third parties for marketing purposes.

Your data may be shared only:
- With the HMB cloud service (logbook.hmba.boats) if you create an account and sync
- When you explicitly export a PDF or GPX file and share it using Android's share functionality

---

## 5. Data Retention

- **Local data:** Remains on your device until you delete the App or clear its data
- **Cloud data:** If you delete your online account, all cloud data is deleted within 30 days
- **Exported files:** Remain in your device's storage until you delete them manually

---

## 6. Permissions

The App requests the following Android permissions:

| Permission | Reason |
|-----------|--------|
| `ACCESS_FINE_LOCATION` | GPS tracking for the sailing logbook |
| `ACCESS_COARSE_LOCATION` | Fallback location for weather |
| `FOREGROUND_SERVICE` | Background GPS tracking when screen is off |
| `INTERNET` | Weather data, map tiles, optional cloud sync |
| `CAMERA` | Taking photos for logbook entries |
| `READ_EXTERNAL_STORAGE` | Attaching photos from gallery |
| `WRITE_EXTERNAL_STORAGE` | Saving exported PDF/GPX files |
| `WAKE_LOCK` | Keeping GPS active during tracking |
| `RECEIVE_BOOT_COMPLETED` | Restarting background tracking after device reboot |

---

## 7. Children's Privacy

The App is not intended for users under 13 years of age. We do not knowingly collect personal data from children.

---

## 8. Your Rights (GDPR – EU Users)

If you are located in the European Union, you have the following rights:

- **Right of access:** Request a copy of your personal data
- **Right to rectification:** Correct inaccurate data
- **Right to erasure:** Request deletion of your data ("right to be forgotten")
- **Right to portability:** Receive your data in a machine-readable format (JSON/CSV available via export)
- **Right to object:** Object to processing of your personal data

To exercise any of these rights, contact: **steclaco@gmail.com**

---

## 9. Data Security

- All local data is stored in Android's application sandbox, inaccessible to other apps
- Cloud communication uses HTTPS/TLS encryption
- Passwords are never stored in plain text

---

## 10. Changes to This Policy

We may update this Privacy Policy periodically. Significant changes will be communicated through the App. The "Last updated" date at the top of this document will always reflect the most recent revision.

---

## 11. Contact

If you have questions about this Privacy Policy or your data:

**Email:** steclaco@gmail.com
**GitHub:** https://github.com/IO986/HMB-Sailing-LogBook
