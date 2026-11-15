package com.https1121.overdrive.companion;

import android.content.Context;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.animation.DecelerateInterpolator;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.google.android.material.color.MaterialColors;

/**
 * A small, fully rounded status chip just below the page header (replaces the bottom
 * Snackbar of 3.4.1). Material You colours, RTL text, short fade + slide in and out.
 */
final class Pill {
    private final TextView view;
    private final GradientDrawable dot = new GradientDrawable();
    private final float dp;
    private final Runnable hide = this::hide;

    Pill(FrameLayout parent) {
        Context c = parent.getContext();
        dp = c.getResources().getDisplayMetrics().density;
        view = new TextView(c);
        GradientDrawable bg = new GradientDrawable();
        bg.setCornerRadius(999 * dp);
        bg.setColor(MaterialColors.getColor(parent, com.google.android.material.R.attr.colorSecondaryContainer));
        view.setBackground(bg);
        view.setTextColor(MaterialColors.getColor(parent, com.google.android.material.R.attr.colorOnSecondaryContainer));
        view.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        view.setGravity(Gravity.CENTER);
        view.setMaxLines(2);
        view.setEllipsize(TextUtils.TruncateAt.END);
        view.setLayoutDirection(View.LAYOUT_DIRECTION_RTL);
        view.setTextDirection(View.TEXT_DIRECTION_RTL);
        view.setPaddingRelative(px(16), px(8), px(16), px(8));
        view.setMinHeight(px(36));
        view.setElevation(px(3));
        dot.setShape(GradientDrawable.OVAL);
        dot.setSize(px(8), px(8));
        view.setCompoundDrawablesRelativeWithIntrinsicBounds(dot, null, null, null);
        view.setCompoundDrawablePadding(px(8));
        view.setVisibility(View.GONE);
        view.setClickable(false);
        FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(FrameLayout.LayoutParams.WRAP_CONTENT,
                FrameLayout.LayoutParams.WRAP_CONTENT, Gravity.TOP | Gravity.CENTER_HORIZONTAL);
        lp.leftMargin = lp.rightMargin = px(24);
        parent.addView(view, lp);
    }

    private int px(float v) { return Math.round(v * dp); }

    /** @param top offset from the top of the window, in px (below the page header). */
    void show(String text, int dotAttr, int top, long durationMs) {
        view.removeCallbacks(hide);
        view.animate().cancel();
        dot.setColor(MaterialColors.getColor(view, dotAttr));
        view.setText(text);
        FrameLayout.LayoutParams lp = (FrameLayout.LayoutParams) view.getLayoutParams();
        lp.topMargin = top;
        view.setLayoutParams(lp);
        if (view.getVisibility() != View.VISIBLE) {
            view.setAlpha(0f);
            view.setTranslationY(-px(8));
            view.setVisibility(View.VISIBLE);
        }
        view.animate().alpha(1f).translationY(0f).setDuration(220).setInterpolator(new DecelerateInterpolator()).start();
        view.postDelayed(hide, durationMs);
    }

    private void hide() {
        view.animate().alpha(0f).translationY(-px(8)).setDuration(200)
                .withEndAction(() -> view.setVisibility(View.GONE)).start();
    }
}
