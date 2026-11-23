import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {createHash} from 'node:crypto';
import {FileBlob,SpreadsheetFile} from '@oai/artifact-tool';

const root=path.resolve(process.env.LMX_DOCS_NEW_PARTS||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=path.resolve(process.env.LMX_REPORT_OUTPUT||'/tmp/lmx-statistics-20261122');
await fs.mkdir(output,{recursive:true});
const {highlightMinimums}=await import(pathToFileURL(path.join(root,'tools/report_minima.mjs')).href);
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
  const previews={};
  async function render(stage) {
    const range=stage==='before'?`A1:I${totalRow+5}`:`A1:J${totalRow+7}`;
    const image=await wb.render({sheetName,range,scale:1.3,format:'png'});
    const target=path.join(output,`${stem}.${stage}.png`);
    await fs.writeFile(target,new Uint8Array(await image.arrayBuffer()));
    previews[stage]=target;
  }
  await render('before');
  sh.getRange('F3').values=[['23 ноября 2026']];
  for(let i=0;i<rows.length;i++)sh.getRange(`B${7+i}:I${7+i}`).values=[languages.map(l=>rows[i].metrics[l].characters)];
  sh.getRange(`J6:J${totalRow}`).copyFrom(sh.getRange(`B6:B${totalRow}`),'all');
  sh.getRange('J:J').format.columnWidth=23;
  sh.getRange('J6').values=[['LMX без сложного Throws']];
  sh.getRange('J6').format.wrapText=true;
  sh.getRange('A6:J6').format.rowHeight=39;
  sh.getRange(`J7:J${totalRow-1}`).values=rows.map(row=>[row.metrics.LMX.without_complex_throws_characters]);
  sh.getRange(`J${totalRow}`).formulas=[[`=SUM(J7:J${totalRow-1})`]];
  sh.getRange(`J7:J${totalRow}`).setNumberFormat('0');
  sh.getRange(`J${totalRow+1}`).clear({applyTo:'all'});
  highlightMinimums(sh,{startRow:7,endRow:totalRow,full:'B',adjusted:'J',foreign:['C','D','E','F','G','H','I']});
  sh.getRange('A4:J4').merge();
  sh.getRange('A4').values=[['Непробельные символы. Основные отношения используют полные размеры. Зелёный — минимум строки.']];
  sh.getRange('A4:J4').format.wrapText=true;
  sh.getRange('A4:J4').format.rowHeight=28;
  const notes=[
    ['Итого / LMX: отношение сумм полных исходников. Значение больше 1 означает больший объём.',24],
    ['Зелёный: LMX без сложного Throws, если короче полного; при равенстве — полный LMX. Равные минимумы разных языков подсвечены вместе.',36],
    ['Явные Throws и copy(Throws) — преимущество LMX: видно, какие ошибки метод может бросить. Такие объявления не хочется сокращать.',36],
    ['Дополнительный счёт сохраняет заголовок и первый синтаксический аргумент Throws; copy и ссылки считаются целиком. Исходный код не изменён.',36],
    ['Источник: текущие *_comparison.md; нормы ../LMX_semantics.en.md. Единое ядро, кратчайший полный допустимый вариант.',24]
  ];
  for(let i=0;i<notes.length;i++){
    const row=totalRow+3+i;const range=sh.getRange(`A${row}:J${row}`);range.merge();
    sh.getRange(`A${row}`).values=[[notes[i][0]]];
    range.format.wrapText=true;range.format.rowHeight=notes[i][1];
    range.format.font={name:'Arial',size:10,color:'#526171'};
  }
  wb.recalculate();
  const sums=languages.map(l=>rows.reduce((n,x)=>n+x.metrics[l].characters,0));
  const actual=sh.getRange(`B${totalRow}:I${totalRow}`).values[0];
  if(actual.some((v,i)=>v!==sums[i]))throw Error(`${filename}: total mismatch`);
  const adjustedTotal=rows.reduce((n,row)=>n+row.metrics.LMX.without_complex_throws_characters,0);
  if(sh.getRange(`J${totalRow}`).values[0][0]!==adjustedTotal)throw Error(`${filename}: adjusted total mismatch`);
  const ratios=sh.getRange(`B${totalRow+1}:I${totalRow+1}`).values[0];
  if(ratios.some((v,i)=>Math.abs(v-sums[i]/sums[0])>1e-10))throw Error(`${filename}: ratio mismatch`);
  const firstValue=sh.getRange('B7').values[0][0];
  sh.getRange('B7').values=[[firstValue+13]];wb.recalculate();
  if(sh.getRange(`B${totalRow}`).values[0][0]!==sums[0]+13)throw Error(`${filename}: formula recalculation failed`);
  sh.getRange('B7').values=[[firstValue]];wb.recalculate();
  const firstAdjusted=sh.getRange('J7').values[0][0];
  sh.getRange('J7').values=[[firstAdjusted+17]];wb.recalculate();
  if(sh.getRange(`J${totalRow}`).values[0][0]!==adjustedTotal+17)throw Error(`${filename}: adjusted formula recalculation failed`);
  sh.getRange('J7').values=[[firstAdjusted]];wb.recalculate();
  if(sh.getRange(`J${totalRow}`).values[0][0]!==adjustedTotal)throw Error(`${filename}: adjusted total restore failed`);
  const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!',options:{useRegex:true,maxResults:20},maxChars:1800});
  await fs.writeFile(path.join(output,`${stem}.errors.ndjson`),errors.ndjson);
  await render('after');
  const saved=path.join(output,filename);await(await SpreadsheetFile.exportXlsx(wb)).save(saved);await fs.copyFile(saved,target);
  const sha256=createHash('sha256').update(await fs.readFile(target)).digest('hex');
  reports.push({file:filename,sheet:sheetName,records:rows.length,totals:sums,without_complex_throws_total:adjustedTotal,live_totals_verified:true,ratios_verified:true,recalculation_change_restore:true,adjusted_recalculation_change_restore:true,minimum_rules:'tools/report_minima.mjs; MIN over B:I and J; equal LMX pair chooses B; different-language ties retained',previews,sha256,visual_review:'PENDING'});
  console.log(JSON.stringify(reports.at(-1)));
}
await fs.writeFile(path.join(root,'validation/gof_workbook_validation_20261122.json'),JSON.stringify({date:'2026-11-23',engine:'@oai/artifact-tool',shared_minimum_rules:'tools/report_minima.mjs',files:reports},null,2)+'\n');
