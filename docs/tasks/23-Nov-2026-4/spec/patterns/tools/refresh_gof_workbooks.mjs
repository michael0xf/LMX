// Current GoF publication: full source counts and green minimum cells.
process.env.LMX_PUBLICATION_FILTER='re:^LMX_Comparison_';
process.argv=process.argv.slice(0,2);
await import('./publish_workbooks.mjs');
