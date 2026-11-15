package com.https1121.overdrive.companion;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.AssetManager;
import android.content.res.Configuration;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.os.SystemClock;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.CookieManager;
import android.webkit.JavascriptInterface;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.webkit.MimeTypeMap;
import android.webkit.ValueCallback;
import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.core.content.ContextCompat;
import java.util.ArrayList;
import java.util.LinkedHashSet;

import androidx.activity.EdgeToEdge;
import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.ColorUtils;
import androidx.core.graphics.Insets;
import androidx.core.splashscreen.SplashScreen;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;

import com.google.android.material.color.DynamicColors;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The OverDrive web UI exactly as Chrome on a phone shows it, in an app window: no URL bar,
 * no native chrome of our own. Static files come from the web build bundled in the APK; only
 * data goes to the car. The single visual change is the colour tokens (see WebInjection).
 */
public class MainActivity extends AppCompatActivity {
    static final String EXTRA_WEB_LOGIN_BASE = "web_login_base";
    private static final int MAX_CACHE_BYTES = 1024 * 1024;

    private WebView web;
    private View topBar, bottomBar;
    private FrameLayout root;
    private OnBackPressedCallback backCallback;

    private String base;
    private Uri baseUri;
    private AssetManager assets;
    private File apiCache;
    private String headInjection;
    private SharedPreferences prefs;

    private volatile boolean loggedOut, webLoginMode, bundledLoginFallback;
    private volatile boolean firstFrame;
    private volatile boolean wasOffline;

    // 3.4.2: downloads, file uploads, and the status pill.
    private Pill pill;
    private Downloads downloads;
    private ValueCallback<Uri[]> fileCallback;
    private ActivityResultLauncher<Intent> filePicker;
    private boolean askedNotifications;

    @SuppressLint({"SetJavaScriptEnabled", "AddJavascriptInterface"})
    @Override
    protected void onCreate(Bundle b) {
        SplashScreen splash = SplashScreen.installSplashScreen(this);
        DynamicColors.applyToActivityIfAvailable(this);
        EdgeToEdge.enable(this);
        super.onCreate(b);

        SecureStore store = new SecureStore(this);
        String webLoginBase = getIntent().getStringExtra(EXTRA_WEB_LOGIN_BASE);
        String jwt = null;
        if (webLoginBase != null) {
            base = webLoginBase;
            webLoginMode = true;
        } else {
            base = store.get(LoginActivity.K_URL);
            jwt = store.get(LoginActivity.K_JWT);
            if (base == null || jwt == null) {
                startActivity(new Intent(this, LoginActivity.class));
                finish();
                return;
            }
        }
        final long t0 = SystemClock.uptimeMillis();
        splash.setKeepOnScreenCondition(() -> !firstFrame && SystemClock.uptimeMillis() - t0 < 2500);

        baseUri = Uri.parse(base);
        assets = getAssets();
        apiCache = new File(getCacheDir(), "api");
        apiCache.mkdirs();
        prefs = getSharedPreferences("shell", MODE_PRIVATE);
        headInjection = WebInjection.build(this);

        // Before the first page paints, use the colours that page painted last time (or the
        // web's page colour for the phone's current light/dark mode), so there is no white flash.
        boolean night = (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
        int page = WebInjection.pageColor(this, night);
        String nightKey = night ? "n" : "d";
        int pageBg = prefs.getInt("page_" + nightKey, page);
        int topBg = prefs.getInt("top_" + nightKey, pageBg);
        int botBg = prefs.getInt("bot_" + nightKey, pageBg);

        root = new FrameLayout(this);
        root.setBackgroundColor(pageBg);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        topBar = new View(this);
        bottomBar = new View(this);
        web = new WebView(this);
        col.addView(topBar, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0));
        col.addView(web, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
        col.addView(bottomBar, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0));
        root.addView(col, new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        setContentView(root);
        getWindow().getDecorView().setBackgroundColor(pageBg);
        applyBars(topBg, botBg, pageBg);
        pill = new Pill(root);
        filePicker = registerForActivityResult(new ActivityResultContracts.StartActivityForResult(), res -> {
            ValueCallback<Uri[]> cb = fileCallback;
            fileCallback = null;
            if (cb == null) return;
            Uri[] picked = null;
            Intent d = res.getData();
            if (res.getResultCode() == RESULT_OK && d != null) {
                if (d.getClipData() != null && d.getClipData().getItemCount() > 0) {
                    picked = new Uri[d.getClipData().getItemCount()];
                    for (int i = 0; i < picked.length; i++) picked[i] = d.getClipData().getItemAt(i).getUri();
                } else if (d.getData() != null) {
                    picked = new Uri[]{d.getData()};
                }
            }
            cb.onReceiveValue(picked);
        });

        // The page sits between the system bars, like Chrome's content area; the bars take the
        // colour of what is under them on the page.
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, insets) -> {
            Insets i = insets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.displayCutout());
            Insets ime = insets.getInsets(WindowInsetsCompat.Type.ime());
            v.setPadding(i.left, 0, i.right, 0);
            topBar.getLayoutParams().height = i.top;
            bottomBar.getLayoutParams().height = Math.max(i.bottom, ime.bottom);
            topBar.requestLayout();
            bottomBar.requestLayout();
            return WindowInsetsCompat.CONSUMED;
        });

        backCallback = new OnBackPressedCallback(true) {
            @Override public void handleOnBackPressed() {
                if (web.canGoBack()) { web.goBack(); return; }
                setEnabled(false);
                getOnBackPressedDispatcher().onBackPressed();
            }
        };
        getOnBackPressedDispatcher().addCallback(this, backCallback);

        web.setBackgroundColor(pageBg);
        web.setOverScrollMode(View.OVER_SCROLL_NEVER);
        web.setOnLongClickListener(v -> true);   // no link previews / text-selection handles
        web.setLongClickable(false);
        web.setHapticFeedbackEnabled(false);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);
        s.setMediaPlaybackRequiresUserGesture(false);
        s.setSupportZoom(false);
        s.setBuiltInZoomControls(false);
        s.setDisplayZoomControls(false);
        s.setTextZoom(100);
        s.setUseWideViewPort(true);      // honour the page's <meta viewport>, as Chrome does
        s.setLoadWithOverviewMode(false);
        s.setSupportMultipleWindows(false);
        // zrok free-tier shares put a warning page in front of User-Agents that start with
        // "Mozilla/5.0"; leading with our own product token keeps WebView traffic out of it.
        // The rest is the stock (mobile) WebView UA, so the site serves its phone layout.
        s.setUserAgentString(Auth.UA + " " + WebSettings.getDefaultUserAgent(this));
        downloads = new Downloads(this, s.getUserAgentString(), (text, error) -> runOnUiThread(() ->
                showPill(text, error ? androidx.appcompat.R.attr.colorError : androidx.appcompat.R.attr.colorPrimary, 2750)));
        // Anything the page navigates to that turns out to be a file (Content-Disposition etc.).
        web.setDownloadListener((url, ua, disposition, mimetype, length) -> {
            Uri du = Uri.parse(url);
            if ("blob".equals(du.getScheme()) || "data".equals(du.getScheme())) {
                web.evaluateJavascript("window.__odSave&&window.__odSave(" + org.json.JSONObject.quote(url) + ",'')", null);
            } else if ("http".equals(du.getScheme()) || "https".equals(du.getScheme())) {
                startDownload(url, Downloads.fileName(null, disposition, url, mimetype));
            }
        });
        CookieManager.getInstance().setAcceptCookie(true);
        if (jwt != null) setSessionCookie(jwt);
        web.addJavascriptInterface(new Bridge(), "ODCompanion");
        web.setWebChromeClient(new ShellChrome());
        web.setWebViewClient(new ShellClient());

        String start = webLoginMode ? "/login.html" : "/";
        if (b != null && b.getString("url") != null && sameOrigin(Uri.parse(b.getString("url")))) {
            web.loadUrl(b.getString("url"), zrokHeaders());
        } else {
            web.loadUrl(base + start, zrokHeaders());
        }
    }

    @Override
    protected void onSaveInstanceState(@NonNull Bundle out) {
        super.onSaveInstanceState(out);
        if (web != null && web.getUrl() != null) out.putString("url", web.getUrl());
    }

    // ---------------------------------------------------------------- system bars

    private static final Pattern RGB = Pattern.compile("rgba?\\(\\s*([\\d.]+)\\s*,\\s*([\\d.]+)\\s*,\\s*([\\d.]+)(?:\\s*,\\s*([\\d.]+))?");

    /** CSS rgb()/rgba() over the page colour, as an opaque Android colour. */
    private static int parse(String css, int under) {
        if (css == null) return under;
        Matcher m = RGB.matcher(css);
        if (!m.find()) return under;
        int c = Color.rgb(Math.round(Float.parseFloat(m.group(1))), Math.round(Float.parseFloat(m.group(2))),
                Math.round(Float.parseFloat(m.group(3))));
        float a = m.group(4) == null ? 1f : Float.parseFloat(m.group(4));
        return a >= 1f ? c : ColorUtils.blendARGB(under, c, a);
    }

    private void applyBars(int top, int bottom, int page) {
        topBar.setBackgroundColor(top);
        bottomBar.setBackgroundColor(bottom);
        root.setBackgroundColor(page);
        WindowInsetsControllerCompat wic = WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        wic.setAppearanceLightStatusBars(ColorUtils.calculateLuminance(top) > 0.5);
        wic.setAppearanceLightNavigationBars(ColorUtils.calculateLuminance(bottom) > 0.5);
    }

    private class Bridge {
        /** blob:/data: download read by the injected hook (base64 body). */
        @JavascriptInterface public void saveBase64(String b64, String name, String mime) {
            askNotifications();
            downloads.saveBase64(b64, name, mime);
        }
        /** <a download href="http(s)://..."> — fetched natively with the session. */
        @JavascriptInterface public void download(String url, String name) {
            Uri u = Uri.parse(url);
            if (!"http".equals(u.getScheme()) && !"https".equals(u.getScheme())) return;
            runOnUiThread(() -> startDownload(url, name));
        }
        @JavascriptInterface public void downloadFailed(String why) {
            downloads.fail(new Exception(why));
        }
        @JavascriptInterface public void onBars(String top, String bottom, String pageCss) {
            runOnUiThread(() -> {
                int page = parse(pageCss, Color.BLACK);
                int t = parse(top, page), bo = parse(bottom, page);
                applyBars(t, bo, page);
                web.setBackgroundColor(page);
                getWindow().getDecorView().setBackgroundColor(page);
                boolean night = (getResources().getConfiguration().uiMode & Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES;
                String k = night ? "n" : "d";
                prefs.edit().putInt("page_" + k, page).putInt("top_" + k, t).putInt("bot_" + k, bo).apply();
            });
        }
    }

    private void logout() {
        SecureStore s = new SecureStore(this);
        s.put(LoginActivity.K_JWT, null);
        s.put(LoginActivity.K_CODE, null);
        CookieManager.getInstance().removeAllCookies(null);
        web.clearCache(false);
        startActivity(new Intent(this, LoginActivity.class));
        finish();
    }

    // ---------------------------------------------------------------- WebView client

    private static Map<String, String> zrokHeaders() {
        Map<String, String> h = new HashMap<>();
        h.put("skip_zrok_interstitial", "true");
        return h;
    }

    private void setSessionCookie(String jwt) {
        String secure = "https".equals(baseUri.getScheme()) ? "; Secure" : "";
        CookieManager.getInstance().setCookie(base, "byd_session=" + jwt + "; Path=/; Max-Age=2592000; SameSite=Lax" + secure);
        CookieManager.getInstance().flush();
    }

    private boolean captureWebLoginToken() {
        String cookies = CookieManager.getInstance().getCookie(base);
        if (cookies == null) return false;
        for (String part : cookies.split(";")) {
            String kv = part.trim();
            if (kv.startsWith("byd_session=") && kv.length() > 12) {
                SecureStore st = new SecureStore(this);
                st.put(LoginActivity.K_URL, base);
                st.put(LoginActivity.K_CODE, null);
                st.put(LoginActivity.K_JWT, kv.substring(12));
                webLoginMode = false;
                loggedOut = false;
                return true;
            }
        }
        return false;
    }

    private boolean sameOrigin(Uri u) {
        return u.getScheme() != null && u.getScheme().equals(baseUri.getScheme())
                && u.getHost() != null && u.getHost().equalsIgnoreCase(baseUri.getHost())
                && u.getPort() == baseUri.getPort();
    }

    private String assetFor(String path) {
        if (path == null || path.contains("..")) return null;
        if (path.equals("/") || path.equals("/index.html")) return "web/local/index.html";
        if (path.equals("/login")) return "web/local/login.html";
        if (path.startsWith("/local/shared/")) return "web/" + path.substring("/local/".length());
        if (path.startsWith("/shared/") || path.startsWith("/i18n/")) return "web" + path;
        String name = path.substring(1);
        if (name.contains("/")) return null;
        if (!name.endsWith(".html") && !name.endsWith(".json")) name = name + ".html";
        return "web/local/" + name;
    }

    private static String mime(String p) {
        String l = p.toLowerCase(Locale.ROOT);
        if (l.endsWith(".html")) return "text/html";
        if (l.endsWith(".js")) return "application/javascript";
        if (l.endsWith(".css")) return "text/css";
        if (l.endsWith(".json")) return "application/json";
        if (l.endsWith(".webp")) return "image/webp";
        if (l.endsWith(".png")) return "image/png";
        if (l.endsWith(".svg")) return "image/svg+xml";
        if (l.endsWith(".wasm")) return "application/wasm";
        if (l.endsWith(".glb")) return "model/gltf-binary";
        if (l.endsWith(".ttf")) return "font/ttf";
        return "application/octet-stream";
    }

    private static byte[] readAll(InputStream in) throws IOException {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        byte[] buf = new byte[16384]; int n;
        while ((n = in.read(buf)) > 0) bo.write(buf, 0, n);
        in.close();
        return bo.toByteArray();
    }

    private WebResourceResponse html(byte[] raw, int code) {
        String page = WebInjection.inject(new String(raw, StandardCharsets.UTF_8), headInjection);
        Map<String, String> h = new HashMap<>();
        h.put("Cache-Control", "no-cache");
        return new WebResourceResponse("text/html", "utf-8", code, "OK", h,
                new ByteArrayInputStream(page.getBytes(StandardCharsets.UTF_8)));
    }

    private WebResourceResponse fromAssets(String assetPath) {
        try {
            if (assetPath.endsWith(".html")) return html(readAll(assets.open(assetPath)), 200);
            InputStream in = assets.open(assetPath);
            String m = mime(assetPath);
            String enc = (m.startsWith("text/") || m.contains("javascript") || m.contains("json")) ? "utf-8" : null;
            WebResourceResponse r = new WebResourceResponse(m, enc, in);
            Map<String, String> h = new HashMap<>();
            h.put("Cache-Control", "no-cache");
            r.setResponseHeaders(h);
            return r;
        } catch (IOException e) {
            return null;
        }
    }

    private class ShellClient extends WebViewClient {
        @Override
        public WebResourceResponse shouldInterceptRequest(WebView view, WebResourceRequest req) {
            Uri u = req.getUrl();
            if (!sameOrigin(u)) return null;
            String path = u.getPath() == null ? "/" : u.getPath();
            String method = req.getMethod();
            if ("POST".equals(method) && path.equals("/auth/logout")) loggedOut = true;
            if (!"GET".equals(method)) return null;
            if (path.equals("/sw.js")) {
                return new WebResourceResponse("text/plain", "utf-8", 404, "Not Found", new HashMap<>(),
                        new ByteArrayInputStream(new byte[0]));
            }
            boolean isLogin = path.equals("/login") || path.equals("/login.html");
            if (isLogin && webLoginMode && !bundledLoginFallback) {
                return proxyGet(u.toString(), req.getRequestHeaders(), true); // the server's own login page
            }
            String asset = assetFor(path);
            if (asset != null) {
                WebResourceResponse r = fromAssets(asset);
                if (r != null) return r;
                if (asset.endsWith(".html")) return proxyGet(u.toString(), req.getRequestHeaders(), true);
            }
            if (path.startsWith("/api/") || path.equals("/status") || path.equals("/auth/status")) {
                Map<String, String> rh = req.getRequestHeaders();
                String accept = rh.get("Accept");
                if (accept != null && accept.contains("text/event-stream")) return null;
                if (rh.containsKey("Range") || rh.containsKey("range")) return null;
                return proxyGet(u.toString(), rh, false);
            }
            return null;
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest req) {
            Uri u = req.getUrl();
            if (sameOrigin(u)) {
                String p = u.getPath();
                boolean isLogin = "/login.html".equals(p) || "/login".equals(p);
                if (webLoginMode) {
                    if (!isLogin) captureWebLoginToken();
                    return false;
                }
                if (isLogin) {
                    if (loggedOut) { logout(); return true; }
                    reauth(u.getQueryParameter("redirect"));
                    return true;
                }
                // location.href = '/api/.../download' and the like: a file, not a page.
                if (p != null && (p.startsWith("/api/") || p.startsWith("/video/"))) {
                    startDownload(u.toString(), null);
                    return true;
                }
                return false;
            }
            if ("blob".equals(u.getScheme()) || "data".equals(u.getScheme())) return false;
            try { startActivity(new Intent(Intent.ACTION_VIEW, u)); } catch (Exception ignored) { }
            return true;
        }

        @Override
        public void onPageCommitVisible(WebView view, String url) {
            firstFrame = true;
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            firstFrame = true;
            String p = Uri.parse(url).getPath();
            boolean isLogin = "/login.html".equals(p) || "/login".equals(p);
            if (webLoginMode && !isLogin) captureWebLoginToken();
        }

        @Override
        public void onReceivedError(WebView view, WebResourceRequest req, WebResourceError err) {
            if (webLoginMode && req.isForMainFrame() && !bundledLoginFallback) {
                bundledLoginFallback = true;
                view.loadUrl(base + "/login.html", zrokHeaders());
            }
        }
    }

    private void reauth(String redirect) {
        final SecureStore store = new SecureStore(this);
        final String code = store.get(LoginActivity.K_CODE);
        if (code == null) {
            webLoginMode = true;
            runOnUiThread(() -> {
                web.loadUrl(base + "/login.html" + (redirect != null ? "?redirect=" + Uri.encode(redirect) : ""), zrokHeaders());
            });
            return;
        }
        new Thread(() -> {
            try {
                Auth.Result r = Auth.login(base, code);
                store.put(LoginActivity.K_JWT, r.jwt);
                runOnUiThread(() -> {
                    setSessionCookie(r.jwt);
                    String target = (redirect != null && redirect.startsWith("/")) ? redirect : "/";
                    web.loadUrl(base + target, zrokHeaders());
                });
            } catch (Exception e) {
                runOnUiThread(() -> {
                    startActivity(new Intent(this, LoginActivity.class));
                    finish();
                });
            }
        }).start();
    }

    private WebResourceResponse proxyGet(String url, Map<String, String> reqHeaders, boolean isHtml) {
        File cacheFile = new File(apiCache, sha1(url));
        File metaFile = new File(apiCache, sha1(url) + ".meta");
        HttpURLConnection c = null;
        try {
            c = (HttpURLConnection) new URL(url).openConnection();
            c.setConnectTimeout(15000);
            c.setReadTimeout(30000);
            c.setInstanceFollowRedirects(true);
            for (Map.Entry<String, String> e : reqHeaders.entrySet()) {
                String k = e.getKey().toLowerCase(Locale.ROOT);
                if (k.equals("accept-encoding") || k.startsWith("if-") || k.equals("cookie")) continue;
                c.setRequestProperty(e.getKey(), e.getValue());
            }
            c.setRequestProperty("skip_zrok_interstitial", "true");
            String cookie = CookieManager.getInstance().getCookie(url);
            if (cookie != null) c.setRequestProperty("Cookie", cookie);
            int code = c.getResponseCode();
            List<String> setCookies = c.getHeaderFields().get("Set-Cookie");
            if (setCookies != null) for (String sc : setCookies) CookieManager.getInstance().setCookie(url, sc);
            String ct = c.getContentType() == null ? "application/octet-stream" : c.getContentType();
            String mimeType = ct.split(";")[0].trim();
            String lower = ct.toLowerCase(Locale.ROOT);
            String charset = lower.contains("charset=") ? ct.substring(lower.indexOf("charset=") + 8).trim() : "utf-8";
            Map<String, String> h = new HashMap<>();
            for (Map.Entry<String, List<String>> e : c.getHeaderFields().entrySet()) {
                if (e.getKey() == null || e.getValue() == null || e.getValue().isEmpty()) continue;
                String k = e.getKey().toLowerCase(Locale.ROOT);
                if (k.equals("content-length") || k.equals("transfer-encoding") || k.equals("content-encoding")
                        || k.equals("connection") || k.equals("set-cookie")) continue;
                h.put(e.getKey(), e.getValue().get(0));
            }
            String reason = c.getResponseMessage() == null || c.getResponseMessage().isEmpty() ? "OK" : c.getResponseMessage();
            InputStream body = code >= 400 ? c.getErrorStream() : c.getInputStream();
            if (body == null) body = new ByteArrayInputStream(new byte[0]);
            markOnline();
            if (isHtml && mimeType.equals("text/html")) {
                byte[] raw = readAll(body);
                c.disconnect();
                return html(raw, code);
            }
            if (code == 200 && mimeType.equals("application/json")
                    && c.getContentLength() >= 0 && c.getContentLength() <= MAX_CACHE_BYTES) {
                byte[] bytes = readAll(body);
                c.disconnect();
                try (FileOutputStream fo = new FileOutputStream(cacheFile)) { fo.write(bytes); }
                try (FileOutputStream fo = new FileOutputStream(metaFile)) {
                    fo.write(String.valueOf(System.currentTimeMillis()).getBytes(StandardCharsets.UTF_8));
                }
                return new WebResourceResponse(mimeType, charset, code, reason, h, new ByteArrayInputStream(bytes));
            }
            return new WebResourceResponse(mimeType, charset, code, reason, h, body);
        } catch (IOException e) {
            if (c != null) c.disconnect();
            if (!isHtml && cacheFile.exists() && metaFile.exists()) {
                try {
                    long when = Long.parseLong(new String(readAll(new FileInputStream(metaFile)), StandardCharsets.UTF_8).trim());
                    markOffline(when);
                    Map<String, String> h = new HashMap<>();
                    h.put("X-OverDrive-Offline", "1");
                    return new WebResourceResponse("application/json", "utf-8", 200, "OK", h, new FileInputStream(cacheFile));
                } catch (Exception ignored) { }
            }
            markOffline(-1);
            byte[] err = "{\"success\":false,\"error\":\"אין חיבור לרכב\"}".getBytes(StandardCharsets.UTF_8);
            return new WebResourceResponse("application/json", "utf-8", 503, "Offline", new HashMap<>(),
                    new ByteArrayInputStream(err));
        }
    }

    // Offline / reconnected: a rounded native pill just below the page header (3.4.2).
    // Same triggers and durations as the 3.4.1 snackbar (LENGTH_LONG / LENGTH_SHORT).
    private void markOnline() {
        if (!wasOffline) return;
        wasOffline = false;
        runOnUiThread(() -> showPill("החיבור לרכב חזר", androidx.appcompat.R.attr.colorPrimary, 1500));
    }

    private void markOffline(long since) {
        if (wasOffline) return;
        wasOffline = true;
        runOnUiThread(() -> {
            String msg = since > 0
                    ? "אין חיבור לרכב · מוצגים הנתונים האחרונים מ־" + new SimpleDateFormat("HH:mm", Locale.ROOT).format(new Date(since))
                    : "אין חיבור לרכב";
            showPill(msg, androidx.appcompat.R.attr.colorError, 2750);
        });
    }

    private static final String HEADER_BOTTOM_JS = "(function(){var h=document.querySelector('.mobile-header');"
            + "if(!h||getComputedStyle(h).display==='none')return -1;return Math.max(0,h.getBoundingClientRect().bottom);})()";

    /** Under the web's page header (".mobile-header"), centred; falls back to 64dp below the status bar. */
    private void showPill(String text, int dotAttr, long ms) {
        if (pill == null || web == null) return;
        float d = getResources().getDisplayMetrics().density;
        web.evaluateJavascript(HEADER_BOTTOM_JS, v -> {
            float css = -1;
            try { css = Float.parseFloat(v); } catch (Exception ignored) { }
            int below = css >= 0 ? Math.round(css * d) : Math.round(64 * d);
            pill.show(text, dotAttr, topBar.getHeight() + below + Math.round(8 * d), ms);
        });
    }

    // ---------------------------------------------------------------- downloads / uploads

    private void startDownload(String url, String name) {
        askNotifications();
        downloads.fetch(url, name, sameOrigin(Uri.parse(url)) ? new SecureStore(this).get(LoginActivity.K_JWT) : null);
    }

    private void askNotifications() {
        if (Build.VERSION.SDK_INT < 33 || askedNotifications) return;
        askedNotifications = true;
        runOnUiThread(() -> {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 7);
            }
        });
    }

    private class ShellChrome extends WebChromeClient {
        @Override
        public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, FileChooserParams params) {
            if (fileCallback != null) fileCallback.onReceiveValue(null);
            fileCallback = callback;
            Intent i = new Intent(Intent.ACTION_GET_CONTENT).addCategory(Intent.CATEGORY_OPENABLE);
            String[] types = acceptMimes(params.getAcceptTypes());
            if (types.length == 1) i.setType(types[0]);
            else { i.setType("*/*"); if (types.length > 1) i.putExtra(Intent.EXTRA_MIME_TYPES, types); }
            if (params.getMode() == FileChooserParams.MODE_OPEN_MULTIPLE) i.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true);
            try {
                filePicker.launch(Intent.createChooser(i, null));
            } catch (Exception e) {
                fileCallback = null;
                return false;
            }
            return true;
        }
    }

    /** accept="image/png,.json,audio/*" to MIME types; any token we can't map means "all files". */
    private static String[] acceptMimes(String[] accept) {
        LinkedHashSet<String> out = new LinkedHashSet<>();
        if (accept != null) for (String raw : accept) {
            if (raw == null) continue;
            for (String t : raw.split(",")) {
                t = t.trim().toLowerCase(Locale.ROOT);
                if (t.isEmpty()) continue;
                if (t.startsWith(".")) {
                    String m = MimeTypeMap.getSingleton().getMimeTypeFromExtension(t.substring(1));
                    if (m == null) return new String[0];
                    out.add(m);
                } else if (t.contains("/")) {
                    out.add(t);
                } else {
                    return new String[0];
                }
            }
        }
        return out.toArray(new String[0]);
    }

    private static String sha1(String s) {
        try {
            byte[] d = MessageDigest.getInstance("SHA-1").digest(s.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte x : d) sb.append(String.format(Locale.ROOT, "%02x", x));
            return sb.toString();
        } catch (Exception e) {
            return Integer.toHexString(s.hashCode());
        }
    }
}
