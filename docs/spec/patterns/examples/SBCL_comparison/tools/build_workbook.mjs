import path from 'node:path';
import fs from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
const root=path.resolve(process.argv[2]||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=process.argv[3]?path.resolve(process.argv[3]):null;
process.env.LMX_DOCS_NEW_PARTS=path.resolve(root,'../..');
process.env.LMX_PUBLICATION_FILTER='examples/SBCL_comparison/';
if(output)process.env.LMX_REPORT_OUTPUT=output;
process.argv=process.argv.slice(0,2);
await import('../../../tools/publish_workbooks.mjs');
if(output){await fs.mkdir(output,{recursive:true});await fs.copyFile(path.join(root,'LMX_Comparison_SBCL.xlsx'),path.join(output,'LMX_Comparison_SBCL.xlsx'));}
