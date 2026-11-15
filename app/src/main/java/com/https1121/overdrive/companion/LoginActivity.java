package com.https1121.overdrive.companion;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.progressindicator.LinearProgressIndicator;
import com.google.android.material.textfield.TextInputEditText;
import com.google.android.material.textfield.TextInputLayout;

/** Native Material 3 login. Same contract as the server's login.html (see Auth). */
public class LoginActivity extends AppCompatActivity {
    static final String K_URL = "server_url";
    static final String K_CODE = "access_code";
    static final String K_JWT = "jwt";

    private TextInputEditText url, code;
    private TextInputLayout urlLayout, codeLayout;
    private TextView status;
    private MaterialButton go, webLogin;
    private LinearProgressIndicator progress;

    @Override
    protected void onCreate(Bundle b) {
        EdgeToEdge.enable(this);
        super.onCreate(b);
        setContentView(R.layout.activity_login);
        View root = findViewById(R.id.login_root);
        ViewCompat.setOnApplyWindowInsetsListener(root, (v, insets) -> {
            Insets i = insets.getInsets(WindowInsetsCompat.Type.systemBars() | WindowInsetsCompat.Type.ime());
            v.setPadding(i.left, i.top, i.right, i.bottom);
            return WindowInsetsCompat.CONSUMED;
        });
        url = findViewById(R.id.url);
        code = findViewById(R.id.code);
        urlLayout = findViewById(R.id.url_layout);
        codeLayout = findViewById(R.id.code_layout);
        status = findViewById(R.id.status);
        go = findViewById(R.id.go);
        webLogin = findViewById(R.id.web_login);
        progress = findViewById(R.id.login_progress);
        ((TextView) findViewById(R.id.version)).setText("OverDrive Companion 3.3.0 · ממשק " + WebSource.label(this));
        String saved = new SecureStore(this).get(K_URL);
        if (saved != null) url.setText(saved);
        go.setOnClickListener(v -> attempt());
        webLogin.setOnClickListener(v -> openWebLogin());
        code.setOnEditorActionListener((v, a, e) -> { attempt(); return true; });
    }

    private void attempt() {
        urlLayout.setError(null);
        codeLayout.setError(null);
        status.setText("");
        final String base = Auth.normalize(String.valueOf(url.getText()));
        final String c = Auth.cleanCode(String.valueOf(code.getText()));
        if (base == null) { urlLayout.setError("כתובת השרת לא תקינה"); return; }
        if (c.isEmpty()) { codeLayout.setError("צריך להזין קוד גישה"); return; }
        if (c.length() < 8) { codeLayout.setError("קוד הגישה קצר מדי (לפחות 8 תווים)"); return; }
        url.setText(base);
        go.setEnabled(false);
        webLogin.setVisibility(View.GONE);
        progress.setVisibility(View.VISIBLE);
        new Thread(() -> {
            String err = null;
            Auth.Result res = null;
            try { res = Auth.login(base, c); } catch (Exception e) { err = Auth.mapNetwork(e); }
            final String fErr = err;
            final Auth.Result fRes = res;
            runOnUiThread(() -> {
                go.setEnabled(true);
                progress.setVisibility(View.INVISIBLE);
                if (fErr != null) {
                    status.setText(fErr);
                    webLogin.setVisibility(View.VISIBLE);
                    return;
                }
                SecureStore s = new SecureStore(this);
                s.put(K_URL, fRes.base);
                s.put(K_CODE, c);
                s.put(K_JWT, fRes.jwt);
                startActivity(new Intent(this, MainActivity.class).addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK));
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
                finish();
            });
        }).start();
    }

    private void openWebLogin() {
        String base = Auth.normalize(String.valueOf(url.getText()));
        if (base == null) { urlLayout.setError("כתובת השרת לא תקינה"); return; }
        startActivity(new Intent(this, MainActivity.class)
                .putExtra(MainActivity.EXTRA_WEB_LOGIN_BASE, base)
                .addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK));
        finish();
    }
}
