import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'getting-started',
    'declarative',
    {
      type: 'category',
      label: 'Commands',
      link: {
        type: 'doc',
        id: 'commands/commands-index',
      },
      items: [
        'commands/commands-workspace',
        'commands/commands-run',
        'commands/commands-package',
        'commands/commands-module',
        'commands/commands-feature',
        'commands/commands-failure',
        'commands/commands-datasource',
        'commands/commands-enum',
        'commands/commands-model',
        'commands/commands-sequence',
        'commands/commands-logic',
        'commands/commands-input',
        'commands/commands-ui',
        'commands/commands-app',
        'commands/commands-app-integration',
        'commands/commands-compose',
        'commands/commands-maintenance',
      ],
    },
    'releases',
  ],
};

export default sidebars;