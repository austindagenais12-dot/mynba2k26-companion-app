import { CareerState, DynamicEvent, Game, Relationship, Sponsor, SocialPost, NewsItem, HistoryItem, Storyline, Transaction } from './model';

const routes = ['NCAA College','JUCO → NCAA','Overtime Elite','NBL Next Stars','European Pro','International Academy → European Pro'];
const schools = ['Michigan State','Providence','Villanova','Arizona','UCLA','Baylor','Virginia Tech','Creighton','Dayton'];
const overseas = ['Adelaide 36ers','Perth Wildcats','Melbourne United','Paris Basketball','ASVEL','Bourg-en-Bresse','Gran Canaria','Joventut'];
const media = [
  ['Hoops Central','@HoopsCentral'],['League Wire','@LeagueWire'],['The Sixth Man','@SixthManPod'],['Numbers Room','@NumbersRoom'],['Courtside Report','@CourtsideReport']
];
const brands = [
  ['Apex Athletics','Shoe & Apparel'],['Pulse Audio','Technology'],['Northstar Motors','Automotive'],['Volt Sports Drink','Beverage'],['Vanta Timepieces','Luxury'],['LevelUp Gaming','Gaming']
];
const personalities = ['Competitive','Professional','Private','Charismatic','Loyal','Leader','Showman','Community-Oriented'];

const id = (prefix:string) => `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2,8)}`;
const clamp = (n:number,a=0,b=100) => Math.max(a,Math.min(b,Math.round(n)));
const pick = <T,>(arr:T[]):T => arr[Math.floor(Math.random()*arr.length)];
const now = () => new Date().toISOString().slice(0,10);
const clone = <T,>(value:T):T => JSON.parse(JSON.stringify(value));

function pushHistory(s:CareerState,title:string,body:string,category:string,importance='Personal',canon:'2K Confirmed'|'User Confirmed'|'Companion Canon'|'Rumor'='Companion Canon') {
  s.history.unshift({id:id('h'),date:s.player.currentDate||now(),title,body,category,importance,canon});
}
function notify(s:CareerState,icon:string,title:string,body:string){
  s.notifications.unshift({id:id('nt'),date:s.player.currentDate||now(),icon,title,body,read:false});
}
function news(s:CareerState,headline:string,body:string,importance='Background',canon:'2K Confirmed'|'User Confirmed'|'Companion Canon'|'Rumor'='Companion Canon'){
  const outlet = pick(media);
  s.news.unshift({id:id('n'),date:s.player.currentDate||now(),outlet:outlet[0],headline,body,importance,canon});
}
function social(s:CareerState,body:string,kind='Media',canon:'2K Confirmed'|'User Confirmed'|'Companion Canon'|'Rumor'='Companion Canon'){
  const outlet = pick(media);
  s.social.unshift({id:id('s'),date:s.player.currentDate||now(),author:outlet[0],handle:outlet[1],body,likes:Math.floor(300+Math.random()*12000),reposts:Math.floor(20+Math.random()*1200),replies:Math.floor(10+Math.random()*600),kind,canon});
}

export function calculateOverall(s:CareerState):number {
  const weights:Record<string,number> = {};
  s.attributes.forEach(a=>weights[a.name]=1);
  if(['PG','SG'].includes(s.player.position)) ['Three-Point Shot','Ball Handle','Speed With Ball','Pass Accuracy','Perimeter Defense','Speed','Agility'].forEach(k=>weights[k]=1.8);
  else if(['SF','PF'].includes(s.player.position)) ['Driving Dunk','Three-Point Shot','Perimeter Defense','Strength','Defensive Rebound','Speed'].forEach(k=>weights[k]=1.6);
  else ['Standing Dunk','Interior Defense','Block','Defensive Rebound','Strength','Close Shot'].forEach(k=>weights[k]=2);
  const total = s.attributes.reduce((sum,a)=>sum+a.rating*(weights[a.name]||1),0);
  const w = s.attributes.reduce((sum,a)=>sum+(weights[a.name]||1),0);
  s.player.overall = clamp(total/w-1.5,40,99);
  return s.player.overall;
}

export function attributeUpgradeCost(rating:number){ return Math.round(300 + Math.pow(Math.max(0,rating-55),1.68)*21); }

export type PlayerProfileInput = {
  name:string; position:string; age:number; height:string; weight:number; hometown:string; nationality:string;
  dominantHand:'Right'|'Left'; highSchoolYear:string; schoolOrClub:string; jersey:number;
};

function applyProfileFields(s:CareerState,input:PlayerProfileInput){
  s.player.name=input.name.trim();
  s.player.position=input.position;
  s.player.age=clamp(input.age,14,40);
  s.player.height=input.height.trim();
  s.player.weight=clamp(input.weight,120,400);
  s.player.hometown=input.hometown.trim();
  s.player.nationality=input.nationality.trim()||'Unknown';
  s.player.dominantHand=input.dominantHand;
  s.player.highSchoolYear=input.highSchoolYear;
  s.player.schoolOrClub=input.schoolOrClub.trim();
  s.player.jersey=clamp(input.jersey,0,99);
}

export function initializeCareerProfile(state:CareerState,input:PlayerProfileInput):CareerState {
  const s=clone(state); const oldName=s.player.name; const oldSchool=s.player.schoolOrClub;
  applyProfileFields(s,input); s.settings.onboardingComplete=true; s.version=Math.max(2,s.version||1);
  // Replace only the starter placeholder copy. Existing career history is preserved for upgraded saves.
  if(s.history.length===1 && s.history[0]?.title==='Career begins'){
    s.history[0].body=`${s.player.name}'s basketball story begins in ${s.player.hometown}.`;
    s.history[0].canon='User Confirmed';
  }
  const swap=(text:string)=>text.split(oldName).join(s.player.name).split(oldSchool).join(s.player.schoolOrClub);
  s.social=s.social.map(post=>({...post,body:swap(post.body)}));
  s.news=s.news.map(item=>({...item,body:swap(item.body),headline:swap(item.headline)}));
  if(s.relationships.length && s.relationships[0].name==='Maya Carter')s.relationships[0].name='Family Member';
  calculateOverall(s);
  notify(s,'✅','Player profile ready',`${s.player.name} • ${s.player.position} • #${s.player.jersey}`);
  return s;
}

export function updatePlayerProfile(state:CareerState,input:PlayerProfileInput):CareerState {
  const s=clone(state); const oldName=s.player.name; applyProfileFields(s,input); s.settings.onboardingComplete=true; s.version=Math.max(2,s.version||1); calculateOverall(s);
  pushHistory(s,'Player profile updated',`${oldName} is now listed as ${s.player.name}, ${s.player.position}, #${s.player.jersey}.`,'Career','Personal','User Confirmed');
  notify(s,'✏️','Profile updated',`${s.player.name} • ${s.player.height} • ${s.player.weight} lbs`);
  return s;
}

export function upgradeAttribute(state:CareerState,name:string):{state:CareerState;message:string} {
  const s=clone(state); const a=s.attributes.find(x=>x.name===name); if(!a)return{state:s,message:'Attribute not found.'};
  if(a.rating>=a.cap)return{state:s,message:'Attribute cap reached.'};
  const cost=attributeUpgradeCost(a.rating); if(s.player.xp<cost)return{state:s,message:`Need ${cost.toLocaleString()} XP.`};
  const old=a.rating; s.player.xp-=cost; a.rating++; calculateOverall(s);
  pushHistory(s,`${name} improved`,`${name} increased from ${old} to ${a.rating}.`,'Development');
  return{state:s,message:`${name} is now ${a.rating}.`};
}

export function randomizeProspect(state:CareerState):CareerState {
  const s=clone(state);
  // Preserve the identity/body information the user entered on the setup screen.
  // This button now randomizes basketball ability, upside and personality only.
  const pos=s.player.position;
  s.player.potential=82+Math.floor(Math.random()*15); s.player.followers=2500+Math.floor(Math.random()*20000); s.player.marketability=35+Math.floor(Math.random()*20);
  s.player.traits=[pick(personalities)];
  s.attributes=s.attributes.map(a=>({...a,rating:clamp(a.rating+(Math.floor(Math.random()*11)-5),30,88)})); calculateOverall(s);
  pushHistory(s,'Basketball profile generated',`${s.player.name} begins as a ${s.player.overall} OVR ${pos} with ${s.player.potential} potential.`,'Career','Career','User Confirmed');
  return s;
}

export function chooseRoute(state:CareerState,route:string):CareerState {
  const s=clone(state); s.player.route=route; s.player.stage='Pre-NBA';
  s.player.schoolOrClub = route.includes('NCAA') || route==='NCAA College' ? pick(schools) : route==='Overtime Elite' ? 'Overtime Elite' : pick(overseas);
  pushHistory(s,'Pathway chosen',`${s.player.name} chose ${route} and joined ${s.player.schoolOrClub}.`,'Career','Career','User Confirmed');
  social(s,`${s.player.name} is taking the ${route} route. Scouts will be watching.`,'Recruiting');
  notify(s,'🏀','New pathway',`${route} • ${s.player.schoolOrClub}`);
  return s;
}

export function simulatePreNBASegment(state:CareerState):CareerState {
  const s=clone(state); const detail=s.settings.simDetail;
  const games=detail==='Quick'?10:detail==='Detailed'?5:8;
  const quality=(s.player.overall-55)/25;
  const ppg=Math.max(4,Math.round((8+quality*15+Math.random()*7)*10)/10);
  const apg=Math.round((2+quality*5+Math.random()*2)*10)/10;
  const rpg=Math.round((2+quality*4+Math.random()*2)*10)/10;
  const bump=Math.random()<0.17?-1:Math.random()<0.68?1:2;
  s.attributes.forEach(a=>{ if(Math.random()<0.35)a.rating=clamp(a.rating+bump,30,a.cap); }); calculateOverall(s);
  s.player.followers+=Math.floor(3000+ppg*1200); s.player.marketability=clamp(s.player.marketability+(ppg>=18?5:2));
  const stock=s.player.overall>=78?'Lottery':s.player.overall>=73?'First Round':s.player.overall>=69?'Second Round':'Undrafted / Return';
  s.player.draftProjection=stock;
  pushHistory(s,`${s.player.schoolOrClub} season checkpoint`,`${games} games simulated: ${ppg} PPG, ${rpg} RPG, ${apg} APG. Draft outlook: ${stock}.`,'Pre-NBA','Team');
  social(s,`${s.player.name} is averaging ${ppg} points through the latest stretch. Current outlook: ${stock}.`,'Draft');
  if(Math.random()<0.65)s.events.unshift(generateEvent(s,'Pre-NBA'));
  if(s.player.overall>=72 && s.sponsors.length===0) s.sponsors.push(generateSponsorOffer(s,true));
  s.player.phase='Season';
  return s;
}

export function declareForDraft(state:CareerState):CareerState {
  const s=clone(state); s.player.stage='Awaiting Draft'; s.player.draftDeclared=true; s.player.phase='NBA Draft';
  pushHistory(s,'Declared for NBA Draft',`${s.player.name} declared with a ${s.player.draftProjection} projection and ${s.player.overall} overall.`,'Draft','Career','User Confirmed');
  news(s,`${s.player.name} declares for NBA Draft`,`The ${s.player.schoolOrClub} prospect will now let NBA 2K26 MyNBA determine where his career begins.`,'National','User Confirmed');
  notify(s,'🎓','Draft handoff ready','Run the draft inside NBA 2K26, then enter the result here.');
  return s;
}

export function confirmDraftResult(state:CareerState,team:string,pickNo:number):CareerState {
  const s=clone(state); s.player.stage='NBA'; s.player.team=team.toUpperCase(); s.player.draftPick=pickNo; s.player.role=pickNo<=14?'Rotation':pickNo<=30?'Bench / Rotation':'Development'; s.player.phase='Rookie Season'; s.player.age=Math.max(19,s.player.age); s.player.money=100000; s.player.careerEarnings=100000;
  pushHistory(s,'NBA Draft',`${s.player.name} was selected #${pickNo} by ${s.player.team} inside NBA 2K26 MyNBA.`,'Draft','Career','2K Confirmed');
  social(s,`BREAKING: ${s.player.name} is headed to ${s.player.team} with pick #${pickNo}.`,'Breaking','2K Confirmed');
  news(s,`${s.player.team} selects ${s.player.name}`,`The ${s.player.position} officially begins his NBA career after being selected #${pickNo}.`,'National','2K Confirmed');
  notify(s,'🎉','Welcome to the NBA',`${s.player.team} • Pick #${pickNo}`);
  s.relationships.push({id:id('r'),name:'NBA Head Coach',role:'Coach',team:s.player.team,trust:55,respect:58,friendship:25,loyalty:45,rivalry:0,resentment:0,influence:95,closeness:32,status:'New Relationship',memories:['Met after draft night.']});
  s.storylines.unshift({id:id('st'),title:'The Rookie Year',arcType:'Career Chapter',status:'Active',heat:40,summary:`Can ${s.player.name} earn a real role in ${s.player.team}?`,participants:[s.player.name,s.player.team],started:s.player.currentDate});
  return s;
}

export function gameXP(g:Omit<Game,'id'|'date'|'xp'>):number {
  const fgPct=g.fga?g.fgm/g.fga:0; const threePct=g.tpa?g.tpm/g.tpa:0;
  let xp=g.pts*42+g.reb*34+g.ast*52+g.stl*90+g.blk*90-g.tov*32+Math.round(fgPct*700)+Math.round(threePct*260)+Math.max(-150,g.plusMinus*10)+(g.result==='W'?450:0);
  const mult=g.importance==='Rivalry'?1.12:g.importance==='Playoff'?1.25:g.importance==='Elimination'?1.45:g.importance==='Finals'?1.6:1;
  return Math.max(250,Math.round(xp*mult));
}

export function logGame(state:CareerState,input:Omit<Game,'id'|'date'|'xp'>):CareerState {
  const s=clone(state); const xp=gameXP(input); const g:Game={...input,id:id('g'),date:s.player.currentDate,xp}; s.games.unshift(g); s.player.xp+=xp; s.player.fatigue=clamp(s.player.fatigue+Math.round(g.minutes/7)); s.player.morale=clamp(s.player.morale+(g.result==='W'?2:-2));
  const followerGain=Math.max(80,Math.round(g.pts*90+g.ast*60+(g.importance==='Playoff'?5000:0))); s.player.followers+=followerGain;
  if(g.pts>=30)s.player.marketability=clamp(s.player.marketability+2); if(g.pts>=40)s.player.legacy+=1;
  pushHistory(s,`${g.result} vs ${g.opponent}`,`${g.pts} PTS • ${g.reb} REB • ${g.ast} AST • ${g.stl} STL • +${xp.toLocaleString()} XP`,'Game',g.importance==='Regular'?'Personal':'National','2K Confirmed');
  social(s,`${s.player.name}: ${g.pts} PTS, ${g.reb} REB and ${g.ast} AST in a ${g.result==='W'?'win':'loss'} against ${g.opponent}.`,'Game Reaction','2K Confirmed');
  if(g.pts>=30) social(s,`${s.player.name} was cooking tonight. ${g.pts} points and the timeline is noticing.`,'Fan Reaction');
  if(g.importance!=='Regular') news(s,`${s.player.name} delivers in a ${g.importance.toLowerCase()} game`,`The ${s.player.team} guard finished with ${g.pts} points and ${g.ast} assists.`,'National','2K Confirmed');
  s.sponsors.forEach(sp=>{if(sp.status==='Active')sp.progress=clamp(sp.progress+(g.pts>=20?6:3),0,sp.target)});
  updateMilestones(s,g); updateStorylines(s,g); maybeDynamicEvent(s,g); maybeSponsor(s,g); updateRelationshipsAfterGame(s,g);
  notify(s,'🏀','Game processed',`${g.pts}/${g.reb}/${g.ast} • +${xp.toLocaleString()} XP`);
  return s;
}

function updateMilestones(s:CareerState,g:Game){
  const mark=(name:string,cond:boolean)=>{const m=s.milestones.find(x=>x.name===name);if(m&&!m.achieved&&cond){m.achieved=true;m.date=s.player.currentDate;pushHistory(s,name,`Career milestone achieved: ${name}.`,'Milestone','Career','2K Confirmed');notify(s,'🏆','Career milestone',name)}};
  mark('First NBA Game',s.games.length===1); mark('First 30-Point NBA Game',g.pts>=30); mark('First 50-Point Game',g.pts>=50); mark('First Triple-Double',[g.pts,g.reb,g.ast,g.stl,g.blk].filter(x=>x>=10).length>=3); mark('First Playoff Win',g.result==='W'&&['Playoff','Elimination','Finals'].includes(g.importance));
}
function updateStorylines(s:CareerState,g:Game){
  const recent=s.games.slice(0,6); const avg=recent.reduce((x,y)=>x+y.pts,0)/Math.max(1,recent.length);
  if(recent.length>=4&&avg>=25&&!s.storylines.some(x=>x.status==='Active'&&x.title==='On a Heater'))s.storylines.unshift({id:id('st'),title:'On a Heater',arcType:'Performance',status:'Active',heat:68,summary:`${s.player.name} is averaging ${avg.toFixed(1)} over the last ${recent.length} games.`,participants:[s.player.name],started:s.player.currentDate});
  if(g.importance==='Rivalry'&&!s.storylines.some(x=>x.status==='Active'&&x.title.includes(g.opponent)))s.storylines.unshift({id:id('st'),title:`The ${g.opponent} Rivalry`,arcType:'Rivalry',status:'Active',heat:58,summary:`Repeated high-stakes meetings with ${g.opponent} are becoming personal.`,participants:[s.player.name,g.opponent],started:s.player.currentDate});
}
function updateRelationshipsAfterGame(s:CareerState,g:Game){
  s.relationships.forEach(r=>{if(r.role==='Coach')r.trust=clamp(r.trust+(g.pts>=20?2:0)+(g.tov>=6?-2:0));if(r.role==='Teammate'&&g.ast>=8)r.respect=clamp(r.respect+2);r.status=statusFor(r)});
}
function statusFor(r:Relationship){const positive=(r.trust+r.respect+r.friendship+r.loyalty+r.closeness)/5; if(r.rivalry>=75)return'Bitter Rival';if(r.resentment>=65)return'Strained';if(positive>=85)return'Very Close';if(positive>=70)return'Close';if(positive>=55)return'Positive';return'Uncertain';}
function maybeDynamicEvent(s:CareerState,g?:Game){const chance=s.settings.immersionMode==='Chaos'?0.75:s.settings.immersionMode==='Full Life'?0.55:s.settings.immersionMode==='Immersive'?0.42:0.24;if(Math.random()<chance)s.events.unshift(generateEvent(s,g?'NBA':'Life'));}
function maybeSponsor(s:CareerState,g:Game){if((g.pts>=30||s.player.followers>250000)&&Math.random()<0.22&&s.sponsors.filter(x=>x.status==='Offer').length<3){s.sponsors.unshift(generateSponsorOffer(s));notify(s,'🤝','New sponsor interest',s.sponsors[0].brand)}}

export function generateEvent(s:CareerState,context='NBA'):DynamicEvent {
  const pool=[
    {title:'Coach Wants a Word',body:'Your recent play has the staff reconsidering your role. Coach asks how you feel about taking on more responsibility.',category:'Team',importance:'Team',choices:[['Embrace it','Coach appreciates your confidence.',{trust:6,morale:2}],['Ask for more freedom','Your ambition is noticed around the locker room.',{respect:3,marketability:2}],['Keep it team-first','Teammates appreciate the response.',{friendship:5,trust:2}]]},
    {title:'Veteran Dinner Invite',body:'A veteran teammate invites you out after practice, but you had recovery work planned.',category:'Life',importance:'Personal',choices:[['Go to dinner','You bond with the group.',{friendship:7,fatigue:4}],['Recover','You protect your body for the next game.',{fatigue:-9,friendship:-1}],['Stop by briefly','You split the difference.',{friendship:3,fatigue:-3}]]},
    {title:'Trade Rumor Hits the Feed',body:'A national insider says teams are monitoring your situation. You never asked for a trade.',category:'Media',importance:'National',choices:[['Deny it','The denial calms some speculation.',{marketability:1}],['Say nothing','The story stays alive.',{marketability:2}],['Like the rumor','Speculation explodes.',{marketability:6,trust:-4}]]},
    {title:'Private Summer Run',body:'A star invites you to a private run with established pros.',category:'Training',importance:'Personal',choices:[['Accept','You earn respect in a tough run.',{respect:6,fatigue:7}],['Stick to your plan','Your disciplined program continues.',{morale:2,fatigue:-4}],['Bring a teammate','The session strengthens a relationship.',{friendship:7,respect:3}]]},
    {title:'Sponsor Wants More',body:'A sponsor asks for an extra appearance during a busy stretch.',category:'Sponsors',importance:'Personal',choices:[['Do it','The sponsor is pleased, but you feel the workload.',{marketability:4,fatigue:7}],['Renegotiate','Your agent pushes back.',{agentTrust:4}],['Decline','You protect recovery at the cost of brand warmth.',{fatigue:-5,marketability:-2}]]},
    {title:'Locker-Room Friction',body:'A teammate privately questions your shot selection.',category:'Team',importance:'Team',choices:[['Hear him out','The conversation is productive.',{respect:5,friendship:3}],['Defend your game','The disagreement gets heated.',{resentment:7,morale:1}],['Go to the coach','The issue becomes bigger than expected.',{trust:1,resentment:4}]]}
  ];
  const e=pick(pool); return{id:id('e'),date:s.player.currentDate,title:e.title,body:e.body,category:e.category,importance:e.importance,choices:e.choices.map(c=>({label:c[0] as string,outcome:c[1] as string,effects:c[2] as Record<string,number>}))};
}

export function resolveEvent(state:CareerState,eventId:string,choiceIndex:number):CareerState {
  const s=clone(state); const e=s.events.find(x=>x.id===eventId); if(!e||e.resolved)return s; const c=e.choices[choiceIndex]; e.resolved=c.label;
  Object.entries(c.effects).forEach(([k,v])=>{
    if(k==='marketability')s.player.marketability=clamp(s.player.marketability+v);
    else if(k==='morale')s.player.morale=clamp(s.player.morale+v);
    else if(k==='fatigue')s.player.fatigue=clamp(s.player.fatigue+v);
    else if(k==='agentTrust')s.player.agentTrust=clamp(s.player.agentTrust+v);
    else s.relationships.slice(0,2).forEach(r=>{if(k in r)(r as any)[k]=clamp((r as any)[k]+v);r.status=statusFor(r)});
  });
  pushHistory(s,e.title,`${c.label}: ${c.outcome}`,'Encounter',e.importance,'User Confirmed'); notify(s,'💬','Encounter resolved',c.outcome);
  if(e.category==='Media')social(s,`${s.player.name}'s response to the latest rumor is drawing attention.`,'Media Reaction');
  return s;
}

export function generateSponsorOffer(s:CareerState,preNBA=false):Sponsor {
  const b=pick(brands); const value=Math.round((preNBA?25000:250000)+s.player.marketability*(preNBA?2500:35000)+Math.random()*(preNBA?100000:1200000));
  return{id:id('sp'),brand:b[0],category:b[1],status:'Offer',years:1+Math.floor(Math.random()*4),value,bonus:Math.round(value*0.18),obligations:preNBA?'2 posts + 1 appearance':'4 posts/year + 2 appearances',interest:65+Math.floor(Math.random()*31),relationship:55,objective:preNBA?'Reach 100K followers':'Make an All-Star push / grow audience',progress:0,target:100};
}

export function sponsorAction(state:CareerState,idv:string,action:'accept'|'counter'|'decline'):CareerState {
  const s=clone(state);const sp=s.sponsors.find(x=>x.id===idv);if(!sp)return s;
  if(action==='accept'){sp.status='Active';s.player.money+=Math.round(sp.value*.2);s.player.careerEarnings+=Math.round(sp.value*.2);s.finances.unshift({id:id('f'),date:s.player.currentDate,kind:'Endorsement',description:`${sp.brand} signing payment`,amount:Math.round(sp.value*.2),balanceAfter:s.player.money});pushHistory(s,`Signed with ${sp.brand}`,`${sp.years}-year endorsement valued at $${sp.value.toLocaleString()}.`,'Sponsors','National','User Confirmed');}
  if(action==='decline'){sp.status='Declined';sp.relationship=clamp(sp.relationship-8);}
  if(action==='counter'){const success=Math.random()<0.58;if(success){sp.value=Math.round(sp.value*1.12);sp.interest=clamp(sp.interest-4);notify(s,'🤝','Counter accepted',`${sp.brand} improved its offer.`)}else{sp.interest=clamp(sp.interest-10);notify(s,'🤝','Brand holds firm',`${sp.brand} did not improve the offer.`)}}
  return s;
}

export function addUserPost(state:CareerState,body:string):CareerState {const s=clone(state);s.social.unshift({id:id('s'),date:s.player.currentDate,author:s.player.name,handle:`@${s.player.name.replace(/\s+/g,'')}`,body,likes:0,reposts:0,replies:0,kind:'Player',canon:'User Confirmed'});s.player.followers+=Math.floor(100+Math.random()*1200);return s;}
export function toggleLike(state:CareerState,postId:string):CareerState {const s=clone(state);const p=s.social.find(x=>x.id===postId);if(p){p.likedByUser=!p.likedByUser;p.likes=Math.max(0,p.likes+(p.likedByUser?1:-1));}return s;}

export function manualTransaction(state:CareerState,type:string,player:string,fromTeam:string,toTeam:string):CareerState {
  const s=clone(state);const tx:Transaction={id:id('tx'),date:s.player.currentDate,type,player,fromTeam:fromTeam.toUpperCase(),toTeam:toTeam.toUpperCase(),canon:'2K Confirmed'};s.transactions.unshift(tx);
  if(player.trim().toLowerCase()===s.player.name.trim().toLowerCase()){const old=s.player.team;s.player.team=toTeam.toUpperCase();pushHistory(s,`${type}: ${old} → ${s.player.team}`,`${s.player.name} moved from ${old} to ${s.player.team} inside NBA 2K26.`,'Transaction','Career','2K Confirmed');social(s,`BREAKING: ${s.player.name} is headed from ${old} to ${s.player.team}.`,'Breaking','2K Confirmed');s.relationships.forEach(r=>{if(r.role==='Coach')r.status='Former Coach'});notify(s,'🚨','Team changed',`${old} → ${s.player.team}`)} else {news(s,`${player}: ${fromTeam} → ${toTeam}`,`${type} confirmed in your MyNBA universe.`,'Background','2K Confirmed');}
  return s;
}

export function offseasonActivity(state:CareerState,activity:string):CareerState {
  const s=clone(state);let body='';
  if(activity==='Skill Training'){const candidates=s.attributes.filter(a=>a.rating<a.cap);for(let i=0;i<3;i++){const a=pick(candidates);a.rating=clamp(a.rating+1,0,a.cap)}calculateOverall(s);s.player.fatigue=clamp(s.player.fatigue+10);body='Targeted training improved three attributes.'}
  else if(activity==='Recovery'){s.player.fatigue=clamp(s.player.fatigue-22);s.player.morale=clamp(s.player.morale+4);body='You prioritized recovery and entered the next phase fresher.'}
  else if(activity==='Relationships'){s.relationships.forEach(r=>{if(Math.random()<.4){r.friendship=clamp(r.friendship+4);r.closeness=clamp(r.closeness+3);r.status=statusFor(r)}});body='You invested time in the people around you.'}
  else if(activity==='Sponsor Work'){s.sponsors.filter(x=>x.status==='Active').forEach(x=>x.relationship=clamp(x.relationship+6));s.player.marketability=clamp(s.player.marketability+5);s.player.fatigue=clamp(s.player.fatigue+6);body='Sponsor appearances raised your profile.'}
  else if(activity==='Community'){s.player.marketability=clamp(s.player.marketability+3);s.player.legacy+=1;body='Community work strengthened your local reputation.'}
  else if(activity==='Vacation'){s.player.fatigue=clamp(s.player.fatigue-16);s.player.morale=clamp(s.player.morale+10);body='Time away helped reset your body and mind.'}
  else {s.player.morale=clamp(s.player.morale+3);body='The offseason activity added another chapter to your life away from games.'}
  pushHistory(s,activity,body,'Offseason','Personal','User Confirmed'); if(Math.random()<0.35)s.events.unshift(generateEvent(s,'Offseason'));return s;
}

export function advanceSeason(state:CareerState):CareerState {
  const s=clone(state);s.player.seasonYear+=1;s.player.age+=1;s.player.phase='Offseason';s.player.fatigue=clamp(s.player.fatigue-20);s.player.morale=clamp(s.player.morale+4);
  const decline=s.player.age>=33?Math.random()<0.55:s.player.age>=30?Math.random()<0.22:false;if(decline){s.attributes.filter(a=>['Speed','Agility','Vertical','Stamina'].includes(a.name)).forEach(a=>a.rating=clamp(a.rating-1,30,a.cap));calculateOverall(s)}
  pushHistory(s,`Season ${s.player.seasonYear} begins`,`A new chapter begins at age ${s.player.age}.`,'Career','Career','User Confirmed');
  s.worldPlayers.forEach(w=>{w.age++;if(w.age<28&&Math.random()<.5)w.overall=clamp(w.overall+1,40,99);if(w.age>32&&Math.random()<.45)w.overall=clamp(w.overall-1,40,99)});
  return s;
}

export function changeSetting(state:CareerState,key:string,value:any):CareerState {const s=clone(state);(s.settings as any)[key]=value;return s;}
