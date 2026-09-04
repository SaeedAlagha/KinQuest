# Judge web access

Sila can be presented without the App Store or TestFlight. Judges scan one QR
code and use the production Flutter experience in Safari, Chrome, or another
modern browser.

## Judge instructions

1. Scan the Sila QR code.
2. Open the HTTPS link in Safari.
3. Use **Try the 3-minute Competition Demo** for the complete judged story.
4. Optional on iPhone: choose **Share → Add to Home Screen**, enable
   **Open as Web App**, and tap **Add**.

The permanent default address is:

`https://kinquest-af379.web.app`

![Scan to open Sila](sila-judge-qr.png)

## Team release command

The API gateway must already be deployed at an HTTPS URL. Then run:

```sh
KINQUEST_API_BASE_URL=https://your-api.example \
  ./tool/deploy_judge_web.sh
```

Firebase Hosting deploys the contents of `build/web` and keeps app routes
working when a browser refreshes a nested URL. The release build embeds only
the public gateway address; Gemini and OpenRouter keys remain on the server.

## Pre-demo checks

- Scan the QR code on both an iPhone and an Android phone.
- Complete the three-minute demo once in English and once in Arabic.
- Confirm portrait layouts do not clip at 320 logical pixels wide.
- Sign in with a demo family and open at least one AI-powered game.
- Test Sila Chat and voice on the venue network.
- Keep a second device signed in and a screen recording as fallback.
