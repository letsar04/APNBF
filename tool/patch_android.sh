#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"
python3 - <<'PY'
from pathlib import Path
p=Path('android/app/src/main/AndroidManifest.xml')
s=p.read_text()
if 'android.permission.INTERNET' not in s:
    s=s.replace('<manifest ', '<manifest xmlns:android="http://schemas.android.com/apk/res/android" ', 1) if 'xmlns:android' not in s else s
    s=s.replace('<application ', '    <uses-permission android:name="android.permission.INTERNET" />\n\n    <application ', 1)
intent='''        <intent-filter>\n            <action android:name="android.intent.action.VIEW" />\n            <category android:name="android.intent.category.DEFAULT" />\n            <category android:name="android.intent.category.BROWSABLE" />\n            <data android:scheme="apnbf" />\n        </intent-filter>\n'''
if 'android:scheme="apnbf"' not in s:
    marker='            <intent-filter>\n                <action android:name="android.intent.action.MAIN"/>'
    s=s.replace(marker, intent+marker, 1)
s=s.replace('android:label="apnbf"','android:label="APNBF"')
p.write_text(s)
PY
