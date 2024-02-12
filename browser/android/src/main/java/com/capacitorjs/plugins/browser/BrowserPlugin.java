package com.capacitorjs.plugins.browser;

import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import com.getcapacitor.Logger;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.util.WebColor;

@CapacitorPlugin(name = "Browser")
public class BrowserPlugin extends Plugin {

    private Browser implementation;

    public static BrowserControllerListener browserControllerListener;
    private static BrowserControllerActivity browserControllerActivityInstance;

    public static void setBrowserControllerListener(BrowserControllerListener listener) {
        browserControllerListener = listener;
        if (listener == null) {
            browserControllerActivityInstance = null;
        }
    }

    public void load() {
        implementation = new Browser(getContext());
        implementation.setBrowserEventListener(this::onBrowserEvent);
    }

    @PluginMethod
    public void open(PluginCall call) {
        String urlString = call.getString("url");
        if (urlString == null || urlString.isEmpty()) {
            call.reject("Must provide a valid URL to open");
            return;
        }

        Intent intent = new Intent(getContext(), BrowserControllerActivity.class);
        intent.putExtra("url", urlString);
        getContext().startActivity(intent);

        call.resolve();
    }

    @PluginMethod
    public void close(PluginCall call) {
        if (browserControllerActivityInstance != null) {
            browserControllerActivityInstance = null;
            Intent intent = new Intent(getContext(), BrowserControllerActivity.class);
            intent.putExtra("close", true);
            getContext().startActivity(intent);
        }
        call.resolve();
    }

    @Override
    protected void handleOnResume() {
        if (!implementation.bindService()) {
            Logger.error(getLogTag(), "Error binding to custom tabs service", null);
        }
    }

    @Override
    protected void handleOnPause() {
        implementation.unbindService();
    }

    void onBrowserEvent(int event) {
        switch (event) {
            case Browser.BROWSER_LOADED:
                notifyListeners("browserPageLoaded", null);
                break;
            case Browser.BROWSER_FINISHED:
                notifyListeners("browserFinished", null);
                break;
        }
    }
}
