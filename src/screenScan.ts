export type ScanConfidence = 'High' | 'Medium';

export type GameScanKey =
  | 'opponent' | 'result' | 'importance'
  | 'pts' | 'reb' | 'ast' | 'stl' | 'blk' | 'tov'
  | 'fgm' | 'fga' | 'tpm' | 'tpa' | 'ftm' | 'fta'
  | 'minutes' | 'plusMinus';

export type ScannedGameField = {
  key: GameScanKey;
  value: string;
  confidence: ScanConfidence;
};

export type ScannedAttribute = {
  name: string;
  rating: number;
  confidence: ScanConfidence;
};

export type ScannedBadge = {
  name: string;
  level: 'Locked' | 'Bronze' | 'Silver' | 'Gold' | 'HOF' | 'Legend';
  confidence: ScanConfidence;
};

export type ScannedTransaction = {
  type: string;
  player: string;
  fromTeam: string;
  toTeam: string;
  confidence: ScanConfidence;
  sourceLine: string;
};

export type ScannedPlayerFieldKey =
  | 'team' | 'position' | 'overall' | 'potential' | 'age'
  | 'jersey' | 'height' | 'weight';

export type ScannedPlayerField = {
  key: ScannedPlayerFieldKey;
  value: string | number;
  confidence: ScanConfidence;
};

const NBA_TEAMS: Record<string, string[]> = {
  ATL: ['ATL', 'ATLANTA', 'ATLANTA HAWKS', 'HAWKS'],
  BOS: ['BOS', 'BOSTON', 'BOSTON CELTICS', 'CELTICS'],
  BKN: ['BKN', 'BROOKLYN', 'BROOKLYN NETS', 'NETS'],
  CHA: ['CHA', 'CHARLOTTE', 'CHARLOTTE HORNETS', 'HORNETS'],
  CHI: ['CHI', 'CHICAGO', 'CHICAGO BULLS', 'BULLS'],
  CLE: ['CLE', 'CLEVELAND', 'CLEVELAND CAVALIERS', 'CAVALIERS', 'CAVS'],
  DAL: ['DAL', 'DALLAS', 'DALLAS MAVERICKS', 'MAVERICKS', 'MAVS'],
  DEN: ['DEN', 'DENVER', 'DENVER NUGGETS', 'NUGGETS'],
  DET: ['DET', 'DETROIT', 'DETROIT PISTONS', 'PISTONS'],
  GSW: ['GSW', 'GOLDEN STATE', 'GOLDEN STATE WARRIORS', 'WARRIORS'],
  HOU: ['HOU', 'HOUSTON', 'HOUSTON ROCKETS', 'ROCKETS'],
  IND: ['IND', 'INDIANA', 'INDIANA PACERS', 'PACERS'],
  LAC: ['LAC', 'LA CLIPPERS', 'LOS ANGELES CLIPPERS', 'CLIPPERS'],
  LAL: ['LAL', 'LA LAKERS', 'LOS ANGELES LAKERS', 'LAKERS'],
  MEM: ['MEM', 'MEMPHIS', 'MEMPHIS GRIZZLIES', 'GRIZZLIES'],
  MIA: ['MIA', 'MIAMI', 'MIAMI HEAT', 'HEAT'],
  MIL: ['MIL', 'MILWAUKEE', 'MILWAUKEE BUCKS', 'BUCKS'],
  MIN: ['MIN', 'MINNESOTA', 'MINNESOTA TIMBERWOLVES', 'TIMBERWOLVES', 'WOLVES'],
  NOP: ['NOP', 'NEW ORLEANS', 'NEW ORLEANS PELICANS', 'PELICANS'],
  NYK: ['NYK', 'NEW YORK', 'NEW YORK KNICKS', 'KNICKS'],
  OKC: ['OKC', 'OKLAHOMA CITY', 'OKLAHOMA CITY THUNDER', 'THUNDER'],
  ORL: ['ORL', 'ORLANDO', 'ORLANDO MAGIC', 'MAGIC'],
  PHI: ['PHI', 'PHILADELPHIA', 'PHILADELPHIA 76ERS', '76ERS', 'SIXERS'],
  PHX: ['PHX', 'PHOENIX', 'PHOENIX SUNS', 'SUNS'],
  POR: ['POR', 'PORTLAND', 'PORTLAND TRAIL BLAZERS', 'TRAIL BLAZERS', 'BLAZERS'],
  SAC: ['SAC', 'SACRAMENTO', 'SACRAMENTO KINGS', 'KINGS'],
  SAS: ['SAS', 'SAN ANTONIO', 'SAN ANTONIO SPURS', 'SPURS'],
  TOR: ['TOR', 'TORONTO', 'TORONTO RAPTORS', 'RAPTORS'],
  UTA: ['UTA', 'UTAH', 'UTAH JAZZ', 'JAZZ'],
  WAS: ['WAS', 'WASHINGTON', 'WASHINGTON WIZARDS', 'WIZARDS']
};

const ATTRIBUTE_ALIASES: Record<string, string[]> = {
  'Close Shot': ['CLOSE SHOT', 'CLOSE SHT'],
  'Driving Layup': ['DRIVING LAYUP', 'DRV LAYUP', 'DRIVE LAYUP'],
  'Driving Dunk': ['DRIVING DUNK', 'DRV DUNK', 'DRIVE DUNK'],
  'Standing Dunk': ['STANDING DUNK', 'STAND DUNK'],
  'Post Control': ['POST CONTROL', 'POST CTRL'],
  'Mid-Range Shot': ['MID-RANGE SHOT', 'MID RANGE SHOT', 'MID-RANGE', 'MID RANGE'],
  'Three-Point Shot': ['THREE-POINT SHOT', 'THREE POINT SHOT', '3PT SHOT', '3-POINT SHOT'],
  'Free Throw': ['FREE THROW', 'FREE-THROW'],
  'Pass Accuracy': ['PASS ACCURACY', 'PASS ACC'],
  'Ball Handle': ['BALL HANDLE', 'BALL HANDLING'],
  'Speed With Ball': ['SPEED WITH BALL', 'SPEED W/BALL', 'SPD WITH BALL'],
  'Interior Defense': ['INTERIOR DEFENSE', 'INTERIOR DEF', 'INT DEFENSE'],
  'Perimeter Defense': ['PERIMETER DEFENSE', 'PERIMETER DEF', 'PER DEFENSE'],
  Steal: ['STEAL'],
  Block: ['BLOCK'],
  'Offensive Rebound': ['OFFENSIVE REBOUND', 'OFF REBOUND', 'OFF. REBOUND'],
  'Defensive Rebound': ['DEFENSIVE REBOUND', 'DEF REBOUND', 'DEF. REBOUND'],
  Speed: ['SPEED'],
  Agility: ['AGILITY'],
  Strength: ['STRENGTH'],
  Vertical: ['VERTICAL'],
  Stamina: ['STAMINA']
};

const BADGE_ALIASES: Record<string, string[]> = {
  'Physical Finisher': ['PHYSICAL FINISHER'],
  'Float Game': ['FLOAT GAME'],
  Posterizer: ['POSTERIZER'],
  'Aerial Wizard': ['AERIAL WIZARD'],
  'Set Shot Specialist': ['SET SHOT SPECIALIST'],
  'Limitless Range': ['LIMITLESS RANGE'],
  Deadeye: ['DEADEYE'],
  'Shifty Shooter': ['SHIFTY SHOOTER'],
  'Handles For Days': ['HANDLES FOR DAYS'],
  Dimer: ['DIMER'],
  Unpluckable: ['UNPLUCKABLE'],
  'Lightning Launch': ['LIGHTNING LAUNCH'],
  'On-Ball Menace': ['ON-BALL MENACE', 'ON BALL MENACE'],
  Interceptor: ['INTERCEPTOR'],
  Challenger: ['CHALLENGER'],
  'High-Flying Denier': ['HIGH-FLYING DENIER', 'HIGH FLYING DENIER']
};

const GAME_LABELS: Record<Exclude<GameScanKey, 'opponent' | 'result' | 'importance'>, string[]> = {
  pts: ['PTS', 'POINTS'],
  reb: ['REB', 'REBOUNDS'],
  ast: ['AST', 'ASSISTS'],
  stl: ['STL', 'STEALS'],
  blk: ['BLK', 'BLOCKS'],
  tov: ['TOV', 'TO', 'TURNOVERS'],
  fgm: ['FGM'],
  fga: ['FGA'],
  tpm: ['3PM', '3PTM'],
  tpa: ['3PA', '3PTA'],
  ftm: ['FTM'],
  fta: ['FTA'],
  minutes: ['MIN', 'MINS', 'MINUTES'],
  plusMinus: ['+/-', 'PLUS/MINUS', 'PLUS MINUS']
};

const GAME_BOUNDS: Record<Exclude<GameScanKey, 'opponent' | 'result' | 'importance'>, [number, number]> = {
  pts: [0, 120], reb: [0, 70], ast: [0, 40], stl: [0, 20], blk: [0, 25], tov: [0, 30],
  fgm: [0, 60], fga: [0, 80], tpm: [0, 35], tpa: [0, 50], ftm: [0, 50], fta: [0, 60],
  minutes: [0, 80], plusMinus: [-100, 100]
};

function linesFrom(rawText: string): string[] {
  return rawText
    .replace(/[‐‑‒–—]/g, '-')
    .replace(/[|¦]/g, ' ')
    .split(/\r?\n/)
    .map(line => line.replace(/\s+/g, ' ').trim())
    .filter(Boolean);
}

function upper(value: string): string {
  return value.normalize('NFKD').replace(/[\u0300-\u036f]/g, '').toUpperCase();
}

function comparable(value: string): string {
  return upper(value).replace(/[^A-Z0-9+/-]+/g, ' ').replace(/\s+/g, ' ').trim();
}

function compact(value: string): string {
  return comparable(value).replace(/[^A-Z0-9]/g, '');
}

function escapeRegex(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function numberFromToken(token: string): number | null {
  const trimmed = token.trim();
  if (!/[0-9OIL]/i.test(trimmed)) return null;
  const repaired = trimmed
    .replace(/[Oo]/g, '0')
    .replace(/[Il|]/g, '1')
    .replace(/[^0-9+-.]/g, '');
  if (!/^[+-]?\d+(?:\.\d+)?$/.test(repaired)) return null;
  const value = Number(repaired);
  return Number.isFinite(value) ? value : null;
}

function numericTokens(line: string): number[] {
  const prepared=line.replace(/([0-9OIl])\s*[-/]\s*([0-9OIl])/g,'$1 $2');
  const raw = prepared.match(/[+-]?[0-9OIl|]{1,3}(?:\.[0-9]{1,2})?%?/g) || [];
  return raw.map(numberFromToken).filter((value): value is number => value !== null);
}

function findAliasIndex(line: string, aliases: string[]): { index: number; alias: string } | null {
  const normalized = comparable(line);
  let best: { index: number; alias: string } | null = null;
  for (const alias of aliases) {
    const normalizedAlias = comparable(alias);
    const match = new RegExp(`(?:^|\\s)${escapeRegex(normalizedAlias).replace(/\\ /g, '\\s+')}(?=\\s|$)`).exec(normalized);
    if (!match) continue;
    const index = match.index + (match[0].startsWith(' ') ? 1 : 0);
    if (!best || normalizedAlias.length > best.alias.length) best = { index, alias: normalizedAlias };
  }
  return best;
}

function numberNearAlias(lines: string[], lineIndex: number, aliases: string[], min: number, max: number): { value: number; confidence: ScanConfidence } | null {
  const normalized = comparable(lines[lineIndex]);
  const found = findAliasIndex(normalized, aliases);
  if (!found) return null;
  const after = normalized.slice(found.index + found.alias.length, found.index + found.alias.length + 24);
  const afterValues = numericTokens(after).filter(value => value >= min && value <= max);
  if (afterValues.length) return { value: Math.round(afterValues[0]), confidence: 'High' };
  const before = normalized.slice(Math.max(0, found.index - 10), found.index);
  const beforeValues = numericTokens(before).filter(value => value >= min && value <= max);
  if (beforeValues.length) return { value: Math.round(beforeValues[beforeValues.length - 1]), confidence: 'Medium' };
  for (const neighbor of [lineIndex + 1, lineIndex - 1]) {
    if (neighbor < 0 || neighbor >= lines.length) continue;
    const values = numericTokens(lines[neighbor]).filter(value => value >= min && value <= max);
    if (values.length === 1) return { value: Math.round(values[0]), confidence: 'Medium' };
  }
  return null;
}

function teamMatches(text: string, allowedCodes?: string[]): { code: string; index: number; matched: string }[] {
  const normalized = comparable(text);
  const allowed = new Set((allowedCodes?.length ? allowedCodes : Object.keys(NBA_TEAMS)).map(code => code.toUpperCase()));
  const matches: { code: string; index: number; matched: string }[] = [];
  for (const [code, aliases] of Object.entries(NBA_TEAMS)) {
    if (!allowed.has(code)) continue;
    let best: { code: string; index: number; matched: string } | null = null;
    for (const alias of [...aliases].sort((a, b) => b.length - a.length)) {
      const candidate = comparable(alias);
      const regex = new RegExp(`(?:^|\\s)${escapeRegex(candidate).replace(/\\ /g, '\\s+')}(?=\\s|$)`);
      const hit = regex.exec(normalized);
      if (!hit) continue;
      const index = hit.index + (hit[0].startsWith(' ') ? 1 : 0);
      best = { code, index, matched: candidate };
      break;
    }
    if (best) matches.push(best);
  }
  return matches.sort((a, b) => a.index - b.index);
}

function dedupeBy<T>(items: T[], key: (item: T) => string): T[] {
  const seen = new Set<string>();
  return items.filter(item => {
    const value = key(item);
    if (seen.has(value)) return false;
    seen.add(value);
    return true;
  });
}

export function parseAttributeScreen(rawText: string, attributeNames: string[]): ScannedAttribute[] {
  const lines = linesFrom(rawText);
  const output: ScannedAttribute[] = [];
  const names = [...attributeNames].sort((a, b) => b.length - a.length);
  for (const name of names) {
    const aliases = ATTRIBUTE_ALIASES[name] || [upper(name)];
    for (let index = 0; index < lines.length; index += 1) {
      if (!findAliasIndex(lines[index], aliases)) continue;
      if (name === 'Speed' && findAliasIndex(lines[index], ATTRIBUTE_ALIASES['Speed With Ball'])) continue;
      const found = numberNearAlias(lines, index, aliases, 25, 99);
      if (found) output.push({ name, rating: found.value, confidence: found.confidence });
      break;
    }
  }
  return dedupeBy(output, item => item.name);
}

function badgeLevelNear(lines: string[], lineIndex: number): ScannedBadge['level'] | null {
  const detect=(region:string):ScannedBadge['level']|null=>{
    if (/\bLEGEND(?:ARY)?\b/.test(region)) return 'Legend';
    if (/\b(?:HALL OF FAME|HOF)\b/.test(region)) return 'HOF';
    if (/\bGOLD\b/.test(region)) return 'Gold';
    if (/\bSILVER\b/.test(region)) return 'Silver';
    if (/\bBRONZE\b/.test(region)) return 'Bronze';
    if (/\b(?:LOCKED|NONE)\b/.test(region)) return 'Locked';
    return null;
  };
  const same=detect(upper(lines[lineIndex]));if(same)return same;
  const next=lines[lineIndex+1]?detect(upper(lines[lineIndex+1])):null;if(next)return next;
  const previous=lines[lineIndex-1]?detect(upper(lines[lineIndex-1])):null;if(previous)return previous;
  return null;
}

export function parseBadgeScreen(rawText: string, badgeNames: string[]): ScannedBadge[] {
  const lines = linesFrom(rawText);
  const output: ScannedBadge[] = [];
  for (const name of badgeNames) {
    const aliases = BADGE_ALIASES[name] || [upper(name)];
    for (let index = 0; index < lines.length; index += 1) {
      if (!findAliasIndex(lines[index], aliases)) continue;
      const level = badgeLevelNear(lines, index);
      if (level) output.push({ name, level, confidence: upper(lines[index]).includes(upper(level)) ? 'High' : 'Medium' });
      break;
    }
  }
  return dedupeBy(output, item => item.name);
}

type HeaderColumn = Exclude<GameScanKey, 'opponent' | 'result' | 'importance'> | 'ignore';

function headerColumns(token: string): HeaderColumn[] {
  const value = upper(token).replace(/[.:]/g, '');
  const compactValue=value.replace(/[^A-Z0-9+%/-]/g,'');
  if (['FGM-A','FGM/A','FGMA','FG'].includes(compactValue)) return ['fgm','fga'];
  if (['3PM-A','3PM/A','3PMA','3PT','3P'].includes(compactValue)) return ['tpm','tpa'];
  if (['FTM-A','FTM/A','FTMA','FT'].includes(compactValue)) return ['ftm','fta'];
  if (['FG%', 'FGP', '3P%', '3PT%', 'FT%','OREB','DREB','PF','FOULS'].includes(compactValue)) return ['ignore'];
  for (const [key, aliases] of Object.entries(GAME_LABELS) as [Exclude<GameScanKey, 'opponent' | 'result' | 'importance'>, string[]][]) {
    if (aliases.some(alias => comparable(alias) === comparable(value))) return [key];
  }
  return [];
}

function parseHeaderRow(lines: string[], playerName: string): ScannedGameField[] {
  let best: { fields: ScannedGameField[]; score: number } | null = null;
  const surname = compact(playerName.split(/\s+/).slice(-1)[0] || playerName);
  for (let headerIndex = 0; headerIndex < lines.length; headerIndex += 1) {
    const tokens = lines[headerIndex].split(/\s+/);
    const columns = tokens.flatMap(headerColumns);
    if (columns.length < 4) continue;
    for (let offset = 1; offset <= 10 && headerIndex + offset < lines.length; offset += 1) {
      const candidate = lines.slice(headerIndex + offset, Math.min(lines.length, headerIndex + offset + 2)).join(' ');
      const numbers = numericTokens(candidate);
      if (numbers.length < columns.length) continue;
      const aligned = numbers.slice(numbers.length - columns.length);
      const fields: ScannedGameField[] = [];
      columns.forEach((column, index) => {
        if (column === 'ignore') return;
        const value = Math.round(aligned[index]);
        const [min, max] = GAME_BOUNDS[column];
        if (value >= min && value <= max) fields.push({ key: column, value: String(value), confidence: 'High' });
      });
      const playerMatch = surname.length > 2 && compact(candidate).includes(surname);
      const score = fields.length * 2 + (playerMatch ? 20 : 0) - offset;
      if (!best || score > best.score) best = { fields, score };
    }
  }
  return best?.fields || [];
}

function parseLabeledGameFields(lines: string[]): ScannedGameField[] {
  const fields: ScannedGameField[] = [];
  for (const [key, aliases] of Object.entries(GAME_LABELS) as [Exclude<GameScanKey, 'opponent' | 'result' | 'importance'>, string[]][]) {
    const [min, max] = GAME_BOUNDS[key];
    for (let index = 0; index < lines.length; index += 1) {
      if (!findAliasIndex(lines[index], aliases)) continue;
      const found = numberNearAlias(lines, index, aliases, min, max);
      if (found) fields.push({ key, value: String(found.value), confidence: found.confidence });
      break;
    }
  }
  const text = comparable(lines.join(' '));
  const shooting: [RegExp, GameScanKey, GameScanKey][] = [
    [/(?:^|\s)FG(?:M-A)?\s*([0-9OIl]{1,2})\s*[-/]\s*([0-9OIl]{1,2})(?=\s|$)/, 'fgm', 'fga'],
    [/(?:^|\s)(?:3PT|3P)(?:M-A)?\s*([0-9OIl]{1,2})\s*[-/]\s*([0-9OIl]{1,2})(?=\s|$)/, 'tpm', 'tpa'],
    [/(?:^|\s)FT(?:M-A)?\s*([0-9OIl]{1,2})\s*[-/]\s*([0-9OIl]{1,2})(?=\s|$)/, 'ftm', 'fta']
  ];
  for (const [regex, madeKey, attemptKey] of shooting) {
    const match = regex.exec(text);
    if (!match) continue;
    const made = numberFromToken(match[1]);
    const attempted = numberFromToken(match[2]);
    if (made !== null && attempted !== null && made >= 0 && attempted >= made) {
      fields.push({ key: madeKey, value: String(made), confidence: 'High' });
      fields.push({ key: attemptKey, value: String(attempted), confidence: 'High' });
    }
  }
  return fields;
}

function parseScoreboard(lines: string[], ownTeam: string, teamCodes: string[]): ScannedGameField[] {
  const allowed = new Set(teamCodes.map(code => code.toUpperCase()));
  const teamScores: { code: string; score: number; line: number }[] = [];
  lines.forEach((line, lineIndex) => {
    const normalized = comparable(line);
    for (const team of teamMatches(normalized, teamCodes)) {
      const after = normalized.slice(team.index + team.matched.length, team.index + team.matched.length + 12);
      const before = normalized.slice(Math.max(0, team.index - 5), team.index);
      const score = [...numericTokens(after), ...numericTokens(before)].find(value => value >= 40 && value <= 250);
      if (score !== undefined) teamScores.push({ code: team.code, score: Math.round(score), line: lineIndex });
    }
  });
  for (let index = 0; index < lines.length - 1; index += 1) {
    const exactTeam = comparable(lines[index]);
    if (!allowed.has(exactTeam)) continue;
    const next = numericTokens(lines[index + 1]).find(value => value >= 40 && value <= 250);
    if (next !== undefined) teamScores.push({ code: exactTeam, score: Math.round(next), line: index });
  }
  const unique = dedupeBy(teamScores, item => `${item.code}:${item.score}`);
  const own = unique.find(item => item.code === ownTeam.toUpperCase());
  const opponent = unique.find(item => item.code !== ownTeam.toUpperCase() && Math.abs((own?.line ?? item.line) - item.line) <= 5)
    || unique.find(item => item.code !== ownTeam.toUpperCase());
  const fields: ScannedGameField[] = [];
  if (opponent) fields.push({ key: 'opponent', value: opponent.code, confidence: own ? 'High' : 'Medium' });
  if (own && opponent && own.score !== opponent.score) fields.push({ key: 'result', value: own.score > opponent.score ? 'W' : 'L', confidence: 'High' });
  if (!opponent) {
    const flattened = comparable(lines.join(' '));
    const versus = /(?:VS|VERSUS|@)\s+([A-Z]{3})\b/.exec(flattened);
    if (versus && allowed.has(versus[1]) && versus[1] !== ownTeam.toUpperCase()) fields.push({ key: 'opponent', value: versus[1], confidence: 'Medium' });
  }
  return fields;
}

export function parseGameScreen(rawText: string, context: { playerName: string; ownTeam: string; teamCodes?: string[] }): ScannedGameField[] {
  const lines = linesFrom(rawText);
  const teamCodes = context.teamCodes?.length ? context.teamCodes : Object.keys(NBA_TEAMS);
  const output = [
    ...parseHeaderRow(lines, context.playerName),
    ...parseLabeledGameFields(lines),
    ...parseScoreboard(lines, context.ownTeam, teamCodes)
  ];
  const allText = comparable(lines.join(' '));
  if (/\bFINALS?\b/.test(allText)) output.push({ key: 'importance', value: 'Finals', confidence: 'High' });
  else if (/\bELIMINATION\b/.test(allText)) output.push({ key: 'importance', value: 'Elimination', confidence: 'High' });
  else if (/\bPLAYOFFS?\b/.test(allText)) output.push({ key: 'importance', value: 'Playoff', confidence: 'High' });
  else if (/\bRIVALRY\b/.test(allText)) output.push({ key: 'importance', value: 'Rivalry', confidence: 'High' });
  if (!output.some(item => item.key === 'result')) {
    if (/\b(?:WIN|VICTORY)\b/.test(allText)) output.push({ key: 'result', value: 'W', confidence: 'Medium' });
    else if (/\b(?:LOSS|DEFEAT)\b/.test(allText)) output.push({ key: 'result', value: 'L', confidence: 'Medium' });
  }
  const priority: Record<ScanConfidence, number> = { High: 2, Medium: 1 };
  return output
    .sort((a, b) => priority[b.confidence] - priority[a.confidence])
    .filter((item, index, array) => array.findIndex(other => other.key === item.key) === index);
}

function cleanPlayerName(value: string): string {
  return value
    .replace(/^\s*(?:\d{1,2}[/-]\d{1,2}(?:[/-]\d{2,4})?|\d{4}[/-]\d{1,2}[/-]\d{1,2})\s*/i, '')
    .replace(/\b(?:THE|TRANSACTION|NEWS|BREAKING|OFFICIAL)\b/gi, ' ')
    .replace(/[^A-Za-zÀ-ÿ.' -]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .split(' ')
    .map(part => part ? part[0].toUpperCase() + part.slice(1).toLowerCase() : part)
    .join(' ');
}

function plausiblePlayerName(value: string): boolean {
  const words = value.split(/\s+/).filter(Boolean);
  if (words.length < 2 || words.length > 5 || value.length < 5 || value.length > 55) return false;
  return !/\b(?:TRADED|SIGNED|WAIVED|RELEASED|ACQUIRED|CLAIMED|ASSIGNED|CELTICS|LAKERS|WARRIORS|TRANSACTIONS?)\b/i.test(value);
}

function scanTransactionCandidate(sourceLine: string, allowedTeams: string[]): ScannedTransaction | null {
  const line = comparable(sourceLine);
  const teams = teamMatches(line, allowedTeams);
  const firstTeam = teams[0]?.code || '';
  const lastTeam = teams[teams.length - 1]?.code || '';
  let player = '';
  let type = '';
  let fromTeam = '';
  let toTeam = '';
  let match: RegExpExecArray | null;

  match = /^(.+?)\s+(?:WAS\s+|HAS\s+BEEN\s+)?TRADED\s+FROM\s+.+?\s+TO\s+.+$/.exec(line);
  if (match) {
    player = cleanPlayerName(match[1]); type = 'Trade'; fromTeam = firstTeam; toTeam = lastTeam;
  } else {
    match = /^.+?\s+TRADED\s+(.+?)\s+TO\s+.+$/.exec(line);
    if (match && teams.length >= 2) {
      player = cleanPlayerName(match[1]); type = 'Trade'; fromTeam = firstTeam; toTeam = lastTeam;
    }
  }
  if (!player) {
    match = /^(.+?)\s+(?:WAS\s+)?TRADED\s+TO\s+.+$/.exec(line);
    if (match) {
      player = cleanPlayerName(match[1]); type = 'Trade'; toTeam = lastTeam;
    }
  }
  if (!player) {
    match = /^(.+?)\s+(?:HAS\s+)?(?:SIGNED|AGREED\s+TO\s+SIGN)\s+(?:WITH|BY)\s+.+$/.exec(line);
    if (match) {
      player = cleanPlayerName(match[1]); type = 'Free Agent Signing'; fromTeam = 'FA'; toTeam = lastTeam;
    }
  }
  if (!player) {
    match = /^.+?\s+SIGNED\s+(.+)$/.exec(line);
    if (match && firstTeam) {
      player = cleanPlayerName(match[1].replace(new RegExp(teamMatches(match[1], allowedTeams)[0]?.matched || '$^'), ''));
      type = 'Free Agent Signing'; fromTeam = 'FA'; toTeam = firstTeam;
    }
  }
  if (!player) {
    match = /^(.+?)\s+(?:WAS\s+)?(?:WAIVED|RELEASED)\s+BY\s+.+$/.exec(line);
    if (match) {
      player = cleanPlayerName(match[1]); type = /WAIVED/.test(line) ? 'Waiver' : 'Release'; fromTeam = lastTeam; toTeam = 'FA';
    }
  }
  if (!player) {
    match = /^.+?\s+(?:WAIVED|RELEASED)\s+(.+)$/.exec(line);
    if (match && firstTeam) {
      player = cleanPlayerName(match[1]); type = /WAIVED/.test(line) ? 'Waiver' : 'Release'; fromTeam = firstTeam; toTeam = 'FA';
    }
  }
  if (!player) {
    match = /^(.+?)\s+(?:WAS\s+)?CLAIMED\s+(?:OFF\s+WAIVERS\s+)?BY\s+.+$/.exec(line);
    if (match) {
      player = cleanPlayerName(match[1]); type = 'Waiver Claim'; fromTeam = 'WAIVERS'; toTeam = lastTeam;
    }
  }
  if (!plausiblePlayerName(player) || (!fromTeam && !toTeam)) return null;
  return { type, player, fromTeam, toTeam, confidence: fromTeam && toTeam ? 'High' : 'Medium', sourceLine };
}

export function parseTransactionLog(rawText: string, teamCodes?: string[]): ScannedTransaction[] {
  const lines = linesFrom(rawText);
  const allowedTeams = teamCodes?.length ? teamCodes : Object.keys(NBA_TEAMS);
  const action = /\b(?:TRADED|SIGNED|WAIVED|RELEASED|CLAIMED)\b/i;
  const parsed: ScannedTransaction[] = [];
  lines.forEach((line, index) => {
    if (!action.test(line)) return;
    const direct = scanTransactionCandidate(line, allowedTeams);
    if (direct) { parsed.push(direct); return; }
    const candidates = [
      index > 0 ? `${lines[index - 1]} ${line}` : '',
      index < lines.length - 1 ? `${line} ${lines[index + 1]}` : '',
      index > 0 && index < lines.length - 1 ? `${lines[index - 1]} ${line} ${lines[index + 1]}` : ''
    ].filter(Boolean);
    const recovered = candidates.map(candidate => scanTransactionCandidate(candidate, allowedTeams)).find(Boolean);
    if (recovered) parsed.push(recovered);
  });
  return dedupeBy(
    parsed,
    item => `${compact(item.type)}:${compact(item.player)}:${item.fromTeam}:${item.toTeam}`
  );
}

export function parsePlayerOverview(rawText: string, teamCodes?: string[]): ScannedPlayerField[] {
  const lines = linesFrom(rawText);
  const fields: ScannedPlayerField[] = [];
  const numeric: { key: ScannedPlayerFieldKey; aliases: string[]; min: number; max: number }[] = [
    { key: 'overall', aliases: ['OVR', 'OVERALL'], min: 25, max: 99 },
    { key: 'potential', aliases: ['POT', 'POTENTIAL'], min: 25, max: 99 },
    { key: 'age', aliases: ['AGE'], min: 14, max: 50 },
    { key: 'jersey', aliases: ['JERSEY', 'JERSEY NUMBER', 'NUMBER'], min: 0, max: 99 },
    { key: 'weight', aliases: ['WEIGHT', 'WT'], min: 120, max: 400 }
  ];
  for (const item of numeric) {
    for (let index = 0; index < lines.length; index += 1) {
      if (!findAliasIndex(lines[index], item.aliases)) continue;
      const result = numberNearAlias(lines, index, item.aliases, item.min, item.max);
      if (result) fields.push({ key: item.key, value: result.value, confidence: result.confidence });
      break;
    }
  }
  const allText = lines.join(' ');
  if (!fields.some(field => field.key === 'jersey')) {
    const jersey = /(?:^|\s)#\s*([0-9OIl]{1,2})(?=\s|$)/.exec(allText);
    const value = jersey ? numberFromToken(jersey[1]) : null;
    if (value !== null && value >= 0 && value <= 99) fields.push({ key: 'jersey', value, confidence: 'Medium' });
  }
  const height = /\b([5-7])\s*['′]\s*([0-9]{1,2})\s*(?:["″]|\b)/.exec(allText)
    || /\bHEIGHT\s*[: -]?\s*([5-7])\s*[-]\s*([0-9]{1,2})\b/i.exec(allText);
  if (height && Number(height[2]) <= 11) fields.push({ key: 'height', value: `${height[1]}'${height[2]}"`, confidence: 'High' });
  const position = /(?:\bPOSITION\b\s*[: -]?\s*)?\b(PG|SG|SF|PF|C)\b/i.exec(allText);
  if (position) fields.push({ key: 'position', value: upper(position[1]), confidence: upper(allText).includes('POSITION') ? 'High' : 'Medium' });
  const teams = teamMatches(allText, teamCodes);
  if (teams.length) fields.push({ key: 'team', value: teams[0].code, confidence: 'Medium' });
  return dedupeBy(fields, field => field.key);
}

export function humanizeScanKey(key: GameScanKey | ScannedPlayerFieldKey): string {
  const labels: Record<string, string> = {
    opponent: 'Opponent', result: 'Result', importance: 'Game importance', pts: 'PTS', reb: 'REB', ast: 'AST', stl: 'STL', blk: 'BLK', tov: 'TOV',
    fgm: 'FGM', fga: 'FGA', tpm: '3PM', tpa: '3PA', ftm: 'FTM', fta: 'FTA', minutes: 'MIN', plusMinus: '+/−',
    team: 'Team', position: 'Position', overall: 'Overall', potential: 'Potential', age: 'Age', jersey: 'Jersey #', height: 'Height', weight: 'Weight'
  };
  return labels[key] || key;
}
