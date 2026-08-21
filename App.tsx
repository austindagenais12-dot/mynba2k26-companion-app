import React, { useEffect, useMemo, useState } from 'react';
import {
  Alert, KeyboardAvoidingView, Modal, Platform, Pressable, SafeAreaView, ScrollView,
  Share, StyleSheet, Switch, Text, TextInput, View
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import Storage from 'expo-sqlite/kv-store';
import { createDefaultState } from './src/defaultState';
import {
  addUserPost, advanceSeason, attributeUpgradeCost, changeSetting, chooseRoute, confirmDraftResult,
  declareForDraft, generateEvent, logGame, manualTransaction, offseasonActivity, randomizeProspect,
  resolveEvent, simulatePreNBASegment, sponsorAction, toggleLike, upgradeAttribute
} from './src/engine';
import { CareerState, DynamicEvent, SocialPost } from './src/model';

const SAVE_KEY = 'nba2k26-career-companion-mobile-v1';
const ACCENT = '#ff5a47';
const BG = '#0b0d11';
const PANEL = '#141820';
const PANEL2 = '#1b202a';
const BORDER = '#2a303b';
const TEXT = '#f5f7fb';
const MUTED = '#9ca6b5';
const GOOD = '#5bd89c';
const WARN = '#f5c76d';

const routes = ['NCAA College','JUCO → NCAA','Overtime Elite','NBL Next Stars','European Pro','International Academy → European Pro'];
const teams = ['ATL','BOS','BKN','CHA','CHI','CLE','DAL','DEN','DET','GSW','HOU','IND','LAC','LAL','MEM','MIA','MIL','MIN','NOP','NYK','OKC','ORL','PHI','PHX','POR','SAC','SAS','TOR','UTA','WAS'];
const importances = ['Regular','Rivalry','Playoff','Elimination','Finals'] as const;
const clone = <T,>(v:T):T => JSON.parse(JSON.stringify(v));
const fmtMoney = (n:number) => n >= 1_000_000 ? `$${(n/1_000_000).toFixed(1)}M` : `$${Math.round(n/1000)}K`;
const pct = (n:number) => `${Math.max(0,Math.min(100,n))}%`;

function Card({children, style}:{children:React.ReactNode;style?:any}) { return <View style={[styles.card,style]}>{children}</View>; }
function Row({children,style}:{children:React.ReactNode;style?:any}) { return <View style={[styles.row,style]}>{children}</View>; }
function Pill({text,tone='accent'}:{text:string;tone?:'accent'|'good'|'warn'|'muted'}) {
  const color=tone==='good'?GOOD:tone==='warn'?WARN:tone==='muted'?MUTED:ACCENT;
  return <View style={[styles.pill,{borderColor:color}]}><Text style={[styles.pillText,{color}]}>{text}</Text></View>;
}
function Metric({label,value,sub}:{label:string;value:string|number;sub?:string}) {return <View style={styles.metric}><Text style={styles.mutedSmall}>{label}</Text><Text style={styles.metricValue}>{value}</Text>{sub?<Text style={styles.mutedSmall}>{sub}</Text>:null}</View>}
function SectionTitle({title,side}:{title:string;side?:React.ReactNode}) {return <Row style={{justifyContent:'space-between',alignItems:'center'}}><Text style={styles.sectionTitle}>{title}</Text>{side}</Row>}
function Btn({label,onPress,variant='solid',disabled=false,small=false}:{label:string;onPress:()=>void;variant?:'solid'|'outline'|'ghost'|'danger';disabled?:boolean;small?:boolean}){
  const solid=variant==='solid'; return <Pressable disabled={disabled} onPress={onPress} style={({pressed})=>[
    styles.btn,small&&styles.btnSmall,solid&&styles.btnSolid,variant==='outline'&&styles.btnOutline,variant==='ghost'&&styles.btnGhost,variant==='danger'&&styles.btnDanger,
    disabled&&{opacity:.4},pressed&&!disabled&&{opacity:.72}
  ]}><Text style={[styles.btnText,solid&&{color:'#fff'},variant==='danger'&&{color:'#fff'}]}>{label}</Text></Pressable>
}
function Progress({value}:{value:number}){return <View style={styles.progressTrack}><View style={[styles.progressFill,{width:pct(value)}]}/></View>}
function Field({label,value,onChange,keyboard='default',placeholder}:{label:string;value:string;onChange:(v:string)=>void;keyboard?:any;placeholder?:string}){
  return <View style={{gap:6,flex:1,minWidth:120}}><Text style={styles.label}>{label}</Text><TextInput value={value} onChangeText={onChange} keyboardType={keyboard} placeholder={placeholder} placeholderTextColor="#626b78" style={styles.input}/></View>
}
function Canon({value}:{value:string}) {const tone=value==='2K Confirmed'?'good':value==='Rumor'?'warn':'muted';return <Pill text={value} tone={tone}/>}

export default function App(){
  const [state,setState]=useState<CareerState>(()=>createDefaultState());
  const [loaded,setLoaded]=useState(false);
  const [tab,setTab]=useState<'Home'|'Career'|'Play'|'Social'|'More'>('Home');
  const [more,setMore]=useState<'Menu'|'Player'|'Relationships'|'Sponsors'|'Life'|'League'|'History'|'Settings'>('Menu');
  const [event,setEvent]=useState<DynamicEvent|null>(null);
  const [socialDetail,setSocialDetail]=useState<SocialPost|null>(null);

  useEffect(()=>{(async()=>{try{const raw=await Storage.getItem(SAVE_KEY);if(raw)setState(JSON.parse(raw));}catch{}finally{setLoaded(true)}})()},[]);
  useEffect(()=>{if(!loaded)return;const t=setTimeout(()=>Storage.setItem(SAVE_KEY,JSON.stringify(state)).catch(()=>{}),250);return()=>clearTimeout(t)},[state,loaded]);

  const unread=state.notifications.filter(n=>!n.read).length;
  const activeStory=state.storylines.find(s=>s.status==='Active');
  const activeEvent=state.events.find(e=>!e.resolved);
  const last5=state.games.slice(0,5);
  const avgPts=last5.length?last5.reduce((x,g)=>x+g.pts,0)/last5.length:0;

  const markNotifications=()=>{const s=clone(state);s.notifications.forEach(n=>n.read=true);setState(s)};
  const goMore=(screen:typeof more)=>{setMore(screen);setTab('More')};

  return <SafeAreaView style={styles.safe}>
    <StatusBar style="light" />
    <View style={styles.app}>
      <Header state={state} unread={unread} onNotifications={markNotifications}/>
      <View style={styles.body}>
        {tab==='Home'&&<Home state={state} activeStory={activeStory} activeEvent={activeEvent} avgPts={avgPts} onEvent={setEvent} onNavigate={(t)=>setTab(t)} onMore={goMore}/>} 
        {tab==='Career'&&<Career state={state} setState={setState}/>} 
        {tab==='Play'&&<Play state={state} setState={setState}/>} 
        {tab==='Social'&&<Social state={state} setState={setState} onPost={setSocialDetail}/>} 
        {tab==='More'&&<MoreRoot screen={more} setScreen={setMore} state={state} setState={setState} onEvent={setEvent}/>} 
      </View>
      <BottomNav tab={tab} setTab={(t)=>{setTab(t);if(t==='More'&&more!=='Menu'){} }} unread={unread}/>
    </View>
    <EventModal state={state} event={event} onClose={()=>setEvent(null)} onResolve={(idx)=>{if(!event)return;setState(resolveEvent(state,event.id,idx));setEvent(null)}}/>
    <SocialModal state={state} post={socialDetail} onClose={()=>setSocialDetail(null)} onRespond={(text)=>{let s=addUserPost(state,`@${socialDetail?.handle.replace('@','')} ${text}`);setState(s);setSocialDetail(null)}}/>
  </SafeAreaView>
}

function Header({state,unread,onNotifications}:{state:CareerState;unread:number;onNotifications:()=>void}){
  const p=state.player;return <View style={styles.header}>
    <View style={styles.avatar}><Text style={styles.avatarText}>{p.name.split(' ').map(x=>x[0]).join('').slice(0,2)}</Text></View>
    <View style={{flex:1}}><Row style={{gap:7,alignItems:'center'}}><Text numberOfLines={1} style={styles.playerName}>{p.name}</Text><Pill text={`${p.overall} OVR`} tone="accent"/></Row><Text style={styles.sub}>{p.stage==='NBA'?`${p.team} • ${p.position} • ${p.role}`:`${p.schoolOrClub} • ${p.position} • ${p.stage}`}</Text></View>
    <Pressable onPress={onNotifications} style={styles.bell}><Text style={{fontSize:20}}>🔔</Text>{unread>0?<View style={styles.badge}><Text style={styles.badgeText}>{Math.min(99,unread)}</Text></View>:null}</Pressable>
  </View>
}

function BottomNav({tab,setTab,unread}:{tab:string;setTab:(t:any)=>void;unread:number}){
  const items=[['Home','⌂'],['Career','◎'],['Play','🏀'],['Social','#'],['More','•••']];return <View style={styles.bottomNav}>{items.map(([name,icon])=><Pressable key={name} onPress={()=>setTab(name)} style={styles.navItem}><Text style={[styles.navIcon,tab===name&&{color:ACCENT}]}>{icon}</Text><Text style={[styles.navLabel,tab===name&&{color:ACCENT}]}>{name}</Text>{name==='More'&&unread>0?<View style={styles.navDot}/>:null}</Pressable>)}</View>
}

function Home({state,activeStory,activeEvent,avgPts,onEvent,onNavigate,onMore}:{state:CareerState;activeStory:any;activeEvent:any;avgPts:number;onEvent:(e:any)=>void;onNavigate:(t:any)=>void;onMore:(m:any)=>void}){
  const p=state.player;const latestNews=state.news[0];return <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
    <View style={styles.metrics}><Metric label="OVERALL" value={p.overall} sub={`Potential ${p.potential}`}/><Metric label="FOLLOWERS" value={p.followers>=1e6?`${(p.followers/1e6).toFixed(2)}M`:`${Math.round(p.followers/1000)}K`} sub={`Marketability ${p.marketability}`}/><Metric label="MORALE" value={p.morale} sub={`Fatigue ${p.fatigue}`}/><Metric label="LEGACY" value={p.legacy} sub={`Year ${p.seasonYear}`}/></View>

    {activeEvent?<Card style={{borderColor:ACCENT}}><Row style={{justifyContent:'space-between'}}><Pill text="NEW ENCOUNTER"/><Text style={styles.mutedSmall}>{activeEvent.category}</Text></Row><Text style={styles.cardTitle}>{activeEvent.title}</Text><Text style={styles.bodyText}>{activeEvent.body}</Text><Btn label="Open encounter" onPress={()=>onEvent(activeEvent)}/></Card>:null}

    <Card><SectionTitle title="Career pulse" side={<Pill text={p.phase} tone="muted"/>}/><View style={styles.statTriplet}><Metric label="LAST 5 PPG" value={avgPts.toFixed(1)}/><Metric label="XP" value={p.xp.toLocaleString()}/><Metric label="MONEY" value={fmtMoney(p.money)}/></View>{activeStory?<View style={styles.callout}><Text style={styles.mutedSmall}>CURRENT STORYLINE</Text><Text style={styles.cardTitle}>{activeStory.title}</Text><Text style={styles.bodyText}>{activeStory.summary}</Text><Progress value={activeStory.heat}/></View>:<Text style={styles.muted}>No major storyline is dominating your career right now.</Text>}</Card>

    {latestNews?<Card><SectionTitle title="Top story" side={<Canon value={latestNews.canon}/>}/><Text style={styles.cardTitle}>{latestNews.headline}</Text><Text style={styles.bodyText}>{latestNews.body}</Text><Text style={styles.mutedSmall}>{latestNews.outlet}</Text></Card>:null}

    <Card><SectionTitle title="Quick actions"/><View style={styles.wrap}><Btn small label="Log Game" onPress={()=>onNavigate('Play')}/><Btn small label="Social" variant="outline" onPress={()=>onNavigate('Social')}/><Btn small label="Relationships" variant="outline" onPress={()=>onMore('Relationships')}/><Btn small label="Sponsors" variant="outline" onPress={()=>onMore('Sponsors')}/><Btn small label="League News" variant="outline" onPress={()=>onMore('League')}/><Btn small label="History" variant="outline" onPress={()=>onMore('History')}/></View></Card>

    <Card><SectionTitle title="Latest notifications" side={<Text style={styles.mutedSmall}>{state.notifications.filter(n=>!n.read).length} unread</Text>}/>{state.notifications.slice(0,5).map(n=><View key={n.id} style={styles.listRow}><Text style={{fontSize:18}}>{n.icon}</Text><View style={{flex:1}}><Text style={styles.listTitle}>{n.title}</Text><Text style={styles.mutedSmall}>{n.body}</Text></View>{!n.read?<View style={styles.unreadDot}/>:null}</View>)}{state.notifications.length===0?<Text style={styles.muted}>No notifications yet.</Text>:null}</Card>
  </ScrollView>
}

function Career({state,setState}:{state:CareerState;setState:(s:CareerState)=>void}){
  const p=state.player;const [team,setTeam]=useState('TOR');const [pickNo,setPickNo]=useState('14');
  return <ScrollView contentContainerStyle={styles.scroll}>
    <SectionTitle title="Career" side={<Pill text={p.stage}/>}/>
    {p.stage==='High School'?<>
      <Card><Text style={styles.cardTitle}>Build your origin</Text><Text style={styles.bodyText}>Your pre-NBA career is intentionally compressed. Generate a prospect, pick a pathway, then simulate only the important checkpoints.</Text><View style={styles.infoGrid}><Info label="Position" value={p.position}/><Info label="Height" value={p.height}/><Info label="Overall" value={`${p.overall}`}/><Info label="Potential" value={`${p.potential}`}/></View><Btn label="Randomize prospect" onPress={()=>setState(randomizeProspect(state))}/></Card>
      <Card><Text style={styles.cardTitle}>Choose a path</Text>{routes.map(r=><Pressable key={r} onPress={()=>setState(chooseRoute(state,r))} style={styles.choiceRow}><View><Text style={styles.listTitle}>{r}</Text><Text style={styles.mutedSmall}>{routeDescription(r)}</Text></View><Text style={styles.arrow}>›</Text></Pressable>)}</Card>
    </>:null}

    {p.stage==='Pre-NBA'?<>
      <Card><SectionTitle title={p.schoolOrClub} side={<Pill text={p.route} tone="muted"/>}/><View style={styles.infoGrid}><Info label="OVR" value={`${p.overall}`}/><Info label="Projection" value={p.draftProjection}/><Info label="Followers" value={p.followers.toLocaleString()}/><Info label="Potential" value={`${p.potential}`}/></View><Text style={styles.bodyText}>Tap a checkpoint to simulate a meaningful stretch instead of grinding through every amateur game.</Text><Btn label={`Sim next ${state.settings.simDetail.toLowerCase()} checkpoint`} onPress={()=>setState(simulatePreNBASegment(state))}/><Btn label="Declare for NBA Draft" variant="outline" disabled={p.overall<66} onPress={()=>setState(declareForDraft(state))}/></Card>
      <CareerTimeline state={state}/>
    </>:null}

    {p.stage==='Awaiting Draft'?<Card style={{borderColor:ACCENT}}><Pill text="HANDOFF TO NBA 2K26"/><Text style={styles.cardTitle}>Let MyNBA run your draft</Text><Text style={styles.bodyText}>Create/import this prospect into the 2K26 draft class, let MyNBA conduct the actual draft, then confirm the result here.</Text><View style={styles.infoGrid}><Info label="OVR" value={`${p.overall}`}/><Info label="Potential" value={`${p.potential}`}/><Info label="Projection" value={p.draftProjection}/><Info label="Position" value={p.position}/></View><Text style={styles.label}>Drafted by</Text><View style={styles.chips}>{teams.map(t=><Pressable key={t} onPress={()=>setTeam(t)} style={[styles.chip,team===t&&styles.chipActive]}><Text style={[styles.chipText,team===t&&{color:'#fff'}]}>{t}</Text></Pressable>)}</View><Field label="Pick number" value={pickNo} onChange={setPickNo} keyboard="number-pad"/><Btn label="Confirm 2K draft result" onPress={()=>setState(confirmDraftResult(state,team,Math.max(1,Number(pickNo)||1)))}/></Card>:null}

    {p.stage==='NBA'?<>
      <Card><SectionTitle title={`${p.team} • Year ${p.seasonYear}`} side={<Pill text={p.role} tone="good"/>}/><View style={styles.infoGrid}><Info label="Overall" value={`${p.overall}`}/><Info label="Draft" value={p.draftPick?`#${p.draftPick}`:'—'}/><Info label="Games" value={`${state.games.length}`}/><Info label="XP" value={p.xp.toLocaleString()}/></View><Text style={styles.bodyText}>NBA 2K26 remains the source of truth for games, draft outcomes and roster moves. The companion turns those confirmed events into your RPG career.</Text></Card>
      <CareerTimeline state={state}/>
      <Card><Text style={styles.cardTitle}>Season transition</Text><Text style={styles.bodyText}>Use this after you finish the season in MyNBA. Aging, wear-and-tear and league-world progression are applied here.</Text><Btn label="Advance to next season" variant="outline" onPress={()=>Alert.alert('Advance season?','Only do this after your MyNBA season is complete.',[{text:'Cancel',style:'cancel'},{text:'Advance',onPress:()=>setState(advanceSeason(state))}])}/></Card>
    </>:null}
  </ScrollView>
}
function routeDescription(r:string){if(r==='NCAA College')return'Traditional college route with exposure, awards and transfer choices.';if(r.includes('JUCO'))return'Late-bloomer route with a second recruiting opportunity.';if(r==='NBL Next Stars')return'Professional competition in Australia with NBA exposure.';if(r==='Overtime Elite')return'Development-first alternative pathway.';if(r.includes('European'))return'Professional overseas development against older competition.';return'International academy path into pro basketball.'}
function CareerTimeline({state}:{state:CareerState}){return <Card><SectionTitle title="Career timeline"/>{state.history.slice(0,8).map(h=><View key={h.id} style={styles.timelineRow}><View style={styles.timelineDot}/><View style={{flex:1}}><Row style={{justifyContent:'space-between'}}><Text style={styles.listTitle}>{h.title}</Text><Canon value={h.canon}/></Row><Text style={styles.mutedSmall}>{h.date} • {h.category}</Text><Text style={styles.bodyText}>{h.body}</Text></View></View>)}</Card>}

function Play({state,setState}:{state:CareerState;setState:(s:CareerState)=>void}){
  const [opponent,setOpponent]=useState('BOS');const [result,setResult]=useState<'W'|'L'>('W');const [importance,setImportance]=useState<(typeof importances)[number]>('Regular');
  const [v,setV]=useState({pts:'24',reb:'5',ast:'8',stl:'1',blk:'0',tov:'3',fgm:'9',fga:'17',tpm:'3',tpa:'7',ftm:'3',fta:'4',minutes:'34',plusMinus:'8'});
  const set=(k:string,val:string)=>setV(x=>({...x,[k]:val}));
  if(state.player.stage!=='NBA')return <ScrollView contentContainerStyle={styles.scroll}><Card><Text style={styles.cardTitle}>NBA games unlock after draft night</Text><Text style={styles.bodyText}>Finish the short pre-NBA path first. Once 2K26 drafts your player, this becomes the fastest way to feed game results into the career universe.</Text></Card></ScrollView>;
  const submit=()=>{const n=(k:keyof typeof v)=>Number(v[k])||0;setState(logGame(state,{opponent,result,importance,pts:n('pts'),reb:n('reb'),ast:n('ast'),stl:n('stl'),blk:n('blk'),tov:n('tov'),fgm:n('fgm'),fga:n('fga'),tpm:n('tpm'),tpa:n('tpa'),ftm:n('ftm'),fta:n('fta'),minutes:n('minutes'),plusMinus:n('plusMinus')}));Alert.alert('Game added','The companion updated progression, social media, storylines, sponsors, relationships and milestones.')};
  return <KeyboardAvoidingView style={{flex:1}} behavior={Platform.OS==='ios'?'padding':undefined}><ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
    <SectionTitle title="Log 2K Game" side={<Canon value="2K Confirmed"/>}/>
    <Card><Text style={styles.cardTitle}>{state.player.team} game result</Text><Text style={styles.label}>Opponent</Text><View style={styles.chips}>{teams.filter(t=>t!==state.player.team).map(t=><Pressable key={t} onPress={()=>setOpponent(t)} style={[styles.chip,opponent===t&&styles.chipActive]}><Text style={[styles.chipText,opponent===t&&{color:'#fff'}]}>{t}</Text></Pressable>)}</View><Row style={{gap:8}}><Btn label="WIN" variant={result==='W'?'solid':'outline'} onPress={()=>setResult('W')}/><Btn label="LOSS" variant={result==='L'?'solid':'outline'} onPress={()=>setResult('L')}/></Row><Text style={styles.label}>Game importance</Text><View style={styles.chips}>{importances.map(i=><Pressable key={i} onPress={()=>setImportance(i)} style={[styles.chip,importance===i&&styles.chipActive]}><Text style={[styles.chipText,importance===i&&{color:'#fff'}]}>{i}</Text></Pressable>)}</View></Card>
    <Card><Text style={styles.cardTitle}>Box score</Text><View style={styles.formGrid}><Field label="PTS" value={v.pts} onChange={x=>set('pts',x)} keyboard="number-pad"/><Field label="REB" value={v.reb} onChange={x=>set('reb',x)} keyboard="number-pad"/><Field label="AST" value={v.ast} onChange={x=>set('ast',x)} keyboard="number-pad"/><Field label="STL" value={v.stl} onChange={x=>set('stl',x)} keyboard="number-pad"/><Field label="BLK" value={v.blk} onChange={x=>set('blk',x)} keyboard="number-pad"/><Field label="TOV" value={v.tov} onChange={x=>set('tov',x)} keyboard="number-pad"/><Field label="FGM" value={v.fgm} onChange={x=>set('fgm',x)} keyboard="number-pad"/><Field label="FGA" value={v.fga} onChange={x=>set('fga',x)} keyboard="number-pad"/><Field label="3PM" value={v.tpm} onChange={x=>set('tpm',x)} keyboard="number-pad"/><Field label="3PA" value={v.tpa} onChange={x=>set('tpa',x)} keyboard="number-pad"/><Field label="FTM" value={v.ftm} onChange={x=>set('ftm',x)} keyboard="number-pad"/><Field label="FTA" value={v.fta} onChange={x=>set('fta',x)} keyboard="number-pad"/><Field label="MIN" value={v.minutes} onChange={x=>set('minutes',x)} keyboard="number-pad"/><Field label="+/-" value={v.plusMinus} onChange={x=>set('plusMinus',x)} keyboard="numbers-and-punctuation"/></View><Btn label="Finish game & process career" onPress={submit}/></Card>
    {state.games.length>0?<Card><SectionTitle title="Recent games"/>{state.games.slice(0,7).map(g=><View key={g.id} style={styles.listRow}><Pill text={g.result} tone={g.result==='W'?'good':'warn'}/><View style={{flex:1}}><Text style={styles.listTitle}>vs {g.opponent} • {g.pts}/{g.reb}/{g.ast}</Text><Text style={styles.mutedSmall}>{g.importance} • +{g.xp.toLocaleString()} XP</Text></View></View>)}</Card>:null}
  </ScrollView></KeyboardAvoidingView>
}

function Social({state,setState,onPost}:{state:CareerState;setState:(s:CareerState)=>void;onPost:(p:SocialPost)=>void}){
  const [text,setText]=useState('');return <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
    <SectionTitle title="Social" side={<Pill text={`${state.player.followers.toLocaleString()} followers`}/>}/>
    <Card><Text style={styles.label}>Post as {state.player.name}</Text><TextInput multiline value={text} onChangeText={setText} placeholder="What's happening in your career?" placeholderTextColor="#626b78" style={[styles.input,{minHeight:82,textAlignVertical:'top'}]}/><Btn label="Post" disabled={!text.trim()} onPress={()=>{setState(addUserPost(state,text.trim()));setText('')}}/></Card>
    {state.social.map(p=><Card key={p.id} style={p.kind==='Breaking'?{borderColor:ACCENT}:undefined}><Row style={{justifyContent:'space-between',alignItems:'center'}}><View><Text style={styles.listTitle}>{p.author}</Text><Text style={styles.mutedSmall}>{p.handle} • {p.date}</Text></View><Canon value={p.canon}/></Row><Text style={styles.socialBody}>{p.body}</Text><Row style={{gap:16}}><Pressable onPress={()=>setState(toggleLike(state,p.id))}><Text style={[styles.socialAction,p.likedByUser&&{color:ACCENT}]}>{p.likedByUser?'♥':'♡'} {p.likes.toLocaleString()}</Text></Pressable><Pressable onPress={()=>onPost(p)}><Text style={styles.socialAction}>Reply {p.replies?`(${p.replies})`:''}</Text></Pressable><Text style={styles.socialAction}>↻ {p.reposts.toLocaleString()}</Text></Row></Card>)}
  </ScrollView>
}

function MoreRoot({screen,setScreen,state,setState,onEvent}:{screen:any;setScreen:(s:any)=>void;state:CareerState;setState:(s:CareerState)=>void;onEvent:(e:DynamicEvent)=>void}){
  if(screen==='Menu')return <ScrollView contentContainerStyle={styles.scroll}><SectionTitle title="More"/><View style={styles.menuGrid}>{[
    ['Player','🏀','Attributes, badges & progression'],['Relationships','🤝','People, memories & rivalries'],['Sponsors','💼','Deals, agent & brand value'],['Life','🌆','Events, offseason & lifestyle'],['League','📰','News, transactions & world'],['History','🏆','Milestones, chapters & legacy'],['Settings','⚙️','Immersion, backups & import/export']
  ].map(([name,icon,desc])=><Pressable key={name} onPress={()=>setScreen(name)} style={styles.menuCard}><Text style={{fontSize:28}}>{icon}</Text><Text style={styles.cardTitle}>{name}</Text><Text style={styles.mutedSmall}>{desc}</Text></Pressable>)}</View></ScrollView>;
  const back=<Pressable onPress={()=>setScreen('Menu')}><Text style={styles.back}>‹ More</Text></Pressable>;
  if(screen==='Player')return <PlayerScreen state={state} setState={setState} back={back}/>;
  if(screen==='Relationships')return <Relationships state={state} setState={setState} back={back}/>;
  if(screen==='Sponsors')return <Sponsors state={state} setState={setState} back={back}/>;
  if(screen==='Life')return <Life state={state} setState={setState} back={back} onEvent={onEvent}/>;
  if(screen==='League')return <League state={state} setState={setState} back={back}/>;
  if(screen==='History')return <History state={state} back={back}/>;
  return <Settings state={state} setState={setState} back={back}/>;
}

function PlayerScreen({state,setState,back}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode}){
  const cats=[...new Set(state.attributes.map(a=>a.category))];return <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="Player Development" side={<Pill text={`${state.player.xp.toLocaleString()} XP`}/>}/>
    <View style={styles.metrics}><Metric label="OVR" value={state.player.overall}/><Metric label="POT" value={state.player.potential}/><Metric label="MORALE" value={state.player.morale}/><Metric label="FATIGUE" value={state.player.fatigue}/></View>
    {cats.map(cat=><Card key={cat}><Text style={styles.cardTitle}>{cat}</Text>{state.attributes.filter(a=>a.category===cat).map(a=>{const cost=attributeUpgradeCost(a.rating);return <View key={a.name} style={styles.attrRow}><View style={{flex:1}}><Text style={styles.listTitle}>{a.name}</Text><Text style={styles.mutedSmall}>Upgrade: {cost.toLocaleString()} XP</Text><Progress value={a.rating}/></View><Text style={styles.attrValue}>{a.rating}</Text><Btn small label="+1" variant="outline" onPress={()=>{const r=upgradeAttribute(state,a.name);setState(r.state);if(r.message.startsWith('Need'))Alert.alert('Not enough XP',r.message)}}/></View>})}</Card>)}
    <Card><Text style={styles.cardTitle}>Badges</Text>{state.badges.map(b=><View key={b.name} style={styles.listRow}><View style={{flex:1}}><Text style={styles.listTitle}>{b.name}</Text><Text style={styles.mutedSmall}>{b.category}</Text></View><Pill text={b.level} tone={b.level==='Locked'?'muted':'accent'}/></View>)}</Card>
  </ScrollView>
}

function Relationships({state,setState,back}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode}){
  return <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="Relationships" side={<Pill text={`${state.relationships.length} people`}/>}/>{state.relationships.map(r=><Card key={r.id}><Row style={{justifyContent:'space-between'}}><View style={{flex:1}}><Text style={styles.cardTitle}>{r.name}</Text><Text style={styles.mutedSmall}>{r.role}{r.team?` • ${r.team}`:''}</Text></View><Pill text={r.status} tone={r.rivalry>60?'warn':'good'}/></Row><View style={styles.infoGrid}><Info label="Trust" value={`${r.trust}`}/><Info label="Respect" value={`${r.respect}`}/><Info label="Friendship" value={`${r.friendship}`}/><Info label="Rivalry" value={`${r.rivalry}`}/></View>{r.memories.slice(-2).map((m,i)=><Text key={i} style={styles.memory}>• {m}</Text>)}<Btn small label="Spend time / interact" variant="outline" onPress={()=>setState(offseasonActivity(state,'Relationships'))}/></Card>)}</ScrollView>
}

function Sponsors({state,setState,back}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode}){
  const offers=state.sponsors.filter(s=>s.status==='Offer'),active=state.sponsors.filter(s=>s.status==='Active');return <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="Sponsors & Agent" side={<Pill text={`Agent trust ${state.player.agentTrust}`}/>}/>
    <View style={styles.metrics}><Metric label="MONEY" value={fmtMoney(state.player.money)}/><Metric label="CAREER EARNINGS" value={fmtMoney(state.player.careerEarnings)}/><Metric label="MARKETABILITY" value={state.player.marketability}/><Metric label="ACTIVE DEALS" value={active.length}/></View>
    {offers.length===0?<Card><Text style={styles.cardTitle}>No open offers</Text><Text style={styles.bodyText}>Big games, follower growth and career milestones can create new brand interest.</Text></Card>:offers.map(sp=><Card key={sp.id} style={{borderColor:ACCENT}}><Row style={{justifyContent:'space-between'}}><View><Text style={styles.cardTitle}>{sp.brand}</Text><Text style={styles.mutedSmall}>{sp.category}</Text></View><Pill text={`${sp.interest}% interest`}/></Row><View style={styles.infoGrid}><Info label="Value" value={fmtMoney(sp.value)}/><Info label="Years" value={`${sp.years}`}/><Info label="Bonus" value={fmtMoney(sp.bonus)}/><Info label="Obligations" value={sp.obligations}/></View><Text style={styles.bodyText}>{sp.objective}</Text><View style={styles.wrap}><Btn small label="Accept" onPress={()=>setState(sponsorAction(state,sp.id,'accept'))}/><Btn small label="Counter" variant="outline" onPress={()=>setState(sponsorAction(state,sp.id,'counter'))}/><Btn small label="Decline" variant="ghost" onPress={()=>setState(sponsorAction(state,sp.id,'decline'))}/></View></Card>)}
    {active.map(sp=><Card key={sp.id}><Row style={{justifyContent:'space-between'}}><View><Text style={styles.cardTitle}>{sp.brand}</Text><Text style={styles.mutedSmall}>{sp.category} • Active</Text></View><Pill text={fmtMoney(sp.value)} tone="good"/></Row><Text style={styles.bodyText}>{sp.objective}</Text><Progress value={sp.progress/sp.target*100}/><Text style={styles.mutedSmall}>{sp.progress} / {sp.target} objective progress</Text></Card>)}
    <Card><Text style={styles.cardTitle}>Agent</Text><Text style={styles.listTitle}>{state.player.agentName}</Text><Text style={styles.bodyText}>Your agent relationship influences negotiations, sponsor counters, media strategy and future career decisions.</Text><Progress value={state.player.agentTrust}/></Card>
  </ScrollView>
}

function Life({state,setState,back,onEvent}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode;onEvent:(e:DynamicEvent)=>void}){
  const unresolved=state.events.filter(e=>!e.resolved);return <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="Life & Offseason" side={<Pill text={state.player.phase} tone="muted"/>}/>
    {unresolved.map(e=><Card key={e.id} style={{borderColor:e.importance==='National'?ACCENT:BORDER}}><Row style={{justifyContent:'space-between'}}><Pill text={e.category}/><Text style={styles.mutedSmall}>{e.importance}</Text></Row><Text style={styles.cardTitle}>{e.title}</Text><Text style={styles.bodyText}>{e.body}</Text><Btn label="Make a decision" onPress={()=>onEvent(e)}/></Card>)}
    <Card><Text style={styles.cardTitle}>Generate an encounter</Text><Text style={styles.bodyText}>Use this when you want an extra off-court moment. Normal gameplay also generates events automatically.</Text><Btn label="Generate encounter" variant="outline" onPress={()=>{const s=clone(state);s.events.unshift(generateEvent(s,'Manual'));setState(s)}}/></Card>
    <Card><Text style={styles.cardTitle}>Offseason week</Text><Text style={styles.bodyText}>Choose one priority. You cannot maximize development, recovery, relationships and brand work simultaneously.</Text><View style={styles.wrap}>{['Skill Training','Recovery','Relationships','Sponsor Work','Community','Vacation'].map(a=><Btn key={a} small label={a} variant="outline" onPress={()=>setState(offseasonActivity(state,a))}/>)}</View></Card>
  </ScrollView>
}

function League({state,setState,back}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode}){
  const [type,setType]=useState('Trade');const [player,setPlayer]=useState(state.player.name);const [from,setFrom]=useState(state.player.team||'TOR');const [to,setTo]=useState('MIA');
  return <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">{back}<SectionTitle title="League Universe" side={<Pill text={`${state.transactions.length} confirmed moves`}/>}/>
    <Card><Text style={styles.cardTitle}>Confirm an important MyNBA transaction</Text><Text style={styles.bodyText}>Mobile has no game sync, so tell the companion only about trades/free-agency moves that matter. These are recorded as 2K Confirmed canon.</Text><Field label="Player" value={player} onChange={setPlayer}/><Field label="Transaction type" value={type} onChange={setType}/><Row style={{gap:8}}><Field label="From" value={from} onChange={setFrom}/><Field label="To" value={to} onChange={setTo}/></Row><Btn label="Confirm roster move" onPress={()=>setState(manualTransaction(state,type,player,from,to))}/></Card>
    <Card><SectionTitle title="Around the league"/>{state.news.slice(0,12).map(n=><View key={n.id} style={styles.newsRow}><View style={{flex:1}}><Text style={styles.listTitle}>{n.headline}</Text><Text style={styles.bodyText}>{n.body}</Text><Text style={styles.mutedSmall}>{n.outlet} • {n.date}</Text></View><Canon value={n.canon}/></View>)}</Card>
    <Card><SectionTitle title="World players"/>{state.worldPlayers.map(w=><View key={w.id} style={styles.listRow}><View style={styles.avatarSmall}><Text style={styles.avatarSmallText}>{w.name.split(' ').map(x=>x[0]).join('').slice(0,2)}</Text></View><View style={{flex:1}}><Text style={styles.listTitle}>{w.name} • {w.position}</Text><Text style={styles.mutedSmall}>{w.team||'Prospect'} • {w.overall} OVR • {w.personality}</Text></View><Pill text={w.reputation} tone="muted"/></View>)}</Card>
    {state.transactions.length>0?<Card><SectionTitle title="Transaction history"/>{state.transactions.slice(0,10).map(tx=><View key={tx.id} style={styles.listRow}><View style={{flex:1}}><Text style={styles.listTitle}>{tx.player}: {tx.fromTeam} → {tx.toTeam}</Text><Text style={styles.mutedSmall}>{tx.type} • {tx.date}</Text></View><Canon value={tx.canon}/></View>)}</Card>:null}
  </ScrollView>
}

function History({state,back}:{state:CareerState;back:React.ReactNode}){
  const achieved=state.milestones.filter(m=>m.achieved);return <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="History & Legacy" side={<Pill text={`Legacy ${state.player.legacy}`}/>}/>
    <View style={styles.metrics}><Metric label="SEASONS" value={Math.max(0,state.player.seasonYear-2026)}/><Metric label="GAMES LOGGED" value={state.games.length}/><Metric label="MILESTONES" value={achieved.length}/><Metric label="EARNINGS" value={fmtMoney(state.player.careerEarnings)}/></View>
    <Card><Text style={styles.cardTitle}>Trophy room / milestones</Text>{state.milestones.map(m=><View key={m.id} style={styles.listRow}><Text style={{fontSize:20}}>{m.achieved?'🏆':'○'}</Text><View style={{flex:1}}><Text style={[styles.listTitle,!m.achieved&&{color:MUTED}]}>{m.name}</Text>{m.date?<Text style={styles.mutedSmall}>{m.date}</Text>:null}</View>{m.achieved?<Pill text="Achieved" tone="good"/>:null}</View>)}</Card>
    <Card><Text style={styles.cardTitle}>Storyline archive</Text>{state.storylines.map(st=><View key={st.id} style={styles.storyRow}><Row style={{justifyContent:'space-between'}}><Text style={styles.listTitle}>{st.title}</Text><Pill text={st.status} tone={st.status==='Active'?'accent':'muted'}/></Row><Text style={styles.bodyText}>{st.summary}</Text><Progress value={st.heat}/></View>)}</Card>
    <CareerTimeline state={state}/>
  </ScrollView>
}

function Settings({state,setState,back}:{state:CareerState;setState:(s:CareerState)=>void;back:React.ReactNode}){
  const [importText,setImportText]=useState('');
  const reset=()=>Alert.alert('Reset career?','This permanently replaces the current local save.',[{text:'Cancel',style:'cancel'},{text:'Reset',style:'destructive',onPress:()=>setState(createDefaultState())}]);
  const doImport=()=>{try{const parsed=JSON.parse(importText);if(!parsed.player||!parsed.attributes)throw new Error();setState(parsed);setImportText('');Alert.alert('Imported','Career save loaded.')}catch{Alert.alert('Invalid save','The pasted JSON is not a valid Career Companion save.')}};
  return <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">{back}<SectionTitle title="Settings"/>
    <Card><Text style={styles.cardTitle}>Immersion</Text><Text style={styles.label}>Mode</Text><View style={styles.chips}>{['Basketball Focused','Immersive','Full Life','Chaos'].map(x=><Pressable key={x} onPress={()=>setState(changeSetting(state,'immersionMode',x))} style={[styles.chip,state.settings.immersionMode===x&&styles.chipActive]}><Text style={[styles.chipText,state.settings.immersionMode===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View><Text style={styles.label}>Pre-NBA simulation detail</Text><View style={styles.chips}>{['Quick','Normal','Detailed'].map(x=><Pressable key={x} onPress={()=>setState(changeSetting(state,'simDetail',x))} style={[styles.chip,state.settings.simDetail===x&&styles.chipActive]}><Text style={[styles.chipText,state.settings.simDetail===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View><Row style={{justifyContent:'space-between',alignItems:'center'}}><View style={{flex:1}}><Text style={styles.listTitle}>Optional romantic-life events</Text><Text style={styles.mutedSmall}>Off by default. Does not affect core career progression.</Text></View><Switch value={state.settings.romanceEnabled} onValueChange={v=>setState(changeSetting(state,'romanceEnabled',v))} trackColor={{true:ACCENT,false:'#343b46'}}/></Row></Card>
    <Card><Text style={styles.cardTitle}>Backup / transfer</Text><Text style={styles.bodyText}>The Android and iOS versions use the same JSON save format, so you can move a career between phones manually.</Text><Btn label="Share / export save" onPress={()=>Share.share({title:'NBA 2K26 Career Companion Save',message:JSON.stringify(state)})}/><Text style={styles.label}>Import save JSON</Text><TextInput multiline value={importText} onChangeText={setImportText} placeholder="Paste exported save JSON here" placeholderTextColor="#626b78" style={[styles.input,{minHeight:110,textAlignVertical:'top'}]}/><Btn label="Import pasted save" variant="outline" disabled={!importText.trim()} onPress={doImport}/></Card>
    <Card><Text style={styles.cardTitle}>Canon rules</Text><Text style={styles.bodyText}>2K Confirmed = something you say happened inside MyNBA. Companion Canon = generated story around those events. Rumor = intentionally unverified in-universe information. This mobile edition never claims to be directly synced to your game.</Text></Card>
    <Card><Text style={styles.cardTitle}>Danger zone</Text><Btn label="Reset career" variant="danger" onPress={reset}/></Card>
  </ScrollView>
}

function EventModal({state,event,onClose,onResolve}:{state:CareerState;event:DynamicEvent|null;onClose:()=>void;onResolve:(i:number)=>void}){
  if(!event)return null;return <Modal transparent animationType="slide" visible onRequestClose={onClose}><View style={styles.modalScrim}><View style={styles.modalSheet}><Row style={{justifyContent:'space-between'}}><Pill text={event.category}/><Pressable onPress={onClose}><Text style={styles.close}>×</Text></Pressable></Row><Text style={styles.modalTitle}>{event.title}</Text><Text style={styles.bodyText}>{event.body}</Text><Text style={styles.mutedSmall}>Consequences are intentionally not shown as exact +/− numbers.</Text>{event.choices.map((c,i)=><Pressable key={c.label} onPress={()=>onResolve(i)} style={styles.modalChoice}><Text style={styles.listTitle}>{c.label}</Text><Text style={styles.mutedSmall}>Choose this response</Text></Pressable>)}</View></View></Modal>
}
function SocialModal({state,post,onClose,onRespond}:{state:CareerState;post:SocialPost|null;onClose:()=>void;onRespond:(t:string)=>void}){
  if(!post)return null;return <Modal transparent animationType="slide" visible onRequestClose={onClose}><View style={styles.modalScrim}><View style={styles.modalSheet}><Row style={{justifyContent:'space-between'}}><Text style={styles.cardTitle}>Reply to {post.handle}</Text><Pressable onPress={onClose}><Text style={styles.close}>×</Text></Pressable></Row><View style={styles.callout}><Text style={styles.bodyText}>{post.body}</Text></View>{[
    'Appreciate it. Work is just getting started.','😂 Keep that same energy.','We’ll see what happens on the court.','No comment — just focused on the next game.'
  ].map(t=><Pressable key={t} onPress={()=>onRespond(t)} style={styles.modalChoice}><Text style={styles.listTitle}>{t}</Text></Pressable>)}</View></View></Modal>
}
function Info({label,value}:{label:string;value:string}){return <View style={styles.info}><Text style={styles.mutedSmall}>{label.toUpperCase()}</Text><Text numberOfLines={2} style={styles.infoValue}>{value}</Text></View>}

const styles=StyleSheet.create({
  safe:{flex:1,backgroundColor:BG},app:{flex:1,backgroundColor:BG},body:{flex:1},scroll:{padding:16,paddingBottom:32,gap:12},
  header:{minHeight:72,paddingHorizontal:16,paddingVertical:10,borderBottomWidth:1,borderBottomColor:BORDER,flexDirection:'row',alignItems:'center',gap:12,backgroundColor:BG},
  avatar:{width:48,height:48,borderRadius:24,backgroundColor:ACCENT,alignItems:'center',justifyContent:'center'},avatarText:{color:'#fff',fontWeight:'900',fontSize:16},playerName:{color:TEXT,fontSize:18,fontWeight:'800',maxWidth:190},sub:{color:MUTED,fontSize:12,marginTop:3},
  bell:{width:42,height:42,borderRadius:14,backgroundColor:PANEL,alignItems:'center',justifyContent:'center',borderWidth:1,borderColor:BORDER},badge:{position:'absolute',right:-3,top:-4,minWidth:18,height:18,borderRadius:9,backgroundColor:ACCENT,alignItems:'center',justifyContent:'center',paddingHorizontal:4},badgeText:{color:'#fff',fontSize:10,fontWeight:'900'},
  bottomNav:{height:68,borderTopWidth:1,borderTopColor:BORDER,backgroundColor:'#0e1116',flexDirection:'row',paddingBottom:Platform.OS==='ios'?7:0},navItem:{flex:1,alignItems:'center',justifyContent:'center',position:'relative'},navIcon:{color:MUTED,fontSize:21,fontWeight:'700'},navLabel:{color:MUTED,fontSize:10,marginTop:3,fontWeight:'700'},navDot:{position:'absolute',top:10,right:'27%',width:7,height:7,borderRadius:4,backgroundColor:ACCENT},
  card:{backgroundColor:PANEL,borderRadius:18,borderWidth:1,borderColor:BORDER,padding:15,gap:11},metric:{backgroundColor:PANEL2,borderRadius:15,borderWidth:1,borderColor:BORDER,padding:12,flex:1,minWidth:145},metrics:{flexDirection:'row',flexWrap:'wrap',gap:9},metricValue:{color:TEXT,fontSize:24,fontWeight:'900',marginVertical:3},
  sectionTitle:{color:TEXT,fontSize:22,fontWeight:'900'},cardTitle:{color:TEXT,fontSize:17,fontWeight:'800'},bodyText:{color:'#d8dee7',fontSize:14,lineHeight:20},muted:{color:MUTED,fontSize:14},mutedSmall:{color:MUTED,fontSize:11,lineHeight:16},label:{color:'#cbd2dc',fontSize:12,fontWeight:'700',marginTop:3},
  row:{flexDirection:'row'},wrap:{flexDirection:'row',flexWrap:'wrap',gap:8},pill:{borderWidth:1,borderRadius:999,paddingHorizontal:8,paddingVertical:4,alignSelf:'flex-start'},pillText:{fontSize:10,fontWeight:'800'},
  btn:{borderRadius:13,minHeight:44,paddingHorizontal:14,paddingVertical:11,alignItems:'center',justifyContent:'center',marginTop:2},btnSmall:{minHeight:38,paddingVertical:8,paddingHorizontal:12},btnSolid:{backgroundColor:ACCENT},btnOutline:{borderWidth:1,borderColor:BORDER,backgroundColor:PANEL2},btnGhost:{backgroundColor:'transparent'},btnDanger:{backgroundColor:'#a52b34'},btnText:{color:TEXT,fontSize:13,fontWeight:'800'},
  progressTrack:{height:8,borderRadius:5,backgroundColor:'#252b35',overflow:'hidden',marginTop:5},progressFill:{height:'100%',backgroundColor:ACCENT,borderRadius:5},callout:{backgroundColor:'#211a1a',borderRadius:14,borderLeftWidth:3,borderLeftColor:ACCENT,padding:12,gap:5},
  statTriplet:{flexDirection:'row',flexWrap:'wrap',gap:8},listRow:{flexDirection:'row',alignItems:'center',gap:10,paddingVertical:9,borderBottomWidth:StyleSheet.hairlineWidth,borderBottomColor:BORDER},listTitle:{color:TEXT,fontSize:14,fontWeight:'700'},unreadDot:{width:8,height:8,borderRadius:4,backgroundColor:ACCENT},
  infoGrid:{flexDirection:'row',flexWrap:'wrap',gap:8},info:{width:'47%',backgroundColor:PANEL2,borderRadius:12,padding:10,borderWidth:1,borderColor:BORDER},infoValue:{color:TEXT,fontSize:14,fontWeight:'800',marginTop:3},choiceRow:{minHeight:58,paddingVertical:12,borderBottomWidth:1,borderBottomColor:BORDER,flexDirection:'row',justifyContent:'space-between',alignItems:'center'},arrow:{color:ACCENT,fontSize:28},
  chips:{flexDirection:'row',flexWrap:'wrap',gap:7},chip:{borderRadius:10,borderWidth:1,borderColor:BORDER,backgroundColor:PANEL2,paddingHorizontal:10,paddingVertical:7},chipActive:{backgroundColor:ACCENT,borderColor:ACCENT},chipText:{color:'#c7ced8',fontSize:11,fontWeight:'800'},
  input:{backgroundColor:'#0f1217',borderRadius:12,borderWidth:1,borderColor:BORDER,color:TEXT,paddingHorizontal:12,paddingVertical:11,fontSize:14},formGrid:{flexDirection:'row',flexWrap:'wrap',gap:10},
  timelineRow:{flexDirection:'row',gap:10,paddingVertical:8},timelineDot:{width:10,height:10,borderRadius:5,backgroundColor:ACCENT,marginTop:6},socialBody:{color:TEXT,fontSize:15,lineHeight:22},socialAction:{color:MUTED,fontSize:12,fontWeight:'700'},
  menuGrid:{flexDirection:'row',flexWrap:'wrap',gap:10},menuCard:{width:'48%',minHeight:145,backgroundColor:PANEL,borderRadius:18,borderWidth:1,borderColor:BORDER,padding:15,gap:8},back:{color:ACCENT,fontSize:15,fontWeight:'800'},
  attrRow:{flexDirection:'row',alignItems:'center',gap:10,paddingVertical:9,borderBottomWidth:StyleSheet.hairlineWidth,borderBottomColor:BORDER},attrValue:{color:TEXT,fontSize:21,fontWeight:'900',width:36,textAlign:'center'},memory:{color:'#c3cad4',fontSize:12,fontStyle:'italic'},newsRow:{flexDirection:'row',gap:10,paddingVertical:12,borderBottomWidth:1,borderBottomColor:BORDER},
  avatarSmall:{width:38,height:38,borderRadius:19,backgroundColor:PANEL2,borderWidth:1,borderColor:BORDER,alignItems:'center',justifyContent:'center'},avatarSmallText:{color:TEXT,fontSize:11,fontWeight:'900'},storyRow:{paddingVertical:11,gap:6,borderBottomWidth:1,borderBottomColor:BORDER},
  modalScrim:{flex:1,backgroundColor:'rgba(0,0,0,.72)',justifyContent:'flex-end'},modalSheet:{backgroundColor:'#12161d',borderTopLeftRadius:26,borderTopRightRadius:26,borderWidth:1,borderColor:BORDER,padding:18,paddingBottom:Platform.OS==='ios'?34:22,gap:12,maxHeight:'82%'},modalTitle:{color:TEXT,fontSize:24,fontWeight:'900'},modalChoice:{backgroundColor:PANEL2,borderRadius:15,borderWidth:1,borderColor:BORDER,padding:14,gap:4},close:{color:MUTED,fontSize:30,lineHeight:32}
});
