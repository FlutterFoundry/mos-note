# Privacy Policy for Memos Note

**Last updated: July 2025**

## Introduction

Memos Note ("we," "our," or "the App") is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our mobile application. By using Memos Note, you agree to the practices described in this policy.

**App Name:** Memos Note  
**Package Name:** com.mos.note  
**Developer Contact:** sheenazien.dev@gmail.com  

---

## 1. Data We Collect

### 1.1 Information You Provide Directly

- **Account Credentials:** When you sign in to your self-hosted Memos server, your username and password are sent directly to your own server. We do not collect, store, or have access to your credentials.
- **Memo Content:** All notes, comments, and attachments you create are stored on your self-hosted Memos server and locally on your device. We do not have access to your memo content.

### 1.2 Information Stored Locally on Your Device

The following data is stored **only on your device** and is never transmitted to us or any third-party analytics service:

- **Authentication Tokens:** Stored securely in encrypted storage (Android Keystore / iOS Keychain) to maintain your login session.
- **Cached User Information:** User ID, username, display name, email, and role — cached locally for offline access.
- **Memo Data:** Local copies of your memos stored in a SQLite database on your device for offline functionality.
- **App Preferences:** Theme mode (dark/light/system) and language preference.
- **Instance URL:** The URL of your self-hosted Memos server, stored locally for API communication.

### 1.3 Device and Network Information

- **Network Connectivity Status:** The App checks your internet connection status to determine whether to operate in online or offline mode. This check is performed locally and no connection data is sent to external servers.

### 1.4 Data We Do NOT Collect

We want to be transparent about what we **do not** collect:

- We do **not** collect device identifiers (IMEI, advertising ID, Android ID).
- We do **not** collect geolocation data.
- We do **not** collect analytics or usage tracking data.
- We do **not** collect crash reports (unless you explicitly opt in via system-level prompts).
- We do **not** collect personal information beyond what is described above.
- We do **not** share any data with third parties.

---

## 2. How We Use Your Information

- **To provide the App's core functionality:** Creating, editing, viewing, and syncing memos between your device and your self-hosted Memos server.
- **To maintain your session:** Authentication tokens are used to keep you logged in.
- **To enable offline access:** Local storage allows you to use the App without an internet connection.
- **To share memos (at your request):** When you choose to share a memo, the App generates a share link through your self-hosted server. The share action uses the device's native sharing functionality.

---

## 3. How Your Data Is Stored and Secured

### 3.1 Local Storage

- **SQLite Database:** Memo content and pending operations are stored in a local SQLite database (`memos_local.db`).
- **Encrypted Secure Storage:** Authentication tokens are stored using `flutter_secure_storage`, which uses Android Encrypted SharedPreferences (backed by Android Keystore) on Android and the iOS Keychain on iOS.
- **SharedPreferences:** Non-sensitive preferences (theme, language) are stored using standard platform preferences.

### 3.2 Network Communication

- All API communication between the App and your self-hosted Memos server uses HTTPS where available.
- The App communicates **only** with the Memos server URL you configure during setup.
- No data is sent to any third-party servers, analytics platforms, or advertising networks.

### 3.3 Security Measures

- Authentication tokens are encrypted at rest using platform-native secure storage.
- We follow industry best practices for data security within the App.
- However, no method of electronic storage is 100% secure. We encourage you to use HTTPS for your self-hosted server.

---

## 4. Third-Party Services

### 4.1 Self-Hosted Memos Server

Memos Note is a client application for [Memos](https://github.com/usememos/memos), an open-source, self-hosted note-taking platform. The App connects **only** to the Memos server instance you configure. Data sent to your server is governed by:

- Your server's own privacy policy
- The hosting provider you choose for your server

We have no control over and are not responsible for the privacy practices of your self-hosted Memos server.

### 4.2 Third-Party Libraries

The App uses the following open-source libraries that may handle data locally:

| Library | Purpose | Data Handled |
|---------|---------|-------------|
| `sqflite` | Local database | Memo data (stored locally) |
| `flutter_secure_storage` | Encrypted storage | Auth tokens (encrypted) |
| `shared_preferences` | Preferences | Theme/language settings |
| `dio` | HTTP client | API communication with your server |
| `connectivity_plus` | Network status | Connection state (local only) |
| `cached_network_image` | Image caching | Images from your server (cached locally) |
| `image_picker` | Image selection | Images you select (sent to your server) |
| `share_plus` | Native sharing | Share links (via OS sharing) |
| `url_launcher` | URL handling | External links (via browser) |

None of these libraries transmit data to us or any third party beyond your own self-hosted server.

---

## 5. Images and Media

### 5.1 Images You Attach to Memos

- When you attach an image to a memo, the App uses the `image_picker` library to access your device's photo gallery or camera (with your permission).
- Selected images are encoded and uploaded **only** to your self-hosted Memos server as attachments.
- We do not collect, store, or transmit your images to any other location.

### 5.2 Camera and Storage Permissions

The App may request the following permissions:

- **Camera access:** To attach photos to your memos (only when you choose to add an image).
- **Storage access:** To read images from your gallery for memo attachments.

These permissions are used **solely** for the functionality described above and are never used for any other purpose.

---

## 6. Data Sharing and Disclosure

We do **not** sell, trade, rent, or otherwise share your personal data with any third parties.

The only data transmission that occurs is between your device and the self-hosted Memos server that **you** configure and control.

---

## 7. Data Retention and Deletion

### 7.1 Local Data

- All local data (memos cache, authentication tokens, preferences) can be deleted by:
  - **Clearing App Data** in your device settings
  - **Signing out** of the App (which clears cached authentication data)
  - **Uninstalling** the App (which removes all local data)

### 7.2 Server Data

- Data stored on your self-hosted Memos server must be managed according to that server's policies and administration tools.
- Deleting memos within the App sends a delete request to your server. Check your server configuration for soft-delete vs. hard-delete policies.

---

## 8. Children's Privacy

Memos Note is a general-purpose productivity tool. We do not knowingly collect personal information from children under the age of 13. As we do not collect data on our servers, the App does not pose additional risk to children. However, parents and guardians should supervise their children's use of any self-hosted server.

---

## 9. International Users

Your self-hosted Memos server may be located in any country. Data transmitted between the App and your server may be subject to the laws and regulations of the jurisdiction where your server is hosted. Please consider this when choosing a hosting location for your Memos instance.

---

## 10. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any material changes by:

- Updating the "Last updated" date at the top of this policy
- Posting a notice within the App (for significant changes)

Your continued use of the App after any changes constitutes your acceptance of the updated Privacy Policy.

---

## 11. Contact Us

If you have any questions, concerns, or requests regarding this Privacy Policy, please contact us at:

- **Email:** sheenazien.dev@gmail.com
- **GitHub:** [https://github.com/sheenazien8/mos-note](https://github.com/sheenazien8/mos-note)

We will respond to all reasonable inquiries and requests within 30 days.

---

## 12. Consent

By downloading and using Memos Note, you consent to this Privacy Policy. If you do not agree with this policy, please do not use the App.

---

*This Privacy Policy is designed to comply with Google Play Store requirements including the Google Play User Data Policy, and applicable data protection regulations.*
