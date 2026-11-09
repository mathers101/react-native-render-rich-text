import { NativeTabs } from "expo-router/native-tabs";
import { useColorScheme } from "react-native";

import { Colors } from "@/constants/theme";

export default function AppTabs() {
  const scheme = useColorScheme();
  const colors = Colors[scheme === "dark" ? "dark" : "light"];

  return (
    <NativeTabs
      backgroundColor={colors.background}
      indicatorColor={colors.backgroundElement}
      labelStyle={{ selected: { color: colors.text } }}
    >
      <NativeTabs.Trigger name="index">
        <NativeTabs.Trigger.Label>Home</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon sf={{ default: "house", selected: "house.fill" }} md="home" />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="code">
        <NativeTabs.Trigger.Label>Code</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon sf="chevron.left.forwardslash.chevron.right" md="code" />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="lists">
        <NativeTabs.Trigger.Label>Lists</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon sf="list.bullet" md="format_list_bulleted" />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="long">
        <NativeTabs.Trigger.Label>Long</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon sf={{ default: "scroll", selected: "scroll.fill" }} md="subject" />
      </NativeTabs.Trigger>
    </NativeTabs>
  );
}
