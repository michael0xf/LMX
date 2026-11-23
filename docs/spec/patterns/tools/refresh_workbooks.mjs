import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath,pathToFileURL} from 'node:url';
import { FileBlob, SpreadsheetFile, Workbook } from '@oai/artifact-tool';

const root = path.resolve(process.env.LMX_DOCS_NEW_PARTS || path.join(path.dirname(fileURLToPath(import.meta.url)), '..'));
const {highlightMinimums}=await import(pathToFileURL(path.join(root,'tools/report_minima.mjs')).href);
const statistics=JSON.parse(await fs.readFile(path.join(root,'validation/statistics_20261122.json'),'utf8'));
const outputDir = path.resolve(process.env.LMX_REPORT_OUTPUT || path.join('/tmp', 'lmx-statistics-20261122'));
const mode = process.argv[2] || 'inspect';
const throwsNote='На мой взгляд, явные Throws — преимущество LMX: предельно ясно, какие ошибки может породить метод; сокращать эти записи не хочется. Дополнительная колонка сохраняет заголовок, первый написанный аргумент и полные ссылки copy. Зелёным отмечен минимум сопоставимой строки; при равных счётчиках LMX отмечается только полный.';
const selected = process.argv.slice(3);
await fs.mkdir(outputDir, {recursive:true});
const groups = (await fs.readdir(root,{withFileTypes:true})).filter(x => mode !== 'summary' && x.isDirectory() && /^\d\d_/.test(x.name) && (!selected.length || selected.includes(x.name))).map(x=>x.name).sort();
const reports = mode === 'summary' || (mode !== 'inspect' && selected.length)
  ? JSON.parse(await fs.readFile(path.join(root,'validation','workbook_validation_20261122.json'),'utf8')).groups.filter(x=>!groups.includes(x.group))
  : [];
for (const group of groups) {
  const target = path.join(root,group,`LMX_Comparison_${group}.xlsx`);
  const data = JSON.parse(await fs.readFile(path.join(root,group,'patterns.json'),'utf8'));
  const wb = await SpreadsheetFile.importXlsx(await FileBlob.load(target));
  const sh = wb.worksheets.getItem('Сравнение');
  if(mode === 'inspect') {
    const overview = await wb.inspect({kind:'region',sheetId:sh.name,range:'A1:M24',maxChars:4000,tableMaxRows:4,tableMaxCols:6});
    await fs.writeFile(path.join(outputDir,group+'.before.ndjson'),overview.ndjson);
    const preview = await wb.render({sheetName:sh.name,range:'A1:K20',scale:1,format:'png'});
    await fs.writeFile(path.join(outputDir,group+'.before.png'),new Uint8Array(await preview.arrayBuffer()));
    console.log(JSON.stringify({group,phase:'before',preview:path.join(outputDir,group+'.before.png')}));
    continue;
  }
  const before = await wb.render({sheetName:sh.name,range:'A1:K20',scale:1,format:'png'});
  await fs.writeFile(path.join(outputDir,group+'.before.png'),new Uint8Array(await before.arrayBuffer()));
  const patterns = [...data.patterns].sort((a,b) => (a.paired_with||a.id)-(b.paired_with||b.id) || (a.kind==='implementation')-(b.kind==='implementation') || a.id-b.id);
  const langs=['LMX',...data.languages];
  sh.getRange('B3').values=[[`${langs.join(' / ')}; 2026-11-23`]];
  sh.getRange('B4').values=[['Основной — сопоставимый клиент или реализация; разные подходы показаны отдельно.']];
  sh.getRange('L6').copyFrom(sh.getRange('D6'),'all');sh.getRange('L6').values=[['без сложного\nThrows']];sh.getRange('L:L').format.columnWidth=22;
  const cells=[];
  for(let i=0;i<patterns.length;i++) {
    const p=patterns[i], row=7+i;
    const counts=p.listings.map(l=>{
      const code=l.code.trim()+'\n';
      return {chars:[...code].filter(x=>!(/\s/u.test(x))).length,lines:code.split(/\r?\n/).filter(x=>x.trim()).length,bytes:Buffer.byteLength(code,'utf8')};
    });
    sh.getRange(`A${row}:I${row}`).values=[[p.id,p.name,p.kind==='implementation'?'реализация':p.implementation_ids?.length?'использование':'ядро',...counts.map(x=>x.chars),...counts.map(x=>x.lines)]];
    const adjusted=p.listings.find(x=>x.language==='LMX').metrics.without_complex_throws_characters;
    sh.getRange(`L${row}`).values=[[adjusted]];sh.getRange(`L${row}`).format={font:{name:'Arial',size:11,color:'#20364A'},fill:row%2?'#FFFFFF':'#F0F3F6',verticalAlignment:'center'};
    cells.push({id:p.id,row,expected:counts,adjusted});
  }
  const lastData=6+patterns.length;
  for(let r=lastData+1;r<=lastData+2;r++){
    const label=String(sh.getRange(`B${r}`).values[0][0]??'');
    if(/реализ/i.test(label))sh.getRange(`L${r}`).formulas=[[`=SUMIFS(L7:L${lastData},C7:C${lastData},"реализация")`]];
    else if(/основ|сценар/i.test(label))sh.getRange(`L${r}`).formulas=[[`=SUMIFS(L7:L${lastData},C7:C${lastData},"<>реализация")`]];
    else if(/всего/i.test(label))sh.getRange(`L${r}`).formulas=[[`=SUM(L7:L${lastData})`]];
    sh.getRange(`L${r}`).format={fill:'#E3EBF1',font:{bold:true}};
  }
  sh.getRange(`L7:L${lastData+2}`).setNumberFormat('#,##0');
  sh.getRange(`B${lastData+5}:L${lastData+8}`).unmerge();
  sh.getRange(`B${lastData+5}:L${lastData+8}`).merge();
  sh.getRange(`B${lastData+5}`).values=[[throwsNote]];
  sh.getRange(`B${lastData+5}:L${lastData+8}`).format={wrapText:true,verticalAlignment:'center',font:{name:'Arial',size:11,color:'#526575'}};
  highlightMinimums(sh,{startRow:7,endRow:lastData+2,full:'D',adjusted:'L',foreign:['E','F'],eligible:'$D7>0'});
  wb.recalculate();
  for(const item of cells) {
    const values=sh.getRange(`D${item.row}:K${item.row}`).values[0];
    for(let j=0;j<3;j++) if(values[j]!==item.expected[j].chars || values[j+3]!==item.expected[j].lines) throw Error(`Metric mismatch ${group}/${item.id}/${j}`);
    if(sh.getRange(`L${item.row}`).values[0][0]!==item.adjusted)throw Error('Supplementary metric mismatch');
    const a=item.expected[0].chars,b=item.expected[1].chars,c=item.expected[2].chars;
    if(Math.abs(values[6]-a/b)>1e-10 || Math.abs(values[7]-a/c)>1e-10)throw Error(`Ratio mismatch ${group}/${item.id}`);
  }
  // Verify existing live formulas by changing a source count and restoring it.
  const original=sh.getRange('D7').values[0][0];
  sh.getRange('D7').values=[[original+17]];
  wb.recalculate();
  if(Math.abs(sh.getRange('J7').values[0][0]-(original+17)/sh.getRange('E7').values[0][0])>1e-10)throw Error(`Recalculation failed ${group}`);
  sh.getRange('D7').values=[[original]];
  wb.recalculate();
  const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:30},maxChars:2500});
  await fs.writeFile(path.join(outputDir,group+'.errors.ndjson'),errors.ndjson);
  const last=lastData+8;
  const preview=await wb.render({sheetName:sh.name,range:`A1:L${last}`,scale:1,format:'png'});
  await fs.writeFile(path.join(outputDir,group+'.after.png'),new Uint8Array(await preview.arrayBuffer()));
  const saved=path.join(outputDir,`LMX_Comparison_${group}.xlsx`);
  await (await SpreadsheetFile.exportXlsx(wb)).save(saved);
  await fs.copyFile(saved,target);
  reports.push({group,records:patterns.length,counts_verified:true,ratios_verified:true,recalculation_change_restore:true,export:saved});
  console.log(JSON.stringify(reports.at(-1)));
}
if(mode!=='inspect') {
  const stats=JSON.parse(await fs.readFile(path.join(root,'validation','statistics_20261122.json'),'utf8'));
  const wb=await SpreadsheetFile.importXlsx(await FileBlob.load(path.join(root,'STATISTICS_2026-11-22.xlsx')));
  const sh=wb.worksheets.getItem('Группы');
  const ex=wb.worksheets.getItem('Примеры');
  const gf=wb.worksheets.getItem('GoF');
  const variants=wb.worksheets.getItem('Варианты');
  for(const sheet of [sh,ex,gf,variants]){sheet.getUsedRange().unmerge();sheet.getUsedRange().clear({applyTo:'contents'});}
  function note(s,start,lastCol) {
    const end=start+3;
    s.getRange(`A${start}:${lastCol}${end}`).merge();
    s.getRange(`A${start}`).values=[[throwsNote]];
    s.getRange(`A${start}:${lastCol}${end}`).format={wrapText:true,verticalAlignment:'center',font:{name:'Arial',size:10,color:'#526575'}};
    return end;
  }
  function base(s,title,subtitle,end,widths) {
    s.showGridLines=false;
    s.getRange(`A1:${end}45`).format.font={name:'Arial',size:10,color:'#20364A'};
    s.getRange('A2').values=[[title]];
    s.getRange('A2').format.font={name:'Arial',size:15,bold:true,color:'#17344C'};
    s.getRange('A3').values=[[subtitle]];
    s.getRange('A3').format.font={name:'Arial',size:10,italic:true,color:'#526575'};
    widths.forEach((width,i)=>s.getRange(`${String.fromCharCode(65+i)}1:${String.fromCharCode(65+i)}45`).format.columnWidth=width);
    s.getRange(`A5:${end}5`).format={fill:'#233D55',font:{name:'Arial',size:10,bold:true,color:'#FFFFFF'},rowHeight:38,wrapText:true,horizontalAlignment:'center',verticalAlignment:'center'};
    s.freezePanes.freezeRows(5);
  }
  base(sh,'Статистика LMX: группы сравнений','23 ноября 2026. Основные листинги; сохранённые альтернативы исключены.','K',[42,23,10,14,15,14,15,14,14,14,22]);
  sh.getRange('A5:K5').values=[['Группа','Слой','Сравнения','LMX\nсимволы','Контроль 1','Символы','Контроль 2','Символы','LMX /\nконтроль 1','LMX /\nконтроль 2','без сложного\nThrows']];
  let row=6;
  for(const g of stats.groups)for(const layer of ['scenario','usage','shared_implementation_client','implementation']) {
    const n=g.records.filter(x=>x.layer===layer).length;if(!n)continue;
    const t=g.totals[layer],a=g.languages[1],b=g.languages[2];
    sh.getRange(`A${row}:H${row}`).values=[[g.title,{scenario:'Сценарии',usage:'Клиенты библиотек',shared_implementation_client:'Клиенты общего тела',implementation:'Реализации'}[layer],n,t.LMX.characters,a,t[a].characters,b,t[b].characters]];
    sh.getRange(`I${row}:J${row}`).formulas=[[`=D${row}/F${row}`,`=D${row}/H${row}`]];
    sh.getRange(`K${row}`).values=[[t.LMX.without_complex_throws_characters]];
    row++;
  }
  const end=row-1;
  sh.getRange(`K6:K${end}`).setNumberFormat('#,##0');
  highlightMinimums(sh,{startRow:6,endRow:end,full:'D',adjusted:'K',foreign:['F','H']});
  sh.getRange(`A6:J${end}`).format.rowHeight=38;
  sh.getRange(`A6:B${end}`).format.wrapText=true;
  sh.getRange(`C6:D${end}`).setNumberFormat('#,##0');sh.getRange(`F6:F${end}`).setNumberFormat('#,##0');sh.getRange(`H6:H${end}`).setNumberFormat('#,##0');
  sh.getRange(`I6:J${end}`).setNumberFormat('0.00"x"');
  for(const c of ['E','G'])sh.getRange(`${c}6:${c}${end}`).format.horizontalAlignment='center';
  sh.getRange(`A${row+1}:B${row+1}`).values=[['Всего сравнений','']];
  sh.getRange(`C${row+1}`).formulas=[[`=SUM(C6:C${end})`]];
  sh.getRange(`A${row+1}:J${row+1}`).format={fill:'#E3EBF1',font:{bold:true},rowHeight:25};
  sh.getRange(`A${row+3}`).values=[['Суммарный рейтинг языков по разным группам не строится.']];
  sh.getRange(`A${row+4}`).values=[['Источники: patterns.json каждой группы; validation/statistics_20261122.json.']];
  sh.getRange(`A${row+6}`).values=[['Функциональные компоненты: общие определения без повторного счёта']];
  const shared=stats.functional_library_dependencies.unique_required_total;
  sh.getRange(`A${row+7}:D${row+7}`).values=[['LMX-зависимости, символы',shared.characters,'Непустые строки',shared.lines]];
  sh.getRange(`E${row+7}:F${row+7}`).values=[['Без сложного Throws',shared.without_complex_throws_characters]];
  sh.getRange(`E${row+7}`).format.wrapText=true;
  sh.getRange(`A${row+8}:D${row+8}`).values=[['Публичные имена',stats.receiver_library.public_receivers,'Запуск LMX','Не проводился']];
  sh.getRange(`B${row+7}:B${row+8}`).format.horizontalAlignment='center';
  const shLast=note(sh,row+10,'K');
  base(ex,'Исходные 24 примера: изменения','До — загруженный spec.tar.gz; после — текущий основной. Выбор пары см. на листе «Варианты».','I',[11,16,16,15,15,15,15,18,38]);
  ex.getRange('J5').values=[['без сложного\nThrows (после)']];ex.getRange('J5').format={fill:'#233D55',font:{bold:true,color:'#FFFFFF'},wrapText:true};ex.getRange('J:J').format.columnWidth=23;
  ex.getRange('A5:I5').values=[['Пример','Символы\nдо','Символы\nпосле','Изменение','Строки\nдо','Строки\nпосле','Изменение','Другой подход','Исходник']];
  const ers=stats.functional_receiver_counts.rows;
  for(let i=0;i<ers.length;i++) {
    const x=ers[i],r=6+i;
    ex.getRange(`A${r}:C${r}`).values=[[x.id,x.before.characters,x.after.characters]];
    ex.getRange(`J${r}`).values=[[x.after.without_complex_throws_characters]];
    ex.getRange(`D${r}`).formulas=[[`=C${r}-B${r}`]];
    ex.getRange(`E${r}:F${r}`).values=[[x.before.nonblank_lines,x.after.nonblank_lines]];
    ex.getRange(`G${r}`).formulas=[[`=F${r}-E${r}`]];
    ex.getRange(`H${r}:I${r}`).values=[[x.has_alternative||x.archived_inline?'Да':x.changed?'Клиент сохранён':'Без изменений','examples/'+x.file]];
  }
  const et=6+ers.length;
  ex.getRange(`A${et}`).values=[['Итого']];
  for(const c of ['B','C','D','E','F','G','J'])ex.getRange(`${c}${et}`).formulas=[[`=SUM(${c}6:${c}${et-1})`]];
  ex.getRange(`A6:I${et}`).format.rowHeight=24;ex.getRange(`B6:G${et}`).setNumberFormat('#,##0');
  ex.getRange(`H6:H${et-1}`).format.horizontalAlignment='center';
  ex.getRange(`A${et}:I${et}`).format.fill='#E3EBF1';ex.getRange(`A${et}:I${et}`).format.font.bold=true;
  ex.getRange(`A${et+2}`).values=[['Источник: examples/validation/functional_receiver_counts.json.']];
  ex.getRange(`J6:J${et}`).setNumberFormat('#,##0');ex.getRange(`J${et}`).format={fill:'#E3EBF1',font:{bold:true}};
  const exLast=note(ex,et+4,'J');
  base(gf,'Подборка GoF','23 сравнения, 184 основных листинга; пересчитано по текущим исходникам.','D',[22,22,61,23]);
  gf.getRange('A5:D5').values=[['Язык','Непробельные символы','Источник','без сложного\nThrows']];
  let gr=6;
  for(const [lang,total] of Object.entries(stats.gof.total_characters))gf.getRange(`A${gr}:D${gr++}`).values=[[lang,total,'23 корневых *_comparison.md',lang==='LMX'?stats.gof.total_without_complex_throws_characters:null]];
  const gl=6+Object.keys(stats.gof.total_characters).indexOf('LMX');const green={fill:'#D9EEDB',font:{color:'#155B29',bold:true}};
  gf.getRange(`B6:B${gr-1}`).conditionalFormats.deleteAll();
  gf.getRange(`D${gl}`).conditionalFormats.deleteAll();
  gf.getRange(`B6:B${gr-1}`).conditionalFormats.addCustom(`=AND(B6=MIN($B$6:$B$${gr-1},$D$${gl}),OR(ROW()<>${gl},B6<=$D$${gl}))`,green);
  gf.getRange(`D${gl}`).conditionalFormats.addCustom(`=AND(D${gl}<B${gl},D${gl}=MIN($B$6:$B$${gr-1},D${gl}))`,green);
  gf.getRange(`A6:C${gr-1}`).format.rowHeight=25;gf.getRange(`B6:B${gr-1}`).setNumberFormat('#,##0');
  gf.getRange(`B6:B${gr-1}`).format.horizontalAlignment='center';
  gf.getRange('A16').values=[['Метрики описывают приведённый код, не скорость языка.']];
  gf.getRange(`D${gl}`).setNumberFormat('#,##0');
  const gfLast=note(gf,18,'D');
  base(variants,'Основные и сохранённые варианты LMX','Минимум среди корректных вариантов с сопоставимой границей; единое ядро.','H',[13,21,18,18,20,72,22,22]);
  variants.getRange('A5:H5').values=[['Пример','Основной','Основной,\nсимволы','Второй,\nсимволы','Второй\nсопоставим','Договор и граница сравнения','без сложного\nThrows (основной)','без сложного\nThrows (второй)']];
  let vr=6;
  for(const x of ers.filter(x=>x.has_alternative)) {
    const a=x.selected_variant,b=x.alternative_variant,allowed=x.eligible_variants||Object.keys(x.variants);
    const note=x.fairness_note||'Оба варианта сохраняют один договор; выбран более короткий.';
    variants.getRange(`A${vr}:H${vr}`).values=[[x.id,a,x.variants[a].characters,x.variants[b].characters,allowed.includes(b)?'Да':'Нет',note,x.variants[a].without_complex_throws_characters,x.variants[b].without_complex_throws_characters]];
    variants.getRange(`A${vr}:F${vr}`).format={wrapText:true,rowHeight:Math.max(36,14*Math.ceil(note.length/75)+14),verticalAlignment:'center'};
    vr++;
  }
  const functional=JSON.parse(await fs.readFile(path.join(root,'09_functional_computation/patterns.json'),'utf8'));
  for(const x of functional.patterns) {
    const active=x.listings.find(l=>l.language==='LMX').code;
    const count=s=>[...s].filter(c=>!(/\s/u.test(c))).length;
    const selectedName=x.primary_variant?.LMX||'core',choices=x.variants?.LMX||{},eligible=x.eligible_variants?.LMX||[];
    for(const name of Object.keys(choices).filter(n=>n!==selectedName)) {
      const note=x.id===84?'Полные bracket и Around одного договора. Основной выбран по меньшему полному размеру; приоритета ядра нет.':`Разные способы: ${selectedName} / ${name}. Поля, эффекты и результат сохранены.`;
      const own=x.listings.find(l=>l.language==='LMX').metrics.without_complex_throws_characters;
      const variantRecord=(statistics.throws_variant_metrics||[]).find(v=>v.id===x.id&&v.variant===name);
      variants.getRange(`A${vr}:H${vr}`).values=[[String(x.id).padStart(3,'0'),selectedName,count(active),count(choices[name]),eligible.includes(name)?'Да':'Нет',note,own,variantRecord?.without_complex_throws_characters??null]];
      variants.getRange(`A${vr}:F${vr}`).format={wrapText:true,rowHeight:Math.max(52,14*Math.ceil(note.length/75)+14),verticalAlignment:'center'};
      vr++;
    }
  }
  highlightMinimums(variants,{startRow:6,endRow:vr-1,full:'C',adjusted:'G',extraPairs:[{full:'D',adjusted:'H'}],foreign:[],eligible:'$E6="Да"'});
  variants.getRange(`G6:H${vr-1}`).setNumberFormat('#,##0');
  variants.getRange(`C6:D${vr-1}`).setNumberFormat('#,##0');
  variants.getRange(`E6:E${vr-1}`).format.horizontalAlignment='center';
  for(let r=6;r<vr;r++)if(r%2===1)variants.getRange(`A${r}:H${r}`).format.fill='#F0F3F6';
  const variantsLast=note(variants,vr+2,'H');
  for(const [s,last,col] of [[sh,end,'K'],[ex,et-1,'J'],[gf,gr-1,'D']])for(let r=6;r<=last;r++)if(r%2===1)s.getRange(`A${r}:${col}${r}`).format.fill='#F0F3F6';
  wb.recalculate();
  if(sh.getRange(`C${row+1}`).values[0][0]!==99)throw Error('Summary catalog count is not 99');
  const initialCount=sh.getRange('C6').values[0][0];
  sh.getRange('C6').values=[[initialCount+1]];wb.recalculate();
  if(sh.getRange(`C${row+1}`).values[0][0]!==100)throw Error('Summary count recalculation failed');
  sh.getRange('C6').values=[[initialCount]];wb.recalculate();
  const initialExample=ex.getRange('C6').values[0][0],initialTotal=ex.getRange(`C${et}`).values[0][0];
  ex.getRange('C6').values=[[initialExample+7]];wb.recalculate();
  if(ex.getRange(`C${et}`).values[0][0]!==initialTotal+7)throw Error('Summary example total recalculation failed');
  ex.getRange('C6').values=[[initialExample]];wb.recalculate();
  const checks=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!',options:{useRegex:true,maxResults:30},maxChars:2500});
  await fs.writeFile(path.join(outputDir,'summary.errors.ndjson'),checks.ndjson);
  for(const [sheet,range,file] of [['Группы',`A1:K${shLast}`,'groups'],['Примеры',`A1:J${exLast}`,'examples'],['GoF',`A1:D${gfLast}`,'gof'],['Варианты',`A1:H${variantsLast}`,'variants']]){
    const img=await wb.render({sheetName:sheet,range,scale:1,format:'png'});
    await fs.writeFile(path.join(outputDir,'summary.'+file+'.png'),new Uint8Array(await img.arrayBuffer()));
  }
  const saved=path.join(outputDir,'STATISTICS_2026-11-22.xlsx');
  await (await SpreadsheetFile.exportXlsx(wb)).save(saved);
  await fs.copyFile(saved,path.join(root,'STATISTICS_2026-11-22.xlsx'));
  reports.sort((a,b)=>a.group.localeCompare(b.group));
  await fs.writeFile(path.join(root,'validation','workbook_validation_20261122.json'),JSON.stringify({date:'2026-11-23',engine:'@oai/artifact-tool',scope:'Metrics, ratio formulas, recalculation and saved XLSX; no native Excel execution asserted',groups:reports,summary:{sheets:4,comparison_count_verified:99,recalculation_change_restore:true,path:saved}},null,2)+'\n');
  console.log(JSON.stringify({summary:saved,groups:reports.length}));
}
