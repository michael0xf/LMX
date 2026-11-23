import path from 'node:path';
import fs from 'node:fs/promises';
import {fileURLToPath} from 'node:url';
const root=path.resolve(process.env.LMX_DOCS_NEW_PARTS||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const mode=process.argv[2]||'inspect';
if(mode==='inspect'){
  const {FileBlob,SpreadsheetFile}=await import('@oai/artifact-tool');
  const entries=(await fs.readdir(root,{withFileTypes:true})).filter(x=>x.isDirectory()&&/^0[1-9]_/.test(x.name));
  for(const entry of entries){
    const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(path.join(root,entry.name,'LMX_Comparison_'+entry.name+'.xlsx')));
    const result=await wb.inspect({kind:'region',sheetId:'Сравнение',range:'A1:L20',maxChars:2000,tableMaxRows:8});
    console.log(JSON.stringify({group:entry.name,inspection:result.ndjson}));
  }
}else{
  process.env.LMX_DOCS_NEW_PARTS=root;
  process.env.LMX_PUBLICATION_FILTER=mode==='summary'?'STATISTICS_2026-11-22':'re:^(0[1-9]_|STATISTICS_2026-11-22)';
  process.argv=process.argv.slice(0,2);
  await import('./publish_workbooks.mjs');
}
