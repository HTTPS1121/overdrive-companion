package com.https1121.overdrive.companion;

import android.os.Handler;
import android.os.Looper;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Periodic reachability check: zrok/tunnel vs car server. Drives the status bar and pill copy.
 */
final class ConnectionMonitor {
    enum LinkState { CONNECTED, CHECKING, TUNNEL_DOWN, CAR_DOWN }

    interface Listener {
        void onBar(LinkState state);

        void onPill(String text, int dotAttr, long durationMs);
    }

    private static final long INTERVAL_MS = 3500;

    private final Handler main = new Handler(Looper.getMainLooper());
    private final AtomicBoolean running = new AtomicBoolean();
    private final String base;
    private final Listener listener;
    private LinkState last = LinkState.CONNECTED;
    private boolean hadOutage;

    ConnectionMonitor(String base, Listener listener) {
        this.base = base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
        this.listener = listener;
    }

    void start() {
        if (!running.compareAndSet(false, true)) return;
        schedule(0);
    }

    void stop() {
        running.set(false);
        main.removeCallbacks(tick);
    }

    private final Runnable tick = new Runnable() {
        @Override
        public void run() {
            if (!running.get()) return;
            new Thread(ConnectionMonitor.this::probe, "od-health").start();
        }
    };

    private void schedule(long delay) {
        if (running.get()) main.postDelayed(tick, delay);
    }

    void notifyProxyFailure() {
        main.post(() -> applyState(LinkState.CAR_DOWN, true));
    }

    void notifyProxySuccess() {
        if (last != LinkState.CONNECTED) main.post(() -> applyState(LinkState.CONNECTED, true));
    }

    private void probe() {
        if (!running.get()) return;
        LinkState prev = last;
        if (prev != LinkState.CONNECTED) main.post(() -> listener.onBar(LinkState.CHECKING));
        LinkState next = measure();
        main.post(() -> applyState(next, prev != next || next != LinkState.CONNECTED));
        schedule(INTERVAL_MS);
    }

    private void applyState(LinkState next, boolean announce) {
        LinkState prev = last;
        last = next;
        if (next == LinkState.CONNECTED) {
            listener.onBar(LinkState.CONNECTED);
            if (hadOutage && announce) {
                listener.onPill("החיבור חזר", com.google.android.material.R.attr.colorPrimary, 1500);
            }
            hadOutage = false;
            return;
        }
        hadOutage = true;
        listener.onBar(next);
        if (announce && prev != next) {
            String msg = next == LinkState.TUNNEL_DOWN ? "אין חיבור למנהרה" : "אין חיבור לרכב";
            listener.onPill(msg, androidx.appcompat.R.attr.colorError, 2750);
        }
    }

    private LinkState measure() {
        boolean tunnel = false;
        try {
            tunnel = head(base, 6000);
        } catch (IOException ignored) {
            return LinkState.TUNNEL_DOWN;
        }
        if (!tunnel) return LinkState.TUNNEL_DOWN;
        try {
            boolean car = head(base + "/status", 8000);
            if (car) return LinkState.CONNECTED;
            car = head(base + "/auth/status", 8000);
            return car ? LinkState.CONNECTED : LinkState.CAR_DOWN;
        } catch (IOException e) {
            return LinkState.CAR_DOWN;
        }
    }

    private boolean head(String url, int timeout) throws IOException {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(timeout);
        c.setReadTimeout(timeout);
        c.setInstanceFollowRedirects(true);
        c.setRequestMethod("HEAD");
        c.setRequestProperty("skip_zrok_interstitial", "true");
        c.setRequestProperty("User-Agent", Auth.UA);
        String cookie = android.webkit.CookieManager.getInstance().getCookie(url);
        if (cookie != null) c.setRequestProperty("Cookie", cookie);
        int code = c.getResponseCode();
        c.disconnect();
        return code > 0 && code < 500;
    }
}