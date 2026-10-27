import { useState } from 'react';
import {
  Pressable,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { darkModeTextStyle, RichText } from 'react-native-render-rich-text';
import { FIXTURES, type FixtureId } from './fixtures';

const lightTextStyle = {
  paragraph: { color: '#1c1917', fontSize: 16, lineHeight: 26 },
  link: { color: '#9a3412' },
  factoid: {
    color: '#23670d',
    backgroundColor: '#9bfc6e',
    borderColor: '#278308',
  },
  blockquote: {
    borderColor: '#c2410c',
    color: '#44403c',
  },
  code: { color: '#7c2d12', backgroundColor: '#ffedd5' },
  codeBlock: {
    color: '#f5f5f4',
    backgroundColor: '#292524',
    borderColor: '#44403c',
  },
};

function Gallery() {
  const [fixtureId, setFixtureId] = useState<FixtureId>('mixed');
  const [lastLink, setLastLink] = useState('No link opened yet');
  const [lastFactoid, setLastFactoid] = useState('No factoid opened yet');
  const [dark, setDark] = useState(false);
  const fixture = FIXTURES.find(item => item.id === fixtureId) ?? FIXTURES[0];

  return (
    <SafeAreaView
      style={[styles.screen, dark && styles.screenDark]}
      edges={['top', 'bottom']}
    >
      <StatusBar barStyle={dark ? 'light-content' : 'dark-content'} />
      <View style={styles.header}>
        <Text style={[styles.kicker, dark && styles.kickerDark]}>TipTap</Text>
        <View style={styles.titleRow}>
          <Text style={[styles.title, dark && styles.titleDark]}>
            Rich text
          </Text>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={
              dark ? 'Switch to light mode' : 'Switch to dark mode'
            }
            accessibilityState={{ selected: dark }}
            onPress={() => setDark(value => !value)}
            style={[styles.modeToggle, dark && styles.modeToggleDark]}
          >
            <Text
              style={[
                styles.modeToggleLabel,
                dark && styles.modeToggleLabelDark,
              ]}
            >
              {dark ? 'Light' : 'Dark'}
            </Text>
          </Pressable>
        </View>
        <Text style={[styles.subtitle, dark && styles.subtitleDark]}>
          Four documents the display path knows how to draw.
        </Text>
      </View>
      <View style={styles.tabs}>
        {FIXTURES.map(item => {
          const selected = item.id === fixture.id;
          return (
            <Pressable
              key={item.id}
              accessibilityRole="button"
              accessibilityState={{ selected }}
              onPress={() => setFixtureId(item.id)}
              style={[
                styles.tab,
                dark && styles.tabDark,
                selected && styles.tabSelected,
                selected && dark && styles.tabSelectedDark,
              ]}
            >
              <Text
                style={[
                  styles.tabLabel,
                  dark && styles.tabLabelDark,
                  selected && styles.tabLabelSelected,
                  selected && dark && styles.tabLabelSelectedDark,
                ]}
              >
                {item.label}
              </Text>
            </Pressable>
          );
        })}
      </View>
      <ScrollView
        contentContainerStyle={styles.scroll}
        style={styles.scrollView}
      >
        <View style={[styles.sheet, dark && styles.sheetDark]}>
          <RichText
            document={fixture.document}
            onLinkPress={setLastLink}
            onFactoidPress={setLastFactoid}
            textStyle={dark ? darkModeTextStyle : lightTextStyle}
          />
        </View>
      </ScrollView>
      <View style={[styles.footer, dark && styles.footerDark]}>
        <Text style={[styles.footerLabel, dark && styles.footerLabelDark]}>
          Last link
        </Text>
        <Text
          numberOfLines={1}
          style={[styles.footerValue, dark && styles.footerValueDark]}
        >
          {lastLink}
        </Text>
        <Text
          style={[
            styles.footerLabel,
            styles.footerLabelSpaced,
            dark && styles.footerLabelDark,
          ]}
        >
          Last factoid
        </Text>
        <Text
          numberOfLines={1}
          style={[styles.footerValue, dark && styles.footerValueDark]}
        >
          {lastFactoid}
        </Text>
      </View>
    </SafeAreaView>
  );
}

export default function App() {
  return (
    <SafeAreaProvider>
      <Gallery />
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
    backgroundColor: '#f6f1e8',
  },
  screenDark: {
    backgroundColor: '#010409',
  },
  header: {
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
  },
  kicker: {
    color: '#9a3412',
    fontSize: 12,
    fontWeight: '700',
    letterSpacing: 1.2,
    textTransform: 'uppercase',
  },
  kickerDark: {
    color: '#58A6FF',
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
    marginTop: 4,
  },
  title: {
    color: '#1c1917',
    flex: 1,
    fontSize: 32,
    fontWeight: '700',
  },
  titleDark: {
    color: '#F0F6FC',
  },
  modeToggle: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: '#d6d3d1',
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: '#fffaf3',
  },
  modeToggleDark: {
    backgroundColor: '#161B22',
    borderColor: '#30363D',
  },
  modeToggleLabel: {
    color: '#44403c',
    fontSize: 14,
    fontWeight: '600',
  },
  modeToggleLabelDark: {
    color: '#E6EDF3',
  },
  subtitle: {
    color: '#57534e',
    fontSize: 15,
    lineHeight: 21,
    marginTop: 4,
  },
  subtitleDark: {
    color: '#8B949E',
  },
  tabs: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  tab: {
    borderRadius: 999,
    borderWidth: 1,
    borderColor: '#d6d3d1',
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: '#fffaf3',
  },
  tabDark: {
    backgroundColor: '#161B22',
    borderColor: '#30363D',
  },
  tabSelected: {
    backgroundColor: '#1c1917',
    borderColor: '#1c1917',
  },
  tabSelectedDark: {
    backgroundColor: '#F0F6FC',
    borderColor: '#F0F6FC',
  },
  tabLabel: {
    color: '#44403c',
    fontSize: 14,
    fontWeight: '600',
  },
  tabLabelDark: {
    color: '#C9D1D9',
  },
  tabLabelSelected: {
    color: '#fafaf9',
  },
  tabLabelSelectedDark: {
    color: '#0D1117',
  },
  scrollView: {
    flex: 1,
  },
  scroll: {
    paddingHorizontal: 20,
    paddingBottom: 24,
  },
  sheet: {
    backgroundColor: '#fffaf3',
    borderRadius: 18,
    paddingHorizontal: 18,
    paddingVertical: 16,
    borderWidth: 1,
    borderColor: '#e7e5e4',
  },
  sheetDark: {
    backgroundColor: '#0D1117',
    borderColor: '#30363D',
  },
  footer: {
    borderTopWidth: 1,
    borderTopColor: '#e7e5e4',
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#fffaf3',
  },
  footerDark: {
    borderTopColor: '#30363D',
    backgroundColor: '#0D1117',
  },
  footerLabel: {
    color: '#78716c',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.8,
  },
  footerLabelDark: {
    color: '#8B949E',
  },
  footerLabelSpaced: {
    marginTop: 10,
  },
  footerValue: {
    color: '#1c1917',
    fontSize: 14,
    marginTop: 4,
  },
  footerValueDark: {
    color: '#E6EDF3',
  },
});
