import React, { useEffect, useState } from "react";
import { ActivityIndicator, Image, StyleSheet, Text, View } from "react-native";
import { StatusBar } from "expo-status-bar";
import { WebView } from "react-native-webview";

const GAME_ASSET = require("./starfall-shattered-fates.html");

export default function App() {
  const [gameUri, setGameUri] = useState<string | null>(null);
  const [loadError, setLoadError] = useState(false);

  useEffect(() => {
    try {
      const resolved = Image.resolveAssetSource(GAME_ASSET);
      if (resolved?.uri) setGameUri(resolved.uri);
      else setLoadError(true);
    } catch {
      setLoadError(true);
    }
  }, []);

  if (loadError) {
    return (
      <View style={styles.fallback}>
        <Text style={styles.fallbackTitle}>Unable to load the campaign</Text>
        <Text style={styles.fallbackText}>Rebuild the APK so the bundled game file is included, then reopen the app.</Text>
      </View>
    );
  }

  if (!gameUri) {
    return (
      <View style={styles.loading}>
        <StatusBar style="light" />
        <ActivityIndicator size="large" color="#a899ff" />
        <Text style={styles.loadingTitle}>Preparing the galaxy…</Text>
        <Text style={styles.loadingText}>Loading your offline campaign deck</Text>
      </View>
    );
  }

  return (
    <View style={styles.app}>
      <StatusBar style="light" />
      <WebView
        source={{ uri: gameUri }}
        style={styles.webview}
        originWhitelist={["*"]}
        javaScriptEnabled
        domStorageEnabled
        allowsInlineMediaPlayback
        allowFileAccess
        allowFileAccessFromFileURLs
        allowUniversalAccessFromFileURLs
        setSupportMultipleWindows={false}
        startInLoadingState
        renderLoading={() => (
          <View style={styles.loading}>
            <ActivityIndicator size="large" color="#a899ff" />
          </View>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  app: { flex: 1, backgroundColor: "#070914" },
  webview: { flex: 1, backgroundColor: "#070914" },
  loading: { flex: 1, alignItems: "center", justifyContent: "center", gap: 12, backgroundColor: "#070914" },
  loadingTitle: { color: "#f4f3ff", fontSize: 18, fontWeight: "700", marginTop: 14 },
  loadingText: { color: "#a5a8c3", fontSize: 12 },
  fallback: { flex: 1, padding: 28, alignItems: "center", justifyContent: "center", backgroundColor: "#070914" },
  fallbackTitle: { color: "#f4f3ff", fontSize: 20, fontWeight: "700", textAlign: "center" },
  fallbackText: { maxWidth: 340, marginTop: 12, color: "#a5a8c3", fontSize: 13, lineHeight: 20, textAlign: "center" }
});
