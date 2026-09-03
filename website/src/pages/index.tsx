import React from 'react';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';

const cards = [
  {
    title: 'Generate Fast',
    text: 'Scaffold app, module, feature, slice, and UI templates with strict-safe generation defaults.',
  },
  {
    title: 'Compose Precisely',
    text: 'Compose flows are split by mode: compose-main, compose-form, compose-pag, compose-pmi, compose-sec.',
  },
  {
    title: 'Auditable Output',
    text: 'Each major operation reports created, injected, updated, skipped, or removed paths.',
  },
  {
    title: 'Versioned Docs',
    text: 'Documentation is versioned and published automatically to GitHub Pages from this repository.',
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
            Public, versioned documentation for Feature Slice Driven Architecture CLI.
            Learn the architecture, install quickly, and run production-safe command workflows.
          </p>
          <div className="heroCta">
            <Link className="button button--primary button--lg" to="/docs/overview">
              Start With Overview
            </Link>
            <Link className="button button--secondary button--lg" to="/docs/commands">
              Explore Commands
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
