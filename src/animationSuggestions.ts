import type { CareerState } from './model';

export type AnimationSuggestion={category:string;name:string;requirement:string;reason:string;qualified:boolean;alternative?:string};
type Pick={name:string;min:number;requirement:string};

function rating(state:CareerState,name:string):number{return state.attributes.find(item=>item.name===name)?.rating??0}
export function heightToInches(value:string):number{const match=/([5-7])\s*['′-]\s*([0-9]{1,2})/.exec(value);return match?Number(match[1])*12+Math.min(11,Number(match[2])):75}
function choose(value:number,picks:Pick[],fallback:Pick):Pick{return picks.find(item=>value>=item.min)??fallback}

export function getAnimationSuggestions(state:CareerState):AnimationSuggestion[]{
  const height=heightToInches(state.player.height);const shooting=Math.max(rating(state,'Three-Point Shot'),rating(state,'Mid-Range Shot'));
  const handle=rating(state,'Ball Handle'),speedBall=rating(state,'Speed With Ball'),layup=rating(state,'Driving Layup');
  const dunk=rating(state,'Driving Dunk'),standing=rating(state,'Standing Dunk'),vertical=rating(state,'Vertical'),passing=rating(state,'Pass Accuracy');
  const perimeter=rating(state,'Perimeter Defense'),rebound=rating(state,'Defensive Rebound');

  const jump=height<=64
    ?choose(shooting,[{name:'Stephen Curry',min:93,requirement:'93 Mid-Range or Three-Point Shot'},{name:'Kyrie Irving',min:89,requirement:'89 Mid-Range or Three-Point Shot'},{name:'Allen Iverson',min:83,requirement:'83 Mid-Range or Three-Point Shot'},{name:'Jaden Ivey',min:77,requirement:'77 Mid-Range or Three-Point Shot'},{name:'Bronny James Jr.',min:63,requirement:'63 Mid-Range or Three-Point Shot'}],{name:'Default Small',min:0,requirement:'No rating threshold'})
    :height<=69
      ?choose(shooting,[{name:'Kevin Durant',min:89,requirement:'89 Mid-Range or Three-Point Shot'},{name:'Cade Cunningham',min:84,requirement:'84 Mid-Range or Three-Point Shot'},{name:'DeMar DeRozan',min:83,requirement:'83 Mid-Range or Three-Point Shot'},{name:'Max Christie',min:78,requirement:'78 Mid-Range or Three-Point Shot'},{name:'Bilal Coulibaly',min:64,requirement:'64 Mid-Range or Three-Point Shot'}],{name:'Default Swing',min:0,requirement:'No rating threshold'})
      :choose(shooting,[{name:'Kevin Durant',min:89,requirement:'89 Mid-Range or Three-Point Shot'},{name:'LaMarcus Aldridge',min:83,requirement:'83 Mid-Range or Three-Point Shot'},{name:'Zach Collins',min:78,requirement:'78 Mid-Range or Three-Point Shot'},{name:'Zach Edey',min:71,requirement:'71 Mid-Range or Three-Point Shot'},{name:'Nicolas Claxton',min:60,requirement:'60 Mid-Range or Three-Point Shot'},{name:'Tim Duncan',min:45,requirement:'45 Mid-Range or Three-Point Shot'}],{name:'Default Big',min:0,requirement:'No rating threshold'});

  const dribble=height<=64
    ?choose(speedBall,[{name:'Stephen Curry',min:91,requirement:'91 Speed With Ball, 5\'9"–6\'4"'},{name:'Jalen Brunson',min:87,requirement:'87 Speed With Ball, 5\'9"–6\'4"'},{name:'Luka Doncic',min:80,requirement:'80 Speed With Ball, up to 6\'9"'},{name:'Anthony Edwards',min:76,requirement:'76 Speed With Ball, up to 6\'9"'},{name:'Pro',min:70,requirement:'70 Speed With Ball'}],{name:speedBall>=40?'Normal':'Basic',min:0,requirement:speedBall>=40?'40 Speed With Ball':'25 Speed With Ball'})
    :height<=69
      ?choose(speedBall,[{name:'Luka Doncic',min:80,requirement:'80 Speed With Ball, up to 6\'9"'},{name:'Devin Booker',min:80,requirement:'80 Speed With Ball, up to 6\'9"'},{name:'Anthony Edwards',min:76,requirement:'76 Speed With Ball, up to 6\'9"'},{name:'Cade Cunningham',min:75,requirement:'75 Speed With Ball, up to 6\'9"'},{name:'Pro',min:70,requirement:'70 Speed With Ball'}],{name:speedBall>=40?'Normal':'Basic',min:0,requirement:speedBall>=40?'40 Speed With Ball':'25 Speed With Ball'})
      :choose(speedBall,[{name:'Pro',min:70,requirement:'70 Speed With Ball'},{name:'Normal',min:40,requirement:'40 Speed With Ball'}],{name:'Basic',min:0,requirement:'25 Speed With Ball'});

  const layupPick=height<=64
    ?choose(layup,[{name:'Ja Morant',min:87,requirement:'87 Driving Layup, 5\'9"–6\'4"'},{name:'Kyrie Irving',min:85,requirement:'85 Driving Layup, 5\'9"–6\'4"'},{name:"De'Aaron Fox",min:84,requirement:'84 Driving Layup, 5\'9"–6\'4"'},{name:'Anthony Edwards',min:84,requirement:'84 Driving Layup, 5\'9"–6\'4"'}],{name:'Default Small',min:0,requirement:'No rating threshold'})
    :height<=69
      ?choose(layup,[{name:'LeBron James',min:87,requirement:'87 Driving Layup, 6\'5"–6\'9"'},{name:'Jayson Tatum',min:85,requirement:'85 Driving Layup, 6\'5"–6\'9"'},{name:'Franz Wagner',min:84,requirement:'84 Driving Layup, 6\'5"–7\'4"'},{name:'Amen Thompson',min:82,requirement:'82 Driving Layup, 6\'5"–6\'9"'},{name:'Paul George',min:75,requirement:'75 Driving Layup, up to 6\'9"'}],{name:'Default Swing',min:0,requirement:'No rating threshold'})
      :choose(layup,[{name:'Kevin Durant',min:80,requirement:'80 Driving Layup, 6\'5"–7\'4"'},{name:'Nikola Jokic',min:79,requirement:'79 Driving Layup, 6\'10"–7\'4"'},{name:'Domantas Sabonis',min:78,requirement:'78 Driving Layup, 6\'10"–7\'4"'},{name:'Joel Embiid',min:73,requirement:'73 Driving Layup, 6\'10"–7\'4"'},{name:'Victor Wembanyama',min:70,requirement:'70 Driving Layup, 6\'10"–7\'4"'}],{name:'Default Big',min:0,requirement:'No rating threshold'});

  let dunkPick:Pick={name:height<=69?'CJ McCollum Signature Dunks':"Shaquille O'Neal Signature Dunks",min:height<=69?40:55,requirement:height<=69?'40 Driving Dunk, 25 Vertical, up to 6\'9"':'55 Driving Dunk, 80 Standing Dunk, 50 Vertical'};
  if(height<=64){
    if(dunk>=89&&vertical>=68)dunkPick={name:'Ja Morant Signature Dunks',min:89,requirement:'89 Driving Dunk, 68 Vertical'};
    else if(dunk>=85&&vertical>=70)dunkPick={name:"De'Aaron Fox Signature Dunks",min:85,requirement:'85 Driving Dunk, 70 Vertical'};
    else if(dunk>=80&&vertical>=70)dunkPick={name:'Malik Monk Signature Dunks',min:80,requirement:'80 Driving Dunk, 70 Vertical'};
  }
  else if(height<=69){
    if(dunk>=93&&vertical>=80)dunkPick={name:'Russell Westbrook Signature Dunks',min:93,requirement:'93 Driving Dunk, 80 Vertical'};
    else if(dunk>=88&&vertical>=73)dunkPick={name:'Zach LaVine Signature Dunks',min:88,requirement:'88 Driving Dunk, 73 Vertical'};
    else if(dunk>=84&&standing>=40&&vertical>=64)dunkPick={name:'LeBron James Signature Dunks',min:84,requirement:'84 Driving Dunk, 40 Standing Dunk, 64 Vertical'};
    else if(dunk>=83&&standing>=60&&vertical>=60)dunkPick={name:'Amen Thompson Signature Dunks',min:83,requirement:'83 Driving Dunk, 60 Standing Dunk, 60 Vertical'};
    else if(dunk>=80&&vertical>=60)dunkPick={name:'Paul George Signature Dunks',min:80,requirement:'80 Driving Dunk, 60 Vertical'};
  }
  else if(dunk>=75&&standing>=90&&vertical>=69)dunkPick={name:'Victor Wembanyama Signature Dunks',min:75,requirement:'75 Driving Dunk, 90 Standing Dunk, 69 Vertical'};
  else if(dunk>=75&&standing>=70&&vertical>=45)dunkPick={name:'Domantas Sabonis Signature Dunks',min:75,requirement:'75 Driving Dunk, 70 Standing Dunk, 45 Vertical'};
  else if(dunk>=65&&standing>=75&&vertical>=50)dunkPick={name:'Dwight Howard Signature Dunks',min:65,requirement:'65 Driving Dunk, 75 Standing Dunk, 50 Vertical'};

  const pass=choose(passing,[{name:'Darius Garland',min:92,requirement:'92 Pass Accuracy'},{name:'Tyrese Haliburton',min:91,requirement:'91 Pass Accuracy'},{name:'Chris Paul',min:90,requirement:'90 Pass Accuracy'},{name:'Luka Doncic',min:88,requirement:'88 Pass Accuracy'},{name:'LeBron James',min:85,requirement:'85 Pass Accuracy'},{name:'Shai Gilgeous-Alexander',min:83,requirement:'83 Pass Accuracy'},{name:'James Harden',min:82,requirement:'82 Pass Accuracy'},{name:'Nikola Jokic',min:79,requirement:'79 Pass Accuracy'},{name:'Ja Morant',min:75,requirement:'75 Pass Accuracy'}],{name:'Normal',min:0,requirement:'No elite pass-style threshold'});
  const motion=height<=64?(perimeter>=75?'Alex Caruso':'Tyrese Maxey'):height<=69?(perimeter>=75?'Kawhi Leonard':rebound>=70?'Dennis Rodman':'LeBron James'):(rebound>=75?'Dennis Rodman':perimeter>=65?'Jaren Jackson Jr.':'Chet Holmgren');
  const dunkQualified=dunk>=dunkPick.min&&(
    dunkPick.name.includes("Shaquille")?standing>=80&&vertical>=50:
    dunkPick.name.includes('McCollum')?vertical>=25:
    true
  );

  return [
    {category:'Jump Shot Base',name:jump.name,requirement:jump.requirement,qualified:shooting>=jump.min,reason:`Matched to ${state.player.height} and your ${shooting} best shooting rating.`},
    {category:'Dribble Style',name:dribble.name,requirement:dribble.requirement,qualified:speedBall>=dribble.min,reason:`Fits a ${state.player.position} with ${handle} Ball Handle and ${speedBall} Speed With Ball.`,alternative:height<=69&&dribble.name!=='Pro'?'Pro':''},
    {category:'Layup Style',name:layupPick.name,requirement:layupPick.requirement,qualified:layup>=layupPick.min,reason:`Uses your ${layup} Driving Layup and height band.`},
    {category:'Signature Dunks',name:dunkPick.name,requirement:dunkPick.requirement,qualified:dunkQualified,reason:`Selected from ${dunk} Driving Dunk, ${standing} Standing Dunk and ${vertical} Vertical.`},
    {category:'Pass Style',name:pass.name,requirement:pass.requirement,qualified:passing>=pass.min,reason:`Built around your ${passing} Pass Accuracy.`},
    {category:'Motion Style',name:motion,requirement:'No attribute guarantee — confirm availability in MyPLAYER animations',qualified:true,reason:`Optional movement flavor for your height, position and defensive profile.`}
  ];
}
