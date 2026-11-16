package com.https1121.overdrive.companion;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.core.content.FileProvider;

import com.google.android.material.dialog.MaterialAlertDialogBuilder;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.atomic.AtomicBoolean;

/** Checks GitHub releases/latest and offers an in-app APK download + installer intent. */
final class AppUpdater {
    private static final String TAG = "AppUpdater";
    private static final String REPO = "HTTPS1121/overdrive-companion";
    private static final AtomicBoolean CHECKING = new AtomicBoolean();

    static void checkIfNeeded(Activity activity) {
        if (!CHECKING.compareAndSet(false, true)) return;
        new Thread(() -> {
            try {
                int installed = installedVersionCode(activity);
                JSONObject rel = fetchLatest();
                JSONObject meta = metaFromRelease(rel);
                int latest = meta.getInt("versionCode");
                if (latest <= installed) return;
                String name = meta.optString("versionName", rel.getString("tag_name"));
                String apkUrl = apkUrlFromRelease(rel);
                if (apkUrl == null) return;
                activity.runOnUiThread(() -> prompt(activity, name, latest, apkUrl));
            } catch (Exception e) {
                Log.w(TAG, "update check failed", e);
            } finally {
                CHECKING.set(false);
            }
        }, "od-update-check").start();
    }

    private static int installedVersionCode(Activity a) throws PackageManager.NameNotFoundException {
        PackageInfo pi = a.getPackageManager().getPackageInfo(a.getPackageName(), 0);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            return (int) pi.getLongVersionCode();
        }
        return pi.versionCode;
    }

    private static JSONObject fetchLatest() throws Exception {
        URL u = new URL("https://api.github.com/repos/" + REPO + "/releases/latest");
        HttpURLConnection c = (HttpURLConnection) u.openConnection();
        c.setConnectTimeout(15000);
        c.setReadTimeout(15000);
        c.setRequestProperty("Accept", "application/vnd.github+json");
        c.setRequestProperty("User-Agent", Auth.UA);
        try (InputStream in = c.getInputStream()) {
            byte[] buf = in.readAllBytes();
            return new JSONObject(new String(buf));
        } finally {
            c.disconnect();
        }
    }

    private static JSONObject metaFromRelease(JSONObject rel) throws Exception {
        JSONArray assets = rel.getJSONArray("assets");
        for (int i = 0; i < assets.length(); i++) {
            JSONObject a = assets.getJSONObject(i);
            String n = a.getString("name");
            if (n.endsWith("-meta.json")) {
                return readJsonUrl(a.getString("browser_download_url"));
            }
        }
        throw new IllegalStateException("companion-release-meta.json missing on latest release");
    }

    private static JSONObject readJsonUrl(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setRequestProperty("User-Agent", Auth.UA);
        try (InputStream in = c.getInputStream()) {
            return new JSONObject(new String(in.readAllBytes()));
        } finally {
            c.disconnect();
        }
    }

    private static String apkUrlFromRelease(JSONObject rel) {
        JSONArray assets = rel.optJSONArray("assets");
        if (assets == null) return null;
        for (int i = 0; i < assets.length(); i++) {
            JSONObject a = assets.optJSONObject(i);
            if (a == null) continue;
            String n = a.optString("name", "");
            if (n.endsWith(".apk")) return a.optString("browser_download_url");
        }
        return null;
    }

    private static void prompt(Activity activity, String versionName, int versionCode, String apkUrl) {
        new MaterialAlertDialogBuilder(activity)
                .setTitle("עדכון זמין")
                .setMessage("גרסה " + versionName + " (קוד " + versionCode + ") זמינה להורדה.")
                .setPositiveButton("עדכן", (d, w) -> downloadAndInstall(activity, apkUrl, versionName))
                .setNegativeButton("לא עכשיו", null)
                .show();
    }

    private static void downloadAndInstall(Activity activity, String apkUrl, String versionName) {
        var dlg = new MaterialAlertDialogBuilder(activity)
                .setTitle("מוריד עדכון")
                .setMessage("מוריד עדכון…")
                .setCancelable(false)
                .show();
        new Thread(() -> {
            File dir = new File(activity.getCacheDir(), "updates");
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
            File apk = new File(dir, "overdrive-companion-" + versionName + ".apk");
            try {
                HttpURLConnection c = (HttpURLConnection) new URL(apkUrl).openConnection();
                c.setRequestProperty("User-Agent", Auth.UA);
                try (InputStream in = new BufferedInputStream(c.getInputStream());
                     FileOutputStream out = new FileOutputStream(apk)) {
                    byte[] buf = new byte[16384];
                    int n;
                    while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
                } finally {
                    c.disconnect();
                }
                activity.runOnUiThread(() -> {
                    dlg.dismiss();
                    installApk(activity, apk);
                });
            } catch (Exception e) {
                activity.runOnUiThread(() -> {
                    dlg.dismiss();
                    new MaterialAlertDialogBuilder(activity)
                            .setTitle("ההורדה נכשלה")
                            .setMessage(e.getMessage() == null ? "נסה שוב מאוחר יותר" : e.getMessage())
                            .setPositiveButton("אישור", null)
                            .show();
                });
            }
        }, "od-update-dl").start();
    }

    private static void installApk(Activity activity, File apk) {
        Uri uri = FileProvider.getUriForFile(activity, activity.getPackageName() + ".fileprovider", apk);
        Intent i = new Intent(Intent.ACTION_VIEW);
        i.setDataAndType(uri, "application/vnd.android.package-archive");
        i.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        try {
            activity.startActivity(i);
        } catch (Exception e) {
            new MaterialAlertDialogBuilder(activity)
                    .setTitle("לא ניתן להתקין")
                    .setMessage("אפשר התקנת APK מהגדרות המכשיר ונסה שוב.")
                    .setPositiveButton("אישור", null)
                    .show();
        }
    }
}