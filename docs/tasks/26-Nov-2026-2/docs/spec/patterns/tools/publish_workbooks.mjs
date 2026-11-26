import fs from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {FileBlob, SpreadsheetFile, Workbook} from '@oai/artifact-tool';

// One model for all publication formats. Imported workbooks retain their sheet
// identities and drawings; only the requested comparison ranges are rebuilt.
const root=path.resolve(process.env.LMX_DOCS_NEW_PARTS||path.join(path.dirname(fileURLToPath(import.meta.url)),'..'));
const output=path.resolve(process.env.LMX_REPORT_OUTPUT||'/tmp/lmx-full-source-publication');
const filter=process.env.LMX_PUBLICATION_FILTER||process.argv[2]||'';
const selected=stem=>!filter||(filter.startsWith('re:')?new RegExp(filter.slice(3)).test(stem):stem.includes(filter));
const model=JSON.parse(await fs.readFile(path.join(root,'PUBLICATION_DATA.json'),'utf8'));
const editionParts=model.edition.split('-').map(Number);
const months=['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'];
const editionLabel=`${editionParts[2]} ${months[editionParts[1]-1]} ${editionParts[0]}`;
const receiptPath=`validation/workbook_publication_${model.edition.replaceAll('-','')}.json`;
await fs.mkdir(output,{recursive:true});
const reports=[];
let previous=[];
if(filter){
  let previousPath=receiptPath;
  try { await fs.access(path.join(root,previousPath)); }
  catch(error){
    if(error.code!=='ENOENT')throw error;
    const names=(await fs.readdir(path.join(root,'validation'))).filter(name=>/^workbook_publication_\d+\.json$/.test(name)).sort().reverse();
    previousPath=names.length?'validation/'+names[0]:null;
  }
  if(previousPath){
    const prior=JSON.parse(await fs.readFile(path.join(root,previousPath),'utf8'));
    previous=prior.files.map(item=>({...item,generation_receipt:item.generation_receipt||previousPath,generation_edition:item.generation_edition||prior.edition}));
  }
}
const green='#176233';
const ink='#17344C';
function column(index){let text='';for(index++;index;index=Math.floor((index-1)/26))text=String.fromCharCode(65+(index-1)%26)+text;return text;}
function addr(row,col){return column(col)+row;}
function absolute(row,col){return '$'+column(col)+'$'+row;}
function numbers(values){return values.filter(value=>typeof value==='number'&&Number.isFinite(value));}

for(const source of model.documents){
  if(!selected(source.stem))continue;
  const target=path.join(root,source.stem+'.xlsx');
  let wb;
  try { wb=await SpreadsheetFile.importXlsx(await FileBlob.load(target)); }
  catch(error) {
    if(error.code!=='ENOENT' && !String(error.message).includes('ENOENT'))throw error;
    wb=Workbook.create();
    for(const view of source.sheets)wb.worksheets.add(view.name);
  }
  const checks=[];const totals=[];const comparisonGroups=[];const renders=[];
  for(const view of source.sheets){
    const sh=wb.worksheets.getItem(view.name);
    const old=sh.getUsedRange();
    old.unmerge();old.conditionalFormats.deleteAll();old.clear({applyTo:'all'});
    sh.showGridLines=false;
    const maxColumns=Math.max(...view.tables.map(table=>table.headers.length));
    const last=column(maxColumns-1);
    const base=sh.getRange(`A1:${last}500`);
    base.format={font:{name:'Arial',size:10,color:ink},verticalAlignment:'center',wrapText:true};
    sh.getRange(`A1:${last}2`).merge();
    sh.getRange('A1').values=[[view.title]];
    sh.getRange(`A1:${last}2`).format={fill:ink,font:{name:'Arial',size:18,bold:true,color:'#FFFFFF'},verticalAlignment:'center'};
    sh.getRange(`A1:${last}2`).format.rowHeight=24;
    sh.getRange(`A3:${last}3`).merge();
    sh.getRange('A3').values=[[`${editionLabel} · полные листинги · все объявления и Throws включены`]];
    sh.getRange(`A3:${last}3`).format={font:{name:'Arial',size:10,color:'#526575'},rowHeight:30,wrapText:true};
    const widths=view.tables[0].widths;
    for(let c=0;c<maxColumns;c++)sh.getRange(`${column(c)}:${column(c)}`).format.columnWidth=Math.max(8,(widths[c]||1)*13);
    let row=5;
    for(const table of view.tables){
      const end=column(table.headers.length-1);
      sh.getRange(`A${row}:${last}${row}`).merge();
      sh.getRange(`A${row}`).values=[[table.title]];
      sh.getRange(`A${row}:${last}${row}`).format={font:{name:'Arial',size:12,bold:true,color:ink},rowHeight:28};row++;
      sh.getRange(`A${row}:${end}${row}`).values=[table.headers];
      sh.getRange(`A${row}:${end}${row}`).format={fill:'#233D55',font:{name:'Arial',size:10,bold:true,color:'#FFFFFF'},rowHeight:44,wrapText:true,verticalAlignment:'center'};
      for(const c of table.comparison_columns)sh.getRange(addr(row,c)).format.horizontalAlignment='center';
      const first=row+1;
      const allRows=table.rows.map(values=>[...values]);
      if(table.total)allRows.push(table.total.values);
      for(let index=0;index<allRows.length;index++){
        const rr=first+index;const values=allRows[index];
        sh.getRange(`A${rr}:${end}${rr}`).values=[values];
        sh.getRange(`A${rr}:${end}${rr}`).format.fill=index%2?'#F0F3F6':'#FFFFFF';
        let height=28;
        for(let c=0;c<values.length;c++){
          const chars=String(values[c]??'').length;
          const width=Math.max(8,(widths[c]||1)*13);
          height=Math.max(height,12*Math.ceil(chars/(width*.9))+9);
          if(typeof values[c]==='number'){
            sh.getRange(addr(rr,c)).setNumberFormat('#,##0');
            sh.getRange(addr(rr,c)).format.horizontalAlignment='center';
          }
          checks.push({sheet:sh.name,cell:addr(rr,c),expected:values[c]??null});
        }
        sh.getRange(`A${rr}:${end}${rr}`).format.rowHeight=Math.min(height,190);
        const isTotal=index===table.rows.length;
        const eligible=isTotal?table.total?.compare:table.eligible_rows[index];
        const candidates=table.comparison_columns.filter(c=>typeof values[c]==='number');
        if(eligible&&candidates.length){
          const refs=candidates.map(c=>absolute(rr,c));
          const minimum=Math.min(...candidates.map(c=>values[c]));
          const expected=candidates.filter(c=>values[c]===minimum).map(c=>addr(rr,c));
          const rules=[];
          for(const c of candidates){
            const cell=addr(rr,c);
            const formula=`=AND(ISNUMBER(${cell}),${cell}=MIN(${refs.join(',')}))`;
            sh.getRange(cell).conditionalFormats.addCustom(formula,{
              font:{color:green,bold:true},border:{bottom:{style:'thin',color:green}}
            });
            rules.push({cell,formula});
          }
          comparisonGroups.push({sheet:sh.name,table:table.title,row:rr,cells:candidates.map(c=>addr(rr,c)),expected_winners:expected,rules});
        }
      }
      if(table.total){
        const rr=first+table.rows.length;
        for(const c of table.total.columns){
          const terms=table.total.included_rows.map(i=>addr(first+i,c));
          const formula=terms.length?`=SUM(${terms.join(',')})`:'=0';
          sh.getRange(addr(rr,c)).formulas=[[formula]];
          totals.push({sheet:sh.name,cell:addr(rr,c),expected:table.total.values[c],input:terms[0]||null});
        }
        sh.getRange(`A${rr}:${end}${rr}`).format.fill='#E3EBF1';
        sh.getRange(`A${rr}:${end}${rr}`).format.font.bold=true;
        sh.getRange(`A${rr}:${end}${rr}`).format.borders={top:{style:'thin',color:'#91A6B8'}};
      }
      row=first+allRows.length+1;
      if(table.note){
        const count=Math.max(2,Math.ceil(table.note.length/110));
        sh.getRange(`A${row}:${last}${row+count-1}`).merge();
        sh.getRange(`A${row}`).values=[[table.note]];
        sh.getRange(`A${row}:${last}${row+count-1}`).format={font:{name:'Arial',size:10,color:'#526575'},wrapText:true,verticalAlignment:'center',rowHeight:19};
        row+=count+1;
      }
    }
    for(const note of view.notes){
      if(!note)continue;
      const count=Math.max(2,Math.ceil(note.length/100));
      sh.getRange(`A${row}:${last}${row+count-1}`).merge();sh.getRange(`A${row}`).values=[[note]];
      sh.getRange(`A${row}:${last}${row+count-1}`).format={font:{name:'Arial',size:10,color:'#526575'},rowHeight:18,wrapText:true,verticalAlignment:'center'};
      row+=count+1;
    }
    sh.freezePanes.freezeRows(6);
    renders.push({sheet:sh.name,range:`A1:${last}${row}`,file:source.stem.replaceAll('/','__')+'_'+sh.name+'.png'});
  }
  wb.recalculate();
  for(const check of checks){
    const actual=wb.worksheets.getItem(check.sheet).getRange(check.cell).values[0][0]??null;
    if(actual!==check.expected)throw Error(`Cell mismatch ${source.stem}/${check.sheet}/${check.cell}: ${actual} != ${check.expected}`);
  }
  for(const total of totals){
    const sh=wb.worksheets.getItem(total.sheet);
    if(sh.getRange(total.cell).values[0][0]!==total.expected)throw Error('Cached total mismatch '+source.stem+'/'+total.cell);
    if(total.input){
      const initial=sh.getRange(total.input).values[0][0];
      sh.getRange(total.input).values=[[initial+11]];wb.recalculate();
      if(sh.getRange(total.cell).values[0][0]!==total.expected+11)throw Error('Change/recalculate failed '+source.stem+'/'+total.cell);
      sh.getRange(total.input).values=[[initial]];wb.recalculate();
      if(sh.getRange(total.cell).values[0][0]!==total.expected)throw Error('Restore failed '+source.stem+'/'+total.cell);
    }
  }
  const errors=await wb.inspect({kind:'match',searchTerm:'#REF!|#DIV/0!|#VALUE!|#NAME\\?|#N/A|#NUM!|#NULL!|#SPILL!|#CALC!',options:{useRegex:true,maxResults:25},maxChars:3000});
  await fs.writeFile(path.join(output,source.stem.replaceAll('/','__')+'.errors.ndjson'),errors.ndjson);
  for(const view of source.sheets){
    const values=wb.worksheets.getItem(view.name).getUsedRange().values;
    if(values.flat().some(v=>typeof v==='string'&&/^#(?:REF!|DIV\/0!|VALUE!|NAME\?|N\/A|NUM!|NULL!|SPILL!|CALC!)/.test(v)))throw Error('Formula error in '+source.stem);
  }
  for(const view of renders){
    const picture=await wb.render({sheetName:view.sheet,range:view.range,scale:1,format:'png'});
    await fs.writeFile(path.join(output,view.file),new Uint8Array(await picture.arrayBuffer()));
  }
  const saved=path.join(output,source.stem.replaceAll('/','__')+'.xlsx');
  await(await SpreadsheetFile.exportXlsx(wb)).save(saved);await fs.copyFile(saved,target);
  reports.push({file:source.stem+'.xlsx',sha256:createHash('sha256').update(await fs.readFile(target)).digest('hex'),
                generation_receipt:receiptPath,generation_edition:model.edition,
                checked_cells:checks.length,formula_totals:totals.length,recalculation_change_restore:true,
                formula_errors:0,sheets:source.sheets.map(s=>s.name),renders,comparison_groups:comparisonGroups});
  console.log(JSON.stringify({file:source.stem+'.xlsx',sheets:source.sheets.length,cells:checks.length,comparison_groups:comparisonGroups.length}));
}
for(const mirror of model.mirrors){
  const original=reports.find(r=>r.file===mirror.source+'.xlsx');
  if(!original)continue;
  await fs.copyFile(path.join(root,mirror.source+'.xlsx'),path.join(root,mirror.target+'.xlsx'));
  reports.push({...original,file:mirror.target+'.xlsx',byte_identical_to:mirror.source+'.xlsx'});
}
const changed=new Set(reports.map(file=>file.file));
const published=[...previous.filter(file=>!changed.has(file.file)),...reports];
const report={edition:model.edition,engine:'@oai/artifact-tool',source:'PUBLICATION_DATA.json',
              source_sha256:createHash('sha256').update(await fs.readFile(path.join(root,'PUBLICATION_DATA.json'))).digest('hex'),
              files:published,visual_review:'separate rendered-sheet inspection',lmx_runtime_execution:'NOT_RUN'};
await fs.writeFile(path.join(root,receiptPath),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({workbooks:published.length,updated:reports.length,formula_errors:0}));
