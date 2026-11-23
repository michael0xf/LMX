// One conditional-format rule set for character-count comparisons.
// An equal supplementary LMX count is represented by the full-count cell once.
export function highlightMinimums(sheet, {startRow, endRow, full, adjusted, foreign, extraPairs = [], eligible = 'TRUE'}) {
  if (endRow < startRow) return;
  const pairs = [{full, adjusted}, ...extraPairs];
  const columns = [...pairs.flatMap(pair => [pair.full, pair.adjusted]), ...foreign];
  const cells = columns.map(c => `$${c}${startRow}`);
  const numeric = cells.map(c => `ISNUMBER(${c})`).join(',');
  const minimum = `MIN(${cells.join(',')})`;
  const format = {fill:'#D9EEDB', font:{color:'#155B29', bold:true}};
  for (const column of columns) {
    const cell = `$${column}${startRow}`;
    const pair = pairs.find(pair => column === pair.full || column === pair.adjusted);
    const own = !pair ? '' : column === pair.full ? `,${cell}<=$${pair.adjusted}${startRow}`
      : `,${cell}<$${pair.full}${startRow}`;
    const range = sheet.getRange(`${column}${startRow}:${column}${endRow}`);
    range.conditionalFormats.deleteAll();
    range.conditionalFormats.addCustom(`=AND(${eligible},${numeric},${cell}=${minimum}${own})`, format);
  }
}
