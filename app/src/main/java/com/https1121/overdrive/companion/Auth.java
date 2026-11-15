package com.https1121.overdrive.companion;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ConnectException;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.net.UnknownHostException;
import java.net.UnknownServiceException;
import java.nio.charset.StandardCharsets;
import java.util.Locale;
import java.util.regex.Pattern;

import javax.net.ssl.SSLException;

/**
 * Mirrors the server's own login.html exactly:
 *   GET  /auth/status  -> {"status":"ok","deviceId":"byd-xxxxxxxx"}
 *   POST /auth/token   {"token": deviceId + "-" + accessCode.trim().toLowerCase()}
 *                      -> 200 {"success":true,"jwt":...,"deviceId":...,"expiresIn":...}
 *                      or 200 {"success":false,"error":"<localized>"}
 * (AuthManager.getDeviceToken() == deviceId + "-" + deviceSecret, compared verbatim.)
 */
final class Auth {
    static final String UA = "OverDriveCompanion/3.4.2 (Android)";
    private static final Pattern PRIVATE_IP = Pattern.compile(
            "^(10\\.|192\\.168\\.|172\\.(1[6-9]|2\\d|3[01])\\.|127\\.|169\\.254\\.).*");

    static final class AuthException extends Exception {
        AuthException(String hebrew) { super(hebrew); }
    }

    static final class Result {
        String base, deviceId, jwt;
    }

    /** Accepts "host", "host:port", "https://host/login.html?x", " HTTPS://Host/ " ... -> scheme://host[:port] */
    static String normalize(String raw) {
        if (raw == null) return null;
        String u = raw.replaceAll("\\s+", "");
        if (u.isEmpty()) return null;
        String lower = u.toLowerCase(Locale.ROOT);
        if (!lower.startsWith("http://") && !lower.startsWith("https://")) {
            String hostPart = u.split("[/?#]", 2)[0];
            String host = hostPart.split(":", 2)[0];
            boolean lan = PRIVATE_IP.matcher(host).matches() || host.endsWith(".local");
            u = (lan ? "http://" : "https://") + u;
            if (lan && !hostPart.contains(":")) {
                int cut = u.indexOf('/', u.indexOf("//") + 2);
                u = cut < 0 ? u + ":8080" : u.substring(0, cut) + ":8080" + u.substring(cut);
            }
        }
        try {
            URL p = new URL(u);
            if (p.getHost() == null || p.getHost().isEmpty()) return null;
            String scheme = p.getProtocol().toLowerCase(Locale.ROOT);
            int port = p.getPort();
            boolean defaultPort = port < 0 || (scheme.equals("https") && port == 443) || (scheme.equals("http") && port == 80);
            return scheme + "://" + p.getHost().toLowerCase(Locale.ROOT) + (defaultPort ? "" : ":" + port);
        } catch (Exception e) {
            return null;
        }
    }

    static String cleanCode(String raw) {
        return raw == null ? "" : raw.replaceAll("\\s+", "").toLowerCase(Locale.ROOT);
    }

    private static HttpURLConnection open(String url, String method) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(20000);
        c.setReadTimeout(30000);
        c.setInstanceFollowRedirects(false);
        c.setRequestMethod(method);
        c.setRequestProperty("Accept", "application/json");
        c.setRequestProperty("User-Agent", UA);
        // zrok free-tier public shares show a browser warning page unless this is sent.
        c.setRequestProperty("skip_zrok_interstitial", "true");
        return c;
    }

    private static String readBody(HttpURLConnection c, int code) throws Exception {
        InputStream in = code >= 400 ? c.getErrorStream() : c.getInputStream();
        if (in == null) return "";
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        byte[] buf = new byte[8192];
        int n;
        while ((n = in.read(buf)) > 0 && bo.size() < 256 * 1024) bo.write(buf, 0, n);
        in.close();
        return new String(bo.toByteArray(), StandardCharsets.UTF_8);
    }

    /** Parses a JSON answer or throws a specific Hebrew reason. */
    private static JSONObject expectJson(HttpURLConnection c, String what) throws Exception {
        int code = c.getResponseCode();
        if (code >= 300 && code < 400) {
            String loc = c.getHeaderField("Location");
            throw new AuthException("השרת הפנה לכתובת אחרת (HTTP " + code + ")"
                    + (loc != null ? ": " + loc : "") + ". הזן את הכתובת הסופית.");
        }
        String body = readBody(c, code);
        String ct = c.getContentType() == null ? "" : c.getContentType().toLowerCase(Locale.ROOT);
        String head = body.trim().toLowerCase(Locale.ROOT);
        boolean html = ct.contains("text/html") || head.startsWith("<!doctype") || head.startsWith("<html");
        if (html) {
            String hint = body.toLowerCase(Locale.ROOT).contains("zrok") ? " (דף אזהרה של zrok)" : "";
            throw new AuthException("השרת החזיר דף ולא נתונים" + hint + ", HTTP " + code
                    + ". ייתכן שהכתובת שגויה או שהמנהרה לא מחוברת לרכב.");
        }
        if (code == 404) throw new AuthException("הכתובת לא נמצאה בשרת (HTTP 404) בבקשת " + what + ". ייתכן שזה לא שרת OverDrive.");
        if (code == 502 || code == 503 || code == 504) throw new AuthException("המנהרה לא מצליחה להגיע לרכב (HTTP " + code + "). ייתכן שהרכב כבוי או בלי קליטה.");
        if (code != 200) throw new AuthException("השרת החזיר שגיאה HTTP " + code + " בבקשת " + what + ".");
        try {
            return new JSONObject(body);
        } catch (Exception e) {
            throw new AuthException("התשובה מהשרת אינה נתונים תקינים (" + what + ").");
        }
    }

    static String mapNetwork(Exception e) {
        if (e instanceof AuthException) return e.getMessage();
        if (e instanceof UnknownHostException) return "השרת לא נמצא (DNS). בדוק את הכתובת או את החיבור לאינטרנט.";
        if (e instanceof SocketTimeoutException) return "אין תשובה מהשרת אחרי זמן ההמתנה. ייתכן שהקליטה חלשה או שהרכב לא מחובר.";
        if (e instanceof SSLException) return "בעיית אבטחה בחיבור (TLS): " + e.getClass().getSimpleName() + ". אם זו רשת מקומית, השתמש ב־http://";
        if (e instanceof ConnectException) return "השרת סירב לחיבור. בדוק כתובת ופורט (ברשת מקומית בדרך כלל 8080).";
        if (e instanceof UnknownServiceException) return "חיבור לא מוצפן נחסם במכשיר.";
        return "החיבור נכשל: " + e.getClass().getSimpleName() + (e.getMessage() != null ? " (" + e.getMessage() + ")" : "");
    }

    static String fetchDeviceId(String base) throws Exception {
        HttpURLConnection c = open(base + "/auth/status", "GET");
        try {
            JSONObject j = expectJson(c, "פרטי המכשיר");
            String id = j.optString("deviceId", "");
            if (id.isEmpty() || id.equals("unknown")) throw new AuthException("השרת לא מסר מזהה מכשיר (deviceId). פתח את OverDrive ברכב ונסה שוב.");
            return id;
        } finally { c.disconnect(); }
    }

    /** Full login exactly like login.html. accessCode may also be the full "byd-xxxx-secret" token. */
    static Result login(String base, String accessCode) throws Exception {
        Result r = new Result();
        r.base = base;
        r.deviceId = fetchDeviceId(base);
        String code = cleanCode(accessCode);
        String prefix = r.deviceId.toLowerCase(Locale.ROOT) + "-";
        String fullToken = code.startsWith(prefix) ? r.deviceId + "-" + code.substring(prefix.length())
                                                   : r.deviceId + "-" + code;
        HttpURLConnection c = open(base + "/auth/token", "POST");
        try {
            c.setDoOutput(true);
            c.setRequestProperty("Content-Type", "application/json");
            byte[] body = new JSONObject().put("token", fullToken).toString().getBytes(StandardCharsets.UTF_8);
            c.setFixedLengthStreamingMode(body.length);
            try (OutputStream o = c.getOutputStream()) { o.write(body); }
            JSONObject j = expectJson(c, "ההתחברות");
            if (j.optBoolean("success") && !j.optString("jwt", "").isEmpty()) {
                r.jwt = j.getString("jwt");
                return r;
            }
            String err = j.optString("error", "");
            throw new AuthException("השרת דחה את קוד הגישה" + (err.isEmpty() ? "." : ": " + err)
                    + "\nמזהה המכשיר מהשרת: " + r.deviceId
                    + "\nהקוד צריך להיות קוד הגישה שמוצג באפליקציית OverDrive ברכב (בלי המזהה).");
        } finally { c.disconnect(); }
    }
}
