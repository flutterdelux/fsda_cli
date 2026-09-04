import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';

const cards = [
  {
    title: 'Safe Reruns',
    text: 'Generator output is non-destructive by default: existing files are skipped to avoid accidental overwrite.',
  },
  {
    title: 'Strict When Needed',
    text: 'Enable --strict for fail-fast behavior when files already exist or safe injection anchors are missing.',
  },
  {
    title: 'Explicit Compose Modes',
    text: 'Choose compose mode by intent: main, form, pagination, popup menu action, or section injection.',
  },
  {
    title: 'Traceable File Changes',
    text: 'Major commands print affected path summaries so every generated or injected file is easy to audit.',
  },
];

export default function Home(): JSX.Element {
  return (
    <Layout
      title="FSDA CLI Documentation"
      description="Feature Slice Driven Architecture CLI documentation"
    >
      <header className="hero heroBanner">
        <div className="container">
          <Heading as="h1" className="hero__title">
            FSDA CLI Documentation
          </Heading>
          <p className="hero__subtitle">
            Build FSDA workspaces with predictable generation, explicit composition flows,
            and command outputs you can verify before commit.
          </p>
          <div className="heroCta">
            <Link className="button button--primary button--lg" to="/docs/overview">
              Open Overview
            </Link>
            <Link className="button button--secondary button--lg" to="/docs/commands">
              Command Deep Dive
            </Link>
          </div>
          <div className="heroCardGrid">
            {cards.map((item) => (
              <article className="heroCard" key={item.title}>
                <Heading as="h3">{item.title}</Heading>
                <p>{item.text}</p>
              </article>
            ))}
          </div>
        </div>
      </header>
    </Layout>
  );
}
