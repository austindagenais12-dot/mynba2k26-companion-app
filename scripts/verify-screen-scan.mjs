import assert from 'node:assert/strict';
import {
  parseAttributeScreen,
  parseBadgeScreen,
  parseDraftClass,
  parseGameScreen,
  parsePlayerOverview,
  parseScheduleScreens,
  parseTransactionLog
} from '../src/screenScan.ts';
import { MYNBA_ERAS, rosterForTeam, teamsForEra } from '../src/eraRosters.ts';
import { NBA_SCHEDULE_2025_26 } from '../src/nbaSchedule2025.ts';
import { eventsForSeason, leagueRulesForSeason, teamNameForSeason, teamsForSeason } from '../src/leagueHistory.ts';
import { pendingPlayerScheduleGames, playerScheduleGames, scheduleLocation, scheduleOpponent, scheduleProgress } from '../src/calendarSync.ts';

const game = parseGameScreen(`
FINAL
TOR 112
BOS 108
MIN PTS REB AST STL BLK TOV FGM FGA FG% 3PM 3PA 3P% FTM FTA FT% +/-
Marcus Carter 34 27 5 9 2 1 3 10 18 55.6 4 8 50.0 3 4 75.0 +12
`, { playerName: 'Marcus Carter', ownTeam: 'TOR' });
const gameMap = Object.fromEntries(game.map(field => [field.key, field.value]));
assert.equal(gameMap.pts, '27');
assert.equal(gameMap.fgm, '10');
assert.equal(gameMap.opponent, 'BOS');
assert.equal(gameMap.result, 'W');

const pairedGame = parseGameScreen(`
MIN PTS REB AST STL BLK TO FGM-A 3PM-A FTM-A OREB DREB PF +/-
Marcus Carter 36 31 7 11 1 0 2 12-21 5-9 2-2 1 6 2 +14
`, { playerName: 'Marcus Carter', ownTeam: 'TOR' });
const pairedGameMap = Object.fromEntries(pairedGame.map(field => [field.key, field.value]));
assert.equal(pairedGameMap.pts, '31');
assert.equal(pairedGameMap.fgm, '12');
assert.equal(pairedGameMap.fga, '21');
assert.equal(pairedGameMap.tpm, '5');
assert.equal(pairedGameMap.tpa, '9');
assert.equal(pairedGameMap.plusMinus, '14');

const attributes = parseAttributeScreen(`
FINISHING
Close Shot 68
Driving Layup 79
Driving Dunk 82
PLAYMAKING
Ball Handle 85
Speed With Ball 83
PHYSICALS
Speed 88
`, ['Close Shot', 'Driving Layup', 'Driving Dunk', 'Ball Handle', 'Speed With Ball', 'Speed']);
const attributeMap = Object.fromEntries(attributes.map(attribute => [attribute.name, attribute.rating]));
assert.equal(attributeMap['Driving Dunk'], 82);
assert.equal(attributeMap['Speed With Ball'], 83);
assert.equal(attributeMap.Speed, 88);

const badges = parseBadgeScreen(`
Limitless Range
Gold
Handles For Days — Hall of Fame
On-Ball Menace Silver
`, ['Limitless Range', 'Handles For Days', 'On-Ball Menace']);
const badgeMap = Object.fromEntries(badges.map(badge => [badge.name, badge.level]));
assert.equal(badgeMap['Limitless Range'], 'Gold');
assert.equal(badgeMap['Handles For Days'], 'HOF');
assert.equal(badgeMap['On-Ball Menace'], 'Silver');

const player = parsePlayerOverview(`
MARCUS CARTER
TORONTO RAPTORS
POSITION PG
OVR 84
POTENTIAL 92
AGE 22
HEIGHT 6'3"
WEIGHT 190
# 3
`);
const playerMap = Object.fromEntries(player.map(field => [field.key, field.value]));
assert.equal(playerMap.team, 'TOR');
assert.equal(playerMap.position, 'PG');
assert.equal(playerMap.overall, 84);
assert.equal(playerMap.height, `6'3"`);

const transactions = parseTransactionLog(`
Boston Celtics traded Jayson Tatum to Los Angeles Lakers
Chris Paul signed with Toronto Raptors
Miami Heat waived Duncan Robinson
`);
assert.equal(transactions.length, 3);
assert.deepEqual(
  transactions.map(transaction => [transaction.type, transaction.player, transaction.fromTeam, transaction.toTeam]),
  [
    ['Trade', 'Jayson Tatum', 'BOS', 'LAL'],
    ['Free Agent Signing', 'Chris Paul', 'FA', 'TOR'],
    ['Waiver', 'Duncan Robinson', 'MIA', 'FA']
  ]
);

const prospects=parseDraftClass(`
DRAFT CLASS  NAME POS AGE OVR POT
1 Cooper Flagg SF 18 78 94 TOP 5
2 Dylan Harper PG 19 76 92 LOTTERY
`);
assert.equal(prospects.length,2);
assert.equal(prospects[0].name,'Cooper Flagg');
assert.equal(prospects[0].rank,1);
assert.equal(prospects[0].potential,94);

const schedule=parseScheduleScreens(`
OCT 22 @ BOS
OCT 24 VS NYK
NOV 1 AWAY LAL
`,{teamCode:'TOR',seasonStartYear:2025,teamCodes:['TOR','BOS','NYK','LAL']});
assert.deepEqual(schedule.map(game=>[game.date,game.opponent,game.location]),[
  ['2025-10-22','BOS','Away'],
  ['2025-10-24','NYK','Home'],
  ['2025-11-01','LAL','Away']
]);

assert.equal(NBA_SCHEDULE_2025_26.length,1230);
for(const team of teamsForSeason(2025)){
  assert.equal(NBA_SCHEDULE_2025_26.filter(game=>game.awayTeam===team||game.homeTeam===team).length,82,`${team} schedule must contain 82 games`);
}
assert.equal(teamsForSeason(1983).length,23);
assert.equal(teamsForSeason(1988).length,25);
assert.equal(teamsForSeason(1989).length,27);
assert.equal(teamsForSeason(1995).length,29);
assert.equal(teamsForSeason(2004).length,30);
assert.equal(teamNameForSeason('CHA',2004),'Charlotte Bobcats');
assert.equal(teamNameForSeason('CHA',2014),'Charlotte Hornets');
assert.ok(eventsForSeason(2008).some(event=>event.title.includes('SuperSonics')));
assert.ok(leagueRulesForSeason(2001).some(rule=>rule.label==='Backcourt count'&&rule.value==='8 seconds'));
for(const era of MYNBA_ERAS){
  assert.ok(teamsForEra(era.id).length>=23,`${era.label} must include its opening teams`);
  assert.ok(rosterForTeam(era.id,teamsForEra(era.id)[0]).length>0,`${era.label} opening roster must be populated`);
}

const connectedState={
  player:{team:'TOR'},settings:{myNBAEra:'Modern',myNBASeasonStart:2025},
  scheduleGames:[
    {id:'cal-1',era:'Modern',date:'2025-10-22',awayTeam:'TOR',homeTeam:'BOS'},
    {id:'cal-2',era:'Modern',date:'2025-10-24',awayTeam:'NYK',homeTeam:'TOR'},
    {id:'other-team',era:'Modern',date:'2025-10-24',awayTeam:'LAL',homeTeam:'BOS'}
  ],
  games:[{id:'game-1',scheduleGameId:'cal-1'}]
};
assert.equal(playerScheduleGames(connectedState).length,2);
assert.equal(pendingPlayerScheduleGames(connectedState).length,1);
assert.equal(scheduleOpponent(connectedState.scheduleGames[0],'TOR'),'BOS');
assert.equal(scheduleLocation(connectedState.scheduleGames[0],'TOR'),'Away');
assert.deepEqual(scheduleProgress(connectedState),{total:2,logged:1,remaining:1});

console.log('Screen scanner, connected calendar, era roster and historical timeline verification passed.');
