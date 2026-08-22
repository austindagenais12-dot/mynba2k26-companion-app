import type { CareerState, Game, PhoneContact, PhoneContactRole, PhoneMessage } from './model';
import { ERA_ROSTERS, rosterForTeam } from './eraRosters';

export const PHONE_CONTACT_ROLES:PhoneContactRole[]=['NBA Player','Coach','Scout','Agent','Family','Friend','Trainer','Executive','Media'];

const clone=<T,>(value:T):T=>JSON.parse(JSON.stringify(value));
const id=(prefix:string)=>`${prefix}-${Date.now()}-${Math.random().toString(36).slice(2,8)}`;
const clean=(value:string)=>value.trim().replace(/\s+/g,' ');

export function createStarterPhoneData(date:string):{contacts:PhoneContact[];messages:PhoneMessage[]}{
  const contacts:PhoneContact[]=[
    {id:'phone-family',name:'Family Member',role:'Family',relationshipId:'r1',favorite:true},
    {id:'phone-coach-reynolds',name:'Coach Reynolds',role:'Coach',relationshipId:'r2',favorite:true},
    {id:'phone-scout-morgan',name:'Jordan Morgan',role:'Scout',verified:true}
  ];
  const messages:PhoneMessage[]=[
    {id:'phone-message-scout-welcome',contactId:'phone-scout-morgan',date,body:'I will be following your development. Keep your game film and results current.',direction:'Incoming',read:false,kind:'Career'},
    {id:'phone-message-coach-welcome',contactId:'phone-coach-reynolds',date,body:'Stay ready. The work you put in between games is what changes your career.',direction:'Incoming',read:false,kind:'Career'},
    {id:'phone-message-family-welcome',contactId:'phone-family',date,body:'Proud of you. Keep me posted after every game ❤️',direction:'Incoming',read:true,kind:'Career'}
  ];
  return {contacts,messages};
}

function ensureContact(s:CareerState,name:string,role:PhoneContactRole,team?:string,relationshipId?:string,verified=false):PhoneContact{
  const normalized=clean(name).toLowerCase();
  const existing=s.phoneContacts.find(contact=>contact.name.toLowerCase()===normalized&&contact.role===role);
  if(existing){
    if(team)existing.team=team.toUpperCase();
    if(relationshipId)existing.relationshipId=relationshipId;
    if(verified)existing.verified=true;
    return existing;
  }
  const contact:PhoneContact={id:id('contact'),name:clean(name),role,team:team?.toUpperCase(),relationshipId,verified};
  s.phoneContacts.push(contact);
  return contact;
}

function addNotification(s:CareerState,contact:PhoneContact,body:string){
  s.notifications.unshift({id:id('nt'),date:s.player.currentDate,icon:'💬',title:contact.name,body,read:false});
}

function receive(s:CareerState,contact:PhoneContact,body:string,kind:PhoneMessage['kind']='Career',related?:{gameId?:string;scheduleGameId?:string},notify=true){
  s.phoneMessages.unshift({
    id:id('message'),contactId:contact.id,date:s.player.currentDate,body,direction:'Incoming',read:false,kind,
    relatedGameId:related?.gameId,relatedScheduleGameId:related?.scheduleGameId
  });
  if(notify)addNotification(s,contact,body);
}

function rosterPlayer(s:CareerState,team?:string,offset=0){
  const preferred=team?rosterForTeam(s.settings.myNBAEra,team.toUpperCase()):[];
  const pool=preferred.length?preferred:ERA_ROSTERS.filter(player=>player.era===s.settings.myNBAEra);
  if(!pool.length)return undefined;
  return pool[Math.abs(offset)%pool.length];
}

export type PhoneCareerEvent='PreNBAProgress'|'DraftDeclared'|'Drafted'|'GameLogged'|'SeasonAdvanced'|'TeamChanged';

export function addPhoneCareerEvent(s:CareerState,event:PhoneCareerEvent,details?:{game?:Game;oldTeam?:string;newTeam?:string}){
  if(!Array.isArray(s.phoneContacts))s.phoneContacts=[];
  if(!Array.isArray(s.phoneMessages))s.phoneMessages=[];
  if(event==='PreNBAProgress'){
    const scout=ensureContact(s,'Jordan Morgan','Scout',undefined,undefined,true);
    receive(s,scout,`${s.player.name}, your latest stretch is on my radar. Keep stacking good decisions, not just numbers.`);
    return;
  }
  if(event==='DraftDeclared'){
    const scout=ensureContact(s,'Jordan Morgan','Scout',undefined,undefined,true);
    receive(s,scout,`Declaration is in. Teams will dig into every detail now—film, interviews and how you respond under pressure.`);
    return;
  }
  if(event==='Drafted'){
    const coach=ensureContact(s,'NBA Head Coach','Coach',s.player.team,undefined,true);
    receive(s,coach,`Welcome to ${s.player.team}. Come ready to learn the system and earn every minute.`);
    const teammate=rosterPlayer(s,s.player.team,s.player.draftPick||0);
    if(teammate){
      const contact=ensureContact(s,teammate.name,'NBA Player',teammate.team,undefined,true);
      receive(s,contact,`Welcome to the team. Hit me when you get settled and we will get some work in.`);
    }
    return;
  }
  if(event==='GameLogged'&&details?.game){
    const game=details.game;
    const coach=ensureContact(s,'NBA Head Coach','Coach',s.player.team,undefined,true);
    const coachBody=game.result==='W'
      ? game.tov>4?'Good win. Clean up the turnovers before the next one.':`Good work tonight. Recover, review the film and be ready for the next matchup.`
      : game.pts>=25?`You competed, but we need the complete result. Learn from the film and turn the page.`:`Short memory. Own the details from tonight and respond in the next game.`;
    receive(s,coach,coachBody,'Career',{gameId:game.id,scheduleGameId:game.scheduleGameId});
    if(game.importance!=='Regular'||game.pts>=30||s.games.length%4===0){
      const peer=rosterPlayer(s,game.opponent,s.games.length+game.pts);
      if(peer){
        const contact=ensureContact(s,peer.name,'NBA Player',peer.team,undefined,true);
        receive(s,contact,game.result==='W'?`Good battle tonight. We will see you again.`:`Respect. You made us work for that one.`,'Career',{gameId:game.id,scheduleGameId:game.scheduleGameId});
      }
    }
    return;
  }
  if(event==='SeasonAdvanced'){
    const name=s.player.agentName&&s.player.agentName!=='Unrepresented'?s.player.agentName:'Avery Brooks';
    const agent=ensureContact(s,name,'Agent',undefined,undefined,true);
    receive(s,agent,`New season, new leverage. Let us set priorities before the calendar gets busy.`);
    return;
  }
  if(event==='TeamChanged'){
    const coach=ensureContact(s,'NBA Head Coach','Coach',details?.newTeam||s.player.team,undefined,true);
    receive(s,coach,`Welcome to ${details?.newTeam||s.player.team}. I will send your role expectations after we meet.`);
  }
}

export function addPhoneContact(state:CareerState,input:{name:string;role:PhoneContactRole;team?:string}):CareerState{
  const s=clone(state);const name=clean(input.name);if(!name)return s;
  const before=s.phoneContacts.length;const contact=ensureContact(s,name,input.role,input.team,undefined,input.role==='NBA Player'||input.role==='Coach'||input.role==='Scout');
  if(s.phoneContacts.length>before){
    receive(s,contact,firstMessageFor(contact),'Check-in');
  }
  return s;
}

export function discoverPhoneContact(state:CareerState):CareerState{
  const s=clone(state);const existing=new Set(s.phoneContacts.map(contact=>contact.name.toLowerCase()));
  const ownTeam=rosterForTeam(s.settings.myNBAEra,s.player.team);
  const eraPool=ERA_ROSTERS.filter(player=>player.era===s.settings.myNBAEra);
  const candidates=[...ownTeam,...eraPool].filter(player=>!existing.has(player.name.toLowerCase()));
  const player=candidates[(s.phoneContacts.length+s.games.length)%Math.max(1,candidates.length)];
  if(player){
    const contact=ensureContact(s,player.name,'NBA Player',player.team,undefined,true);
    receive(s,contact,player.team===s.player.team?'Save my number. Let us get some work in after practice.':'Good to connect. I will be following what you do this season.','Check-in');
  }else{
    const scout=ensureContact(s,`League Scout ${s.phoneContacts.length+1}`,'Scout',undefined,undefined,true);
    receive(s,scout,firstMessageFor(scout),'Check-in');
  }
  return s;
}

function firstMessageFor(contact:PhoneContact):string{
  if(contact.role==='Coach')return 'Save my number. I will reach out about your role, preparation and film.';
  if(contact.role==='Scout')return 'I will be tracking your development throughout the season.';
  if(contact.role==='Agent')return 'Keep me updated. We will handle the business side without losing focus on basketball.';
  if(contact.role==='NBA Player')return 'Good to connect. Let us keep in touch this season.';
  if(contact.role==='Trainer')return 'Send me your recovery notes after games and practices.';
  if(contact.role==='Executive')return 'I look forward to following your progress.';
  if(contact.role==='Media')return 'I may reach out when there is a story worth discussing.';
  return 'Save my number. I am always here if you need me.';
}

function responseFor(contact:PhoneContact):string{
  const responses:Record<PhoneContactRole,string[]>={
    'NBA Player':['For sure. Stay locked in and I will see you at the gym.','Respect. Keep putting the work in.','Sounds good. We will talk after the next one.'],
    Coach:['Good. Preparation has to show up in the details.','That is what I wanted to hear. Be ready at film.','Understood. Stay focused on the next assignment.'],
    Scout:['Noted. Your consistency will tell the story.','Good answer. I will keep following your progress.','The film will back it up if the habits are real.'],
    Agent:['I have it handled. Focus on playing well.','Good. I will update you when there is something concrete.','We are aligned. I will make the next call.'],
    Family:['Always proud of you. Call when you get a minute ❤️','You know I am in your corner.','Just take care of yourself too.'],
    Friend:['Say less. I got you.','Bet 😂 Keep doing your thing.','We will catch up after the game.'],
    Trainer:['Perfect. I will adjust the recovery plan.','Hydrate and get your sleep. We will check in tomorrow.','Good. Do not skip the cooldown.'],
    Executive:['Thank you. We will stay in touch.','Understood. Keep building the right habits.','Good to hear. Let your work speak.'],
    Media:['Appreciate the response. I will follow up if needed.','Understood. I will keep the context accurate.','Thanks. Good luck in the next one.']
  };
  const pool=responses[contact.role];return pool[contact.name.length%pool.length];
}

export function sendPhoneReply(state:CareerState,contactId:string,body:string):CareerState{
  const s=clone(state);const contact=s.phoneContacts.find(item=>item.id===contactId);const text=clean(body);if(!contact||!text)return s;
  s.phoneMessages.forEach(message=>{if(message.contactId===contactId)message.read=true});
  s.phoneMessages.unshift({id:id('message'),contactId,date:s.player.currentDate,body:text,direction:'Outgoing',read:true,kind:'Reply'});
  s.phoneMessages.unshift({id:id('message'),contactId,date:s.player.currentDate,body:responseFor(contact),direction:'Incoming',read:true,kind:'Reply'});
  const relationship=contact.relationshipId?s.relationships.find(item=>item.id===contact.relationshipId):s.relationships.find(item=>item.name.toLowerCase()===contact.name.toLowerCase());
  if(relationship){relationship.closeness=Math.min(100,relationship.closeness+1);relationship.trust=Math.min(100,relationship.trust+1)}
  return s;
}

export function markPhoneThreadRead(state:CareerState,contactId:string):CareerState{
  const s=clone(state);s.phoneMessages.forEach(message=>{if(message.contactId===contactId)message.read=true});return s;
}

export function generatePhoneCheckIn(state:CareerState):CareerState{
  const s=clone(state);if(!s.phoneContacts.length)return discoverPhoneContact(s);
  const contact=s.phoneContacts[(s.phoneMessages.length+s.games.length)%s.phoneContacts.length];
  const messages:Record<PhoneContactRole,string>={
    'NBA Player':'How are you feeling about the next matchup?',Coach:'Have you reviewed the next opponent on the calendar?',Scout:'What part of your game has improved most since I last checked in?',Agent:'Anything off the court that I need to get ahead of?',Family:'Checking in. How are you doing outside of basketball?',Friend:'You free after the next game?',Trainer:'How is your body feeling before the next one?',Executive:'Keep building. Consistency is being noticed.',Media:'Would you be open to a quick conversation after your next game?'
  };
  receive(s,contact,messages[contact.role],'Check-in');return s;
}

export function unreadPhoneMessages(state:CareerState):number{
  return state.phoneMessages.filter(message=>message.direction==='Incoming'&&!message.read).length;
}

