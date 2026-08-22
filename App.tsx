import React, { useEffect, useState } from 'react';
import {
  ActivityIndicator, Alert, KeyboardAvoidingView, Modal, Platform, Pressable, SafeAreaView, ScrollView,
  Share, StyleSheet, Switch, Text, TextInput, View
} from 'react-native';
import { StatusBar } from 'expo-status-bar';
import Storage from 'expo-sqlite/kv-store';
import * as ImagePicker from 'expo-image-picker';
import { extractTextFromImage, isSupported as isTextExtractionSupported } from 'expo-text-extractor';
import { createDefaultState } from './src/defaultState';
import {
  addUserPost, advanceSeason, attributeUpgradeCost, changeSetting, chooseRoute, confirmDraftResult,
  declareForDraft, generateEvent, logGame, manualTransaction, offseasonActivity, randomizeProspect,
  resolveEvent, simulatePreNBASegment, sponsorAction, toggleLike, upgradeAttribute,
  initializeCareerProfile, updatePlayerProfile, PlayerProfileInput,
  applyScannedAttributes, applyScannedBadges, applyScannedPlayerOverview, applyScannedTransactions,
  recordGameScreenScan
} from './src/engine';
import { CareerState, DynamicEvent, SocialPost } from './src/model';
import {
  GameScanKey, ScannedAttribute, ScannedBadge, ScannedGameField, ScannedPlayerField, ScannedTransaction,
  humanizeScanKey, parseAttributeScreen, parseBadgeScreen, parseGameScreen,
  parsePlayerOverview, parseTransactionLog
} from './src/screenScan';

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
const pct = (n:number):`${number}%` => `${Math.max(0,Math.min(100,n))}%`;

const positions=['PG','SG','SF','PF','C'];
const schoolYears=['Freshman','Sophomore','Junior','Senior'];

function migrateCareerState(raw:any):CareerState {
  const base=createDefaultState();
  if(!raw||typeof raw!=='object')return base;
  return {
    ...base,
    ...raw,
    version:3,
    player:{...base.player,...(raw.player||{})},
    settings:{...base.settings,...(raw.settings||{}),onboardingComplete:raw.settings?.onboardingComplete??false},
    attributes:Array.isArray(raw.attributes)?raw.attributes:base.attributes,
    badges:Array.isArray(raw.badges)?raw.badges:base.badges,
    games:Array.isArray(raw.games)?raw.games:[],
    relationships:Array.isArray(raw.relationships)?raw.relationships:base.relationships,
    social:Array.isArray(raw.social)?raw.social:base.social,
    news:Array.isArray(raw.news)?raw.news:base.news,
    events:Array.isArray(raw.events)?raw.events:[],
    sponsors:Array.isArray(raw.sponsors)?raw.sponsors:[],
    storylines:Array.isArray(raw.storylines)?raw.storylines:[],
    history:Array.isArray(raw.history)?raw.history:base.history,
    notifications:Array.isArray(raw.notifications)?raw.notifications:[],
    finances:Array.isArray(raw.finances)?raw.finances:[],
    transactions:Array.isArray(raw.transactions)?raw.transactions:[],
    worldPlayers:Array.isArray(raw.worldPlayers)?raw.worldPlayers:base.worldPlayers,
    prospects:Array.isArray(raw.prospects)?raw.prospects:base.prospects,
    milestones:Array.isArray(raw.milestones)?raw.milestones:base.milestones,
    screenScans:Array.isArray(raw.screenScans)?raw.screenScans:[]
  };
}

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

type ScanReviewItem = {
  id:string;
  label:string;
  value:string;
  current?:string;
  confidence:'High'|'Medium';
  payload:any;
  selected?:boolean;
};
type ScanReviewData = {title:string;subtitle:string;items:ScanReviewItem[];rawText:string};

function CameraButton({label,onPress,disabled=false}:{label:string;onPress:()=>void;disabled?:boolean}){
  return <Pressable accessibilityRole="button" accessibilityLabel={label} disabled={disabled} onPress={onPress} style={({pressed})=>[styles.cameraBtn,disabled&&{opacity:.45},pressed&&!disabled&&{opacity:.68}]}><Text style={styles.cameraIcon}>📷</Text></Pressable>;
}

function chooseScanSource(target:string):Promise<'camera'|'library'|null>{
  return new Promise(resolve=>Alert.alert(`Scan ${target}`,'Take a clear photo of the 2K screen, or use a console screenshot already saved on this phone.',[
    {text:'Take photo',onPress:()=>resolve('camera')},
    {text:'Choose screenshot',onPress:()=>resolve('library')},
    {text:'Cancel',style:'cancel',onPress:()=>resolve(null)}
  ],{cancelable:true,onDismiss:()=>resolve(null)}));
}

function use2KScreenScanner(){
  const [busy,setBusy]=useState(false);const [busyLabel,setBusyLabel]=useState('Reading 2K screen…');
  const scan=async(target:string):Promise<string|null>=>{
    if(!isTextExtractionSupported){Alert.alert('Scanner unavailable','Install an EAS or Android development build of this version. The native screen reader is not available inside Expo Go.');return null}
    const source=await chooseScanSource(target);if(!source)return null;
    try{
      if(source==='camera'){
        const existing=await ImagePicker.getCameraPermissionsAsync();
        const permission=existing.granted?existing:await ImagePicker.requestCameraPermissionsAsync();
        if(!permission.granted){Alert.alert('Camera permission needed','Allow camera access to photograph your NBA 2K26 screen. You can still choose an existing screenshot.');return null}
      }
      setBusyLabel(`Reading ${target}…`);setBusy(true);
      const picked=source==='camera'
        ?await ImagePicker.launchCameraAsync({mediaTypes:['images'],quality:1,allowsEditing:false})
        :await ImagePicker.launchImageLibraryAsync({mediaTypes:['images'],quality:1,allowsEditing:false});
      if(picked.canceled||!picked.assets?.[0]?.uri)return null;
      const lines=await extractTextFromImage(picked.assets[0].uri);
      const raw=lines.map(line=>line.trim()).filter(Boolean).join('\n');
      if(!raw){Alert.alert('No text found','Move closer, avoid glare, keep the TV text sharp, and make the section you want fill most of the photo.');return null}
      return raw;
    }catch(error){
      const message=error instanceof Error?error.message:'The screen could not be read.';
      Alert.alert('Could not scan screen',`${message}\n\nTry a sharper photo or choose a direct console screenshot.`);return null;
    }finally{setBusy(false)}
  };
  return {scan,busy,busyLabel};
}

function ScanBusyModal({visible,label}:{visible:boolean;label:string}){
  return <Modal visible={visible} transparent animationType="fade"><View style={styles.busyScrim}><View style={styles.busyCard}><ActivityIndicator size="large" color={ACCENT}/><Text style={styles.cardTitle}>{label}</Text><Text style={styles.mutedSmall}>Recognition happens on this device. Nothing is applied automatically.</Text></View></View></Modal>;
}

function ScanReviewModal({review,onClose,onApply}:{review:ScanReviewData|null;onClose:()=>void;onApply:(items:ScanReviewItem[])=>void}){
  const [draft,setDraft]=useState<ScanReviewItem[]>([]);const [showRaw,setShowRaw]=useState(false);
  useEffect(()=>{setDraft((review?.items||[]).map(item=>({...item,selected:item.selected??true})));setShowRaw(false)},[review]);
  if(!review)return null;
  const selected=draft.filter(item=>item.selected);
  return <Modal visible transparent animationType="slide" onRequestClose={onClose}><View style={styles.modalScrim}><View style={[styles.modalSheet,{maxHeight:'92%'}]}>
    <Row style={{justifyContent:'space-between',alignItems:'flex-start'}}><View style={{flex:1,paddingRight:12}}><Text style={styles.modalTitle}>{review.title}</Text><Text style={styles.mutedSmall}>{review.subtitle}</Text></View><Pressable onPress={onClose}><Text style={styles.close}>×</Text></Pressable></Row>
    <View style={styles.scanPrivacy}><Text style={styles.scanPrivacyText}>Review required • Only checked rows will be applied</Text></View>
    <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={{gap:8}}>{draft.map(item=><Pressable key={item.id} onPress={()=>setDraft(items=>items.map(row=>row.id===item.id?{...row,selected:!row.selected}:row))} style={[styles.scanReviewRow,item.selected&&styles.scanReviewRowSelected]}>
      <View style={[styles.checkBox,item.selected&&styles.checkBoxSelected]}><Text style={styles.checkText}>{item.selected?'✓':''}</Text></View>
      <View style={{flex:1}}><Row style={{justifyContent:'space-between',gap:8}}><Text style={styles.listTitle}>{item.label}</Text><Pill text={item.confidence} tone={item.confidence==='High'?'good':'warn'}/></Row>{item.current!==undefined?<Text style={styles.mutedSmall}>Current: {item.current}</Text>:null}<Text style={styles.scanValue}>Scanned: {item.value}</Text></View>
    </Pressable>)}</ScrollView>
    <Pressable onPress={()=>setShowRaw(value=>!value)}><Text style={styles.rawToggle}>{showRaw?'Hide':'Show'} recognized text</Text></Pressable>
    {showRaw?<ScrollView style={styles.rawOcr} nestedScrollEnabled><Text selectable style={styles.rawOcrText}>{review.rawText}</Text></ScrollView>:null}
    <Row style={{gap:8}}><View style={{flex:1}}><Btn label="Cancel" variant="outline" onPress={onClose}/></View><View style={{flex:1}}><Btn label={`Apply ${selected.length}`} disabled={!selected.length} onPress={()=>onApply(selected)}/></View></Row>
  </View></View></Modal>;
}

export default function App(){
  const [state,setState]=useState<CareerState>(()=>createDefaultState());
  const [loaded,setLoaded]=useState(false);
  const [tab,setTab]=useState<'Home'|'Career'|'Play'|'Social'|'More'>('Home');
  const [more,setMore]=useState<'Menu'|'Player'|'Relationships'|'Sponsors'|'Life'|'League'|'History'|'Settings'>('Menu');
  const [event,setEvent]=useState<DynamicEvent|null>(null);
  const [socialDetail,setSocialDetail]=useState<SocialPost|null>(null);

  useEffect(()=>{(async()=>{try{const raw=await Storage.getItem(SAVE_KEY);if(raw)setState(migrateCareerState(JSON.parse(raw)));}catch{}finally{setLoaded(true)}})()},[]);
  useEffect(()=>{if(!loaded)return;const t=setTimeout(()=>Storage.setItem(SAVE_KEY,JSON.stringify(state)).catch(()=>{}),250);return()=>clearTimeout(t)},[state,loaded]);

  if(!loaded)return <SafeAreaView style={styles.safe}><StatusBar style="light"/><View style={styles.splash}><Text style={styles.splashMark}>2K</Text><Text style={styles.splashTitle}>Career Companion</Text><Text style={styles.muted}>Loading your universe…</Text></View></SafeAreaView>;
  if(!state.settings.onboardingComplete)return <OnboardingScreen state={state} onStart={(profile)=>setState(initializeCareerProfile(state,profile))}/>;

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


function ProfileForm({state,onSave,submitLabel='Save player profile'}:{state:CareerState;onSave:(profile:PlayerProfileInput)=>void;submitLabel?:string}){
  const p=state.player;
  const [name,setName]=useState(p.name||'');
  const [position,setPosition]=useState(p.position||'PG');
  const [age,setAge]=useState(String(p.age||17));
  const [height,setHeight]=useState(p.height||"6'3\"");
  const [weight,setWeight]=useState(String(p.weight||175));
  const [hometown,setHometown]=useState(p.hometown||'');
  const [nationality,setNationality]=useState(p.nationality||'');
  const [dominantHand,setDominantHand]=useState<'Right'|'Left'>(p.dominantHand||'Right');
  const [highSchoolYear,setHighSchoolYear]=useState(p.highSchoolYear||'Senior');
  const [schoolOrClub,setSchoolOrClub]=useState(p.schoolOrClub||'');
  const [jersey,setJersey]=useState(String(p.jersey??0));
  const submit=()=>{
    const cleanName=name.trim(),cleanHome=hometown.trim(),cleanSchool=schoolOrClub.trim(),cleanHeight=height.trim();
    const ageN=Number(age),weightN=Number(weight),jerseyN=Number(jersey);
    if(cleanName.length<2)return Alert.alert('Enter your player name','Use the name you want the companion to use throughout your career.');
    if(!cleanHome)return Alert.alert('Enter a hometown','Your hometown is used for local media and career events.');
    if(!cleanSchool)return Alert.alert('Enter a school or club','This is your starting high-school, academy or club name.');
    if(!cleanHeight)return Alert.alert('Enter a height','Example: 6\'3"');
    if(!Number.isFinite(ageN)||ageN<14||ageN>22)return Alert.alert('Check age','Starting age must be between 14 and 22.');
    if(!Number.isFinite(weightN)||weightN<120||weightN>400)return Alert.alert('Check weight','Enter a weight between 120 and 400 lbs.');
    if(!Number.isFinite(jerseyN)||jerseyN<0||jerseyN>99)return Alert.alert('Check jersey number','Use a jersey number from 0 to 99.');
    onSave({name:cleanName,position,age:ageN,height:cleanHeight,weight:weightN,hometown:cleanHome,nationality:nationality.trim()||'Unknown',dominantHand,highSchoolYear,schoolOrClub:cleanSchool,jersey:jerseyN});
  };
  return <View style={{gap:12}}>
    <Card>
      <Text style={styles.cardTitle}>Identity</Text>
      <Field label="Player name" value={name} onChange={setName} placeholder="Your player's full name"/>
      <View style={styles.formGrid}><Field label="Hometown" value={hometown} onChange={setHometown} placeholder="Toronto, ON"/><Field label="Nationality" value={nationality} onChange={setNationality} placeholder="Canada"/></View>
      <Field label="Starting high school / academy / club" value={schoolOrClub} onChange={setSchoolOrClub} placeholder="Create a school or club name"/>
    </Card>
    <Card>
      <Text style={styles.cardTitle}>Basketball profile</Text>
      <Text style={styles.label}>Position</Text><View style={styles.chips}>{positions.map(x=><Pressable key={x} onPress={()=>setPosition(x)} style={[styles.chip,position===x&&styles.chipActive]}><Text style={[styles.chipText,position===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View>
      <Text style={styles.label}>High-school year</Text><View style={styles.chips}>{schoolYears.map(x=><Pressable key={x} onPress={()=>setHighSchoolYear(x)} style={[styles.chip,highSchoolYear===x&&styles.chipActive]}><Text style={[styles.chipText,highSchoolYear===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View>
      <Text style={styles.label}>Dominant hand</Text><View style={styles.chips}>{(['Right','Left'] as const).map(x=><Pressable key={x} onPress={()=>setDominantHand(x)} style={[styles.chip,dominantHand===x&&styles.chipActive]}><Text style={[styles.chipText,dominantHand===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View>
      <View style={styles.formGrid}><Field label="Age" value={age} onChange={setAge} keyboard="number-pad"/><Field label="Height" value={height} onChange={setHeight} placeholder={'6\'3"'}/><Field label="Weight (lbs)" value={weight} onChange={setWeight} keyboard="number-pad"/><Field label="Jersey #" value={jersey} onChange={setJersey} keyboard="number-pad"/></View>
    </Card>
    <Btn label={submitLabel} onPress={submit}/>
  </View>;
}

function OnboardingScreen({state,onStart}:{state:CareerState;onStart:(profile:PlayerProfileInput)=>void}){
  return <SafeAreaView style={styles.safe}><StatusBar style="light"/><KeyboardAvoidingView style={{flex:1}} behavior={Platform.OS==='ios'?'padding':undefined}><ScrollView contentContainerStyle={styles.onboardingScroll} keyboardShouldPersistTaps="handled" showsVerticalScrollIndicator={false}>
    <View style={styles.onboardingHero}><View style={styles.onboardingLogo}><Text style={styles.onboardingLogoText}>2K</Text></View><Pill text="CAREER COMPANION V1.2"/><Text style={styles.onboardingTitle}>Create your prospect</Text><Text style={styles.onboardingSubtitle}>Set the identity the app will use across recruiting, social media, relationships, sponsors, news and your entire career history.</Text></View>
    <ProfileForm state={state} onSave={onStart} submitLabel="Start career"/>
    <Text style={[styles.mutedSmall,{textAlign:'center',paddingHorizontal:10}]}>You can edit these details later from More → Player. Your ratings and potential remain part of the career simulation.</Text>
  </ScrollView></KeyboardAvoidingView></SafeAreaView>;
}

function ProfileEditorModal({state,visible,onClose,onSave}:{state:CareerState;visible:boolean;onClose:()=>void;onSave:(profile:PlayerProfileInput)=>void}){
  if(!visible)return null;
  return <Modal visible transparent animationType="slide" onRequestClose={onClose}><View style={styles.modalScrim}><View style={[styles.modalSheet,{maxHeight:'94%'}]}><Row style={{justifyContent:'space-between',alignItems:'center'}}><View><Text style={styles.modalTitle}>Edit player profile</Text><Text style={styles.mutedSmall}>Changes affect future companion content.</Text></View><Pressable onPress={onClose}><Text style={styles.close}>×</Text></Pressable></Row><ScrollView keyboardShouldPersistTaps="handled" showsVerticalScrollIndicator={false}><ProfileForm state={state} onSave={onSave} submitLabel="Save changes"/></ScrollView></View></View></Modal>;
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
      <Card><Text style={styles.cardTitle}>Build your origin</Text><Text style={styles.bodyText}>Your identity is locked in from setup. Generate a randomized basketball profile, pick a pathway, then simulate only the important checkpoints.</Text><View style={styles.infoGrid}><Info label="Position" value={p.position}/><Info label="Height" value={p.height}/><Info label="Overall" value={`${p.overall}`}/><Info label="Potential" value={`${p.potential}`}/></View><Btn label="Randomize basketball profile" onPress={()=>setState(randomizeProspect(state))}/></Card>
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
  const emptyGame=()=>({pts:'',reb:'',ast:'',stl:'',blk:'',tov:'',fgm:'',fga:'',tpm:'',tpa:'',ftm:'',fta:'',minutes:'',plusMinus:''});
  const [v,setV]=useState(emptyGame);
  const [review,setReview]=useState<ScanReviewData|null>(null);const scanner=use2KScreenScanner();
  const set=(k:string,val:string)=>setV(x=>({...x,[k]:val}));
  if(state.player.stage!=='NBA')return <ScrollView contentContainerStyle={styles.scroll}><Card><Text style={styles.cardTitle}>NBA games unlock after draft night</Text><Text style={styles.bodyText}>Finish the short pre-NBA path first. Once 2K26 drafts your player, this becomes the fastest way to feed game results into the career universe.</Text></Card></ScrollView>;
  const submit=()=>{const missing=(['pts','reb','ast','minutes'] as (keyof typeof v)[]).filter(key=>v[key].trim()==='');if(missing.length)return Alert.alert('Finish the box score',`Enter or scan ${missing.map(key=>humanizeScanKey(key as GameScanKey)).join(', ')} before processing the game.`);const n=(k:keyof typeof v)=>Number(v[k])||0;setState(logGame(state,{opponent,result,importance,pts:n('pts'),reb:n('reb'),ast:n('ast'),stl:n('stl'),blk:n('blk'),tov:n('tov'),fgm:n('fgm'),fga:n('fga'),tpm:n('tpm'),tpa:n('tpa'),ftm:n('ftm'),fta:n('fta'),minutes:n('minutes'),plusMinus:n('plusMinus')}));setV(emptyGame());Alert.alert('Game added','The companion updated progression, social media, storylines, sponsors, relationships and milestones.')};
  const currentGameValue=(key:GameScanKey)=>key==='opponent'?opponent:key==='result'?result:key==='importance'?importance:(v as Record<string,string>)[key]||'Blank';
  const scanGame=async()=>{const raw=await scanner.scan('game stats');if(!raw)return;const fields=parseGameScreen(raw,{playerName:state.player.name,ownTeam:state.player.team,teamCodes:teams});if(!fields.length){Alert.alert('No box-score fields recognized','Show the stat headings and your player row in the same photo. You can also scan a close-up that contains labels such as PTS, REB, AST, FGM and FGA.');return}setReview({title:'Review game scan',subtitle:'Confirm the scoreboard and box-score values before they fill the game form.',rawText:raw,items:fields.map(field=>({id:field.key,label:humanizeScanKey(field.key),value:field.value,current:currentGameValue(field.key),confidence:field.confidence,payload:field}))})};
  const applyGameScan=(items:ScanReviewItem[])=>{const next={...v};items.forEach(item=>{const field=item.payload as ScannedGameField;if(field.key==='opponent')setOpponent(field.value);else if(field.key==='result'&&(field.value==='W'||field.value==='L'))setResult(field.value);else if(field.key==='importance'&&importances.includes(field.value as any))setImportance(field.value as (typeof importances)[number]);else if(field.key in next)(next as Record<string,string>)[field.key]=field.value});setV(next);setState(recordGameScreenScan(state,items.length));setReview(null);Alert.alert('Game form filled','Review any blank or unusual values, then finish the game normally.')};
  return <KeyboardAvoidingView style={{flex:1}} behavior={Platform.OS==='ios'?'padding':undefined}><ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
    <SectionTitle title="Log 2K Game" side={<Canon value="2K Confirmed"/>}/>
    <Card><Text style={styles.cardTitle}>{state.player.team} game result</Text><Text style={styles.label}>Opponent</Text><View style={styles.chips}>{teams.filter(t=>t!==state.player.team).map(t=><Pressable key={t} onPress={()=>setOpponent(t)} style={[styles.chip,opponent===t&&styles.chipActive]}><Text style={[styles.chipText,opponent===t&&{color:'#fff'}]}>{t}</Text></Pressable>)}</View><Row style={{gap:8}}><Btn label="WIN" variant={result==='W'?'solid':'outline'} onPress={()=>setResult('W')}/><Btn label="LOSS" variant={result==='L'?'solid':'outline'} onPress={()=>setResult('L')}/></Row><Text style={styles.label}>Game importance</Text><View style={styles.chips}>{importances.map(i=><Pressable key={i} onPress={()=>setImportance(i)} style={[styles.chip,importance===i&&styles.chipActive]}><Text style={[styles.chipText,importance===i&&{color:'#fff'}]}>{i}</Text></Pressable>)}</View></Card>
    <Card><Row style={{justifyContent:'space-between',alignItems:'center'}}><View style={{flex:1}}><Text style={styles.cardTitle}>Box score</Text><Text style={styles.mutedSmall}>Tap the camera to fill this from your player row or post-game screen.</Text></View><CameraButton label="Scan game stats" onPress={scanGame}/></Row><View style={styles.formGrid}><Field label="PTS" value={v.pts} onChange={x=>set('pts',x)} keyboard="number-pad"/><Field label="REB" value={v.reb} onChange={x=>set('reb',x)} keyboard="number-pad"/><Field label="AST" value={v.ast} onChange={x=>set('ast',x)} keyboard="number-pad"/><Field label="STL" value={v.stl} onChange={x=>set('stl',x)} keyboard="number-pad"/><Field label="BLK" value={v.blk} onChange={x=>set('blk',x)} keyboard="number-pad"/><Field label="TOV" value={v.tov} onChange={x=>set('tov',x)} keyboard="number-pad"/><Field label="FGM" value={v.fgm} onChange={x=>set('fgm',x)} keyboard="number-pad"/><Field label="FGA" value={v.fga} onChange={x=>set('fga',x)} keyboard="number-pad"/><Field label="3PM" value={v.tpm} onChange={x=>set('tpm',x)} keyboard="number-pad"/><Field label="3PA" value={v.tpa} onChange={x=>set('tpa',x)} keyboard="number-pad"/><Field label="FTM" value={v.ftm} onChange={x=>set('ftm',x)} keyboard="number-pad"/><Field label="FTA" value={v.fta} onChange={x=>set('fta',x)} keyboard="number-pad"/><Field label="MIN" value={v.minutes} onChange={x=>set('minutes',x)} keyboard="number-pad"/><Field label="+/-" value={v.plusMinus} onChange={x=>set('plusMinus',x)} keyboard="numbers-and-punctuation"/></View><Btn label="Finish game & process career" onPress={submit}/></Card>
    {state.games.length>0?<Card><SectionTitle title="Recent games"/>{state.games.slice(0,7).map(g=><View key={g.id} style={styles.listRow}><Pill text={g.result} tone={g.result==='W'?'good':'warn'}/><View style={{flex:1}}><Text style={styles.listTitle}>vs {g.opponent} • {g.pts}/{g.reb}/{g.ast}</Text><Text style={styles.mutedSmall}>{g.importance} • +{g.xp.toLocaleString()} XP</Text></View></View>)}</Card>:null}
  </ScrollView><ScanBusyModal visible={scanner.busy} label={scanner.busyLabel}/><ScanReviewModal review={review} onClose={()=>setReview(null)} onApply={applyGameScan}/></KeyboardAvoidingView>
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
  const [editingProfile,setEditingProfile]=useState(false);
  const [review,setReview]=useState<ScanReviewData|null>(null);const [reviewMode,setReviewMode]=useState<'overview'|'attributes'|'badges'|null>(null);const scanner=use2KScreenScanner();
  const cats=[...new Set(state.attributes.map(a=>a.category))];
  const p=state.player;
  const scanOverview=async()=>{const raw=await scanner.scan('player overview');if(!raw)return;const fields=parsePlayerOverview(raw,teams);if(!fields.length){Alert.alert('No player fields recognized','Include labels such as OVR, POT, AGE, POSITION, HEIGHT or WEIGHT in the photo.');return}const current:Record<string,string>={team:p.team||'Blank',position:p.position,overall:String(p.overall),potential:String(p.potential),age:String(p.age),jersey:String(p.jersey),height:p.height,weight:String(p.weight)};setReviewMode('overview');setReview({title:'Review player scan',subtitle:'Choose which recognized player details should replace the current companion values.',rawText:raw,items:fields.map(field=>({id:field.key,label:humanizeScanKey(field.key),value:String(field.value),current:current[field.key],confidence:field.confidence,payload:field}))})};
  const scanAttributes=async()=>{const raw=await scanner.scan('attributes');if(!raw)return;const found=parseAttributeScreen(raw,state.attributes.map(attribute=>attribute.name));if(!found.length){Alert.alert('No attributes recognized','Fill the photo with the ratings list and keep both each attribute name and its number visible. You can scan one category at a time.');return}setReviewMode('attributes');setReview({title:'Review attribute scan',subtitle:'Only ratings visible and readable in this screenshot are proposed.',rawText:raw,items:found.map(attribute=>({id:attribute.name,label:attribute.name,value:String(attribute.rating),current:String(state.attributes.find(item=>item.name===attribute.name)?.rating??'Blank'),confidence:attribute.confidence,payload:attribute}))})};
  const scanBadges=async()=>{const raw=await scanner.scan('badges');if(!raw)return;const found=parseBadgeScreen(raw,state.badges.map(badge=>badge.name));if(!found.length){Alert.alert('No badge tiers recognized','Show the badge name and its tier text (Bronze, Silver, Gold, Hall of Fame, Legend or Locked) together. Scan another badge page separately if needed.');return}setReviewMode('badges');setReview({title:'Review badge scan',subtitle:'Confirm each badge tier before updating your player.',rawText:raw,items:found.map(badge=>({id:badge.name,label:badge.name,value:badge.level,current:state.badges.find(item=>item.name===badge.name)?.level??'Blank',confidence:badge.confidence,payload:badge}))})};
  const applyPlayerScan=(items:ScanReviewItem[])=>{if(reviewMode==='overview')setState(applyScannedPlayerOverview(state,items.map(item=>item.payload as ScannedPlayerField)));else if(reviewMode==='attributes')setState(applyScannedAttributes(state,items.map(item=>item.payload as ScannedAttribute)));else if(reviewMode==='badges')setState(applyScannedBadges(state,items.map(item=>item.payload as ScannedBadge)));setReview(null);setReviewMode(null)};
  return <>
    <ScrollView contentContainerStyle={styles.scroll}>{back}<SectionTitle title="Player" side={<Pill text={`${p.overall} OVR`}/>}/>
      <Card>
        <Row style={{justifyContent:'space-between',alignItems:'center',gap:8}}><View style={{flex:1}}><Text style={styles.cardTitle}>{p.name}</Text><Text style={styles.mutedSmall}>{p.position} • #{p.jersey} • {p.height} • {p.weight} lbs</Text></View><CameraButton label="Scan player overview" onPress={scanOverview}/><Btn small label="Edit profile" variant="outline" onPress={()=>setEditingProfile(true)}/></Row>
        <View style={styles.infoGrid}><Info label="Age" value={`${p.age}`}/><Info label="Hometown" value={p.hometown}/><Info label="Nationality" value={p.nationality}/><Info label="Dominant hand" value={p.dominantHand}/><Info label="Starting program" value={p.schoolOrClub}/><Info label="HS year" value={p.highSchoolYear}/></View>
      </Card>
      <SectionTitle title="Player Development" side={<Row style={{gap:8,alignItems:'center'}}><Pill text={`${p.xp.toLocaleString()} XP`}/><CameraButton label="Scan attributes" onPress={scanAttributes}/></Row>}/>
      <View style={styles.metrics}><Metric label="OVR" value={p.overall}/><Metric label="POT" value={p.potential}/><Metric label="MORALE" value={p.morale}/><Metric label="FATIGUE" value={p.fatigue}/></View>
      {cats.map(cat=><Card key={cat}><Text style={styles.cardTitle}>{cat}</Text>{state.attributes.filter(a=>a.category===cat).map(a=>{const cost=attributeUpgradeCost(a.rating);return <View key={a.name} style={styles.attrRow}><View style={{flex:1}}><Text style={styles.listTitle}>{a.name}</Text><Text style={styles.mutedSmall}>Upgrade: {cost.toLocaleString()} XP</Text><Progress value={a.rating}/></View><Text style={styles.attrValue}>{a.rating}</Text><Btn small label="+1" variant="outline" onPress={()=>{const r=upgradeAttribute(state,a.name);setState(r.state);if(r.message.startsWith('Need'))Alert.alert('Not enough XP',r.message)}}/></View>})}</Card>)}
      <Card><Row style={{justifyContent:'space-between',alignItems:'center'}}><View><Text style={styles.cardTitle}>Badges</Text><Text style={styles.mutedSmall}>Scan each visible badge page as needed.</Text></View><CameraButton label="Scan badges" onPress={scanBadges}/></Row>{state.badges.map(b=><View key={b.name} style={styles.listRow}><View style={{flex:1}}><Text style={styles.listTitle}>{b.name}</Text><Text style={styles.mutedSmall}>{b.category}</Text></View><Pill text={b.level} tone={b.level==='Locked'?'muted':'accent'}/></View>)}</Card>
    </ScrollView>
    <ProfileEditorModal state={state} visible={editingProfile} onClose={()=>setEditingProfile(false)} onSave={(profile)=>{setState(updatePlayerProfile(state,profile));setEditingProfile(false)}}/>
    <ScanBusyModal visible={scanner.busy} label={scanner.busyLabel}/><ScanReviewModal review={review} onClose={()=>{setReview(null);setReviewMode(null)}} onApply={applyPlayerScan}/>
  </>;
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
  const [review,setReview]=useState<ScanReviewData|null>(null);const scanner=use2KScreenScanner();
  const scanTransactions=async()=>{const raw=await scanner.scan('transaction log');if(!raw)return;const found=parseTransactionLog(raw,teams);if(!found.length){Alert.alert('No transactions recognized','Keep complete transaction sentences visible. The scanner recognizes trades, signings, waivers, releases and waiver claims. You can still use the form for unusual transaction wording.');return}setReview({title:'Review transaction log',subtitle:'Each checked move will be added as 2K Confirmed. Existing matching moves are skipped.',rawText:raw,items:found.map((tx,index)=>({id:`${index}-${tx.player}-${tx.toTeam}`,label:`${tx.type}: ${tx.player}`,value:`${tx.fromTeam||'Unknown'} → ${tx.toTeam||'Unknown'}`,confidence:tx.confidence,payload:tx}))})};
  const applyTransactionScan=(items:ScanReviewItem[])=>{setState(applyScannedTransactions(state,items.map(item=>item.payload as ScannedTransaction)));setReview(null)};
  return <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">{back}<SectionTitle title="League Universe" side={<Pill text={`${state.transactions.length} confirmed moves`}/>}/>
    <Card><Row style={{justifyContent:'space-between',alignItems:'center'}}><View style={{flex:1}}><Text style={styles.cardTitle}>Confirm MyNBA transactions</Text><Text style={styles.mutedSmall}>Scan a full transaction-log page or enter one move below.</Text></View><CameraButton label="Scan league transaction log" onPress={scanTransactions}/></Row><Text style={styles.bodyText}>Reviewed scans and manual entries are recorded as 2K Confirmed canon.</Text><Field label="Player" value={player} onChange={setPlayer}/><Field label="Transaction type" value={type} onChange={setType}/><Row style={{gap:8}}><Field label="From" value={from} onChange={setFrom}/><Field label="To" value={to} onChange={setTo}/></Row><Btn label="Confirm roster move" onPress={()=>setState(manualTransaction(state,type,player,from,to))}/></Card>
    <Card><SectionTitle title="Around the league"/>{state.news.slice(0,12).map(n=><View key={n.id} style={styles.newsRow}><View style={{flex:1}}><Text style={styles.listTitle}>{n.headline}</Text><Text style={styles.bodyText}>{n.body}</Text><Text style={styles.mutedSmall}>{n.outlet} • {n.date}</Text></View><Canon value={n.canon}/></View>)}</Card>
    <Card><SectionTitle title="World players"/>{state.worldPlayers.map(w=><View key={w.id} style={styles.listRow}><View style={styles.avatarSmall}><Text style={styles.avatarSmallText}>{w.name.split(' ').map(x=>x[0]).join('').slice(0,2)}</Text></View><View style={{flex:1}}><Text style={styles.listTitle}>{w.name} • {w.position}</Text><Text style={styles.mutedSmall}>{w.team||'Prospect'} • {w.overall} OVR • {w.personality}</Text></View><Pill text={w.reputation} tone="muted"/></View>)}</Card>
    {state.transactions.length>0?<Card><SectionTitle title="Transaction history"/>{state.transactions.slice(0,10).map(tx=><View key={tx.id} style={styles.listRow}><View style={{flex:1}}><Text style={styles.listTitle}>{tx.player}: {tx.fromTeam} → {tx.toTeam}</Text><Text style={styles.mutedSmall}>{tx.type} • {tx.date}</Text></View><Canon value={tx.canon}/></View>)}</Card>:null}
    <ScanBusyModal visible={scanner.busy} label={scanner.busyLabel}/><ScanReviewModal review={review} onClose={()=>setReview(null)} onApply={applyTransactionScan}/>
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
  const doImport=()=>{try{const parsed=JSON.parse(importText);if(!parsed.player||!parsed.attributes)throw new Error();setState(migrateCareerState(parsed));setImportText('');Alert.alert('Imported','Career save loaded.')}catch{Alert.alert('Invalid save','The pasted JSON is not a valid Career Companion save.')}};
  return <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">{back}<SectionTitle title="Settings"/>
    <Card><Text style={styles.cardTitle}>Immersion</Text><Text style={styles.label}>Mode</Text><View style={styles.chips}>{['Basketball Focused','Immersive','Full Life','Chaos'].map(x=><Pressable key={x} onPress={()=>setState(changeSetting(state,'immersionMode',x))} style={[styles.chip,state.settings.immersionMode===x&&styles.chipActive]}><Text style={[styles.chipText,state.settings.immersionMode===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View><Text style={styles.label}>Pre-NBA simulation detail</Text><View style={styles.chips}>{['Quick','Normal','Detailed'].map(x=><Pressable key={x} onPress={()=>setState(changeSetting(state,'simDetail',x))} style={[styles.chip,state.settings.simDetail===x&&styles.chipActive]}><Text style={[styles.chipText,state.settings.simDetail===x&&{color:'#fff'}]}>{x}</Text></Pressable>)}</View><Row style={{justifyContent:'space-between',alignItems:'center'}}><View style={{flex:1}}><Text style={styles.listTitle}>Optional romantic-life events</Text><Text style={styles.mutedSmall}>Off by default. Does not affect core career progression.</Text></View><Switch value={state.settings.romanceEnabled} onValueChange={v=>setState(changeSetting(state,'romanceEnabled',v))} trackColor={{true:ACCENT,false:'#343b46'}}/></Row></Card>
    <Card><Text style={styles.cardTitle}>Backup / transfer</Text><Text style={styles.bodyText}>The Android and iOS versions use the same JSON save format, so you can move a career between phones manually.</Text><Btn label="Share / export save" onPress={()=>Share.share({title:'NBA 2K26 Career Companion Save',message:JSON.stringify(state)})}/><Text style={styles.label}>Import save JSON</Text><TextInput multiline value={importText} onChangeText={setImportText} placeholder="Paste exported save JSON here" placeholderTextColor="#626b78" style={[styles.input,{minHeight:110,textAlignVertical:'top'}]}/><Btn label="Import pasted save" variant="outline" disabled={!importText.trim()} onPress={doImport}/></Card>
    <Card><SectionTitle title="2K screen scanner" side={<Pill text="ON-DEVICE" tone="good"/>}/><Text style={styles.bodyText}>Camera buttons can read game stats, player overview fields, attributes, badge tiers and league transaction logs. Recognition stays on the device and every proposed change must be reviewed before it is saved.</Text><Text style={styles.mutedSmall}>Best results: use a direct console screenshot or hold the phone square to the TV, move close enough for sharp text, avoid glare, and include each label beside its value.</Text>{state.screenScans.length?<View><Text style={styles.label}>Recent confirmed scans</Text>{state.screenScans.slice(0,5).map(scan=><View key={scan.id} style={styles.listRow}><Text style={{fontSize:18}}>📷</Text><View style={{flex:1}}><Text style={styles.listTitle}>{scan.target} • {scan.recognized} applied</Text><Text style={styles.mutedSmall}>{scan.date} • {scan.summary}</Text></View></View>)}</View>:<Text style={styles.muted}>No confirmed screen scans yet.</Text>}</Card>
    <Card><Text style={styles.cardTitle}>Canon rules</Text><Text style={styles.bodyText}>2K Confirmed = something you manually enter or explicitly approve from a photographed 2K screen. Companion Canon = generated story around those events. Rumor = intentionally unverified in-universe information. Screen recognition is not a direct connection to game memory.</Text></Card>
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
  splash:{flex:1,alignItems:'center',justifyContent:'center',gap:10,padding:24},splashMark:{color:'#fff',fontSize:28,fontWeight:'900',backgroundColor:ACCENT,paddingHorizontal:16,paddingVertical:10,borderRadius:16},splashTitle:{color:TEXT,fontSize:24,fontWeight:'900'},
  onboardingScroll:{padding:18,paddingBottom:40,gap:14},onboardingHero:{gap:10,paddingVertical:12},onboardingLogo:{width:56,height:56,borderRadius:18,backgroundColor:ACCENT,alignItems:'center',justifyContent:'center'},onboardingLogoText:{color:'#fff',fontWeight:'900',fontSize:21},onboardingTitle:{color:TEXT,fontSize:30,fontWeight:'900',marginTop:4},onboardingSubtitle:{color:'#c9d0da',fontSize:15,lineHeight:22},
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
  modalScrim:{flex:1,backgroundColor:'rgba(0,0,0,.72)',justifyContent:'flex-end'},modalSheet:{backgroundColor:'#12161d',borderTopLeftRadius:26,borderTopRightRadius:26,borderWidth:1,borderColor:BORDER,padding:18,paddingBottom:Platform.OS==='ios'?34:22,gap:12,maxHeight:'82%'},modalTitle:{color:TEXT,fontSize:24,fontWeight:'900'},modalChoice:{backgroundColor:PANEL2,borderRadius:15,borderWidth:1,borderColor:BORDER,padding:14,gap:4},close:{color:MUTED,fontSize:30,lineHeight:32},
  cameraBtn:{width:42,height:42,borderRadius:13,borderWidth:1,borderColor:'#5d403d',backgroundColor:'#261b1a',alignItems:'center',justifyContent:'center'},cameraIcon:{fontSize:19},
  busyScrim:{flex:1,backgroundColor:'rgba(0,0,0,.76)',alignItems:'center',justifyContent:'center',padding:24},busyCard:{width:'100%',maxWidth:330,backgroundColor:PANEL,borderRadius:20,borderWidth:1,borderColor:BORDER,padding:24,alignItems:'center',gap:12},
  scanPrivacy:{backgroundColor:'#13231d',borderWidth:1,borderColor:'#245540',borderRadius:12,paddingHorizontal:11,paddingVertical:8},scanPrivacyText:{color:GOOD,fontSize:11,fontWeight:'800'},
  scanReviewRow:{flexDirection:'row',alignItems:'center',gap:10,backgroundColor:PANEL2,borderWidth:1,borderColor:BORDER,borderRadius:14,padding:12},scanReviewRowSelected:{borderColor:'#71443e',backgroundColor:'#221a1a'},checkBox:{width:24,height:24,borderRadius:7,borderWidth:1,borderColor:'#59616e',alignItems:'center',justifyContent:'center'},checkBoxSelected:{backgroundColor:ACCENT,borderColor:ACCENT},checkText:{color:'#fff',fontSize:14,fontWeight:'900'},scanValue:{color:TEXT,fontSize:13,fontWeight:'800',marginTop:3},
  rawToggle:{color:ACCENT,fontSize:12,fontWeight:'800'},rawOcr:{maxHeight:110,backgroundColor:'#090b0e',borderRadius:12,borderWidth:1,borderColor:BORDER,padding:10},rawOcrText:{color:'#bac2ce',fontSize:11,lineHeight:16}
});
