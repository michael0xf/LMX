import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import { FileBlob, SpreadsheetFile, Workbook } from '@oai/artifact-tool';

const root = path.resolve(process.env.LMX_DOCS_NEW_PARTS || path.join(path.dirname(fileURLToPath(import.meta.url)), '..'));
const outputDir = path.resolve(process.env.LMX_REPORT_OUTPUT || path.join('/tmp', 'lmx-statistics-20261122'));
const mode = process.argv[2] || 'inspect';
const selected = process.argv.slice(3);
await fs.mkdir(outputDir, {recursive:true});
const groups = (await fs.readdir(root,{withFileTypes:true})).filter(x => mode !== 'summary' && x.isDirectory() && /^\d\d_/.test(x.name) && (!selected.length || selected.includes(x.name))).map(x=>x.name).sort();
const reports = mode === 'summary' ? JSON.parse(await fs.readFile(path.join(root,'validation','workbook_validation_20261122.json'),'utf8')).groups : [];
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
  sh.getRange('B3').values=[[`${langs.join(' / ')}; 2026-11-22`]];
  sh.getRange('B4').values=[['Основной — самый короткий сопоставимый вариант; второй сохранён отдельно.']];
  const cells=[];
  for(let i=0;i<patterns.length;i++) {
    const p=patterns[i], row=7+i;
    const counts=p.listings.map(l=>{
      const code=l.code.trim()+'\n';
      return {chars:[...code].filter(x=>!(/\s/u.test(x))).length,lines:code.split(/\r?\n/).filter(x=>x.trim()).length,bytes:Buffer.byteLength(code,'utf8')};
    });
    sh.getRange(`A${row}:I${row}`).values=[[p.id,p.name,p.kind==='implementation'?'реализация':p.implementation_ids?.length?'использование':'ядро',...counts.map(x=>x.chars),...counts.map(x=>x.lines)]];
    cells.push({id:p.id,row,expected:counts});
  }
  wb.recalculate();
  for(const item of cells) {
    const values=sh.getRange(`D${item.row}:K${item.row}`).values[0];
    for(let j=0;j<3;j++) if(values[j]!==item.expected[j].chars || values[j+3]!==item.expected[j].lines) throw Error(`Metric mismatch ${group}/${item.id}/${j}`);
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
  const last=patterns.length+10;
  const preview=await wb.render({sheetName:sh.name,range:`A1:K${last}`,scale:1,format:'png'});
  await fs.writeFile(path.join(outputDir,group+'.after.png'),new Uint8Array(await preview.arrayBuffer()));
  const saved=path.join(outputDir,`LMX_Comparison_${group}.xlsx`);
  await (await SpreadsheetFile.exportXlsx(wb)).save(saved);
  await fs.copyFile(saved,target);
  reports.push({group,records:patterns.length,counts_verified:true,ratios_verified:true,recalculation_change_restore:true,export:saved});
  console.log(JSON.stringify(reports.at(-1)));
}
if(mode!=='inspect') {
  const stats=JSON.parse(await fs.readFile(path.join(root,'validation','statistics_20261122.json'),'utf8'));
  const wb=Workbook.create();
  const sh=wb.worksheets.add('Группы');
  const ex=wb.worksheets.add('Примеры');
  const gf=wb.worksheets.add('GoF');
  const variants=wb.worksheets.add('Варианты');
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
  base(sh,'Статистика LMX: группы сравнений','22 ноября 2026. Основные листинги; сохранённые альтернативы исключены.','J',[42,23,10,14,15,14,15,14,14,14]);
  sh.getRange('A5:J5').values=[['Группа','Слой','Сравнения','LMX\nсимволы','Контроль 1','Символы','Контроль 2','Символы','LMX /\nконтроль 1','LMX /\nконтроль 2']];
  let row=6;
  for(const g of stats.groups)for(const layer of ['scenario','usage','implementation']) {
    const n=g.records.filter(x=>x.layer===layer).length;if(!n)continue;
    const t=g.totals[layer],a=g.languages[1],b=g.languages[2];
    sh.getRange(`A${row}:H${row}`).values=[[g.title,{scenario:'Сценарии',usage:'Клиенты библиотек',implementation:'Реализации'}[layer],n,t.LMX.characters,a,t[a].characters,b,t[b].characters]];
    sh.getRange(`I${row}:J${row}`).formulas=[[`=D${row}/F${row}`,`=D${row}/H${row}`]];
    row++;
  }
  const end=row-1;
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
  sh.getRange(`A${row+8}:D${row+8}`).values=[['Публичные имена',stats.receiver_library.public_receivers,'Запуск LMX','Не проводился']];
  sh.getRange(`B${row+7}:B${row+8}`).format.horizontalAlignment='center';
  base(ex,'Корневые примеры: исторический пересчёт','До — исходная редакция; после — текущий основной. Выбор пары см. на листе «Варианты».','I',[11,16,16,15,15,15,15,18,38]);
  ex.getRange('A5:I5').values=[['Пример','Символы\nдо','Символы\nпосле','Изменение','Строки\nдо','Строки\nпосле','Изменение','Архив рядом','Исходник']];
  const ers=stats.functional_receiver_counts.rows;
  for(let i=0;i<ers.length;i++) {
    const x=ers[i],r=6+i;
    ex.getRange(`A${r}:C${r}`).values=[[x.id,x.before.characters,x.after.characters]];
    ex.getRange(`D${r}`).formulas=[[`=C${r}-B${r}`]];
    ex.getRange(`E${r}:F${r}`).values=[[x.before.nonblank_lines,x.after.nonblank_lines]];
    ex.getRange(`G${r}`).formulas=[[`=F${r}-E${r}`]];
    ex.getRange(`H${r}:I${r}`).values=[[x.has_alternative||x.archived_inline?'Да':x.changed?'Клиент сохранён':'Без изменений','examples/'+x.file]];
  }
  const et=6+ers.length;
  ex.getRange(`A${et}`).values=[['Итого']];
  for(const c of ['B','C','D','E','F','G'])ex.getRange(`${c}${et}`).formulas=[[`=SUM(${c}6:${c}${et-1})`]];
  ex.getRange(`A6:I${et}`).format.rowHeight=24;ex.getRange(`B6:G${et}`).setNumberFormat('#,##0');
  ex.getRange(`H6:H${et-1}`).format.horizontalAlignment='center';
  ex.getRange(`A${et}:I${et}`).format.fill='#E3EBF1';ex.getRange(`A${et}:I${et}`).format.font.bold=true;
  ex.getRange(`A${et+2}`).values=[['Источник: examples/validation/functional_receiver_counts.json.']];
  base(gf,'Подборка GoF','23 сравнения, 184 основных листинга; пересчитано по текущим исходникам.','C',[22,22,61]);
  gf.getRange('A5:C5').values=[['Язык','Непробельные символы','Источник']];
  let gr=6;
  for(const [lang,total] of Object.entries(stats.gof.total_characters))gf.getRange(`A${gr}:C${gr++}`).values=[[lang,total,'23 корневых *_comparison.md']];
  gf.getRange(`A6:C${gr-1}`).format.rowHeight=25;gf.getRange(`B6:B${gr-1}`).setNumberFormat('#,##0');
  gf.getRange(`B6:B${gr-1}`).format.horizontalAlignment='center';
  gf.getRange('A16').values=[['Метрики описывают приведённый код, не скорость языка.']];
  base(variants,'Основные и сохранённые варианты LMX','Минимум среди корректных вариантов с сопоставимой границей; единое ядро.','F',[13,21,18,18,20,72]);
  variants.getRange('A5:F5').values=[['Пример','Основной','Основной,\nсимволы','Второй,\nсимволы','Второй\nсопоставим','Договор и граница сравнения']];
  let vr=6;
  for(const x of ers.filter(x=>x.has_alternative)) {
    const a=x.selected_variant,b=x.alternative_variant,allowed=x.eligible_variants||Object.keys(x.variants);
    const note=x.fairness_note||'Оба варианта сохраняют один договор; выбран более короткий.';
    variants.getRange(`A${vr}:F${vr}`).values=[[x.id,a,x.variants[a].characters,x.variants[b].characters,allowed.includes(b)?'Да':'Нет',note]];
    variants.getRange(`A${vr}:F${vr}`).format={wrapText:true,rowHeight:Math.max(36,14*Math.ceil(note.length/75)+14),verticalAlignment:'center'};
    vr++;
  }
  const functional=JSON.parse(await fs.readFile(path.join(root,'09_functional_computation/patterns.json'),'utf8'));
  for(const x of functional.patterns) {
    const active=x.listings.find(l=>l.language==='LMX').code,other=x.alternative?.LMX;
    if(!other)continue;
    const count=s=>[...s].filter(c=>!(/\s/u.test(c))).length;
    const selectedName=x.primary_variant?.LMX||'core',choices=x.variants?.LMX||{},eligible=x.eligible_variants?.LMX||[];
    const alternatives=eligible.filter(n=>n!==selectedName).sort((a,b)=>count(choices[a])-count(choices[b]));
    const second=alternatives.length?choices[alternatives[0]]:[other.context_prefix,other.code].filter(Boolean).join('\n');
    const comparable=alternatives.length>0||other.eligible;
    const note=alternatives.length?(x.id===84?`Оба сравниваемых варианта полностью включают Around и callbacks. Основной использует общие code/eval, второй — отдельные тела. Generic bracket также сохранён. Освобождение, журнал и обработка отказов остаются.`:x.id===83?`Основной объединяет алгоритм в Steps\\code; второй сохраняет отдельные even/odd. Общий список выходов и все обращения учтены; переходы и результат сохранены.`:`Сопоставимая пара ${selectedName} / ${alternatives[0]}; выбран минимум. Дополнительная реализация curry показана и посчитана отдельно. Прежний процедурный код также сохранён.`):'Общий текущий контракт; историческая специализация или прежний API сохранены как пояснение, не как другая версия ядра.';
    variants.getRange(`A${vr}:F${vr}`).values=[[String(x.id).padStart(3,'0'),selectedName,count(active),count(second),comparable?'Да':'Нет',note]];
    variants.getRange(`A${vr}:F${vr}`).format={wrapText:true,rowHeight:Math.max(52,14*Math.ceil(note.length/75)+14),verticalAlignment:'center'};
    vr++;
  }
  variants.getRange(`C6:D${vr-1}`).setNumberFormat('#,##0');
  variants.getRange(`E6:E${vr-1}`).format.horizontalAlignment='center';
  for(let r=6;r<vr;r++)if(r%2===1)variants.getRange(`A${r}:F${r}`).format.fill='#F0F3F6';
  for(const [s,last,col] of [[sh,end,'J'],[ex,et-1,'I'],[gf,gr-1,'C']])for(let r=6;r<=last;r++)if(r%2===1)s.getRange(`A${r}:${col}${r}`).format.fill='#F0F3F6';
  wb.recalculate();
  if(sh.getRange(`C${row+1}`).values[0][0]!==99)throw Error('Summary catalog count is not 99');
  const checks=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!',options:{useRegex:true,maxResults:30},maxChars:2500});
  await fs.writeFile(path.join(outputDir,'summary.errors.ndjson'),checks.ndjson);
  for(const [sheet,range,file] of [['Группы',`A1:J${row+8}`,'groups'],['Примеры',`A1:I${et+2}`,'examples'],['GoF','A1:C17','gof'],['Варианты',`A1:F${vr}`,'variants']]){
    const img=await wb.render({sheetName:sheet,range,scale:1,format:'png'});
    await fs.writeFile(path.join(outputDir,'summary.'+file+'.png'),new Uint8Array(await img.arrayBuffer()));
  }
  const saved=path.join(outputDir,'STATISTICS_2026-11-22.xlsx');
  await (await SpreadsheetFile.exportXlsx(wb)).save(saved);
  await fs.copyFile(saved,path.join(root,'STATISTICS_2026-11-22.xlsx'));
  await fs.writeFile(path.join(root,'validation','workbook_validation_20261122.json'),JSON.stringify({date:'2026-11-22',engine:'@oai/artifact-tool',scope:'Metrics, ratio formulas, recalculation and saved XLSX; no native Excel execution asserted',groups:reports,summary:{sheets:4,comparison_count_verified:99,path:saved}},null,2)+'\n');
  console.log(JSON.stringify({summary:saved,groups:reports.length}));
}
