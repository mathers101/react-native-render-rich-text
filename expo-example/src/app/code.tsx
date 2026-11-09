import { ScrollView, StyleSheet, useColorScheme } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { darkModeTextStyle, RichText } from "react-native-render-rich-text";

import { PressLog, usePressLog } from "@/components/press-log";
import { ThemedText } from "@/components/themed-text";
import { ThemedView } from "@/components/themed-view";
import { BottomTabInset, MaxContentWidth, Spacing } from "@/constants/theme";
import { FIXTURES } from "../../fixtures";

const document = FIXTURES.code[0];

export default function CodeScreen() {
  const textStyle = useColorScheme() === "dark" ? darkModeTextStyle : undefined;
  const { lastLink, lastFactoid, lastMention, onLinkPress, onFactoidPress, onMentionPress, onMentionLongPress } =
    usePressLog();

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        <ScrollView style={styles.scroll} contentContainerStyle={styles.scrollContent}>
          <ThemedText type="code" style={styles.kicker}>
            Code
          </ThemedText>
          <ThemedView type="backgroundElement" style={styles.sheet}>
            <RichText
              document={document}
              onLinkPress={onLinkPress}
              onFactoidPress={onFactoidPress}
              onMentionPress={onMentionPress}
              onMentionLongPress={onMentionLongPress}
              textStyle={textStyle}
              style={styles.richText}
            />
          </ThemedView>
        </ScrollView>
        <PressLog lastLink={lastLink} lastFactoid={lastFactoid} lastMention={lastMention} />
      </SafeAreaView>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    flexDirection: "row",
  },
  safeArea: {
    flex: 1,
    paddingHorizontal: Spacing.four,
    alignItems: "center",
    gap: Spacing.three,
    maxWidth: MaxContentWidth,
  },
  scroll: {
    alignSelf: "stretch",
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    justifyContent: "center",
    gap: Spacing.three,
  },
  kicker: {
    textTransform: "uppercase",
  },
  sheet: {
    gap: Spacing.three,
    alignSelf: "stretch",
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.four,
    borderRadius: Spacing.four,
  },
  richText: {
    alignSelf: "stretch",
  },
});
