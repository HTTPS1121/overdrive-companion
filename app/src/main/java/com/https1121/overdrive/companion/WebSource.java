package com.https1121.overdrive.companion;

import android.content.Context;
import org.json.JSONObject;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

/** Which upstream build the bundled web UI was taken from (assets/WEB_SOURCE.json). */
final class WebSource {
    static String label(Context c) {
        try (InputStream in = c.getAssets().open("WEB_SOURCE.json")) {
            byte[] b = new byte[in.available()];
            int n = in.read(b);
            JSONObject j = new JSONObject(new String(b, 0, n, StandardCharsets.UTF_8));
            String v = j.optString("versionName", "");
            return j.optString("tag", "main") + (v.isEmpty() ? "" : " v" + v);
        } catch (Exception e) {
            return "?";
        }
    }
}
