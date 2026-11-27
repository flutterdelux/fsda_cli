import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'FSDA CLI',
  tagline: 'Feature Slice Driven Architecture CLI',
  url: 'https://flutter-delux.github.io',
  baseUrl: '/fsda_cli/',
  organizationName: 'flutter-delux',
  projectName: 'fsda_cli',
  deploymentBranch: 'gh-pages',
  trailingSlash: false,
  onBrokenLinks: 'throw',
  onBrokenAnchors: 'warn',
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },
  presets: [
    [
      'classic',
      {
        docs: {
          routeBasePath: 'docs',
          sidebarPath: './sidebars.ts',
          showLastUpdateAuthor: true,
          showLastUpdateTime: true,
          includeCurrentVersion: true,
          lastVersion: 'current',
          versions: {
            current: {
              label: 'dev',
              banner: 'none',
            },
            '1.0.16': {
              label: '1.0.16',
            },
          },
          editUrl: 'https://github.com/flutter-delux/fsda_cli/tree/main/website/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],
  themeConfig: {
    colorMode: {
      defaultMode: 'light',
      disableSwitch: false,
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'FSDA CLI',
      items: [
        {
          type: 'docsVersionDropdown',
          position: 'right',
          dropdownActiveClassDisabled: true,
        },
        {
          href: 'https://github.com/flutter-delux/fsda_cli',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Documentation',
          items: [
            {
              label: 'Getting Started',
              to: '/docs/getting-started',
            },
            {
              label: 'Commands',
              to: '/docs/commands',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'GitHub Repository',
              href: 'https://github.com/flutter-delux/fsda_cli',
            },
            {
              label: 'Issue Tracker',
              href: 'https://github.com/flutter-delux/fsda_cli/issues',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Flutter Delux.`,
    },
    prism: {
      additionalLanguages: ['dart', 'bash', 'yaml'],
      magicComments: [
        // Highlight bawaan
        {
          className: 'theme-code-block-highlighted-line',
          line: 'highlight-next-line',
          block: {start: 'highlight-start', end: 'highlight-end'},
        },
        // Highlight REMOVE (Merah + simbol -)
        {
          className: 'code-block-remove-line',
          line: 'remove-next-line',
          block: {start: 'remove-start', end: 'remove-end'},
        },
        // Highlight ADD (Hijau + simbol +)
        {
          className: 'code-block-add-line',
          line: 'add-next-line',
          block: {start: 'add-start', end: 'add-end'},
        },
      ],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
