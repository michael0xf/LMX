import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {FileBlob,SpreadsheetFile} from '@oai/artifact-tool';

const root=path.resolve(process.env.LMX_DOCS_NEW_PARTS||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=path.resolve(process.env.LMX_REPORT_OUTPUT||'/tmp/lmx-statistics-20261122');
await fs.mkdir(output,{recursive:true});
const stats=JSON.parse(await fs.readFile(path.join(root,'validation/gof_statistics_20261122.json'),'utf8'));
const languages=['LMX','Python','Java','C++','C#','TypeScript','Go','Rust'];
const reports=[];
for (const [filename,sheetName,first,last] of [
  ['LMX_Comparison_2026-11-20.xlsx','Сравнение',1,9],
  ['LMX_Comparison_10-18.xlsx','Шаблоны 10–18',10,18],
  ['LMX_Comparison_19-23.xlsx','Шаблоны 19–23',19,23],
]) {
  const target=path.join(root,filename);
  const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(target));
  const sh=wb.worksheets.getItem(sheetName);
  const rows=stats.records.filter(x=>x.id>=first&&x.id<=last);
  const totalRow=7+rows.length;
  const stem=filename.replace('.xlsx','');
  async function render(stage) {
    const image=await wb.render({sheetName,range:`A1:I${totalRow+5}`,scale:1,format:'png'});
    await fs.writeFile(path.join(output,`${stem}.${stage}.png`),new Uint8Array(await image.arrayBuffer()));
  }
  await render('before');
  sh.getRange('F3').values=[['22 ноября 2026']];
  for(let i=0;i<rows.length;i++)sh.getRange(`B${7+i}:I${7+i}`).values=[languages.map(l=>rows[i].metrics[l].characters)];
  sh.getRange(`A${totalRow+4}`).values=[['Единое ядро; из корректных вариантов основным выбран более короткий.']];
  sh.getRange(`A${totalRow+5}`).values=[['Источник: текущие *_comparison.md; нормы ../LMX_semantics.en.md.']];
  wb.recalculate();
  const sums=languages.map(l=>rows.reduce((n,x)=>n+x.metrics[l].characters,0));
  const actual=sh.getRange(`B${totalRow}:I${totalRow}`).values[0];
  if(actual.some((v,i)=>v!==sums[i]))throw Error(`${filename}: total mismatch`);
  const ratios=sh.getRange(`B${totalRow+1}:I${totalRow+1}`).values[0];
  if(ratios.some((v,i)=>Math.abs(v-sums[i]/sums[0])>1e-10))throw Error(`${filename}: ratio mismatch`);
  const firstValue=sh.getRange('B7').values[0][0];
  sh.getRange('B7').values=[[firstValue+13]];wb.recalculate();
  if(sh.getRange(`B${totalRow}`).values[0][0]!==sums[0]+13)throw Error(`${filename}: formula recalculation failed`);
  sh.getRange('B7').values=[[firstValue]];wb.recalculate();
  const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!',options:{useRegex:true,maxResults:20},maxChars:1800});
  await fs.writeFile(path.join(output,`${stem}.errors.ndjson`),errors.ndjson);
  await render('after');
  const saved=path.join(output,filename);await(await SpreadsheetFile.exportXlsx(wb)).save(saved);await fs.copyFile(saved,target);
  reports.push({file:filename,records:rows.length,totals:sums,live_totals_verified:true,ratios_verified:true,recalculation_change_restore:true});
  console.log(JSON.stringify(reports.at(-1)));
}
await fs.writeFile(path.join(root,'validation/gof_workbook_validation_20261122.json'),JSON.stringify({date:'2026-11-22',engine:'@oai/artifact-tool',files:reports},null,2)+'\n');
