import path from 'node:path';
import {fileURLToPath} from 'node:url';
const examples=path.resolve(process.env.LMX_EXAMPLES_ROOT||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
process.env.LMX_DOCS_NEW_PARTS=path.dirname(examples);
process.env.LMX_PUBLICATION_FILTER='examples/';
process.argv=process.argv.slice(0,2);
await import('../../tools/publish_workbooks.mjs');
