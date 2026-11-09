import { useCallback, useState } from "react";
import { StyleSheet, View } from "react-native";
import type { MentionTarget } from "react-native-render-rich-text";

import { ThemedText } from "@/components/themed-text";
import { ThemedView } from "@/components/themed-view";
import { Spacing } from "@/constants/theme";

const EMPTY_LINK = "No link opened yet";
const EMPTY_FACTOID = "No factoid opened yet";
const EMPTY_MENTION = "No mention opened yet";

export function usePressLog() {
  const [lastLink, setLastLink] = useState(EMPTY_LINK);
  const [lastFactoid, setLastFactoid] = useState(EMPTY_FACTOID);
  const [lastMention, setLastMention] = useState(EMPTY_MENTION);

  const onMentionPress = useCallback((mention: MentionTarget) => {
    setLastMention(`Pressed ${mention.label || mention.id}`);
  }, []);

  const onMentionLongPress = useCallback((mention: MentionTarget) => {
    setLastMention(`Held ${mention.label || mention.id}`);
  }, []);

  return {
    lastLink,
    lastFactoid,
    lastMention,
    onLinkPress: setLastLink,
    onFactoidPress: setLastFactoid,
    onMentionPress,
    onMentionLongPress,
  };
}

type PressLogProps = {
  lastLink: string;
  lastFactoid: string;
  lastMention: string;
};

export function PressLog({ lastLink, lastFactoid, lastMention }: PressLogProps) {
  return (
    <ThemedView type="backgroundElement" style={styles.log}>
      <Entry label="Last link" value={lastLink} />
      <Entry label="Last factoid" value={lastFactoid} />
      <Entry label="Last mention" value={lastMention} />
    </ThemedView>
  );
}

function Entry({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.entry}>
      <ThemedText type="smallBold" themeColor="textSecondary" style={styles.label}>
        {label}
      </ThemedText>
      <ThemedText type="small" numberOfLines={1}>
        {value}
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  log: {
    alignSelf: "stretch",
    gap: Spacing.two,
    paddingHorizontal: Spacing.three,
    paddingVertical: Spacing.three,
    borderRadius: Spacing.four,
  },
  entry: {
    gap: Spacing.half,
  },
  label: {
    fontSize: 12,
    letterSpacing: 0.8,
    textTransform: "uppercase",
  },
});
