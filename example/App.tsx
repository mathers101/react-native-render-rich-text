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
import { RichText } from 'react-native-render-rich-text';
import { FIXTURES, type FixtureId } from './fixtures';

function Gallery() {
  const [fixtureId, setFixtureId] = useState<FixtureId>('mixed');
  const [lastLink, setLastLink] = useState('No link opened yet');
  const [lastFactoid, setLastFactoid] = useState('No factoid opened yet');
  const fixture = FIXTURES.find(item => item.id === fixtureId) ?? FIXTURES[0];

  return (
    <SafeAreaView style={styles.screen} edges={['top', 'bottom']}>
      <StatusBar barStyle="dark-content" />
      <View style={styles.header}>
        <Text style={styles.kicker}>TipTap</Text>
        <Text style={styles.title}>Rich text</Text>
        <Text style={styles.subtitle}>
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
              style={[styles.tab, selected && styles.tabSelected]}
            >
              <Text
                style={[styles.tabLabel, selected && styles.tabLabelSelected]}
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
        <View style={styles.sheet}>
          <RichText
            document={fixture.document}
            onLinkPress={setLastLink}
            onFactoidPress={setLastFactoid}
            textStyle={{
              paragraph: { color: '#1c1917', fontSize: 17, lineHeight: 26 },
              link: { color: '#9a3412' },
              factoid: {
                color: '#23670d',
                backgroundColor: '#9bfc6e',
                borderColor: '#278308',
              },
              blockquote: {
                borderColor: '#c2410c',
                color: '#44403c',
                padding: 10,
              },
              code: { color: '#7c2d12', backgroundColor: '#ffedd5' },
              codeBlock: {
                color: '#f5f5f4',
                backgroundColor: '#292524',
                borderColor: '#44403c',
              },
            }}
          />
        </View>
      </ScrollView>
      <View style={styles.footer}>
        <Text style={styles.footerLabel}>Last link</Text>
        <Text numberOfLines={1} style={styles.footerValue}>
          {lastLink}
        </Text>
        <Text style={[styles.footerLabel, styles.footerLabelSpaced]}>
          Last factoid
        </Text>
        <Text numberOfLines={1} style={styles.footerValue}>
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
  title: {
    color: '#1c1917',
    fontSize: 32,
    fontWeight: '700',
    marginTop: 4,
  },
  subtitle: {
    color: '#57534e',
    fontSize: 15,
    lineHeight: 21,
    marginTop: 4,
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
  tabSelected: {
    backgroundColor: '#1c1917',
    borderColor: '#1c1917',
  },
  tabLabel: {
    color: '#44403c',
    fontSize: 14,
    fontWeight: '600',
  },
  tabLabelSelected: {
    color: '#fafaf9',
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
  footer: {
    borderTopWidth: 1,
    borderTopColor: '#e7e5e4',
    paddingHorizontal: 20,
    paddingVertical: 12,
    backgroundColor: '#fffaf3',
  },
  footerLabel: {
    color: '#78716c',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 0.8,
  },
  footerLabelSpaced: {
    marginTop: 10,
  },
  footerValue: {
    color: '#1c1917',
    fontSize: 14,
    marginTop: 4,
  },
});
