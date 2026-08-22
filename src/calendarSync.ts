import type { CareerState, Game, ScheduleGame } from './model';

export function seasonDateRange(seasonStart:number):{start:string;end:string}{
  return {start:`${seasonStart}-07-01`,end:`${seasonStart+1}-06-30`};
}

export function playerScheduleGames(state:CareerState):ScheduleGame[]{
  const team=state.player.team.toUpperCase();
  if(!team)return [];
  const {start,end}=seasonDateRange(state.settings.myNBASeasonStart);
  return state.scheduleGames
    .filter(game=>game.era===state.settings.myNBAEra&&game.date>=start&&game.date<=end&&[game.awayTeam,game.homeTeam].includes(team))
    .sort((a,b)=>a.date.localeCompare(b.date)||a.id.localeCompare(b.id));
}

export function gameForSchedule(state:CareerState,scheduleGameId:string):Game|undefined{
  return state.games.find(game=>game.scheduleGameId===scheduleGameId);
}

export function pendingPlayerScheduleGames(state:CareerState):ScheduleGame[]{
  const logged=new Set(state.games.map(game=>game.scheduleGameId).filter(Boolean));
  return playerScheduleGames(state).filter(game=>!logged.has(game.id));
}

export function scheduleOpponent(game:ScheduleGame,team:string):string{
  return game.homeTeam===team.toUpperCase()?game.awayTeam:game.homeTeam;
}

export function scheduleLocation(game:ScheduleGame,team:string):'Home'|'Away'{
  return game.homeTeam===team.toUpperCase()?'Home':'Away';
}

export function scheduleProgress(state:CareerState):{total:number;logged:number;remaining:number}{
  const games=playerScheduleGames(state);
  const loggedIds=new Set(state.games.map(game=>game.scheduleGameId).filter(Boolean));
  const logged=games.filter(game=>loggedIds.has(game.id)).length;
  return {total:games.length,logged,remaining:games.length-logged};
}

