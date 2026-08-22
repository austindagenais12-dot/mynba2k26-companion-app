import assert from 'node:assert/strict';
import {
  parseAttributeScreen,
  parseBadgeScreen,
  parseGameScreen,
  parsePlayerOverview,
  parseTransactionLog
} from '../src/screenScan.ts';

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

console.log('Screen scanner parser verification passed.');
