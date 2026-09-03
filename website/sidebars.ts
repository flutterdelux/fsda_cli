import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  docsSidebar: [
    'overview',
    'installation',
    {
      type: 'category',
      label: 'Commands',
      link: {
        type: 'doc',
        id: 'commands/commands-index',
      },
      items: [
        'commands/commands-workspace',
        'commands/commands-generation',
        'commands/commands-composition',
        'commands/commands-maintenance',
      ],
    },
    'workflow',
    'versioning',
  ],
};

export default sidebars;
