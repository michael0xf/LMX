import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {FileBlob, SpreadsheetFile, Workbook} from '@oai/artifact-tool';

const root=path.resolve(process.env.LMX_EXAMPLES_ROOT||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=path.resolve(process.env.LMX_REPORT_OUTPUT||'/tmp/lmx-examples-20261123');
await fs.mkdir(output,{recursive:true});
const data=JSON.parse(await fs.readFile(path.join(root,'STATISTICS.json'),'utf8'));
const labels={complete_pair:'Полная пара',related_analogy:'Аналогия',lmx_only:'Только LMX'};
const {highlightMinimums}=await import(pathToFileURL(path.join(root,'../tools/report_minima.mjs')).href);
const reports=[];
const throwsNote='На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод; сокращать эти записи не хочется. «Без сложного Throws» сохраняет заголовок, первый написанный аргумент и полные ссылки copy. Зелёным отмечен минимум сопоставимой строки; при равных счётчиках LMX отмечается только полный.';
async function captureBefore(wb,target){
  const stem=path.basename(target,'.xlsx');
  for(const name of ['Обзор','Haskell','Julia','Perl','Примеры','Реализации']){
    let sh;try{sh=wb.worksheets.getItem(name);}catch{continue;}
    const preview=await wb.render({sheetName:sh.name,range:'A1:I20',scale:1,format:'png'});
    await fs.writeFile(path.join(output,stem+'_'+name+'.before.png'),new Uint8Array(await preview.arrayBuffer()));
  }
}

async function load(target){
  try{await fs.access(target);return await SpreadsheetFile.importXlsx(await FileBlob.load(target));}
  catch(e){if(e.code!=='ENOENT')throw e;return Workbook.create();}
}
function sheet(wb,name){
  try{const sh=wb.worksheets.getItem(name);sh.getRange('A1:P300').unmerge();sh.getRange('A1:P300').clear({applyTo:'contents'});return sh;}
  catch{return wb.worksheets.add(name);}
}
function column(n){let s='';for(n++;n;n=Math.floor((n-1)/26))s=String.fromCharCode(65+(n-1)%26)+s;return s;}
function base(sh,title,subtitle,headers,widths){
  const end=column(headers.length-1);
  sh.getRange("A1:P3").unmerge();
  sh.getRange(`A1:${end}2`).merge();sh.getRange('A1').values=[[title]];
  sh.getRange(`A1:${end}2`).format.fill='#18344C';sh.getRange(`A1:${end}2`).format.font.color='#FFFFFF';
  sh.getRange(`A1:${end}2`).format.font.bold=true;sh.getRange(`A1:${end}2`).format.font.size=20;
  sh.getRange('A1').format.verticalAlignment='center';
  sh.getRange(`A3:${end}3`).merge();sh.getRange('A3').values=[[subtitle]];
  sh.getRange(`A3:${end}3`).format.font.color='#53677B';sh.getRange(`A3:${end}3`).format.rowHeight=34;
  sh.getRange(`A3:${end}3`).format.wrapText=true;
  sh.getRange(`A5:${end}5`).values=[headers];
  sh.getRange(`A5:${end}5`).format.fill='#233D55';sh.getRange(`A5:${end}5`).format.font.color='#FFFFFF';
  sh.getRange(`A5:${end}5`).format.font.bold=true;sh.getRange(`A5:${end}5`).format.wrapText=true;
  sh.getRange(`A5:${end}5`).format.rowHeight=42;
  for(let i=0;i<widths.length;i++)sh.getRange(`${column(i)}:${column(i)}`).format.columnWidth=widths[i];
  sh.freezePanes.freezeRows(5);
  return end;
}
function body(sh,start,end,lastCol){
  if(end<start)return;
  sh.getRange(`A${start}:${lastCol}${end}`).format.font.name='Arial';
  sh.getRange(`A${start}:${lastCol}${end}`).format.font.size=11;
  sh.getRange(`A${start}:${lastCol}${end}`).format.verticalAlignment='center';
  sh.getRange(`A${start}:${lastCol}${end}`).format.wrapText=true;
  sh.getRange(`A${start}:${lastCol}${end}`).format.rowHeight=36;
  for(let r=start;r<=end;r++)sh.getRange(`A${r}:${lastCol}${r}`).format.fill=r%2?'#F0F3F6':'#FFFFFF';
}
function total(sh,row,end){sh.getRange(`A${row}:${end}${row}`).format.fill='#E3EBF1';sh.getRange(`A${row}:${end}${row}`).format.font.bold=true;sh.getRange(`A${row}:${end}${row}`).format.rowHeight=32;}
function cases(wb,name,suite){
  const sh=sheet(wb,name);const rows=data.examples.filter(x=>x.suite===suite);const language=rows[0].foreign_language;
  base(sh,`LMX / ${language}`,`${rows.length} сценария · 23 ноября 2026 · размер кода, не скорость`,
    ['ID','Сценарий','LMX\nсимволы',`${language}\nсимволы`,'Контроль /\nLMX','LMX\nстроки',`${language}\nстроки`,'Граница','без сложного\nThrows'],[10,56,14,15,16,13,14,20,21]);
  for(let i=0;i<rows.length;i++){
    const x=rows[i],r=6+i;
    sh.getRange(`A${r}:D${r}`).values=[[x.id,x.title,x.lmx.characters,x.foreign?.characters??null]];
    if(x.comparison_status==='complete_pair')sh.getRange(`E${r}`).formulas=[[`=D${r}/C${r}`]];
    sh.getRange(`F${r}:I${r}`).values=[[x.lmx.nonblank_lines,x.foreign?.nonblank_lines??null,labels[x.comparison_status],x.lmx.without_complex_throws_characters]];
  }
  const t=6+rows.length;body(sh,6,t-1,'I');sh.getRange(`A${t}:B${t}`).merge();sh.getRange(`A${t}`).values=[['Итого: только полные пары']];
  for(const c of ['C','D','F','G','I'])sh.getRange(`${c}${t}`).formulas=[[`=SUMIF(H6:H${t-1},"Полная пара",${c}6:${c}${t-1})`]];
  sh.getRange(`E${t}`).formulas=[[`=IF(C${t}=0,"",D${t}/C${t})`]];
  sh.getRange(`C6:D${t}`).setNumberFormat('#,##0');sh.getRange(`F6:G${t}`).setNumberFormat('#,##0');sh.getRange(`E6:E${t}`).setNumberFormat('0.000"×"');
  total(sh,t,'I');sh.getRange(`I6:I${t}`).setNumberFormat('#,##0');
  sh.getRange(`A${t+2}:I${t+6}`).merge();sh.getRange(`A${t+2}`).values=[['Непробельные Unicode-символы и непустые строки. Альтернативы и реализации считаются отдельно. Аналогии не входят в коэффициенты; отсутствие пары не равно нулю. '+throwsNote]];sh.getRange(`A${t+2}:I${t+6}`).format={wrapText:true,verticalAlignment:'center',font:{name:'Arial',size:11,color:'#526575'}};
  highlightMinimums(sh,{startRow:6,endRow:t,full:'C',adjusted:'I',foreign:['D'],eligible:`OR($H6="Полная пара",ROW()=${t})`});
  return {sh,rows,totalRow:t,endRow:t+6,language,suite};
}
function impl(wb,name,rows){
  const sh=sheet(wb,name);
  base(sh,'Сравнение реализаций','Полные указанные тела; общие зависимости могут пересекаться между строками.',
    ['Набор','ID','Операции','LMX\nсимволы','Контроль\nсимволы','LMX\nстроки','Контроль\nстроки','без сложного\nThrows'],[15,13,64,16,16,15,16,21]);
  for(let i=0;i<rows.length;i++){
    const x=rows[i],r=6+i;
    sh.getRange(`A${r}:H${r}`).values=[[x.foreign_language,x.id,x.title,x.lmx.characters,x.foreign.characters,x.lmx.nonblank_lines,x.foreign.nonblank_lines,x.lmx.without_complex_throws_characters]];
  }
  body(sh,6,5+rows.length,'H');sh.getRange(`D6:H${Math.max(6,5+rows.length)}`).setNumberFormat('#,##0');
  const n=7+rows.length;sh.getRange(`A${n}:H${n+5}`).merge();sh.getRange(`A${n}`).values=[['Эта таблица не складывается с каждым клиентом. Общие LMX-определения учитываются один раз в конкретном приложении. Иностранные клиенты используют реальные библиотеки, а не эти сравниваемые модули. '+throwsNote]];sh.getRange(`A${n}:H${n+5}`).format={wrapText:true,verticalAlignment:'center',font:{name:'Arial',size:11,color:'#526575'}};
  highlightMinimums(sh,{startRow:6,endRow:5+rows.length,full:'D',adjusted:'H',foreign:['E']});
  return {sh,endRow:n+5,endColumn:'H'};
}
function overview(wb,views){
  const sh=sheet(wb,'Обзор');
  base(sh,'LMX: вся директория examples','23 ноября 2026 · 24 исходных сценария + Julia + Perl + SBCL · разные наборы не образуют рейтинг языков',
    ['Набор','Сценарии','Полные пары','LMX в парах','Контроль в парах','Контроль / LMX','Аналогии','Только LMX','без сложного\nThrows (пары)'],[17,16,18,20,22,22,17,17,22]);
  for(let i=0;i<views.length;i++){
    const v=views[i],s=data.summaries.find(x=>x.suite===v.suite),r=6+i,t=v.totalRow;
    sh.getRange(`A${r}:C${r}`).values=[[v.language,s.examples,s.complete_pairs]];
    sh.getRange(`D${r}:F${r}`).formulas=[[`='${v.sh.name}'!C${t}`,`='${v.sh.name}'!D${t}`,`=IF(D${r}=0,"",E${r}/D${r})`]];
    sh.getRange(`G${r}:H${r}`).values=[[s.related_analogies,s.lmx_only]];
    sh.getRange(`I${r}`).formulas=[[`='${v.sh.name}'!I${t}`]];
  }
  const last=5+views.length;body(sh,6,last,'I');sh.getRange(`B6:E${last}`).setNumberFormat('#,##0');sh.getRange(`I6:I${last}`).setNumberFormat('#,##0');sh.getRange(`F6:F${last}`).setNumberFormat('0.000"×"');
  sh.getRange('A11:H14').merge();sh.getRange('A11').values=[['Сравниваются одинаковые наблюдаемые задачи. Различие архитектуры само по себе не требует её имитации в другом языке. Частичная аналогия явно отмечена и не участвует в коэффициентах. Клиентские размеры и сравнения реализации ядра разделены.']];sh.getRange('A11:H14').format.wrapText=true;
  sh.getRange('A16:H18').merge();sh.getRange('A16').values=[['Источник: examples/STATISTICS.json и исходные наборы. Основная метрика включает комментарии внутри выбранного листинга. Runtime LMX не запускался; выполненные foreign-проверки указаны отдельно в validation.']];sh.getRange('A16:H18').format.wrapText=true;
  sh.getRange('A20:I24').merge();sh.getRange('A20').values=[[throwsNote+' Исходники и основные отношения не меняются.']];sh.getRange('A20:I24').format.wrapText=true;
  highlightMinimums(sh,{startRow:6,endRow:last,full:'D',adjusted:'I',foreign:['E']});
  return {sh,endRow:24,endColumn:'I'};
}
async function finish(wb,target,views,extras){
  wb.recalculate();
  for(const v of views){
    const expected=data.summaries.find(x=>x.suite===v.suite),actual=v.sh.getRange(`C${v.totalRow}:E${v.totalRow}`).values[0];
    if(actual[0]!==expected.paired_lmx_characters||actual[1]!==expected.paired_foreign_characters)throw Error(`${target}: total mismatch for ${v.suite}: ${JSON.stringify(actual)}`);
    if(v.sh.getRange(`I${v.totalRow}`).values[0][0]!==expected.paired_lmx_without_complex_throws_characters)throw Error('Supplementary Throws total mismatch');
    if(expected.paired_ratio!==null&&Math.abs(actual[2]-expected.paired_ratio)>1e-10)throw Error('Ratio mismatch');
    const at=v.rows.findIndex(x=>x.comparison_status==='complete_pair');
    if(at>=0){const cell=`C${6+at}`,old=v.sh.getRange(cell).values[0][0];v.sh.getRange(cell).values=[[old+11]];wb.recalculate();
      if(v.sh.getRange(`C${v.totalRow}`).values[0][0]!==expected.paired_lmx_characters+11)throw Error('Recalculation failed');
      v.sh.getRange(cell).values=[[old]];wb.recalculate();}
  }
  const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!',options:{useRegex:true,maxResults:30},maxChars:3000});
  const stem=path.basename(target,'.xlsx');await fs.writeFile(path.join(output,stem+'.errors.ndjson'),errors.ndjson);
  const renders=[];
  for(const v of [...views.map(v=>({...v,endColumn:'I'})),...extras]){
    const values=v.sh.getRange(`A1:${v.endColumn}${v.endRow}`).values;
    if(values.flat().some(x=>typeof x==='string'&&/^#(?:REF!|DIV\/0!|VALUE!|NAME\?|N\/A|NUM!|NULL!)/.test(x)))throw Error('Formula error found');
    const img=await wb.render({sheetName:v.sh.name,range:`A1:${v.endColumn}${v.endRow}`,scale:1,format:'png'});
    const imagePath=path.join(output,stem+'_'+v.sh.name+'.after.png');await fs.writeFile(imagePath,new Uint8Array(await img.arrayBuffer()));renders.push(imagePath);
  }
  const saved=path.join(output,path.basename(target));await(await SpreadsheetFile.exportXlsx(wb)).save(saved);await fs.copyFile(saved,target);
  const report={file:path.relative(root,target),sheets:[...views,...extras].map(v=>v.sh.name),live_totals_verified:true,ratios_verified:true,recalculation_change_restore:true,formula_errors:0,renders};reports.push(report);console.log(JSON.stringify(report));
}

if(process.env.LMX_WORKBOOK_MODE==='inspect'){
  for(const target of [path.join(root,'STATISTICS.xlsx'),path.join(root,'julia_comparison','LMX_Comparison_Julia.xlsx'),path.join(root,'perl_comparison','LMX_Comparison_Perl.xlsx')]){
    const workbook=await load(target);await captureBefore(workbook,target);
    const check=await workbook.inspect({kind:'sheet',include:'id,name',maxChars:1500});
    console.log(JSON.stringify({file:target,sheets:check.ndjson}));
  }
  process.exit(0);
}

const target=path.join(root,'STATISTICS.xlsx');const wb=await load(target);await captureBefore(wb,target);
// Add overview first for convenient opening; formula targets are filled below.
sheet(wb,'Обзор');const views=['haskell','julia','perl','sbcl'].map(s=>cases(wb,{haskell:'Haskell',julia:'Julia',perl:'Perl',sbcl:'SBCL'}[s],s));
const ov=overview(wb,views),im=impl(wb,'Реализации',data.implementations);await finish(wb,target,views,[ov,im]);
for(const [suite,language] of [['julia','Julia'],['perl','Perl']]){
  const target=path.join(root,suite+'_comparison','LMX_Comparison_'+language+'.xlsx');const wb=await load(target);await captureBefore(wb,target);
  const view=cases(wb,'Примеры',suite),implementations=impl(wb,'Реализации',data.implementations.filter(x=>x.suite===suite));await finish(wb,target,[view],[implementations]);
}
await fs.writeFile(path.join(root,'validation/workbook_validation_20261123.json'),JSON.stringify({edition:'2026-11-23',engine:'@oai/artifact-tool',files:reports},null,2)+'\n');
