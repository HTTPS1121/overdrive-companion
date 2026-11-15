package com.https1121.overdrive.companion;

import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;
import android.util.Base64;
import android.webkit.CookieManager;
import android.webkit.MimeTypeMap;
import android.webkit.URLUtil;

import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Saves what the web UI downloads, the way Chrome would: images go to Pictures/OverDrive,
 * everything else to Download/OverDrive (MediaStore, no storage permission on Android 10+),
 * under the file's own name, followed by a "נשמר" notification that opens the file.
 */
final class Downloads {
    interface Ui { void message(String text, boolean error); }

    static final String CHANNEL = "downloads";
    private static final AtomicInteger IDS = new AtomicInteger(4100);
    private final Activity act;
    private final Ui ui;
    private final String userAgent;
    private final ExecutorService pool = Executors.newSingleThreadExecutor();

    Downloads(Activity act, String userAgent, Ui ui) {
        this.act = act;
        this.userAgent = userAgent;
        this.ui = ui;
        NotificationManager nm = act.getSystemService(NotificationManager.class);
        if (nm != null) {
            NotificationChannel ch = new NotificationChannel(CHANNEL, "הורדות", NotificationManager.IMPORTANCE_DEFAULT);
            ch.setSound(null, null);
            nm.createNotificationChannel(ch);
        }
    }

    /** blob: and data: contents read by the injected page hook. */
    void saveBase64(String b64, String name, String mime) {
        pool.execute(() -> {
            try {
                byte[] bytes = Base64.decode(b64, Base64.DEFAULT);
                String m = cleanMime(mime);
                String n = fileName(name, null, null, m);
                if (m == null) m = mimeFromName(n);
                save(new ByteArrayInputStream(bytes), n, m);
            } catch (Exception e) {
                fail(e);
            }
        });
    }

    /** A regular http(s) download through the tunnel, with the session and the zrok bypass. */
    void fetch(String url, String suggestedName, String jwt) {
        ui.message("מוריד…", false);
        pool.execute(() -> {
            HttpURLConnection c = null;
            try {
                c = (HttpURLConnection) new URL(url).openConnection();
                c.setConnectTimeout(15000);
                c.setReadTimeout(60000);
                c.setInstanceFollowRedirects(true);
                c.setRequestProperty("User-Agent", userAgent);
                c.setRequestProperty("skip_zrok_interstitial", "true");
                String cookie = CookieManager.getInstance().getCookie(url);
                if (cookie != null) c.setRequestProperty("Cookie", cookie);
                if (jwt != null) c.setRequestProperty("Authorization", "Bearer " + jwt);
                int code = c.getResponseCode();
                if (code >= 400) {
                    String err = "HTTP " + code;
                    try (InputStream es = c.getErrorStream()) {
                        if (es != null) {
                            String body = new String(readLimited(es, 4096), StandardCharsets.UTF_8);
                            Matcher m = Pattern.compile("\"error\"\\s*:\\s*\"([^\"]{1,160})\"").matcher(body);
                            if (m.find()) err = m.group(1);
                        }
                    }
                    throw new IOException(err);
                }
                String m = cleanMime(c.getContentType());
                String n = fileName(suggestedName, c.getHeaderField("Content-Disposition"), url, m);
                if (m == null || m.equals("application/octet-stream")) {
                    String g = mimeFromName(n);
                    if (g != null) m = g;
                }
                try (InputStream in = c.getInputStream()) { save(in, n, m == null ? "application/octet-stream" : m); }
            } catch (Exception e) {
                fail(e);
            } finally {
                if (c != null) c.disconnect();
            }
        });
    }

    void fail(Exception e) {
        String msg = e.getMessage();
        ui.message("ההורדה נכשלה" + (msg != null && !msg.isEmpty() ? " · " + msg : ""), true);
    }

    private void save(InputStream in, String name, String mime) throws IOException {
        boolean image = mime != null && mime.startsWith("image/");
        String dir = (image ? Environment.DIRECTORY_PICTURES : Environment.DIRECTORY_DOWNLOADS) + "/OverDrive";
        Uri collection = image ? MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
                : MediaStore.Downloads.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY);
        ContentResolver cr = act.getContentResolver();
        ContentValues v = new ContentValues();
        v.put(MediaStore.MediaColumns.DISPLAY_NAME, name);
        if (mime != null) v.put(MediaStore.MediaColumns.MIME_TYPE, mime);
        v.put(MediaStore.MediaColumns.RELATIVE_PATH, dir);
        v.put(MediaStore.MediaColumns.IS_PENDING, 1);
        Uri item = cr.insert(collection, v);
        if (item == null) throw new IOException("MediaStore");
        try (OutputStream out = cr.openOutputStream(item)) {
            if (out == null) throw new IOException("MediaStore");
            byte[] buf = new byte[65536];
            int r;
            while ((r = in.read(buf)) > 0) out.write(buf, 0, r);
        } catch (IOException e) {
            cr.delete(item, null, null);
            throw e;
        }
        ContentValues done = new ContentValues();
        done.put(MediaStore.MediaColumns.IS_PENDING, 0);
        cr.update(item, done, null, null);
        String finalName = name;
        try (android.database.Cursor q = cr.query(item, new String[]{MediaStore.MediaColumns.DISPLAY_NAME}, null, null, null)) {
            if (q != null && q.moveToFirst()) finalName = q.getString(0);
        } catch (Exception ignored) { }
        notifySaved(item, finalName, mime, dir);
        ui.message("נשמר ב־" + dir + " · " + finalName, false);
    }

    private void notifySaved(Uri item, String name, String mime, String dir) {
        Intent open = new Intent(Intent.ACTION_VIEW).setDataAndType(item, mime)
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_ACTIVITY_NEW_TASK);
        int id = IDS.incrementAndGet();
        PendingIntent pi = PendingIntent.getActivity(act, id, open, PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        NotificationCompat.Builder nb = new NotificationCompat.Builder(act, CHANNEL)
                .setSmallIcon(android.R.drawable.stat_sys_download_done)
                .setContentTitle("נשמר")
                .setContentText(name)
                .setSubText(dir)
                .setContentIntent(pi)
                .setAutoCancel(true);
        try { NotificationManagerCompat.from(act).notify(id, nb.build()); } catch (SecurityException ignored) { }
    }

    // ------------------------------------------------------------------ names and types

    private static String cleanMime(String ct) {
        if (ct == null) return null;
        String m = ct.split(";")[0].trim().toLowerCase(Locale.ROOT);
        return m.isEmpty() ? null : m;
    }

    static String mimeFromName(String n) {
        int dot = n.lastIndexOf('.');
        if (dot < 0) return null;
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(n.substring(dot + 1).toLowerCase(Locale.ROOT));
    }

    private static final Pattern CD_STAR = Pattern.compile("(?i)filename\\*\\s*=\\s*([^']*)'[^']*'([^;]+)");
    private static final Pattern CD = Pattern.compile("(?i)filename\\s*=\\s*(\"([^\"]*)\"|[^;]+)");

    static String fileName(String suggested, String disposition, String url, String mime) {
        String n = suggested;
        if ((n == null || n.trim().isEmpty()) && disposition != null) {
            Matcher m = CD_STAR.matcher(disposition);
            if (m.find()) {
                try { n = URLDecoder.decode(m.group(2).trim(), m.group(1).isEmpty() ? "UTF-8" : m.group(1)); } catch (Exception ignored) { }
            }
            if (n == null || n.isEmpty()) {
                m = CD.matcher(disposition);
                if (m.find()) n = m.group(2) != null ? m.group(2) : m.group(1).trim();
            }
        }
        if ((n == null || n.trim().isEmpty()) && url != null) n = URLUtil.guessFileName(url, disposition, mime);
        if (n == null || n.trim().isEmpty()) n = "overdrive-" + System.currentTimeMillis();
        n = n.replace('\\', '/');
        n = n.substring(n.lastIndexOf('/') + 1).replaceAll("[\\x00-\\x1f:*?\"<>|]", "_").trim();
        if (n.isEmpty() || n.equals(".") || n.equals("..")) n = "overdrive-" + System.currentTimeMillis();
        if (n.indexOf('.') < 0 && mime != null) {
            String ext = MimeTypeMap.getSingleton().getExtensionFromMimeType(mime);
            if (ext != null) n = n + "." + ext;
        }
        return n;
    }

    private static byte[] readLimited(InputStream in, int max) throws IOException {
        byte[] b = new byte[max];
        int off = 0, r;
        while (off < max && (r = in.read(b, off, max - off)) > 0) off += r;
        byte[] out = new byte[off];
        System.arraycopy(b, 0, out, 0, off);
        return out;
    }
}
