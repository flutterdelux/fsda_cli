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
              label: 'next',
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
          to: '/docs/overview',
          label: 'Overview',
          position: 'left',
        },
        {
          to: '/docs/installation',
          label: 'Installation',
          position: 'left',
        },
        {
          to: '/docs/commands',
          label: 'Commands',
          position: 'left',
        },
        {
          to: '/docs/workflow',
          label: 'Workflow',
          position: 'left',
        },
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
              label: 'Overview',
              to: '/docs/overview',
            },
            {
              label: 'Installation',
              to: '/docs/installation',
            },
            {
              label: 'Commands',
              to: '/docs/commands',
            },
            {
              label: 'Workflow',
              to: '/docs/workflow',
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
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
