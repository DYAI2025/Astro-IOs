import { Linking, Pressable, SafeAreaView, StyleSheet, Text, View } from "react-native";

type Props = {
  currentVersion: string;
  requiredVersion: string;
  storeUrl: string;
};

export function ForceUpdateScreen({ currentVersion, requiredVersion, storeUrl }: Props) {
  const openStore = async () => {
    await Linking.openURL(storeUrl);
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.card}>
        <Text style={styles.kicker}>Update Required</Text>
        <Text style={styles.title}>Please update Bazodiac Mobile</Text>
        <Text style={styles.body}>
          Your app version is no longer supported. Update to continue using authentication,
          onboarding, and dashboard features.
        </Text>

        <View style={styles.metaBox}>
          <Text style={styles.metaText}>Current: {currentVersion}</Text>
          <Text style={styles.metaText}>Required: {requiredVersion}</Text>
        </View>

        <Pressable style={styles.button} onPress={() => void openStore()}>
          <Text style={styles.buttonText}>Open Store</Text>
        </Pressable>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: {
    flex: 1,
    backgroundColor: "#060b12",
    justifyContent: "center",
    paddingHorizontal: 20,
  },
  card: {
    borderRadius: 18,
    borderWidth: 1,
    borderColor: "#2b3a4e",
    backgroundColor: "#0f1823",
    padding: 20,
    gap: 12,
  },
  kicker: {
    color: "#d4af37",
    textTransform: "uppercase",
    letterSpacing: 2,
    fontSize: 11,
    fontWeight: "700",
  },
  title: {
    color: "#f5f7fb",
    fontSize: 24,
    fontWeight: "700",
  },
  body: {
    color: "#b5c3d7",
    lineHeight: 22,
    fontSize: 14,
  },
  metaBox: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#243447",
    backgroundColor: "#121e2d",
    padding: 12,
    gap: 6,
  },
  metaText: {
    color: "#d0daea",
    fontSize: 13,
  },
  button: {
    marginTop: 4,
    minHeight: 50,
    borderRadius: 25,
    backgroundColor: "#d4af37",
    alignItems: "center",
    justifyContent: "center",
  },
  buttonText: {
    color: "#101926",
    fontSize: 15,
    fontWeight: "800",
  },
});
