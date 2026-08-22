import type { MyNBAEra } from './model';

export type LeagueHistoryCategory='Expansion'|'Relocation'|'Rebrand'|'Rules'|'Competition'|'Draft'|'Structure';
export type LeagueHistoryEvent={id:string;seasonStart:number;category:LeagueHistoryCategory;title:string;detail:string};
export type HistoricalTeam={code:string;name:string;firstSeason:number;lastSeason?:number};
export type LeagueRuleSnapshot={label:string;value:string;detail:string};

export const LAST_REAL_SEASON_START=2025;
export const ERA_START_YEARS:Record<MyNBAEra,number>={
  'Magic vs Bird':1983,Jordan:1991,Kobe:2002,LeBron:2010,Steph:2016,Modern:2025
};

// Season years use the opening year: 1988 means the 1988-89 season.
const HISTORICAL_TEAMS:HistoricalTeam[]=[
  {code:'ATL',name:'Atlanta Hawks',firstSeason:1968},
  {code:'BOS',name:'Boston Celtics',firstSeason:1946},
  {code:'CHI',name:'Chicago Bulls',firstSeason:1966},
  {code:'CLE',name:'Cleveland Cavaliers',firstSeason:1970},
  {code:'DAL',name:'Dallas Mavericks',firstSeason:1980},
  {code:'DEN',name:'Denver Nuggets',firstSeason:1976},
  {code:'DET',name:'Detroit Pistons',firstSeason:1957},
  {code:'GSW',name:'Golden State Warriors',firstSeason:1971},
  {code:'HOU',name:'Houston Rockets',firstSeason:1971},
  {code:'IND',name:'Indiana Pacers',firstSeason:1976},
  {code:'LAL',name:'Los Angeles Lakers',firstSeason:1960},
  {code:'MIL',name:'Milwaukee Bucks',firstSeason:1968},
  {code:'NYK',name:'New York Knicks',firstSeason:1946},
  {code:'PHI',name:'Philadelphia 76ers',firstSeason:1963},
  {code:'PHX',name:'Phoenix Suns',firstSeason:1968},
  {code:'POR',name:'Portland Trail Blazers',firstSeason:1970},
  {code:'SAS',name:'San Antonio Spurs',firstSeason:1976},
  {code:'UTA',name:'Utah Jazz',firstSeason:1979},
  {code:'SDC',name:'San Diego Clippers',firstSeason:1978,lastSeason:1983},
  {code:'LAC',name:'Los Angeles Clippers',firstSeason:1984},
  {code:'KCK',name:'Kansas City Kings',firstSeason:1975,lastSeason:1984},
  {code:'SAC',name:'Sacramento Kings',firstSeason:1985},
  {code:'NJN',name:'New Jersey Nets',firstSeason:1977,lastSeason:2011},
  {code:'BKN',name:'Brooklyn Nets',firstSeason:2012},
  {code:'WSB',name:'Washington Bullets',firstSeason:1974,lastSeason:1996},
  {code:'WAS',name:'Washington Wizards',firstSeason:1997},
  {code:'SEA',name:'Seattle SuperSonics',firstSeason:1967,lastSeason:2007},
  {code:'OKC',name:'Oklahoma City Thunder',firstSeason:2008},
  {code:'CHH',name:'Charlotte Hornets',firstSeason:1988,lastSeason:2001},
  {code:'NOH',name:'New Orleans Hornets',firstSeason:2002,lastSeason:2012},
  {code:'NOP',name:'New Orleans Pelicans',firstSeason:2013},
  {code:'MIA',name:'Miami Heat',firstSeason:1988},
  {code:'MIN',name:'Minnesota Timberwolves',firstSeason:1989},
  {code:'ORL',name:'Orlando Magic',firstSeason:1989},
  {code:'TOR',name:'Toronto Raptors',firstSeason:1995},
  {code:'VAN',name:'Vancouver Grizzlies',firstSeason:1995,lastSeason:2000},
  {code:'MEM',name:'Memphis Grizzlies',firstSeason:2001},
  {code:'CHA',name:'Charlotte Bobcats',firstSeason:2004}
];

export const LEAGUE_HISTORY_EVENTS:LeagueHistoryEvent[]=[
  {id:'1984-lac',seasonStart:1984,category:'Relocation',title:'Clippers move to Los Angeles',detail:'The San Diego Clippers become the Los Angeles Clippers for 1984-85.'},
  {id:'1984-cap',seasonStart:1984,category:'Structure',title:'Salary cap era begins',detail:'The NBA salary cap takes effect for the 1984-85 season.'},
  {id:'1984-lottery',seasonStart:1984,category:'Draft',title:'Draft Lottery introduced',detail:'The first NBA Draft Lottery is used for the 1985 Draft.'},
  {id:'1984-finals',seasonStart:1984,category:'Competition',title:'Finals changes to 2-3-2',detail:'The NBA Finals adopts the 2-3-2 home-court format beginning with the 1985 Finals.'},
  {id:'1985-sac',seasonStart:1985,category:'Relocation',title:'Kings move to Sacramento',detail:'The Kansas City Kings become the Sacramento Kings for 1985-86.'},
  {id:'1988-expansion',seasonStart:1988,category:'Expansion',title:'Charlotte and Miami join',detail:'The Charlotte Hornets and Miami Heat expand the league from 23 to 25 teams.'},
  {id:'1989-expansion',seasonStart:1989,category:'Expansion',title:'Minnesota and Orlando join',detail:'The Timberwolves and Magic expand the league from 25 to 27 teams.'},
  {id:'1989-lottery',seasonStart:1989,category:'Draft',title:'Weighted Draft Lottery begins',detail:'The 1990 Draft Lottery introduces weighted odds for non-playoff teams.'},
  {id:'1990-clock',seasonStart:1990,category:'Rules',title:'Trent Tucker timing rule',detail:'A normal catch-and-shoot attempt now requires at least 0.3 seconds.'},
  {id:'1994-line',seasonStart:1994,category:'Rules',title:'Three-point line shortened',detail:'The arc becomes a uniform 22 feet for the 1994-95 through 1996-97 seasons.'},
  {id:'1995-expansion',seasonStart:1995,category:'Expansion',title:'Toronto and Vancouver join',detail:'The Raptors and Grizzlies enter the NBA, bringing the league to 29 teams.'},
  {id:'1997-wizards',seasonStart:1997,category:'Rebrand',title:'Bullets become Wizards',detail:'Washington adopts the Wizards name for the 1997-98 season.'},
  {id:'1997-line',seasonStart:1997,category:'Rules',title:'Three-point arc restored',detail:'The NBA restores the 23-foot-9-inch arc, with 22-foot corners.'},
  {id:'1997-restricted',seasonStart:1997,category:'Rules',title:'Restricted area added',detail:'The no-charge semicircle is introduced beneath the basket.'},
  {id:'2001-memphis',seasonStart:2001,category:'Relocation',title:'Grizzlies move to Memphis',detail:'The Vancouver Grizzlies become the Memphis Grizzlies for 2001-02.'},
  {id:'2001-defense',seasonStart:2001,category:'Rules',title:'Zone-defense rules modernize',detail:'Illegal-defense guidelines are removed; defensive three seconds and an eight-second backcourt count begin.'},
  {id:'2002-hornets',seasonStart:2002,category:'Relocation',title:'Hornets move to New Orleans',detail:'The original Charlotte Hornets franchise plays as the New Orleans Hornets.'},
  {id:'2002-playoffs',seasonStart:2002,category:'Competition',title:'First round becomes best-of-seven',detail:'Every 2003 playoff round uses a best-of-seven series.'},
  {id:'2002-replay',seasonStart:2002,category:'Rules',title:'Instant replay arrives',detail:'Replay review begins for end-of-period made shots and timing decisions.'},
  {id:'2004-charlotte',seasonStart:2004,category:'Expansion',title:'Charlotte Bobcats join',detail:'Charlotte returns as an expansion team and the NBA reaches 30 teams.'},
  {id:'2004-divisions',seasonStart:2004,category:'Structure',title:'Six-division alignment begins',detail:'Each conference changes from two divisions to three.'},
  {id:'2004-handcheck',seasonStart:2004,category:'Rules',title:'Hand-checking enforcement tightens',detail:'Perimeter contact rules are emphasized to protect freedom of movement.'},
  {id:'2005-nok',seasonStart:2005,category:'Relocation',title:'Hornets temporarily play in Oklahoma City',detail:'After Hurricane Katrina, most home games are played in Oklahoma City for two seasons.'},
  {id:'2007-no-return',seasonStart:2007,category:'Relocation',title:'Hornets return to New Orleans',detail:'The franchise resumes a full-time New Orleans home schedule.'},
  {id:'2008-okc',seasonStart:2008,category:'Relocation',title:'SuperSonics become Thunder',detail:'Seattle relocates and begins play as the Oklahoma City Thunder.'},
  {id:'2012-brooklyn',seasonStart:2012,category:'Relocation',title:'Nets move to Brooklyn',detail:'The New Jersey Nets become the Brooklyn Nets.'},
  {id:'2013-pelicans',seasonStart:2013,category:'Rebrand',title:'Hornets become Pelicans',detail:'New Orleans adopts the Pelicans name for 2013-14.'},
  {id:'2013-finals',seasonStart:2013,category:'Competition',title:'Finals returns to 2-2-1-1-1',detail:'The 2014 NBA Finals restores the same home-court sequence used in earlier rounds.'},
  {id:'2014-hornets',seasonStart:2014,category:'Rebrand',title:'Bobcats become Hornets',detail:'Charlotte adopts the Hornets name and reclaimed franchise history.'},
  {id:'2018-shotclock',seasonStart:2018,category:'Rules',title:'Offensive-rebound reset becomes 14',detail:'The shot clock resets to 14 seconds instead of 24 after an offensive rebound.'},
  {id:'2018-lottery',seasonStart:2018,category:'Draft',title:'Draft Lottery odds flatten',detail:'Beginning with the 2019 Draft, the three worst records each receive 14% top-pick odds and four picks are drawn.'},
  {id:'2019-challenge',seasonStart:2019,category:'Rules',title:"Coach's Challenge introduced",detail:'Each team may use a timeout to challenge specified calls.'},
  {id:'2020-playin',seasonStart:2020,category:'Competition',title:'Play-In Tournament begins',detail:'Seeds 7 through 10 compete for the final two playoff spots in each conference.'},
  {id:'2022-takefoul',seasonStart:2022,category:'Rules',title:'Transition take-foul penalty',detail:'The offended team receives one free throw and keeps possession for qualifying take fouls.'},
  {id:'2023-cup',seasonStart:2023,category:'Competition',title:'In-Season Tournament begins',detail:'All 30 teams enter group play and a knockout tournament, now known as the NBA Cup.'},
  {id:'2023-challenge',seasonStart:2023,category:'Rules',title:'Successful challenge earns a second',detail:'A team receives another challenge when its first challenge succeeds.'},
  {id:'2024-replay',seasonStart:2024,category:'Rules',title:'Out-of-bounds replay expands',detail:'A challenge review may consider certain fouls immediately connected to an out-of-bounds play.'},
  {id:'2025-heave',seasonStart:2025,category:'Rules',title:'End-of-period heave scoring changes',detail:'Qualifying long missed heaves count as team attempts rather than individual missed field goals.'}
];

export function seasonLabel(startYear:number):string{return `${startYear}-${String((startYear+1)%100).padStart(2,'0')}`}

export function clampSeasonForEra(era:MyNBAEra,seasonStart:number):number{
  const start=ERA_START_YEARS[era];
  return Math.max(start,Math.min(LAST_REAL_SEASON_START,Math.round(seasonStart)||start));
}

export function teamsForSeason(seasonStart:number):string[]{
  return HISTORICAL_TEAMS.filter(team=>team.firstSeason<=seasonStart&&(team.lastSeason===undefined||team.lastSeason>=seasonStart)).map(team=>team.code).sort();
}

export function teamNameForSeason(code:string,seasonStart:number):string{
  if(code==='CHA')return seasonStart>=2014?'Charlotte Hornets':'Charlotte Bobcats';
  if(code==='NOH'&&(seasonStart===2005||seasonStart===2006))return 'New Orleans/Oklahoma City Hornets';
  const team=HISTORICAL_TEAMS.find(item=>item.code===code&&item.firstSeason<=seasonStart&&(item.lastSeason===undefined||item.lastSeason>=seasonStart));
  return team?.name||code;
}

export function eventsForSeason(seasonStart:number):LeagueHistoryEvent[]{return LEAGUE_HISTORY_EVENTS.filter(event=>event.seasonStart===seasonStart)}
export function nextHistoryEvents(seasonStart:number,limit=4):LeagueHistoryEvent[]{return LEAGUE_HISTORY_EVENTS.filter(event=>event.seasonStart>seasonStart).sort((a,b)=>a.seasonStart-b.seasonStart).slice(0,limit)}

export function leagueRulesForSeason(seasonStart:number):LeagueRuleSnapshot[]{
  const draft=seasonStart<1984?'Conference coin flip':seasonStart<1989?'Early Draft Lottery':seasonStart<1994?'Weighted lottery':seasonStart<2018?'Top-three weighted lottery':'Flattened top-four lottery';
  const challenge=seasonStart<2019?'No Coach’s Challenge':seasonStart<2023?'One challenge':'Second challenge after a successful first';
  return [
    {label:'League size',value:`${teamsForSeason(seasonStart).length} teams`,detail:seasonStart<2004?'Expansion and franchise moves follow the historical timeline.':'The 30-team alignment is active.'},
    {label:'NBA Finals',value:seasonStart>=1984&&seasonStart<=2012?'2-3-2 format':'2-2-1-1-1 format',detail:'Home-court sequence for the championship series.'},
    {label:'First round',value:seasonStart>=2002?'Best of 7':'Best of 5',detail:'Historical playoff-series length.'},
    {label:'Defense',value:seasonStart>=2001?'Zone legal + defensive 3 seconds':'Illegal-defense guidelines',detail:seasonStart>=2001?'Modern zone concepts are permitted.':'Era-specific illegal-defense restrictions apply.'},
    {label:'Backcourt count',value:seasonStart>=2001?'8 seconds':'10 seconds',detail:'Time allowed to advance the ball into the frontcourt.'},
    {label:'Offensive-rebound clock',value:seasonStart>=2018?'14-second reset':'24-second reset',detail:'Shot-clock value after an offensive rebound.'},
    {label:'Three-point arc',value:seasonStart>=1994&&seasonStart<=1996?'Uniform 22 feet':'23′9″ / 22-foot corners',detail:'Court geometry for the selected season.'},
    {label:'Draft order',value:draft,detail:seasonStart>=2018?'The three worst teams have equal 14% top-pick odds.':'The lottery format follows its historical period.'},
    {label:"Coach's Challenge",value:challenge,detail:seasonStart<2019?'Replay is official-triggered only.':'Challenge access follows the selected season.'},
    {label:'Postseason access',value:seasonStart>=2020?'Play-In Tournament active':'Top eight qualify directly',detail:seasonStart>=2020?'Seeds 7-10 contest the final playoff berths.':'No Play-In Tournament.'},
    {label:'NBA Cup',value:seasonStart>=2023?'Active':'Not yet introduced',detail:'The in-season competition begins in 2023-24.'}
  ];
}
