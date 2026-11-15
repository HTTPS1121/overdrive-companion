package com.https1121.overdrive.companion;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Color;
import android.view.ContextThemeWrapper;

import com.google.android.material.color.DynamicColors;
import com.google.android.material.color.MaterialColors;

import java.util.Locale;

/**
 * The only thing 3.4.0 changes in the web UI: the colour tokens. The web's own design tokens
 * (shared/design-tokens.css + the supplementals in styles.css) are re-declared with the phone's
 * Material You palette, for both the web's dark (default) and light themes. Layout, fonts,
 * header, sidebar, menus are untouched. Plus non-visual "app feel" rules (no text selection,
 * no long-press callout, no tap highlight, no overscroll).
 */
final class WebInjection {
    private WebInjection() { }


    /** CSS custom properties for one theme, or null when dynamic colour isn't available. */
    private static String vars(Context base, boolean night) {
        Configuration cfg = new Configuration(base.getResources().getConfiguration());
        cfg.uiMode = (cfg.uiMode & ~Configuration.UI_MODE_NIGHT_MASK)
                | (night ? Configuration.UI_MODE_NIGHT_YES : Configuration.UI_MODE_NIGHT_NO);
        Context c = new ContextThemeWrapper(base.createConfigurationContext(cfg), R.style.Theme_OD);
        c = DynamicColors.wrapContextIfAvailable(c);
        StringBuilder sb = new StringBuilder();
        int primary = col(c, androidx.appcompat.R.attr.colorPrimary);
        int tertiary = col(c, com.google.android.material.R.attr.colorTertiary);
        int error = col(c, androidx.appcompat.R.attr.colorError);
        int background = col(c, android.R.attr.colorBackground);
        int surface = col(c, com.google.android.material.R.attr.colorSurface);
        int onSurface = col(c, com.google.android.material.R.attr.colorOnSurface);
        int scLow = col(c, com.google.android.material.R.attr.colorSurfaceContainerLow);
        int sc = col(c, com.google.android.material.R.attr.colorSurfaceContainer);
        int scHigh = col(c, com.google.android.material.R.attr.colorSurfaceContainerHigh);

        put(sb, "--primary", primary);
        put(sb, "--on-primary", col(c, com.google.android.material.R.attr.colorOnPrimary));
        put(sb, "--primary-container", col(c, com.google.android.material.R.attr.colorPrimaryContainer));
        put(sb, "--on-primary-container", col(c, com.google.android.material.R.attr.colorOnPrimaryContainer));
        put(sb, "--secondary", col(c, com.google.android.material.R.attr.colorSecondary));
        put(sb, "--on-secondary", col(c, com.google.android.material.R.attr.colorOnSecondary));
        put(sb, "--secondary-container", col(c, com.google.android.material.R.attr.colorSecondaryContainer));
        put(sb, "--on-secondary-container", col(c, com.google.android.material.R.attr.colorOnSecondaryContainer));
        put(sb, "--tertiary", tertiary);
        put(sb, "--on-tertiary", col(c, com.google.android.material.R.attr.colorOnTertiary));
        put(sb, "--tertiary-container", col(c, com.google.android.material.R.attr.colorTertiaryContainer));
        put(sb, "--on-tertiary-container", col(c, com.google.android.material.R.attr.colorOnTertiaryContainer));
        put(sb, "--error", error);
        put(sb, "--on-error", col(c, com.google.android.material.R.attr.colorOnError));
        put(sb, "--error-container", col(c, com.google.android.material.R.attr.colorErrorContainer));
        put(sb, "--on-error-container", col(c, com.google.android.material.R.attr.colorOnErrorContainer));
        put(sb, "--background", background);
        put(sb, "--on-background", col(c, com.google.android.material.R.attr.colorOnBackground));
        put(sb, "--surface", surface);
        put(sb, "--on-surface", onSurface);
        put(sb, "--surface-variant", col(c, com.google.android.material.R.attr.colorSurfaceVariant));
        put(sb, "--on-surface-variant", col(c, com.google.android.material.R.attr.colorOnSurfaceVariant));
        put(sb, "--surface-dim", col(c, com.google.android.material.R.attr.colorSurfaceDim));
        put(sb, "--surface-bright", col(c, com.google.android.material.R.attr.colorSurfaceBright));
        put(sb, "--surface-container-lowest", col(c, com.google.android.material.R.attr.colorSurfaceContainerLowest));
        put(sb, "--surface-container-low", scLow);
        put(sb, "--surface-container", sc);
        put(sb, "--surface-container-high", scHigh);
        put(sb, "--surface-container-highest", col(c, com.google.android.material.R.attr.colorSurfaceContainerHighest));
        put(sb, "--outline", col(c, com.google.android.material.R.attr.colorOutline));
        put(sb, "--outline-variant", col(c, com.google.android.material.R.attr.colorOutlineVariant));
        put(sb, "--inverse-surface", col(c, com.google.android.material.R.attr.colorSurfaceInverse));
        put(sb, "--inverse-on-surface", col(c, com.google.android.material.R.attr.colorOnSurfaceInverse));
        put(sb, "--inverse-primary", col(c, com.google.android.material.R.attr.colorPrimaryInverse));
        // Semantic tokens that the web defines as copies of tertiary / error.
        put(sb, "--status-info", tertiary);
        put(sb, "--status-danger", error);
        rgba(sb, "--status-info-container", tertiary, night ? 0.14 : 0.12);
        rgba(sb, "--status-danger-container", error, night ? 0.14 : 0.12);
        // Brand-tinted supplementals: same alphas as the web, with the phone's hues.
        rgba(sb, "--primary-soft", primary, night ? 0.13 : 0.10);
        rgba(sb, "--primary-glow", primary, night ? 0.28 : 0.25);
        rgba(sb, "--tertiary-soft", tertiary, night ? 0.12 : 0.09);
        rgba(sb, "--glow-a", primary, night ? 0.09 : 0.07);
        rgba(sb, "--glow-b", tertiary, night ? 0.06 : 0.05);
        rgba(sb, "--danger-soft", error, night ? 0.14 : 0.10);
        rgba(sb, "--state-hover", onSurface, night ? 0.06 : 0.05);
        rgba(sb, "--state-press", onSurface, night ? 0.12 : 0.10);
        sb.append("--shadow-glow:0 0 20px ").append(rgbaStr(primary, night ? 0.15 : 0.16)).append(" !important;");
        if (night) {
            rgba(sb, "--bar", background, 0.94);
            rgba(sb, "--bar-blur", background, 0.62);
        } else {
            put(sb, "--page", sc);
            rgba(sb, "--bar", sc, 0.95);
            rgba(sb, "--bar-blur", sc, 0.72);
            put(sb, "--well", scLow);
            put(sb, "--well-2", scHigh);
            rgba(sb, "--bg-glass", surface, 0.88);
            rgba(sb, "--panel-overlay-bg", surface, 0.96);
            rgba(sb, "--panel-overlay-bg-strong", surface, 0.92);
            put(sb, "--chart-line-1", primary);
            rgba(sb, "--chart-tooltip-bg", surface, 0.97);
        }
        return sb.toString();
    }

    private static int col(Context c, int attr) { return MaterialColors.getColor(c, attr, Color.MAGENTA); }

    private static void put(StringBuilder sb, String name, int color) {
        sb.append(name).append(':').append(String.format(Locale.ROOT, "#%06X", color & 0xFFFFFF)).append(" !important;");
    }

    private static void rgba(StringBuilder sb, String name, int color, double a) {
        sb.append(name).append(':').append(rgbaStr(color, a)).append(" !important;");
    }

    private static String rgbaStr(int color, double a) {
        return String.format(Locale.ROOT, "rgba(%d, %d, %d, %.2f)", Color.red(color), Color.green(color), Color.blue(color), a);
    }

    /** The page background the web will paint for a theme (used before the page draws). */
    static int pageColor(Context base, boolean night) {
        Configuration cfg = new Configuration(base.getResources().getConfiguration());
        cfg.uiMode = (cfg.uiMode & ~Configuration.UI_MODE_NIGHT_MASK)
                | (night ? Configuration.UI_MODE_NIGHT_YES : Configuration.UI_MODE_NIGHT_NO);
        Context c = new ContextThemeWrapper(base.createConfigurationContext(cfg), R.style.Theme_OD);
        if (!DynamicColors.isDynamicColorAvailable()) return night ? 0xFF0E1311 : 0xFFEEF2EF;
        c = DynamicColors.wrapContextIfAvailable(c);
        return night ? col(c, android.R.attr.colorBackground) : col(c, com.google.android.material.R.attr.colorSurfaceContainer);
    }

    static String build(Context ctx) {
        StringBuilder css = new StringBuilder();
        if (DynamicColors.isDynamicColorAvailable()) {
            css.append(":root:not([data-theme=\"light\"]){").append(vars(ctx, true)).append('}');
            css.append(":root[data-theme=\"light\"]{").append(vars(ctx, false)).append('}');
        }
        // Non-visual: behave like an app, not a page.
        css.append("html,body{overscroll-behavior:none}");
        css.append("*{-webkit-tap-highlight-color:transparent;-webkit-touch-callout:none;-webkit-user-select:none;user-select:none}");
        css.append("input,textarea,select,[contenteditable],[contenteditable] *{-webkit-user-select:text;user-select:text}");
        css.append("img,a{-webkit-user-drag:none}");

        // First run follows the phone's light/dark setting ("auto" in the web's own theme picker).
        String boot = "(function(){try{if(!localStorage.getItem('overdrive_theme'))localStorage.setItem('overdrive_theme','auto');}catch(e){}})();";

        // Tell the native side which colours sit under the status and navigation bars.
        String bars = "(function(){if(!window.ODCompanion)return;var last='';"
            + "function bg(el){while(el&&el.nodeType===1){var c=getComputedStyle(el).backgroundColor;"
            + "if(c&&c!=='transparent'&&!/rgba\\([^)]*,\\s*0\\)$/.test(c))return c;el=el.parentElement;}"
            + "return getComputedStyle(document.body||document.documentElement).backgroundColor;}"
            + "function send(){try{var w=window.innerWidth/2,h=window.innerHeight;"
            + "var t=bg(document.elementFromPoint(w,1)),b=bg(document.elementFromPoint(w,h-1)),p=getComputedStyle(document.body).backgroundColor;"
            + "var k=t+'|'+b+'|'+p;if(k!==last){last=k;ODCompanion.onBars(t,b,p);}}catch(e){}}"
            + "var q=0;function soon(){if(q)return;q=setTimeout(function(){q=0;send();},120);}"
            + "document.addEventListener('DOMContentLoaded',function(){send();"
            + "new MutationObserver(soon).observe(document.documentElement,{attributes:true,attributeFilter:['data-theme','class','style']});"
            + "new MutationObserver(soon).observe(document.body,{attributes:true,childList:true,subtree:true});});"
            + "window.addEventListener('load',send);window.addEventListener('scroll',soon,{capture:true,passive:true});"
            + "window.addEventListener('resize',soon);})();";

        // 3.4.2: downloads like Chrome. <a download> clicks (in the page or detached), blob: and data:
        // bodies go to ODCompanion.saveBase64; http(s) files to ODCompanion.download (fetched natively
        // with the session). Blobs are remembered at createObjectURL time so an immediate
        // revokeObjectURL after a.click() (as automations.js does) can't lose the file.
        String dl = "(function(){if(!window.ODCompanion||window.__odSave)return;var B=new Map();"
            + "var oc=URL.createObjectURL,orv=URL.revokeObjectURL;"
            + "URL.createObjectURL=function(o){var u=oc.apply(URL,arguments);try{if(o instanceof Blob)B.set(u,o);}catch(e){}return u;};"
            + "URL.revokeObjectURL=function(u){var r=orv.apply(URL,arguments);setTimeout(function(){B.delete(u);},30000);return r;};"
            + "function send(b,n){var fr=new FileReader();fr.onload=function(){var s=String(fr.result),i=s.indexOf(',');"
            + "ODCompanion.saveBase64(s.slice(i+1),n||'',b.type||'');};fr.onerror=function(){ODCompanion.downloadFailed('read');};fr.readAsDataURL(b);}"
            + "function save(h,n){var u;try{u=new URL(h,location.href);}catch(e){return false;}"
            + "if(u.protocol==='blob:'){var b=B.get(u.href);if(b){send(b,n);return true;}}"
            + "if(u.protocol==='blob:'||u.protocol==='data:'){fetch(u.href).then(function(r){return r.blob();}).then(function(b){send(b,n);})"
            + ".catch(function(e){ODCompanion.downloadFailed(String(e&&e.message||e));});return true;}"
            + "if(u.protocol==='http:'||u.protocol==='https:'){ODCompanion.download(u.href,n||'');return true;}return false;}"
            + "window.__odSave=save;"
            + "function handle(a,ev){if(!a||!a.hasAttribute||!a.hasAttribute('download')||!a.href)return false;"
            + "if(save(a.href,a.getAttribute('download'))){if(ev)ev.preventDefault();return true;}return false;}"
            + "document.addEventListener('click',function(e){if(e.defaultPrevented)return;var t=e.target;"
            + "var a=t&&t.closest?t.closest('a[download]'):null;if(a)handle(a,e);});"
            + "var ac=HTMLAnchorElement.prototype.click;HTMLAnchorElement.prototype.click=function(){"
            + "if(!this.isConnected&&handle(this,null))return;return ac.apply(this,arguments);};})();";

        return "<script>" + boot + "</script><style id=\"od-companion-colors\">" + css + "</style><script>" + bars + "</script><script>" + dl + "</script>";
    }

    /**
     * 3.4.1: the web's app-shell.js loads search.css only on idle (~1 s in), which resizes the
     * header search icon and shifts the header and page body on every navigation. Load it with the
     * page instead, at the end of <head> (the same cascade position the lazy load appends it to).
     * The data attribute is the one app-shell.js checks, so it is never added twice.
     */
    static final String EARLY_SEARCH_CSS =
            "<link rel=\"stylesheet\" href=\"/shared/search.css?v=1\" data-overdrive-search-css=\"1\">";

    /** Splice right after the opening <head> tag, before theme.js and the web's stylesheets. */
    static String inject(String html, String head) {
        int end = indexOfIgnoreCase(html, "</head>");
        if (end >= 0) html = html.substring(0, end) + EARLY_SEARCH_CSS + html.substring(end);
        int i = indexOfIgnoreCase(html, "<head");
        if (i >= 0) {
            int close = html.indexOf('>', i);
            if (close > 0) return html.substring(0, close + 1) + head + html.substring(close + 1);
        }
        return head + html;
    }

    private static int indexOfIgnoreCase(String s, String needle) {
        return s.toLowerCase(Locale.ROOT).indexOf(needle);
    }
}
