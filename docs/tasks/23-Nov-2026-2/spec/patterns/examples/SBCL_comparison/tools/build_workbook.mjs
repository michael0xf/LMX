import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {Workbook, SpreadsheetFile} from '@oai/artifact-tool';

const root=path.resolve(process.argv[2] ?? path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=path.resolve(process.argv[3] ?? root);
await fs.mkdir(output,{recursive:true});
await fs.mkdir(path.join(root,'validation'),{recursive:true});
const read=async p=>JSON.parse(await fs.readFile(path.join(root,p),'utf8'));
const stats=await read('statistics.json');
const impl=await read('validation/implementation_dependencies.json');
const clientTests=await read('validation/common_lisp.json');
const implementationTests=await read('validation/implementation_execution.json');
const coverage=await read('COMMON_LISP_COVERAGE.json');
const wb=Workbook.create();
const clients=wb.worksheets.add('Сравнения');
const implementations=wb.worksheets.add('Реализации');
const theme={ink:'#17324D',muted:'#526171',rule:'#DCE4EB',band:'#F2F5F8',accent:'#E7EEF4'};
for(const sh of [clients,implementations]){
  sh.showGridLines=false;
  sh.getRange('A1:G60').format.font={name:'Arial',size:10,color:theme.ink};
  sh.getRange('A1:G60').format.verticalAlignment='center';
  sh.getRange('A1:G60').format.rowHeight=22;
  for(const [col,width] of Object.entries({A:11,B:56,C:16,D:19,E:16,F:14,G:21}))sh.getRange(`${col}:${col}`).format.columnWidth=width;
  sh.getRange('B1:B60').format.wrapText=true;
  sh.getRange('C1:F60').setNumberFormat('0');
  sh.freezePanes.freezeRows(5);
}
function header(sh,row,values){
  const range=sh.getRange(`A${row}:G${row}`);range.values=[values];
  range.format.fill=theme.ink;range.format.font={name:'Arial',size:10,bold:true,color:'#FFFFFF'};
  range.format.wrapText=true;range.format.rowHeight=34;
}
function band(sh,start,end){for(let r=start;r<=end;r++)if((r-start)%2===1)sh.getRange(`A${r}:G${r}`).format.fill=theme.band;}
const winnerRules=[];
function minima(sh,start,end,completeGate=false){
  const gate=completeGate?`$G${start}="полная",`:'';
  const rules={
    C:`=AND(${gate}$C${start}<=$D${start},$C${start}=MIN($C${start}:$E${start}))`,
    D:`=AND(${gate}$D${start}<$C${start},$D${start}=MIN($C${start}:$E${start}))`,
    E:`=AND(${gate}$E${start}=MIN($C${start}:$E${start}))`
  };
  for(const [column,formula] of Object.entries(rules)){
    const range=`${column}${start}:${column}${end}`;
    sh.getRange(range).conditionalFormats.addCustom(formula,{fill:'#DDF0DF',font:{color:'#176233',bold:true}});
    winnerRules.push({sheet:sh.name,range,formula});
  }
}
function title(sh,text,subtitle){
  sh.getRange('A1').values=[[text]];sh.getRange('A1').format.font={name:'Arial',size:16,bold:true,color:theme.ink};
  sh.getRange('A1:G1').format.rowHeight=29;
  sh.getRange('B2').values=[[subtitle]];sh.getRange('B2').format.font={name:'Arial',size:10,color:theme.muted};
  sh.getRange('B2').format.wrapText=true;sh.getRange('A2:G2').format.rowHeight=38;
}
title(clients,'LMX / Common Lisp на SBCL','23 полные пары; S24 — протокольная аналогия. Полный исходник, Unicode без пробелов.');
clients.getRange('B3').values=[['Редакция 23-Nov-2026 · LMX runtime: NOT_RUN']];
clients.getRange('B3').format.font={name:'Arial',size:10,color:theme.muted};
header(clients,5,['ID','Задача','LMX полный','Без сложного Throws','Lisp полный','Lisp / LMX','В итог']);
const rows=stats.examples.map(r=>[r.id,r.title,r.lmx.characters_nonwhitespace,r.lmx.without_complex_throws_characters,r.foreign.characters_nonwhitespace,null,r.comparison_status==='complete_pair'?'полная':'аналогия']);
clients.getRange('A6:G29').values=rows;
for(const [i,r] of stats.examples.entries()){
  if(r.comparison_status==='complete_pair')clients.getRange(`F${i+6}`).formulas=[[`=E${i+6}/C${i+6}`]];
}
clients.getRange('F6:F30').setNumberFormat('0.000');
clients.getRange('B6:B29').format.rowHeight=31;
band(clients,6,29);
minima(clients,6,29,true);
clients.getRange('B30').values=[['Итого: 23 полные пары']];
for(const c of ['C','D','E'])clients.getRange(`${c}30`).formulas=[[`=SUMIFS(${c}6:${c}29,G6:G29,"полная")`]];
clients.getRange('F30').formulas=[['=E30/C30']];
clients.getRange('A30:G30').format.borders={top:{style:'thin',color:theme.ink}};
clients.getRange('A30:G30').format.font={name:'Arial',size:10,bold:true,color:theme.ink};
minima(clients,30,30);
clients.getRange('B32').values=[['Зелёный — минимум сопоставимой строки. LMX: уменьшенный Throws либо полный при равенстве; равные разные языки подсвечены вместе. copy и ссылки учтены полностью.']];
clients.getRange('B32').format.rowHeight=78;
clients.getRange('B34').values=[['Существенные альтернативы — отдельно от основного итога']];
clients.getRange('B34').format.font={name:'Arial',size:12,bold:true,color:theme.ink};
header(clients,35,['ID','Другой подход','LMX полный','Без сложного Throws','','','']);
clients.getRange('A36:G44').values=stats.alternatives.map(r=>[r.example,r.approach,r.characters_nonwhitespace,r.without_complex_throws_characters,null,null,null]);
clients.getRange('B36:B44').format.rowHeight=32;band(clients,36,44);
clients.getRange('B46').values=[['Явные Throws и copy(Throws) — преимущество: видно, что метод может бросить. Дополнительная метрика не предлагает сокращать эти контракты.']];
clients.getRange('B46').format.rowHeight=78;

title(implementations,'Реализации и проверка','Шесть полных алгоритмических пар. Пересекающиеся зависимости учитываются один раз.');
header(implementations,5,['ID','Операции','LMX полный','Без сложного Throws','Lisp полный','Lisp / LMX','Роль']);
implementations.getRange('A6:G11').values=stats.implementations.map(r=>[r.id,r.title,r.lmx.characters_nonwhitespace,r.lmx.without_complex_throws_characters,r.foreign.characters_nonwhitespace,null,r.dependency_role==='retained_core_variant_only'?'альтернатива':'клиенты']);
implementations.getRange('F6:F11').formulas=stats.implementations.map((_,i)=>[`=E${i+6}/C${i+6}`]);
implementations.getRange('F6:F12').setNumberFormat('0.000');
implementations.getRange('B6:B11').format.rowHeight=38;band(implementations,6,11);
minima(implementations,6,11);
implementations.getRange('B12').values=[['Сумма первичных тел']];
for(const c of ['C','D','E'])implementations.getRange(`${c}12`).formulas=[[`=SUM(${c}6:${c}11)`]];
implementations.getRange('F12').formulas=[['=E12/C12']];
implementations.getRange('A12:G12').format.borders={top:{style:'thin',color:theme.ink}};
implementations.getRange('A12:G12').format.font={name:'Arial',size:10,bold:true,color:theme.ink};
minima(implementations,12,12);
header(implementations,15,['','Уникальные зависимости','Полный','Без сложного Throws','','','']);
implementations.getRange('B16:D18').values=[
  [`LMX: полное замыкание (${impl.unique_definitions} определений)`,impl.unique_lmx_total.characters_without_whitespace,impl.unique_lmx_total.without_complex_throws_characters],
  ['LMX: общая часть вне шести первичных тел',impl.shared_not_in_primary.characters_without_whitespace,impl.shared_not_in_primary.without_complex_throws_characters],
  ['Common Lisp: общая инфраструктура',impl.common_lisp_runtime.characters_without_whitespace,null]
];
implementations.getRange('B16:B18').format.rowHeight=36;band(implementations,16,18);
header(implementations,21,['','Проверка','Успешно','Ожидается','Статус','','']);
implementations.getRange('B22:E25').values=[
  ['Common Lisp клиенты',clientTests.passed,clientTests.expected_assertions,clientTests.status],
  ['Common Lisp reference',implementationTests.checks,implementationTests.checks,implementationTests.status],
  ['Экспорт COMMON-LISP symbols',coverage.total,978,'978 / 978'],
  ['LMX runtime',null,null,'NOT_RUN']
];
band(implementations,22,25);
implementations.getRange('B28').values=[['Добавлено в общее ядро по итогам этого аудита']];
implementations.getRange('B28').format.font={name:'Arial',size:12,bold:true,color:theme.ink};
const names=['assoc','pairlis','getProperty','setProperty','removeProperty','getProperties','mismatch','searchSequence','substitute','asOperand'];
implementations.getRange('B30:C39').values=names.map(name=>[name,'BODY']);
implementations.getRange('E30').values=[['Runtime: NOT_RUN']];
implementations.getRange('E30').format.font={name:'Arial',size:10,bold:true,color:theme.muted};
implementations.getRange('B41').values=[['Полные тела, договоры и 42 runtime acceptance: CORE_STANDARD_LISP.md. Внешняя native реализация FxKernel не оценена нулём.']];
implementations.getRange('B41').format.rowHeight=78;

wb.recalculate();
const original=Number(clients.getRange('C6').values[0][0]);
const before=Number(clients.getRange('C30').values[0][0]);
if(before!==stats.paired_totals.lmx.characters_nonwhitespace)throw new Error('Client total differs from authoritative JSON');
clients.getRange('C6').values=[[original+10]];wb.recalculate();
const changed=Number(clients.getRange('C30').values[0][0]);
if(changed!==before+10)throw new Error('What-if SUMIFS failed');
clients.getRange('C6').values=[[original]];wb.recalculate();
const expected=[stats.paired_totals.lmx.characters_nonwhitespace,stats.paired_totals.lmx.without_complex_throws_characters,stats.paired_totals.foreign.characters_nonwhitespace];
const actual=clients.getRange('C30:E30').values[0].map(Number);
if(actual.some((v,i)=>v!==expected[i]))throw new Error('Restored client totals differ');
const implTotal=Number(implementations.getRange('C12').values[0][0]);
if(implTotal!==stats.implementation_primary_totals.lmx.characters_nonwhitespace)throw new Error('Implementation total differs');
const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A',options:{useRegex:true,maxResults:20},maxChars:3000});
const previews=[];
for(const [sheetName,range,name] of [['Сравнения','A1:G30','clients'],['Сравнения','A32:G46','alternatives'],['Реализации','A1:G25','implementations'],['Реализации','A28:G41','core']]){
  const p=await wb.render({sheetName,range,scale:1.4,format:'png'});const target=path.join(output,`sbcl_${name}.png`);
  await fs.writeFile(target,new Uint8Array(await p.arrayBuffer()));previews.push(target);
}
const target=path.join(output,'LMX_Comparison_SBCL.xlsx');await(await SpreadsheetFile.exportXlsx(wb)).save(target);
if(target!==path.join(root,'LMX_Comparison_SBCL.xlsx'))await fs.copyFile(target,path.join(root,'LMX_Comparison_SBCL.xlsx'));
await fs.writeFile(path.join(root,'validation/workbook_checks.json'),JSON.stringify({status:'PASS',source:'statistics.json',sheets:2,client_totals:actual,implementation_total:implTotal,what_if:{original:before,changed,restored:Number(clients.getRange('C30').values[0][0])},formula_error_inspection:errors,minimum_rules:winnerRules,minimum_rule:'Dynamic MIN(C:E); D eligible only when D<C; C chosen when C<=D; ties between languages retained; S24 gated out.',previews,visual_review:'PENDING'},null,2)+'\n');
console.log(JSON.stringify({file:target,client_totals:actual,implementation_total:implTotal,previews}));
