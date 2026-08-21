import { CareerState, Attribute, Badge } from './model';

const attrs: [string,string,number][] = [
  ['Close Shot','Finishing',66],['Driving Layup','Finishing',74],['Driving Dunk','Finishing',70],['Standing Dunk','Finishing',35],['Post Control','Finishing',42],
  ['Mid-Range Shot','Shooting',71],['Three-Point Shot','Shooting',73],['Free Throw','Shooting',76],
  ['Pass Accuracy','Playmaking',76],['Ball Handle','Playmaking',78],['Speed With Ball','Playmaking',75],
  ['Interior Defense','Defense/Rebounding',48],['Perimeter Defense','Defense/Rebounding',70],['Steal','Defense/Rebounding',66],['Block','Defense/Rebounding',42],['Offensive Rebound','Defense/Rebounding',38],['Defensive Rebound','Defense/Rebounding',58],
  ['Speed','Physicals',81],['Agility','Physicals',79],['Strength','Physicals',62],['Vertical','Physicals',72],['Stamina','Physicals',86]
];

const badgeNames: [string,string][] = [
  ['Physical Finisher','Finishing'],['Float Game','Finishing'],['Posterizer','Finishing'],['Aerial Wizard','Finishing'],
  ['Set Shot Specialist','Shooting'],['Limitless Range','Shooting'],['Deadeye','Shooting'],['Shifty Shooter','Shooting'],
  ['Handles For Days','Playmaking'],['Dimer','Playmaking'],['Unpluckable','Playmaking'],['Lightning Launch','Playmaking'],
  ['On-Ball Menace','Defense'],['Interceptor','Defense'],['Challenger','Defense'],['High-Flying Denier','Defense']
];

const attributes: Attribute[] = attrs.map(([name,category,rating]) => ({name,category,rating,cap:99}));
const badges: Badge[] = badgeNames.map(([name,category], i) => ({name,category,level: i===4 || i===8 ? 'Bronze' : 'Locked',progress:0}));

export function createDefaultState(): CareerState {
  const today = new Date().toISOString().slice(0,10);
  return {
    version: 2,
    player: {
      name:'Marcus Carter',position:'PG',age:17,height:"6'3\"",weight:175,hometown:'Halifax, NS',nationality:'Canada',dominantHand:'Right',highSchoolYear:'Senior',stage:'High School',route:'Undecided',schoolOrClub:'Lakeshore Prep',team:'',jersey:3,
      overall:64,potential:91,seasonYear:2026,currentDate:today,phase:'Preseason',xp:0,money:0,careerEarnings:0,followers:12800,marketability:45,morale:78,fatigue:12,legacy:0,
      agentName:'Unrepresented',agentTrust:50,draftProjection:'Unranked',draftDeclared:false,role:'Prospect',reputation:['Unknown'],traits:['Competitive']
    },
    settings:{immersionMode:'Immersive',simDetail:'Normal',romanceEnabled:false,autosave:true,onboardingComplete:false},
    attributes,badges,games:[],
    relationships:[
      {id:'r1',name:'Family Member',role:'Family',trust:94,respect:88,friendship:92,loyalty:98,rivalry:0,resentment:0,influence:82,closeness:94,status:'Very Close',memories:['Supported you before your basketball career took off.']},
      {id:'r2',name:'Coach Reynolds',role:'Coach',trust:68,respect:74,friendship:35,loyalty:52,rivalry:0,resentment:3,influence:88,closeness:48,status:'Positive',memories:['Believed in your upside early.']}
    ],
    social:[
      {id:'s1',date:today,author:'Hoops Central',handle:'@HoopsCentral',body:'A new season is here. Which under-the-radar guard is about to blow up?',likes:3200,reposts:410,replies:214,kind:'Media',canon:'Companion Canon'},
      {id:'s2',date:today,author:'Local Hoops',handle:'@LocalHoops',body:'Lakeshore Prep guard Marcus Carter has drawn some early regional attention.',likes:684,reposts:82,replies:31,kind:'Local',canon:'Companion Canon'}
    ],
    news:[{id:'n1',date:today,outlet:'Courtside Report',headline:'Prospect season begins',body:'Scouts are starting to build their first real board of the year.',importance:'Background',canon:'Companion Canon'}],
    events:[],sponsors:[],storylines:[],history:[{id:'h1',date:today,title:'Career begins',body:'Your basketball story starts before the NBA.',category:'Career',importance:'Career',canon:'User Confirmed'}],notifications:[],finances:[],transactions:[],
    worldPlayers:[
      {id:'w1',name:'Jalen Cross',team:'',position:'PG',age:18,overall:69,potential:92,personality:'Volatile competitor',reputation:'National prospect',history:['Frequently compared with you by local scouts.']},
      {id:'w2',name:'Andre Lewis',team:'',position:'SG',age:18,overall:70,potential:89,personality:'Media favorite',reputation:'Four-star scorer',history:[]}
    ],
    prospects:[{id:'p1',name:'Elijah Knox',position:'SF',age:17,overall:71,potential:95,projection:'5-star',personality:'Quiet competitor',background:'Explosive two-way wing from Detroit.',status:'High School'}],
    milestones:[
      {id:'m1',name:'First NBA Game',achieved:false},{id:'m2',name:'First 30-Point NBA Game',achieved:false},{id:'m3',name:'First 50-Point Game',achieved:false},{id:'m4',name:'First Triple-Double',achieved:false},{id:'m5',name:'First Playoff Win',achieved:false},{id:'m6',name:'NBA Champion',achieved:false}
    ]
  };
}
