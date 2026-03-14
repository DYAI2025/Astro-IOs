import "react-native-gesture-handler";
import { useEffect } from "react";
import { GestureHandlerRootView } from "react-native-gesture-handler";
import { SafeAreaProvider } from "react-native-safe-area-context";
import { StatusBar } from "expo-status-bar";
import * as Linking from "expo-linking";
import * as WebBrowser from "expo-web-browser";
import { AuthProvider, useAuth } from "./src/contexts/AuthContext";
import { AppStateProvider } from "./src/contexts/AppStateContext";
import { useBootstrap } from "./src/hooks/useBootstrap";
import { getAppVersion, getAppPlatform } from "./src/lib/device";
import { getStoreUrlForCurrentPlatform } from "./src/lib/config";
import { isBelowMinVersion, requiredVersionForPlatform } from "./src/lib/versionGate";
import { useProfile } from "./src/hooks/useProfile";
import { startQueueWorker } from "./src/lib/offlineQueue";
import { LoadingScreen } from "./src/components/LoadingScreen";
import { AuthScreen } from "./src/screens/AuthScreen";
import { OnboardingScreen } from "./src/screens/OnboardingScreen";
import { RootNavigator } from "./src/navigation/RootNavigator";
import { ForceUpdateScreen } from "./src/screens/ForceUpdateScreen";

WebBrowser.maybeCompleteAuthSession();

function MobileRoot() {
  const { user, loading: authLoading } = useAuth();
  const { bootstrap, loading: bootstrapLoading } = useBootstrap();
  const { profile, tier, loading: profileLoading, refresh } = useProfile(user?.id);

  useEffect(() => {
    const stopQueueWorker = startQueueWorker();
    const linkSub = Linking.addEventListener("url", (event) => {
      const lower = event.url.toLowerCase();
      if (lower.includes("checkout/success") || lower.includes("upgrade=success")) {
        void refresh();
      }
    });

    return () => {
      stopQueueWorker();
      linkSub.remove();
    };
  }, [refresh]);

  if (authLoading || bootstrapLoading) {
    return <LoadingScreen label="Preparing Bazodiac Mobile..." />;
  }

  const appVersion = getAppVersion();
  const platform = getAppPlatform() === "ios" ? "ios" : "android";
  const belowMinimum = isBelowMinVersion(appVersion, bootstrap, platform);

  if (belowMinimum) {
    return (
      <ForceUpdateScreen
        currentVersion={appVersion}
        requiredVersion={requiredVersionForPlatform(bootstrap, platform)}
        storeUrl={getStoreUrlForCurrentPlatform()}
      />
    );
  }

  if (!user) {
    return <AuthScreen />;
  }

  if (profileLoading) {
    return <LoadingScreen label="Loading your cosmic profile..." />;
  }

  if (!profile) {
    return <OnboardingScreen onCompleted={refresh} />;
  }

  return (
    <AppStateProvider
      value={{
        userId: user.id,
        profile,
        tier,
        bootstrap,
        refreshProfile: refresh,
      }}
    >
      <RootNavigator />
    </AppStateProvider>
  );
}

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AuthProvider>
          <StatusBar style="light" />
          <MobileRoot />
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
