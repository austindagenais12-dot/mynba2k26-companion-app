import type { MyNBAEra } from './model';

export type EraRosterPlayer={id:string;era:MyNBAEra;team:string;name:string;position:string;age?:number};
export const MYNBA_ERAS:{id:MyNBAEra;label:string;season:string;startYear:number}[]=[
  {id:'Magic vs Bird',label:'Magic vs. Bird Era',season:'1983–84',startYear:1983},
  {id:'Jordan',label:'Jordan Era',season:'1991–92',startYear:1991},
  {id:'Kobe',label:'Kobe Era',season:'2002–03',startYear:2002},
  {id:'LeBron',label:'LeBron Era',season:'2010–11',startYear:2010},
  {id:'Steph',label:'Steph Era',season:'2016–17',startYear:2016},
  {id:'Modern',label:'Modern Era',season:'2025–26',startYear:2025}
];

export const ERA_TEAM_NAMES:Record<string,string>={ATL:'Atlanta Hawks',BOS:'Boston Celtics',BKN:'Brooklyn Nets',BRK:'Brooklyn Nets',CHA:'Charlotte Hornets',CHH:'Charlotte Hornets',CHO:'Charlotte Hornets',CHI:'Chicago Bulls',CLE:'Cleveland Cavaliers',DAL:'Dallas Mavericks',DEN:'Denver Nuggets',DET:'Detroit Pistons',GSW:'Golden State Warriors',HOU:'Houston Rockets',IND:'Indiana Pacers',KCK:'Kansas City Kings',LAC:'Los Angeles Clippers',LAL:'Los Angeles Lakers',MEM:'Memphis Grizzlies',MIA:'Miami Heat',MIL:'Milwaukee Bucks',MIN:'Minnesota Timberwolves',NJN:'New Jersey Nets',NOH:'New Orleans Hornets',NOP:'New Orleans Pelicans',NYK:'New York Knicks',OKC:'Oklahoma City Thunder',ORL:'Orlando Magic',PHI:'Philadelphia 76ers',PHO:'Phoenix Suns',PHX:'Phoenix Suns',POR:'Portland Trail Blazers',SAC:'Sacramento Kings',SAS:'San Antonio Spurs',SDC:'San Diego Clippers',SEA:'Seattle SuperSonics',TOR:'Toronto Raptors',UTA:'Utah Jazz',VAN:'Vancouver Grizzlies',WAS:'Washington Wizards',WSB:'Washington Bullets'};

// Compact offline roster index for every NBA 2K26 MyNBA Era start season.
const RAW_ROSTERS=`
Jordan|ATL|Alexander Volkov|C|27
Jordan|ATL|Blair Rasmussen|C|29
Jordan|ATL|Dominique Wilkins|SF|32
Jordan|ATL|Duane Ferrell|SF|26
Jordan|ATL|Gary Leonard|C|24
Jordan|ATL|Jeff Sanders|SF|26
Jordan|ATL|Jon Koncak|C|28
Jordan|ATL|Kevin Willis|PF|29
Jordan|ATL|Maurice Cheeks|PG|35
Jordan|ATL|Paul Graham|SG|24
Jordan|ATL|Rodney Monroe|SG|23
Jordan|ATL|Rumeal Robinson|PG|25
Jordan|ATL|Stacey Augmon|SG|23
Jordan|ATL|Travis Mays|PG|23
Jordan|BOS|Brian Shaw|PG|25
Jordan|BOS|Dee Brown|PG|23
Jordan|BOS|Ed Pinckney|PF|28
Jordan|BOS|Joe Kleine|C|30
Jordan|BOS|John Bagley|PG|31
Jordan|BOS|Kenny Battle|SG|27
Jordan|BOS|Kevin Gamble|SF|26
Jordan|BOS|Kevin McHale|PF|34
Jordan|BOS|Kevin Pritchard|PG|24
Jordan|BOS|Larry Bird|SF|35
Jordan|BOS|Larry Robinson|SG|24
Jordan|BOS|Reggie Lewis|SG|26
Jordan|BOS|Rick Fox|SF|22
Jordan|BOS|Rickey Green|PG|37
Jordan|BOS|Robert Parish|C|38
Jordan|BOS|Stojko Vrankovic|C|28
Jordan|CHH|Anthony Frederick|SF|27
Jordan|CHH|Cedric Hunter|PG|27
Jordan|CHH|Dell Curry|SG|27
Jordan|CHH|Eric Leckner|C|25
Jordan|CHH|Greg Grant|PG|25
Jordan|CHH|J.R. Reid|C|23
Jordan|CHH|Johnny Newman|SF|28
Jordan|CHH|Kendall Gill|SG|23
Jordan|CHH|Kenny Gattison|PF|27
Jordan|CHH|Kevin Lynch|SG|23
Jordan|CHH|Larry Johnson|PF|22
Jordan|CHH|Mike Gminski|C|32
Jordan|CHH|Muggsy Bogues|PG|27
Jordan|CHH|Rex Chapman|PG|24
Jordan|CHH|Ron Grandison|PF|27
Jordan|CHI|B.J. Armstrong|PG|24
Jordan|CHI|Bill Cartwright|C|34
Jordan|CHI|Chuck Nevitt|C|32
Jordan|CHI|Cliff Levingston|PF|31
Jordan|CHI|Craig Hodges|SG|31
Jordan|CHI|Dennis Hopson|SG|26
Jordan|CHI|Horace Grant|PF|26
Jordan|CHI|John Paxson|PG|31
Jordan|CHI|Mark Randall|PF|24
Jordan|CHI|Michael Jordan|SG|28
Jordan|CHI|Rory Sparrow|PG|33
Jordan|CHI|Scott Williams|PF|23
Jordan|CHI|Scottie Pippen|SF|26
Jordan|CHI|Stacey King|PF|25
Jordan|CHI|Will Perdue|C|26
Jordan|CLE|Bobby Phills|SG|22
Jordan|CLE|Brad Daugherty|C|26
Jordan|CLE|Chucky Brown|SF|23
Jordan|CLE|Craig Ehlo|SG|30
Jordan|CLE|Danny Ferry|PF|25
Jordan|CLE|Henry James|SF|26
Jordan|CLE|Hot Rod|C|29
Jordan|CLE|Jimmy Oliver|SG|22
Jordan|CLE|John Battle|SG|29
Jordan|CLE|John Morton|SG|24
Jordan|CLE|Larry Nance|PF|32
Jordan|CLE|Mark Price|PG|27
Jordan|CLE|Steve Kerr|PG|26
Jordan|CLE|Terrell Brandon|PG|21
Jordan|CLE|Winston Bennett|SF|26
Jordan|DAL|Brad Davis|PG|36
Jordan|DAL|Brian Howard|SF|24
Jordan|DAL|Derek Harper|PG|30
Jordan|DAL|Donald Hodge|PF|22
Jordan|DAL|Doug Smith|PF|22
Jordan|DAL|Fat Lever|SG|31
Jordan|DAL|Herb Williams|C|33
Jordan|DAL|James Donaldson|C|34
Jordan|DAL|Joao Vianna|SF|25
Jordan|DAL|Mike Iuzzolino|PG|24
Jordan|DAL|Randy White|PF|24
Jordan|DAL|Rodney McCray|SF|30
Jordan|DAL|Rolando Blackman|SG|32
Jordan|DAL|Terry Davis|PF|24
Jordan|DAL|Tracy Moore|SF|26
Jordan|DEN|Anthony Cook|PF|24
Jordan|DEN|Dikembe Mutombo|C|25
Jordan|DEN|Greg Anderson|PF|27
Jordan|DEN|Jerome Lane|PF|25
Jordan|DEN|Joe Wolf|C|27
Jordan|DEN|Kevin Brooks|SF|22
Jordan|DEN|Mahmoud Abdul-Rauf|PG|22
Jordan|DEN|Marcus Liberty|SF|23
Jordan|DEN|Mark Macon|SG|22
Jordan|DEN|Reggie Williams|SF|27
Jordan|DEN|Scott Hastings|C|31
Jordan|DEN|Todd Lichti|SG|25
Jordan|DEN|Walter Davis|SF|37
Jordan|DEN|Winston Garland|PG|27
Jordan|DET|Bill Laimbeer|C|34
Jordan|DET|Bob McCann|SF|27
Jordan|DET|Brad Sellers|PF|29
Jordan|DET|Charles Thomas|SG|22
Jordan|DET|Darrell Walker|SG|30
Jordan|DET|Dennis Rodman|PF|30
Jordan|DET|Isiah Thomas|PG|30
Jordan|DET|Joe Dumars|SG|28
Jordan|DET|John Salley|PF|27
Jordan|DET|Lance Blanks|SG|25
Jordan|DET|Mark Aguirre|SF|32
Jordan|DET|Orlando Woolridge|SF|32
Jordan|DET|William Bedford|C|28
Jordan|GSW|Alton Lister|C|33
Jordan|GSW|Billy Owens|PF|22
Jordan|GSW|Billy Thompson|SF|28
Jordan|GSW|Chris Gatling|PF|24
Jordan|GSW|Chris Mullin|SF|28
Jordan|GSW|Jaren Jackson|SG|24
Jordan|GSW|Jim Petersen|PF|29
Jordan|GSW|Mario Elie|SG|28
Jordan|GSW|Mike Smrek|C|29
Jordan|GSW|Rod Higgins|SF|32
Jordan|GSW|Sarunas Marciulionis|SG|27
Jordan|GSW|Tim Hardaway|PG|25
Jordan|GSW|Tom Tolbert|PF|26
Jordan|GSW|Tyrone Hill|C|23
Jordan|GSW|Victor Alexander|C|22
Jordan|GSW|Vincent Askew|SG|25
Jordan|HOU|Buck Johnson|SF|28
Jordan|HOU|Carl Herrera|PF|25
Jordan|HOU|Dan Godfread|C|24
Jordan|HOU|Dave Jamerson|SG|24
Jordan|HOU|Gerald Henderson|PG|36
Jordan|HOU|Hakeem Olajuwon|C|29
Jordan|HOU|John Turner|SF|24
Jordan|HOU|Kennard Winchester|SG|25
Jordan|HOU|Kenny Smith|PG|26
Jordan|HOU|Larry Smith|PF|34
Jordan|HOU|Matt Bullard|PF|24
Jordan|HOU|Otis Thorpe|PF|29
Jordan|HOU|Sleepy Floyd|PG|31
Jordan|HOU|Tree Rollins|C|36
Jordan|HOU|Vernon Maxwell|SG|26
Jordan|IND|Chuck Person|SF|27
Jordan|IND|Dale Davis|PF|22
Jordan|IND|Detlef Schrempf|PF|29
Jordan|IND|George McCloud|SF|24
Jordan|IND|Greg Dreiling|C|29
Jordan|IND|Kenny Williams|SF|22
Jordan|IND|LaSalle Thompson|C|30
Jordan|IND|Micheal Williams|PG|25
Jordan|IND|Mike Sanders|SF|31
Jordan|IND|Randy Wittman|SG|32
Jordan|IND|Reggie Miller|SG|26
Jordan|IND|Rik Smits|C|25
Jordan|IND|Sean Green|SG|21
Jordan|IND|Vern Fleming|PG|29
Jordan|LAC|Bo Kimble|SG|25
Jordan|LAC|Charles Smith|SF|26
Jordan|LAC|Danny Manning|PF|25
Jordan|LAC|David Rivers|PG|27
Jordan|LAC|Doc Rivers|PG|30
Jordan|LAC|Elliot Perry|PG|22
Jordan|LAC|Gary Grant|PG|26
Jordan|LAC|James Edwards|C|36
Jordan|LAC|Ken Norman|SF|27
Jordan|LAC|Lanard Copeland|SG|26
Jordan|LAC|LeRon Ellis|C|22
Jordan|LAC|Loy Vaught|PF|23
Jordan|LAC|Olden Polynice|C|27
Jordan|LAC|Ron Harper|SG|28
Jordan|LAC|Tony Brown|SF|31
Jordan|LAL|A.C. Green|PF|28
Jordan|LAL|Byron Scott|SG|30
Jordan|LAL|Cliff Robinson|PF|31
Jordan|LAL|Demetrius Calip|PG|22
Jordan|LAL|Elden Campbell|C|23
Jordan|LAL|Jack Haley|C|28
Jordan|LAL|James Worthy|SF|30
Jordan|LAL|Keith Owens|SF|22
Jordan|LAL|Sam Perkins|PF|30
Jordan|LAL|Sedale Threatt|PG|30
Jordan|LAL|Terry Teagle|SG|31
Jordan|LAL|Tony Smith|PG|23
Jordan|LAL|Vlade Divac|C|23
Jordan|MIA|Alan Ogg|C|24
Jordan|MIA|Alec Kessler|PF|25
Jordan|MIA|Bimbo Coles|PG|23
Jordan|MIA|Glen Rice|SF|24
Jordan|MIA|Grant Long|PF|25
Jordan|MIA|Jon Sundvold|PG|30
Jordan|MIA|Keith Askins|SF|24
Jordan|MIA|Kevin Edwards|PG|26
Jordan|MIA|Milos Babic|C|23
Jordan|MIA|Rony Seikaly|C|26
Jordan|MIA|Sherman Douglas|PG|25
Jordan|MIA|Steve Smith|SG|22
Jordan|MIA|Willie Burton|SF|23
Jordan|MIL|Alvin Robertson|SG|29
Jordan|MIL|Brad Lohaus|PF|27
Jordan|MIL|Dale Ellis|SF|31
Jordan|MIL|Danny Schayes|C|32
Jordan|MIL|Dave Popson|PF|27
Jordan|MIL|Frank Brickowski|SF|32
Jordan|MIL|Fred Roberts|PF|31
Jordan|MIL|Jay Humphries|PG|29
Jordan|MIL|Jeff Grayer|SG|26
Jordan|MIL|Larry Krystkowiak|PF|27
Jordan|MIL|Lester Conner|PG|32
Jordan|MIL|Moses Malone|C|36
Jordan|MIL|Steve Henson|PG|23
Jordan|MIN|Doug West|SG|24
Jordan|MIN|Felton Spencer|C|24
Jordan|MIN|Gerald Glass|SF|24
Jordan|MIN|Luc Longley|C|23
Jordan|MIN|Myron Brown|PG|22
Jordan|MIN|Pooh Richardson|PG|25
Jordan|MIN|Randy Breuer|C|31
Jordan|MIN|Sam Mitchell|PF|28
Jordan|MIN|Scott Brooks|PG|26
Jordan|MIN|Tellis Frank|PF|26
Jordan|MIN|Tod Murphy|PF|28
Jordan|MIN|Tony Campbell|SF|29
Jordan|MIN|Tyrone Corbin|SF|29
Jordan|NJN|Chris Dudley|C|26
Jordan|NJN|Chris Morris|SF|26
Jordan|NJN|Dave Feitl|C|29
Jordan|NJN|Derrick Coleman|PF|24
Jordan|NJN|Doug Lee|SG|27
Jordan|NJN|Drazen Petrovic|SG|27
Jordan|NJN|Jud Buechler|SF|23
Jordan|NJN|Kenny Anderson|PG|21
Jordan|NJN|Mookie Blaylock|PG|24
Jordan|NJN|Rafael Addison|SF|27
Jordan|NJN|Sam Bowie|C|30
Jordan|NJN|Tate George|SG|23
Jordan|NJN|Terry Mills|PF|24
Jordan|NYK|Anthony Mason|PF|25
Jordan|NYK|Brian Quinnett|SG|25
Jordan|NYK|Carlton McKinney|SG|27
Jordan|NYK|Charles Oakley|PF|28
Jordan|NYK|Gerald Wilkins|SG|28
Jordan|NYK|Greg Anthony|PG|24
Jordan|NYK|John Starks|SG|26
Jordan|NYK|Kiki Vandeweghe|SF|33
Jordan|NYK|Mark Jackson|PG|26
Jordan|NYK|Patrick Eddie|C|24
Jordan|NYK|Patrick Ewing|C|29
Jordan|NYK|Tim McCormick|C|29
Jordan|NYK|Xavier McDaniel|SF|28
Jordan|ORL|Anthony Bowie|SG|28
Jordan|ORL|Bison Dele|PF|22
Jordan|ORL|Chris Corchiani|PG|23
Jordan|ORL|Dennis Scott|SF|23
Jordan|ORL|Greg Kite|C|30
Jordan|ORL|Jeff Turner|SF|29
Jordan|ORL|Jerry Reynolds|SG|29
Jordan|ORL|Mark Acres|C|29
Jordan|ORL|Morlon Wiley|PG|25
Jordan|ORL|Nick Anderson|SG|24
Jordan|ORL|Otis Smith|SG|28
Jordan|ORL|Sam Vincent|PG|28
Jordan|ORL|Scott Skiles|PG|27
Jordan|ORL|Stanley Roberts|C|21
Jordan|ORL|Stephen Thompson|SG|23
Jordan|ORL|Terry Catledge|PF|28
Jordan|PHI|Armen Gilliam|PF|27
Jordan|PHI|Brian Oliver|SG|23
Jordan|PHI|Charles Barkley|SF|28
Jordan|PHI|Charles Shackleford|C|25
Jordan|PHI|Dave Hoppen|C|27
Jordan|PHI|Hersey Hawkins|SG|25
Jordan|PHI|Jayson Williams|PF|23
Jordan|PHI|Jeff Ruland|C|33
Jordan|PHI|Johnny Dawkins|PG|28
Jordan|PHI|Kenny Payne|SF|25
Jordan|PHI|Manute Bol|C|29
Jordan|PHI|Michael Ansley|SF|24
Jordan|PHI|Mitchell Wiggins|SG|32
Jordan|PHI|Ron Anderson|SF|33
Jordan|PHI|Tharon Mayes|SG|23
Jordan|PHO|Andrew Lang|C|25
Jordan|PHO|Cedric Ceballos|SF|22
Jordan|PHO|Dan Majerle|SF|26
Jordan|PHO|Ed Nealy|PF|31
Jordan|PHO|Jeff Hornacek|SG|28
Jordan|PHO|Jerrod Mustaf|PF|22
Jordan|PHO|Kevin Johnson|PG|25
Jordan|PHO|Kurt Rambis|PF|33
Jordan|PHO|Mark West|C|31
Jordan|PHO|Negele Knight|PG|24
Jordan|PHO|Steve Burtt|SG|29
Jordan|PHO|Tim Perry|PF|26
Jordan|PHO|Tom Chambers|PF|32
Jordan|POR|Alaa Abdelnaby|PF|23
Jordan|POR|Buck Williams|PF|31
Jordan|POR|Clifford Robinson|SF|25
Jordan|POR|Clyde Drexler|SG|29
Jordan|POR|Danny Ainge|SG|32
Jordan|POR|Danny Young|PG|29
Jordan|POR|Ennis Whatley|PG|29
Jordan|POR|Jerome Kersey|SF|29
Jordan|POR|Kevin Duckworth|C|27
Jordan|POR|Lamont Strothers|SG|23
Jordan|POR|Mark Bryant|PF|26
Jordan|POR|Robert Pack|PG|22
Jordan|POR|Terry Porter|PG|28
Jordan|POR|Wayne Cooper|C|35
Jordan|SAC|Anthony Bonner|PF|23
Jordan|SAC|Bob Hansen|SG|31
Jordan|SAC|Carl Thomas|SG|22
Jordan|SAC|Duane Causwell|C|23
Jordan|SAC|Dwayne Schintzius|C|23
Jordan|SAC|Jim Les|PG|28
Jordan|SAC|Les Jepsen|C|24
Jordan|SAC|Lionel Simmons|SF|23
Jordan|SAC|Mitch Richmond|SG|26
Jordan|SAC|Pete Chilcutt|PF|23
Jordan|SAC|Randy Brown|PG|23
Jordan|SAC|Spud Webb|PG|28
Jordan|SAC|Steve Scheffler|C|24
Jordan|SAC|Wayman Tisdale|PF|27
Jordan|SAS|Antoine Carr|PF|30
Jordan|SAS|Avery Johnson|PG|26
Jordan|SAS|David Robinson|C|26
Jordan|SAS|Donald Royal|SF|25
Jordan|SAS|Greg Sutton|PG|24
Jordan|SAS|Paul Pressey|SG|33
Jordan|SAS|Rod Strickland|PG|25
Jordan|SAS|Sean Elliott|SF|23
Jordan|SAS|Sean Higgins|SF|23
Jordan|SAS|Sidney Green|PF|31
Jordan|SAS|Steve Bardo|SG|23
Jordan|SAS|Terry Cummings|PF|30
Jordan|SAS|Tom Copa|C|27
Jordan|SAS|Tom Garrick|SG|25
Jordan|SAS|Tony Massenburg|PF|24
Jordan|SAS|Trent Tucker|SG|32
Jordan|SAS|Vinnie Johnson|SG|35
Jordan|SAS|Willie Anderson|SG|25
Jordan|SEA|Bart Kofoed|SG|27
Jordan|SEA|Benoit Benjamin|C|27
Jordan|SEA|Dana Barros|PG|24
Jordan|SEA|Derrick McKey|SF|25
Jordan|SEA|Eddie Johnson|SF|32
Jordan|SEA|Gary Payton|PG|23
Jordan|SEA|Marty Conlon|C|24
Jordan|SEA|Michael Cage|PF|30
Jordan|SEA|Nate McMillan|PG|27
Jordan|SEA|Quintin Dailey|SG|31
Jordan|SEA|Rich King|C|22
Jordan|SEA|Ricky Pierce|SG|32
Jordan|SEA|Shawn Kemp|PF|22
Jordan|UTA|Blue Edwards|SF|26
Jordan|UTA|Bob Thornton|PF|29
Jordan|UTA|Corey Crowder|SF|22
Jordan|UTA|David Benoit|SF|23
Jordan|UTA|Delaney Rudd|SG|29
Jordan|UTA|Eric Murdock|PG|23
Jordan|UTA|Isaac Austin|C|22
Jordan|UTA|Jeff Malone|SG|30
Jordan|UTA|John Stockton|PG|29
Jordan|UTA|Karl Malone|PF|28
Jordan|UTA|Mark Eaton|C|35
Jordan|UTA|Mike Brown|C|28
Jordan|UTA|Thurl Bailey|PF|30
Jordan|WSB|A.J. English|SG|24
Jordan|WSB|Albert King|SF|32
Jordan|WSB|Andre Turner|PG|27
Jordan|WSB|Charles Jones|C|34
Jordan|WSB|David Wingate|SG|28
Jordan|WSB|Derek Strong|PF|23
Jordan|WSB|Greg Foster|PF|23
Jordan|WSB|Harvey Grant|SF|26
Jordan|WSB|LaBradford Smith|SG|22
Jordan|WSB|Larry Stewart|PF|23
Jordan|WSB|Ledell Eackles|SG|25
Jordan|WSB|Michael Adams|PG|29
Jordan|WSB|Pervis Ellison|C|24
Jordan|WSB|Ralph Sampson|C|31
Jordan|WSB|Tom Hammonds|PF|24
Kobe|ATL|Alan Henderson|C|30
Kobe|ATL|Amal McCaskill|C|29
Kobe|ATL|Antonio Harvey|PF|32
Kobe|ATL|Brandon Williams|SF|27
Kobe|ATL|Chris Crawford|PF|27
Kobe|ATL|Corey Benjamin|SG|24
Kobe|ATL|Dan Dickau|PG|24
Kobe|ATL|Darvin Ham|SG|29
Kobe|ATL|Dion Glover|SG|24
Kobe|ATL|Emanual Davis|SG|34
Kobe|ATL|Glenn Robinson|SF|30
Kobe|ATL|Ira Newble|SF|28
Kobe|ATL|Jason Terry|PG|25
Kobe|ATL|Matt Maloney|PG|31
Kobe|ATL|Mike Wilks|SG|23
Kobe|ATL|Nazr Mohammed|C|25
Kobe|ATL|Paul Shirley|PF|25
Kobe|ATL|Shareef Abdur-Rahim|PF|26
Kobe|ATL|Theo Ratliff|C|29
Kobe|BOS|Antoine Walker|PF|26
Kobe|BOS|Bruno Sundov|C|22
Kobe|BOS|Eric Williams|SF|30
Kobe|BOS|Grant Long|PF|36
Kobe|BOS|J.R. Bremer|PG|22
Kobe|BOS|Kedrick Brown|SF|21
Kobe|BOS|Mikki Moore|C|27
Kobe|BOS|Paul Pierce|SG|25
Kobe|BOS|Ruben Wolkowyski|PF|29
Kobe|BOS|Shammond Williams|PG|27
Kobe|BOS|Tony Battie|C|26
Kobe|BOS|Tony Delk|PG|29
Kobe|BOS|Vin Baker|C|31
Kobe|BOS|Walter McCarty|SF|28
Kobe|CHI|Corie Blount|C|34
Kobe|CHI|Dalibor Bagaric|C|22
Kobe|CHI|Donyell Marshall|PF|29
Kobe|CHI|Eddie Robinson|SF|26
Kobe|CHI|Eddy Curry|C|20
Kobe|CHI|Fred Hoiberg|SG|30
Kobe|CHI|Jalen Rose|SF|30
Kobe|CHI|Jamal Crawford|PG|22
Kobe|CHI|Jay Williams|PG|21
Kobe|CHI|Lonny Baxter|C|24
Kobe|CHI|Marcus Fizer|PF|24
Kobe|CHI|Rick Brunson|PG|30
Kobe|CHI|Roger Mason|SF|22
Kobe|CHI|Trenton Hassell|SG|23
Kobe|CHI|Tyson Chandler|C|20
Kobe|CLE|Bimbo Coles|PG|34
Kobe|CLE|Carlos Boozer|PF|21
Kobe|CLE|Chris Mihm|C|23
Kobe|CLE|Dajuan Wagner|SG|19
Kobe|CLE|Darius Miles|SF|21
Kobe|CLE|DeSagana Diop|PF|21
Kobe|CLE|Jumaine Jones|SF|23
Kobe|CLE|Michael Stewart|PF|27
Kobe|CLE|Milt Palacio|PG|24
Kobe|CLE|Ricky Davis|SG|23
Kobe|CLE|Smush Parker|PG|21
Kobe|CLE|Tierre Brown|PG|23
Kobe|CLE|Tyrone Hill|PF|34
Kobe|CLE|Zydrunas Ilgauskas|C|27
Kobe|DAL|Adam Harrington|SG|22
Kobe|DAL|Adrian Griffin|SG|28
Kobe|DAL|Antoine Rigaudeau|SG|31
Kobe|DAL|Avery Johnson|PG|37
Kobe|DAL|Dirk Nowitzki|PF|24
Kobe|DAL|Eduardo Najera|SF|26
Kobe|DAL|Evan Eschmeyer|C|27
Kobe|DAL|Mark Strickland|SF|32
Kobe|DAL|Michael Finley|SF|29
Kobe|DAL|Nick Van|SG|31
Kobe|DAL|Popeye Jones|PF|32
Kobe|DAL|Raef LaFrentz|C|26
Kobe|DAL|Raja Bell|SG|26
Kobe|DAL|Shawn Bradley|C|30
Kobe|DAL|Steve Nash|PG|28
Kobe|DAL|Tariq Abdul-Wahad|SG|28
Kobe|DAL|Walt Williams|SF|32
Kobe|DEN|Chris Andersen|C|24
Kobe|DEN|Chris Whitney|PG|31
Kobe|DEN|Donnell Harvey|SF|22
Kobe|DEN|James Posey|SF|26
Kobe|DEN|Jeff Trepagnier|SG|23
Kobe|DEN|John Crotty|PG|33
Kobe|DEN|Junior Harrington|PG|22
Kobe|DEN|Juwan Howard|PF|29
Kobe|DEN|Kenny Satterfield|PG|21
Kobe|DEN|Marcus Camby|C|28
Kobe|DEN|Mark Blount|C|27
Kobe|DEN|Nene Hilario|C|20
Kobe|DEN|Nikoloz Tskitishvili|SF|19
Kobe|DEN|Predrag Savovic|SG|26
Kobe|DEN|Rodney White|SG|22
Kobe|DEN|Ryan Bowen|SG|27
Kobe|DEN|Vincent Yarbrough|SG|21
Kobe|DET|Ben Wallace|C|28
Kobe|DET|Chauncey Billups|PG|26
Kobe|DET|Chucky Atkins|PG|28
Kobe|DET|Clifford Robinson|PF|36
Kobe|DET|Corliss Williamson|SF|29
Kobe|DET|Danny Manning|PF|36
Kobe|DET|Don Reid|PF|29
Kobe|DET|Hubert Davis|SG|32
Kobe|DET|Jon Barry|SG|33
Kobe|DET|Mehmet Okur|PF|23
Kobe|DET|Michael Curry|SF|34
Kobe|DET|Pepe Sanchez|PG|25
Kobe|DET|Richard Hamilton|SG|24
Kobe|DET|Tayshaun Prince|SF|22
Kobe|DET|Zeljko Rebraca|C|30
Kobe|GSW|A.J. Guyton|PG|24
Kobe|GSW|Adonal Foyle|C|27
Kobe|GSW|Antawn Jamison|SF|26
Kobe|GSW|Bob Sura|SG|29
Kobe|GSW|Chris Mills|PF|33
Kobe|GSW|Danny Fortson|PF|26
Kobe|GSW|Dean Oliver|PG|24
Kobe|GSW|Earl Boykins|PG|26
Kobe|GSW|Erick Dampier|C|27
Kobe|GSW|Gilbert Arenas|PG|21
Kobe|GSW|Guy Rucker|PF|25
Kobe|GSW|Jason Richardson|SG|22
Kobe|GSW|Jiri Welsch|SF|23
Kobe|GSW|Mike Dunleavy|SF|22
Kobe|GSW|Oscar Torres|SG|26
Kobe|GSW|Troy Murphy|PF|22
Kobe|HOU|Bostjan Nachbar|SF|22
Kobe|HOU|Cuttino Mobley|SG|27
Kobe|HOU|Eddie Griffin|PF|20
Kobe|HOU|Glen Rice|SF|35
Kobe|HOU|Jason Collier|C|25
Kobe|HOU|Juaquin Hawkins|SG|29
Kobe|HOU|Kelvin Cato|C|28
Kobe|HOU|Kenny Thomas|PF|25
Kobe|HOU|Maurice Taylor|PF|26
Kobe|HOU|Moochie Norris|PG|29
Kobe|HOU|Steve Francis|PG|25
Kobe|HOU|Terence Morris|SF|24
Kobe|HOU|Tito Maddox|SG|21
Kobe|HOU|Yao Ming|C|22
Kobe|IND|Al Harrington|SF|22
Kobe|IND|Austin Croshere|PF|27
Kobe|IND|Brad Miller|C|26
Kobe|IND|Erick Strickland|SG|29
Kobe|IND|Fred Jones|SG|23
Kobe|IND|Jamaal Tinsley|PG|24
Kobe|IND|Jamison Brewer|PG|22
Kobe|IND|Jeff Foster|C|26
Kobe|IND|Jermaine O'Neal|PF|24
Kobe|IND|Jonathan Bender|SF|22
Kobe|IND|Metta World|SF|23
Kobe|IND|Primoz Brezec|C|23
Kobe|IND|Reggie Miller|SG|37
Kobe|IND|Ron Mercer|SG|26
Kobe|IND|Tim Hardaway|PG|36
Kobe|LAC|Andre Miller|PG|26
Kobe|LAC|Cherokee Parks|PF|30
Kobe|LAC|Chris Wilcox|PF|20
Kobe|LAC|Corey Maggette|SG|23
Kobe|LAC|Elton Brand|PF|23
Kobe|LAC|Eric Piatkowski|SG|32
Kobe|LAC|Keyon Dooling|SG|22
Kobe|LAC|Lamar Odom|SF|23
Kobe|LAC|Marko Jaric|SF|24
Kobe|LAC|Melvin Ely|C|24
Kobe|LAC|Michael Olowokandi|C|27
Kobe|LAC|Quentin Richardson|SG|22
Kobe|LAC|Sean Rooks|C|33
Kobe|LAC|Tremaine Fowlkes|SF|26
Kobe|LAC|Wang Zhizhi|C|25
Kobe|LAL|Brian Shaw|PG|36
Kobe|LAL|Derek Fisher|PG|28
Kobe|LAL|Devean George|SF|25
Kobe|LAL|Jannero Pargo|PG|23
Kobe|LAL|Kareem Rush|PG|22
Kobe|LAL|Kobe Bryant|SG|24
Kobe|LAL|Mark Madsen|PF|27
Kobe|LAL|Rick Fox|SF|33
Kobe|LAL|Robert Horry|PF|32
Kobe|LAL|Samaki Walker|C|26
Kobe|LAL|Shaquille O'Neal|C|30
Kobe|LAL|Soumaila Samake|C|24
Kobe|LAL|Stanislav Medvedenko|PF|23
Kobe|LAL|Tracy Murray|SF|31
Kobe|MEM|Brevin Knight|PG|27
Kobe|MEM|Cezary Trybanski|C|23
Kobe|MEM|Chris Owens|SF|23
Kobe|MEM|Drew Gooden|SF|21
Kobe|MEM|Earl Watson|PG|23
Kobe|MEM|Gordan Giricek|SG|25
Kobe|MEM|Jason Williams|PG|27
Kobe|MEM|Lorenzen Wright|C|27
Kobe|MEM|Michael Dickerson|SG|27
Kobe|MEM|Mike Batiste|PF|25
Kobe|MEM|Pau Gasol|PF|22
Kobe|MEM|Robert Archibald|PF|22
Kobe|MEM|Shane Battier|SF|24
Kobe|MEM|Stromile Swift|PF|23
Kobe|MEM|Wesley Person|SG|31
Kobe|MIA|Anthony Carter|PG|27
Kobe|MIA|Brian Grant|C|30
Kobe|MIA|Caron Butler|SF|22
Kobe|MIA|Eddie House|SG|24
Kobe|MIA|Eddie Jones|SG|31
Kobe|MIA|Ken Johnson|C|24
Kobe|MIA|LaPhonso Ellis|PF|32
Kobe|MIA|Malik Allen|PF|24
Kobe|MIA|Mike James|PG|27
Kobe|MIA|Rasual Butler|SG|23
Kobe|MIA|Sean Lampley|SF|23
Kobe|MIA|Sean Marks|PF|27
Kobe|MIA|Travis Best|PG|30
Kobe|MIA|Vladimir Stepania|C|26
Kobe|MIL|Anthony Mason|C|36
Kobe|MIL|Dan Gadzuric|C|24
Kobe|MIL|Ervin Johnson|C|35
Kobe|MIL|Jamal Sampson|PF|19
Kobe|MIL|Jason Caffey|PF|29
Kobe|MIL|Joel Przybilla|C|23
Kobe|MIL|Kevin Ollie|PG|30
Kobe|MIL|Marcus Haislip|PF|22
Kobe|MIL|Michael Redd|SG|23
Kobe|MIL|Ray Allen|SG|27
Kobe|MIL|Ronald Murray|SG|23
Kobe|MIL|Sam Cassell|PG|33
Kobe|MIL|Tim Thomas|SF|25
Kobe|MIL|Toni Kukoc|PF|34
Kobe|MIN|Anthony Peeler|SG|33
Kobe|MIN|Gary Trent|SF|28
Kobe|MIN|Igor Rakocevic|PG|24
Kobe|MIN|Joe Smith|SF|27
Kobe|MIN|Kendall Gill|SG|34
Kobe|MIN|Kevin Garnett|PF|26
Kobe|MIN|Loren Woods|C|24
Kobe|MIN|Marc Jackson|C|28
Kobe|MIN|Rasho Nesterovic|C|26
Kobe|MIN|Reggie Slater|PF|32
Kobe|MIN|Rod Strickland|PG|36
Kobe|MIN|Troy Hudson|PG|26
Kobe|MIN|Wally Szczerbiak|SF|25
Kobe|NJN|Aaron Williams|C|31
Kobe|NJN|Anthony Johnson|PG|28
Kobe|NJN|Brandon Armstrong|SG|22
Kobe|NJN|Brian Scalabrine|PF|24
Kobe|NJN|Chris Childs|PG|35
Kobe|NJN|Dikembe Mutombo|C|36
Kobe|NJN|Donny Marshall|SF|30
Kobe|NJN|Jason Collins|C|24
Kobe|NJN|Jason Kidd|PG|29
Kobe|NJN|Kenyon Martin|PF|25
Kobe|NJN|Kerry Kittles|SG|28
Kobe|NJN|Lucious Harris|SG|32
Kobe|NJN|Richard Jefferson|SF|22
Kobe|NJN|Rodney Rogers|PF|31
Kobe|NJN|Tamar Slay|SG|22
Kobe|NOH|Baron Davis|PG|23
Kobe|NOH|Bryce Drew|PG|28
Kobe|NOH|Courtney Alexander|PG|25
Kobe|NOH|David Wesley|SG|32
Kobe|NOH|Elden Campbell|C|34
Kobe|NOH|George Lynch|SG|32
Kobe|NOH|Jamaal Magloire|C|24
Kobe|NOH|Jamal Mashburn|SF|30
Kobe|NOH|Jerome Moiso|C|24
Kobe|NOH|Kirk Haston|SF|23
Kobe|NOH|P.J. Brown|PF|33
Kobe|NOH|Randy Livingston|PG|27
Kobe|NOH|Robert Pack|PG|33
Kobe|NOH|Robert Traylor|C|25
Kobe|NOH|Stacey Augmon|SG|34
Kobe|NYK|Allan Houston|SG|31
Kobe|NYK|Charlie Ward|PG|32
Kobe|NYK|Clarence Weatherspoon|PF|32
Kobe|NYK|Frank Williams|PG|22
Kobe|NYK|Howard Eisley|PG|30
Kobe|NYK|Kurt Thomas|C|30
Kobe|NYK|Latrell Sprewell|SF|32
Kobe|NYK|Lavor Postell|SG|24
Kobe|NYK|Lee Nailon|SF|27
Kobe|NYK|Michael Doleac|C|25
Kobe|NYK|Othella Harrington|PF|29
Kobe|NYK|Shandon Anderson|SF|29
Kobe|NYK|Travis Knight|C|28
Kobe|ORL|Andrew DeClercq|C|29
Kobe|ORL|Darrell Armstrong|PG|34
Kobe|ORL|Grant Hill|SF|30
Kobe|ORL|Horace Grant|PF|37
Kobe|ORL|Jacque Vaughn|PG|27
Kobe|ORL|Jeryl Sasser|SG|23
Kobe|ORL|Mike Miller|SF|22
Kobe|ORL|Olumide Oyedeji|C|21
Kobe|ORL|Pat Burke|C|29
Kobe|ORL|Pat Garrity|PF|26
Kobe|ORL|Ryan Humphrey|PF|23
Kobe|ORL|Shawn Kemp|C|33
Kobe|ORL|Steven Hunter|C|21
Kobe|ORL|Tracy McGrady|SG|23
Kobe|PHI|Aaron McKie|SF|30
Kobe|PHI|Allen Iverson|SG|27
Kobe|PHI|Art Long|SF|30
Kobe|PHI|Brian Skinner|PF|26
Kobe|PHI|Derrick Coleman|C|35
Kobe|PHI|Efthimi Rentzias|C|27
Kobe|PHI|Eric Snow|PG|29
Kobe|PHI|Greg Buckner|SG|26
Kobe|PHI|John Salmons|PG|23
Kobe|PHI|Keith Van|PF|27
Kobe|PHI|Mark Bryant|PF|37
Kobe|PHI|Monty Williams|SF|31
Kobe|PHI|Todd MacCulloch|C|27
Kobe|PHO|Alton Ford|PF|21
Kobe|PHO|Amar'e Stoudemire|PF|20
Kobe|PHO|Anfernee Hardaway|SG|31
Kobe|PHO|Bo Outlaw|C|31
Kobe|PHO|Casey Jacobsen|SF|21
Kobe|PHO|Dan Langhi|SF|25
Kobe|PHO|Jake Tsakalidis|C|23
Kobe|PHO|Jake Voskuhl|C|25
Kobe|PHO|Joe Johnson|SG|21
Kobe|PHO|Randy Brown|PG|34
Kobe|PHO|Scott Williams|C|34
Kobe|PHO|Shawn Marion|SF|24
Kobe|PHO|Stephon Marbury|PG|25
Kobe|PHO|Tom Gugliotta|PF|33
Kobe|POR|Antonio Daniels|SG|27
Kobe|POR|Arvydas Sabonis|C|38
Kobe|POR|Bonzi Wells|SG|26
Kobe|POR|Charles Smith|SG|27
Kobe|POR|Chris Dudley|C|37
Kobe|POR|Dale Davis|C|33
Kobe|POR|Damon Stoudamire|PG|29
Kobe|POR|Derek Anderson|PG|28
Kobe|POR|Jeff McInnis|PG|28
Kobe|POR|Qyntel Woods|PF|21
Kobe|POR|Rasheed Wallace|PF|28
Kobe|POR|Ruben Boumtje-Boumtje|C|24
Kobe|POR|Ruben Patterson|SF|27
Kobe|POR|Scottie Pippen|SF|37
Kobe|POR|Zach Randolph|PF|21
Kobe|SAC|Bobby Jackson|PG|29
Kobe|SAC|Chris Webber|PF|29
Kobe|SAC|Damon Jones|PG|26
Kobe|SAC|Doug Christie|SG|32
Kobe|SAC|Gerald Wallace|SF|20
Kobe|SAC|Hedo Turkoglu|SF|23
Kobe|SAC|Jim Jackson|SF|32
Kobe|SAC|Keon Clark|C|27
Kobe|SAC|Lawrence Funderburke|PF|32
Kobe|SAC|Mateen Cleaves|PG|25
Kobe|SAC|Mike Bibby|PG|24
Kobe|SAC|Peja Stojakovic|SF|25
Kobe|SAC|Scot Pollard|C|27
Kobe|SAC|Vlade Divac|C|34
Kobe|SAS|Anthony Goldwire|PG|31
Kobe|SAS|Bruce Bowen|SF|31
Kobe|SAS|Danny Ferry|SF|36
Kobe|SAS|David Robinson|C|37
Kobe|SAS|Devin Brown|SG|24
Kobe|SAS|Kevin Willis|C|40
Kobe|SAS|Malik Rose|PF|28
Kobe|SAS|Manu Ginobili|SG|25
Kobe|SAS|Mengke Bateer|C|27
Kobe|SAS|Speedy Claxton|PG|24
Kobe|SAS|Stephen Jackson|SG|24
Kobe|SAS|Steve Kerr|PG|37
Kobe|SAS|Steve Smith|SG|33
Kobe|SAS|Tim Duncan|PF|26
Kobe|SAS|Tony Parker|PG|20
Kobe|SEA|Ansu Sesay|SF|26
Kobe|SEA|Brent Barry|SG|31
Kobe|SEA|Calvin Booth|C|26
Kobe|SEA|Desmond Mason|SF|25
Kobe|SEA|Gary Payton|PG|34
Kobe|SEA|Jerome James|C|27
Kobe|SEA|Joseph Forte|SG|21
Kobe|SEA|Kenny Anderson|PG|32
Kobe|SEA|Predrag Drobnjak|C|27
Kobe|SEA|Rashard Lewis|SF|23
Kobe|SEA|Reggie Evans|PF|22
Kobe|SEA|Vitaly Potapenko|C|27
Kobe|SEA|Vladimir Radmanovic|PF|22
Kobe|TOR|Alvin Williams|PG|28
Kobe|TOR|Antonio Davis|C|34
Kobe|TOR|Chris Jefferies|SF|22
Kobe|TOR|Damone Brown|PF|23
Kobe|TOR|Greg Foster|C|34
Kobe|TOR|Jelani McCoy|C|25
Kobe|TOR|Jermaine Jackson|SG|26
Kobe|TOR|Jerome Williams|PF|29
Kobe|TOR|Lindsey Hunter|PG|32
Kobe|TOR|Maceo Baston|PF|27
Kobe|TOR|Mamadou N'Diaye|C|27
Kobe|TOR|Michael Bradley|PF|23
Kobe|TOR|Morris Peterson|SF|25
Kobe|TOR|Nate Huffman|C|27
Kobe|TOR|Rafer Alston|PG|26
Kobe|TOR|Vince Carter|SG|26
Kobe|TOR|Voshon Lenard|SG|29
Kobe|TOR|Zendon Hamilton|C|27
Kobe|UTA|Andrei Kirilenko|SF|21
Kobe|UTA|Calbert Cheaney|SG|31
Kobe|UTA|Carlos Arroyo|PG|23
Kobe|UTA|DeShawn Stevenson|SG|21
Kobe|UTA|Greg Ostertag|C|29
Kobe|UTA|Jarron Collins|C|24
Kobe|UTA|John Amaechi|C|32
Kobe|UTA|John Stockton|PG|40
Kobe|UTA|Karl Malone|PF|39
Kobe|UTA|Mark Jackson|PG|37
Kobe|UTA|Matt Harpring|SF|26
Kobe|UTA|Scott Padgett|PF|26
Kobe|UTA|Tony Massenburg|C|35
Kobe|WAS|Bobby Simmons|SG|22
Kobe|WAS|Brendan Haywood|C|23
Kobe|WAS|Brian Cardinal|PF|25
Kobe|WAS|Bryon Russell|SF|32
Kobe|WAS|Charles Oakley|C|39
Kobe|WAS|Christian Laettner|PF|33
Kobe|WAS|Etan Thomas|PF|24
Kobe|WAS|Jahidi White|C|26
Kobe|WAS|Jared Jeffries|SF|21
Kobe|WAS|Jerry Stackhouse|SG|28
Kobe|WAS|Juan Dixon|PG|24
Kobe|WAS|Kwame Brown|C|20
Kobe|WAS|Larry Hughes|PG|24
Kobe|WAS|Michael Jordan|SF|39
Kobe|WAS|Tyronn Lue|PG|25
LeBron|ATL|Al Horford|C|24
LeBron|ATL|Damien Wilkins|SF|31
LeBron|ATL|Etan Thomas|C|32
LeBron|ATL|Jamal Crawford|SG|30
LeBron|ATL|Jason Collins|C|32
LeBron|ATL|Jeff Teague|PG|22
LeBron|ATL|Joe Johnson|SG|29
LeBron|ATL|Jordan Crawford|SG|22
LeBron|ATL|Josh Powell|PF|28
LeBron|ATL|Josh Smith|PF|25
LeBron|ATL|Marvin Williams|SF|24
LeBron|ATL|Maurice Evans|SF|32
LeBron|ATL|Mike Bibby|PG|32
LeBron|ATL|Pape Sy|SF|22
LeBron|ATL|Zaza Pachulia|C|26
LeBron|BOS|Avery Bradley|PG|20
LeBron|BOS|Delonte West|PG|27
LeBron|BOS|Glen Davis|C|25
LeBron|BOS|Jermaine O'Neal|C|32
LeBron|BOS|Kendrick Perkins|C|26
LeBron|BOS|Kevin Garnett|PF|34
LeBron|BOS|Luke Harangody|PF|23
LeBron|BOS|Marquis Daniels|SF|30
LeBron|BOS|Nate Robinson|PG|26
LeBron|BOS|Paul Pierce|SF|33
LeBron|BOS|Rajon Rondo|PG|24
LeBron|BOS|Ray Allen|SG|35
LeBron|BOS|Semih Erden|C|24
LeBron|BOS|Shaquille O'Neal|C|38
LeBron|BOS|Von Wafer|SG|25
LeBron|CHA|Boris Diaw|PF|28
LeBron|CHA|D.J. Augustin|PG|23
LeBron|CHA|Derrick Brown|SF|23
LeBron|CHA|DeSagana Diop|C|29
LeBron|CHA|Dominic McGuire|SF|25
LeBron|CHA|Eduardo Najera|PF|34
LeBron|CHA|Gerald Henderson|SG|23
LeBron|CHA|Gerald Wallace|SF|28
LeBron|CHA|Kwame Brown|C|28
LeBron|CHA|Matt Carroll|SG|30
LeBron|CHA|Nazr Mohammed|C|33
LeBron|CHA|Shaun Livingston|PG|25
LeBron|CHA|Sherron Collins|PG|23
LeBron|CHA|Stephen Jackson|SG|32
LeBron|CHA|Tyrus Thomas|C|24
LeBron|CHI|Brian Scalabrine|PF|32
LeBron|CHI|C.J. Watson|PG|26
LeBron|CHI|Carlos Boozer|C|29
LeBron|CHI|Derrick Rose|PG|22
LeBron|CHI|James Johnson|SF|23
LeBron|CHI|Joakim Noah|C|25
LeBron|CHI|John Lucas|PG|28
LeBron|CHI|Keith Bogans|SG|30
LeBron|CHI|Kurt Thomas|PF|38
LeBron|CHI|Kyle Korver|SG|29
LeBron|CHI|Luol Deng|SF|25
LeBron|CHI|Omer Asik|C|24
LeBron|CHI|Ronnie Brewer|SG|25
LeBron|CHI|Taj Gibson|PF|25
LeBron|CLE|Anderson Varejao|C|28
LeBron|CLE|Antawn Jamison|PF|34
LeBron|CLE|Anthony Parker|SF|35
LeBron|CLE|Christian Eyenga|SF|21
LeBron|CLE|Daniel Gibson|SG|24
LeBron|CLE|J.J. Hickson|C|22
LeBron|CLE|Jamario Moon|SF|30
LeBron|CLE|Jawad Williams|SF|27
LeBron|CLE|Joey Graham|SF|28
LeBron|CLE|Leon Powe|PF|27
LeBron|CLE|Manny Harris|SG|21
LeBron|CLE|Mo Williams|PG|28
LeBron|CLE|Ramon Sessions|PG|24
LeBron|CLE|Ryan Hollins|C|26
LeBron|CLE|Samardo Samuels|PF|22
LeBron|DAL|Alexis Ajinca|C|22
LeBron|DAL|Brendan Haywood|C|31
LeBron|DAL|Brian Cardinal|SF|33
LeBron|DAL|Caron Butler|SF|30
LeBron|DAL|DeShawn Stevenson|SG|29
LeBron|DAL|Dirk Nowitzki|PF|32
LeBron|DAL|Dominique Jones|SG|22
LeBron|DAL|Ian Mahinmi|C|24
LeBron|DAL|J.J. Barea|PG|26
LeBron|DAL|Jason Kidd|PG|37
LeBron|DAL|Jason Terry|SG|33
LeBron|DAL|Rodrigue Beaubois|PG|22
LeBron|DAL|Sasha Pavlovic|SF|27
LeBron|DAL|Shawn Marion|SF|32
LeBron|DAL|Steve Novak|SF|27
LeBron|DAL|Tyson Chandler|C|28
LeBron|DEN|Al Harrington|PF|30
LeBron|DEN|Anthony Carter|PG|35
LeBron|DEN|Arron Afflalo|SG|25
LeBron|DEN|Carmelo Anthony|SF|26
LeBron|DEN|Chauncey Billups|PG|34
LeBron|DEN|Chris Andersen|C|32
LeBron|DEN|Gary Forbes|SF|25
LeBron|DEN|J.R. Smith|SF|25
LeBron|DEN|Kenyon Martin|PF|33
LeBron|DEN|Melvin Ely|C|32
LeBron|DEN|Nene Hilario|C|28
LeBron|DEN|Renaldo Balkman|SF|26
LeBron|DEN|Shelden Williams|PF|27
LeBron|DEN|Ty Lawson|PG|23
LeBron|DET|Austin Daye|SF|22
LeBron|DET|Ben Gordon|SG|27
LeBron|DET|Ben Wallace|C|36
LeBron|DET|Charlie Villanueva|PF|26
LeBron|DET|Chris Wilcox|PF|28
LeBron|DET|DaJuan Summers|SF|23
LeBron|DET|Greg Monroe|C|20
LeBron|DET|Jason Maxiell|PF|27
LeBron|DET|Richard Hamilton|SG|32
LeBron|DET|Rodney Stuckey|PG|24
LeBron|DET|Tayshaun Prince|SF|30
LeBron|DET|Tracy McGrady|SG|31
LeBron|DET|Will Bynum|PG|28
LeBron|GSW|Andris Biedrins|C|24
LeBron|GSW|Brandan Wright|PF|23
LeBron|GSW|Charlie Bell|SG|31
LeBron|GSW|Dan Gadzuric|C|32
LeBron|GSW|David Lee|PF|27
LeBron|GSW|Dorell Wright|SF|25
LeBron|GSW|Ekpe Udoh|C|23
LeBron|GSW|Jeff Adrien|PF|24
LeBron|GSW|Jeremy Lin|PG|22
LeBron|GSW|Lou Amundson|PF|28
LeBron|GSW|Monta Ellis|SG|25
LeBron|GSW|Reggie Williams|SF|24
LeBron|GSW|Rodney Carney|SF|26
LeBron|GSW|Stephen Curry|PG|22
LeBron|GSW|Vladimir Radmanovic|PF|30
LeBron|HOU|Aaron Brooks|PG|26
LeBron|HOU|Brad Miller|C|34
LeBron|HOU|Chase Budinger|SF|22
LeBron|HOU|Chuck Hayes|C|27
LeBron|HOU|Courtney Lee|SG|25
LeBron|HOU|Ish Smith|PG|22
LeBron|HOU|Jared Jeffries|PF|29
LeBron|HOU|Jermaine Taylor|SG|24
LeBron|HOU|Jordan Hill|C|23
LeBron|HOU|Kevin Martin|SG|27
LeBron|HOU|Kyle Lowry|PG|24
LeBron|HOU|Luis Scola|PF|30
LeBron|HOU|Mike Harris|PF|27
LeBron|HOU|Patrick Patterson|PF|21
LeBron|HOU|Shane Battier|SF|32
LeBron|HOU|Yao Ming|C|30
LeBron|IND|A.J. Price|PG|24
LeBron|IND|Brandon Rush|SG|25
LeBron|IND|Dahntay Jones|SG|30
LeBron|IND|Danny Granger|SF|27
LeBron|IND|Darren Collison|PG|23
LeBron|IND|James Posey|SF|34
LeBron|IND|Jeff Foster|C|34
LeBron|IND|Josh McRoberts|PF|23
LeBron|IND|Lance Stephenson|SG|20
LeBron|IND|Mike Dunleavy|SG|30
LeBron|IND|Paul George|SG|20
LeBron|IND|Roy Hibbert|C|24
LeBron|IND|Solomon Jones|C|26
LeBron|IND|T.J. Ford|PG|27
LeBron|IND|Tyler Hansbrough|PF|25
LeBron|LAC|Al-Farouq Aminu|SF|20
LeBron|LAC|Baron Davis|PG|31
LeBron|LAC|Blake Griffin|PF|21
LeBron|LAC|Brian Cook|PF|30
LeBron|LAC|Chris Kaman|C|28
LeBron|LAC|Craig Smith|PF|27
LeBron|LAC|DeAndre Jordan|C|22
LeBron|LAC|Eric Bledsoe|PG|21
LeBron|LAC|Eric Gordon|SG|22
LeBron|LAC|Ike Diogu|PF|27
LeBron|LAC|Jarron Collins|C|32
LeBron|LAC|Randy Foye|SG|27
LeBron|LAC|Rasual Butler|SG|31
LeBron|LAC|Ryan Gomes|SF|28
LeBron|LAC|Willie Warren|PG|21
LeBron|LAL|Andrew Bynum|C|23
LeBron|LAL|Derek Fisher|PG|36
LeBron|LAL|Derrick Caracter|C|22
LeBron|LAL|Devin Ebanks|SG|21
LeBron|LAL|Kobe Bryant|SG|32
LeBron|LAL|Lamar Odom|PF|31
LeBron|LAL|Luke Walton|SF|30
LeBron|LAL|Matt Barnes|SF|30
LeBron|LAL|Metta World|SF|31
LeBron|LAL|Pau Gasol|C|30
LeBron|LAL|Sasha Vujacic|SG|26
LeBron|LAL|Shannon Brown|SG|25
LeBron|LAL|Steve Blake|PG|30
LeBron|LAL|Theo Ratliff|C|37
LeBron|MEM|Acie Law|PG|26
LeBron|MEM|Darrell Arthur|PF|22
LeBron|MEM|DeMarre Carroll|PF|24
LeBron|MEM|Greivis Vasquez|SG|24
LeBron|MEM|Hamed Haddadi|C|25
LeBron|MEM|Hasheem Thabeet|C|23
LeBron|MEM|Marc Gasol|C|26
LeBron|MEM|Mike Conley|PG|23
LeBron|MEM|O.J. Mayo|SG|23
LeBron|MEM|Rudy Gay|SF|24
LeBron|MEM|Sam Young|SF|25
LeBron|MEM|Tony Allen|SG|29
LeBron|MEM|Xavier Henry|SG|19
LeBron|MEM|Zach Randolph|PF|29
LeBron|MIA|Carlos Arroyo|PG|31
LeBron|MIA|Chris Bosh|PF|26
LeBron|MIA|Dexter Pittman|C|22
LeBron|MIA|Dwyane Wade|SG|29
LeBron|MIA|Eddie House|SG|32
LeBron|MIA|Erick Dampier|C|35
LeBron|MIA|Jamaal Magloire|C|32
LeBron|MIA|James Jones|SF|30
LeBron|MIA|Jerry Stackhouse|SG|36
LeBron|MIA|Joel Anthony|C|28
LeBron|MIA|Juwan Howard|PF|37
LeBron|MIA|LeBron James|SF|26
LeBron|MIA|Mario Chalmers|PG|24
LeBron|MIA|Mike Miller|SG|30
LeBron|MIA|Udonis Haslem|PF|30
LeBron|MIA|Zydrunas Ilgauskas|C|35
LeBron|MIL|Andrew Bogut|C|26
LeBron|MIL|Brandon Jennings|PG|21
LeBron|MIL|Brian Skinner|C|34
LeBron|MIL|Carlos Delfino|SF|28
LeBron|MIL|Chris Douglas-Roberts|SF|24
LeBron|MIL|Corey Maggette|SF|31
LeBron|MIL|Drew Gooden|PF|29
LeBron|MIL|Earl Boykins|PG|34
LeBron|MIL|Ersan Ilyasova|PF|23
LeBron|MIL|John Salmons|SG|31
LeBron|MIL|Jon Brockman|C|23
LeBron|MIL|Keyon Dooling|PG|30
LeBron|MIL|Larry Sanders|C|22
LeBron|MIL|Luc Mbah|PF|24
LeBron|MIL|Michael Redd|SG|31
LeBron|MIN|Anthony Tolliver|SF|25
LeBron|MIN|Corey Brewer|SF|24
LeBron|MIN|Darko Milicic|C|25
LeBron|MIN|Jonny Flynn|PG|21
LeBron|MIN|Kevin Love|PF|22
LeBron|MIN|Kosta Koufos|C|21
LeBron|MIN|Lazar Hayward|SF|24
LeBron|MIN|Luke Ridnour|PG|29
LeBron|MIN|Martell Webster|SF|24
LeBron|MIN|Maurice Ager|SG|26
LeBron|MIN|Michael Beasley|SF|22
LeBron|MIN|Nikola Pekovic|C|25
LeBron|MIN|Sebastian Telfair|PG|25
LeBron|MIN|Sundiata Gaines|PG|24
LeBron|MIN|Wayne Ellington|SG|23
LeBron|MIN|Wesley Johnson|SG|23
LeBron|NJN|Anthony Morrow|SG|25
LeBron|NJN|Ben Uzoh|PG|22
LeBron|NJN|Brook Lopez|C|22
LeBron|NJN|Damion James|SF|23
LeBron|NJN|Derrick Favors|PF|19
LeBron|NJN|Devin Harris|PG|27
LeBron|NJN|Joe Smith|PF|35
LeBron|NJN|Johan Petro|C|25
LeBron|NJN|Jordan Farmar|PG|24
LeBron|NJN|Kris Humphries|PF|25
LeBron|NJN|Mario West|SG|26
LeBron|NJN|Orien Greene|SG|28
LeBron|NJN|Quinton Ross|SF|29
LeBron|NJN|Stephen Graham|SG|28
LeBron|NJN|Terrence Williams|SG|23
LeBron|NJN|Travis Outlaw|SF|26
LeBron|NJN|Troy Murphy|PF|30
LeBron|NOH|Aaron Gray|C|26
LeBron|NOH|Chris Paul|PG|25
LeBron|NOH|David West|PF|30
LeBron|NOH|Didier Ilunga-Mbenga|C|30
LeBron|NOH|Emeka Okafor|C|28
LeBron|NOH|Jason Smith|C|24
LeBron|NOH|Jerryd Bayless|PG|22
LeBron|NOH|Marco Belinelli|SG|24
LeBron|NOH|Marcus Thornton|SG|23
LeBron|NOH|Patrick Ewing|SF|26
LeBron|NOH|Peja Stojakovic|SF|33
LeBron|NOH|Pops Mensah-Bonsu|PF|27
LeBron|NOH|Quincy Pondexter|SF|22
LeBron|NOH|Trevor Ariza|SF|25
LeBron|NOH|Willie Green|SG|29
LeBron|NYK|Amar'e Stoudemire|C|28
LeBron|NYK|Andy Rautins|SG|24
LeBron|NYK|Anthony Randolph|PF|21
LeBron|NYK|Danilo Gallinari|PF|22
LeBron|NYK|Henry Walker|SG|23
LeBron|NYK|Landry Fields|SG|22
LeBron|NYK|Raymond Felton|PG|26
LeBron|NYK|Roger Mason|SG|30
LeBron|NYK|Ronny Turiaf|C|28
LeBron|NYK|Shawne Williams|PF|24
LeBron|NYK|Timofey Mozgov|C|24
LeBron|NYK|Toney Douglas|SG|24
LeBron|NYK|Wilson Chandler|SF|23
LeBron|OKC|Byron Mullens|PF|21
LeBron|OKC|Cole Aldrich|C|22
LeBron|OKC|D.J. White|PF|24
LeBron|OKC|Daequan Cook|SG|23
LeBron|OKC|Eric Maynor|PG|23
LeBron|OKC|James Harden|SG|21
LeBron|OKC|Jeff Green|PF|24
LeBron|OKC|Kevin Durant|SF|22
LeBron|OKC|Morris Peterson|SG|33
LeBron|OKC|Nenad Krstic|C|27
LeBron|OKC|Nick Collison|C|30
LeBron|OKC|Royal Ivey|SG|29
LeBron|OKC|Russell Westbrook|PG|22
LeBron|OKC|Serge Ibaka|PF|21
LeBron|OKC|Thabo Sefolosha|SG|26
LeBron|ORL|Brandon Bass|PF|25
LeBron|ORL|Chris Duhon|PG|28
LeBron|ORL|Dwight Howard|C|25
LeBron|ORL|J.J. Redick|SG|26
LeBron|ORL|Jameer Nelson|PG|28
LeBron|ORL|Jason Williams|PG|35
LeBron|ORL|Malik Allen|PF|32
LeBron|ORL|Marcin Gortat|C|26
LeBron|ORL|Mickael Pietrus|SF|28
LeBron|ORL|Quentin Richardson|SF|30
LeBron|ORL|Rashard Lewis|PF|31
LeBron|ORL|Ryan Anderson|PF|22
LeBron|ORL|Vince Carter|SG|34
LeBron|PHI|Andre Iguodala|SF|27
LeBron|PHI|Andres Nocioni|SF|31
LeBron|PHI|Antonio Daniels|PG|35
LeBron|PHI|Craig Brackins|PF|23
LeBron|PHI|Darius Songaila|C|32
LeBron|PHI|Elton Brand|PF|31
LeBron|PHI|Evan Turner|SG|22
LeBron|PHI|Jason Kapono|SF|29
LeBron|PHI|Jodie Meeks|SG|23
LeBron|PHI|Jrue Holiday|PG|20
LeBron|PHI|Lou Williams|SG|24
LeBron|PHI|Marreese Speights|C|23
LeBron|PHI|Spencer Hawes|C|22
LeBron|PHI|Thaddeus Young|PF|22
LeBron|PHI|Tony Battie|C|34
LeBron|PHO|Channing Frye|PF|27
LeBron|PHO|Earl Barron|C|29
LeBron|PHO|Earl Clark|SF|23
LeBron|PHO|Gani Lawal|PF|22
LeBron|PHO|Garret Siler|C|24
LeBron|PHO|Goran Dragic|PG|24
LeBron|PHO|Grant Hill|SF|38
LeBron|PHO|Hakim Warrick|PF|28
LeBron|PHO|Hedo Turkoglu|PF|31
LeBron|PHO|Jared Dudley|SF|25
LeBron|PHO|Jason Richardson|SG|30
LeBron|PHO|Josh Childress|SG|27
LeBron|PHO|Robin Lopez|C|22
LeBron|PHO|Steve Nash|PG|36
LeBron|PHO|Zabian Dowdell|PG|26
LeBron|POR|Andre Miller|PG|34
LeBron|POR|Armon Johnson|PG|21
LeBron|POR|Brandon Roy|SG|26
LeBron|POR|Chris Johnson|C|25
LeBron|POR|Dante Cunningham|PF|23
LeBron|POR|Fabricio Oberto|C|35
LeBron|POR|Joel Przybilla|C|31
LeBron|POR|LaMarcus Aldridge|PF|25
LeBron|POR|Luke Babbitt|SF|21
LeBron|POR|Marcus Camby|C|36
LeBron|POR|Nicolas Batum|SF|22
LeBron|POR|Patty Mills|PG|22
LeBron|POR|Rudy Fernandez|SG|25
LeBron|POR|Sean Marks|C|35
LeBron|POR|Wesley Matthews|SG|24
LeBron|SAC|Antoine Wright|SG|26
LeBron|SAC|Beno Udrih|PG|28
LeBron|SAC|Carl Landry|PF|27
LeBron|SAC|Darnell Jackson|PF|25
LeBron|SAC|DeMarcus Cousins|C|20
LeBron|SAC|Donte Greene|SF|22
LeBron|SAC|Eugene Jeter|PG|27
LeBron|SAC|Francisco Garcia|SF|29
LeBron|SAC|Hassan Whiteside|C|21
LeBron|SAC|Jason Thompson|PF|24
LeBron|SAC|Luther Head|PG|28
LeBron|SAC|Omri Casspi|SF|22
LeBron|SAC|Samuel Dalembert|C|29
LeBron|SAC|Tyreke Evans|SG|21
LeBron|SAS|Alonzo Gee|SG|23
LeBron|SAS|Antonio McDyess|PF|36
LeBron|SAS|Bobby Simmons|SF|30
LeBron|SAS|Chris Quinn|PG|27
LeBron|SAS|Danny Green|SG|23
LeBron|SAS|DeJuan Blair|PF|21
LeBron|SAS|Garrett Temple|SG|24
LeBron|SAS|Gary Neal|SG|26
LeBron|SAS|George Hill|PG|24
LeBron|SAS|Ime Udoka|SF|33
LeBron|SAS|James Anderson|SF|21
LeBron|SAS|Larry Owens|SF|28
LeBron|SAS|Manu Ginobili|SG|33
LeBron|SAS|Matt Bonner|PF|30
LeBron|SAS|Othyus Jeffers|SG|25
LeBron|SAS|Richard Jefferson|SF|30
LeBron|SAS|Tiago Splitter|C|26
LeBron|SAS|Tim Duncan|C|34
LeBron|SAS|Tony Parker|PG|28
LeBron|TOR|Amir Johnson|PF|23
LeBron|TOR|Andrea Bargnani|C|25
LeBron|TOR|David Andersen|PF|30
LeBron|TOR|DeMar DeRozan|SG|21
LeBron|TOR|Ed Davis|PF|21
LeBron|TOR|Jarrett Jack|PG|27
LeBron|TOR|Joey Dorsey|C|27
LeBron|TOR|Jose Calderon|PG|29
LeBron|TOR|Julian Wright|SF|23
LeBron|TOR|Leandro Barbosa|SG|28
LeBron|TOR|Linas Kleiza|SF|26
LeBron|TOR|Marcus Banks|PG|29
LeBron|TOR|Reggie Evans|PF|30
LeBron|TOR|Ronald Dupree|SF|30
LeBron|TOR|Solomon Alabi|C|22
LeBron|TOR|Sonny Weems|SF|24
LeBron|TOR|Trey Johnson|SG|26
LeBron|UTA|Al Jefferson|C|26
LeBron|UTA|Andrei Kirilenko|SF|29
LeBron|UTA|C.J. Miles|SF|23
LeBron|UTA|Deron Williams|PG|26
LeBron|UTA|Earl Watson|PG|31
LeBron|UTA|Francisco Elson|C|34
LeBron|UTA|Gordon Hayward|SF|20
LeBron|UTA|Jeremy Evans|SF|23
LeBron|UTA|Kyle Weaver|SG|24
LeBron|UTA|Kyrylo Fesenko|C|24
LeBron|UTA|Marcus Cousin|C|24
LeBron|UTA|Mehmet Okur|C|31
LeBron|UTA|Paul Millsap|PF|25
LeBron|UTA|Raja Bell|SG|34
LeBron|UTA|Ronnie Price|SG|27
LeBron|WAS|Al Thornton|SF|27
LeBron|WAS|Andray Blatche|PF|24
LeBron|WAS|Cartier Martin|SF|26
LeBron|WAS|Gilbert Arenas|PG|29
LeBron|WAS|Hamady N'Diaye|C|24
LeBron|WAS|Hilton Armstrong|C|26
LeBron|WAS|JaVale McGee|C|23
LeBron|WAS|John Wall|PG|20
LeBron|WAS|Josh Howard|SF|30
LeBron|WAS|Kevin Seraphin|PF|21
LeBron|WAS|Kirk Hinrich|SG|30
LeBron|WAS|Lester Hudson|PG|26
LeBron|WAS|Mustafa Shakur|PG|26
LeBron|WAS|Nick Young|SG|25
LeBron|WAS|Trevor Booker|PF|23
LeBron|WAS|Yi Jianlian|PF|23
Magic vs Bird|ATL|Armond Hill|PG|30
Magic vs Bird|ATL|Billy Paultz|C|35
Magic vs Bird|ATL|Dan Roundfield|PF|30
Magic vs Bird|ATL|Doc Rivers|PG|22
Magic vs Bird|ATL|Dominique Wilkins|SF|24
Magic vs Bird|ATL|Eddie Johnson|SG|28
Magic vs Bird|ATL|John Pinone|SF|22
Magic vs Bird|ATL|Johnny Davis|PG|28
Magic vs Bird|ATL|Mark Landsberger|PF|28
Magic vs Bird|ATL|Mike Glenn|SG|28
Magic vs Bird|ATL|Randy Wittman|SG|24
Magic vs Bird|ATL|Rickey Brown|C|25
Magic vs Bird|ATL|Scott Hastings|PF|23
Magic vs Bird|ATL|Sly Williams|SF|26
Magic vs Bird|ATL|Tree Rollins|C|28
Magic vs Bird|ATL|Wes Matthews|PG|24
Magic vs Bird|BOS|Carlos Clark|SG|23
Magic vs Bird|BOS|Cedric Maxwell|SF|28
Magic vs Bird|BOS|Danny Ainge|SG|24
Magic vs Bird|BOS|Dennis Johnson|SG|29
Magic vs Bird|BOS|Gerald Henderson|PG|28
Magic vs Bird|BOS|Greg Kite|C|22
Magic vs Bird|BOS|Kevin McHale|PF|26
Magic vs Bird|BOS|Larry Bird|PF|27
Magic vs Bird|BOS|M.L. Carr|SF|33
Magic vs Bird|BOS|Quinn Buckner|PG|29
Magic vs Bird|BOS|Robert Parish|C|30
Magic vs Bird|BOS|Scott Wedman|SF|31
Magic vs Bird|CHI|Dave Corzine|C|27
Magic vs Bird|CHI|Dave Greenwood|PF|26
Magic vs Bird|CHI|Ennis Whatley|PG|21
Magic vs Bird|CHI|Jawann Oldham|C|26
Magic vs Bird|CHI|Mitchell Wiggins|SG|24
Magic vs Bird|CHI|Orlando Woolridge|SF|24
Magic vs Bird|CHI|Quintin Dailey|SG|23
Magic vs Bird|CHI|Reggie Theus|PG|26
Magic vs Bird|CHI|Rod Higgins|SF|24
Magic vs Bird|CHI|Ronnie Lester|PG|25
Magic vs Bird|CHI|Sidney Green|PF|23
Magic vs Bird|CHI|Wallace Bryant|C|24
Magic vs Bird|CLE|Ben Poquette|PF|28
Magic vs Bird|CLE|Cliff Robinson|C|23
Magic vs Bird|CLE|Geoff Crompton|C|28
Magic vs Bird|CLE|Geoff Huston|PG|26
Magic vs Bird|CLE|Jeff Cook|C|27
Magic vs Bird|CLE|John Bagley|PG|23
Magic vs Bird|CLE|John Garris|PF|24
Magic vs Bird|CLE|Lonnie Shelton|PF|28
Magic vs Bird|CLE|Paul Thompson|SF|22
Magic vs Bird|CLE|Phil Hubbard|SF|27
Magic vs Bird|CLE|Roy Hinson|SF|22
Magic vs Bird|CLE|Stewart Granger|PG|22
Magic vs Bird|CLE|World B.|SG|30
Magic vs Bird|DAL|Bill Garnett|PF|23
Magic vs Bird|DAL|Brad Davis|PG|28
Magic vs Bird|DAL|Dale Ellis|SF|23
Magic vs Bird|DAL|Derek Harper|PG|22
Magic vs Bird|DAL|Elston Turner|SF|24
Magic vs Bird|DAL|Jay Vincent|SF|24
Magic vs Bird|DAL|Jim Spanarkel|SG|26
Magic vs Bird|DAL|Kurt Nimphius|C|25
Magic vs Bird|DAL|Mark Aguirre|SF|24
Magic vs Bird|DAL|Mark West|C|23
Magic vs Bird|DAL|Pat Cummings|PF|27
Magic vs Bird|DAL|Rolando Blackman|SG|24
Magic vs Bird|DEN|Alex English|SF|30
Magic vs Bird|DEN|Anthony Roberts|SF|28
Magic vs Bird|DEN|Bill Hanzlik|SF|26
Magic vs Bird|DEN|Dan Issel|C|35
Magic vs Bird|DEN|Danny Schayes|C|24
Magic vs Bird|DEN|Dave Robisch|C|34
Magic vs Bird|DEN|Howard Carter|SG|22
Magic vs Bird|DEN|Kenny Dennard|PF|25
Magic vs Bird|DEN|Kiki Vandeweghe|PF|25
Magic vs Bird|DEN|Mike Evans|PG|28
Magic vs Bird|DEN|Richard Anderson|PF|23
Magic vs Bird|DEN|Rob Williams|PG|22
Magic vs Bird|DEN|T.R. Dunn|SG|28
Magic vs Bird|DET|Bill Laimbeer|C|26
Magic vs Bird|DET|Cliff Levingston|PF|23
Magic vs Bird|DET|David Thirdkill|SF|23
Magic vs Bird|DET|Earl Cureton|C|26
Magic vs Bird|DET|Isiah Thomas|PG|22
Magic vs Bird|DET|John Long|SG|27
Magic vs Bird|DET|Kelly Tripucka|SF|24
Magic vs Bird|DET|Ken Austin|SF|22
Magic vs Bird|DET|Kent Benson|C|29
Magic vs Bird|DET|Lionel Hollins|PG|30
Magic vs Bird|DET|Ray Tolbert|PF|25
Magic vs Bird|DET|Terry Tyler|SF|27
Magic vs Bird|DET|Vinnie Johnson|SG|27
Magic vs Bird|DET|Walker Russell|PG|23
Magic vs Bird|GSW|Chris Engler|C|24
Magic vs Bird|GSW|Darren Tillis|C|23
Magic vs Bird|GSW|Don Collins|SG|25
Magic vs Bird|GSW|Joe Barry|C|25
Magic vs Bird|GSW|Larry Smith|PF|26
Magic vs Bird|GSW|Lester Conner|SG|24
Magic vs Bird|GSW|Lorenzo Romar|PG|25
Magic vs Bird|GSW|Mickey Johnson|PF|31
Magic vs Bird|GSW|Mike Bratz|PG|28
Magic vs Bird|GSW|Pace Mannion|SF|23
Magic vs Bird|GSW|Purvis Short|SF|26
Magic vs Bird|GSW|Ron Brewer|SG|28
Magic vs Bird|GSW|Russell Cross|C|22
Magic vs Bird|GSW|Sam Williams|PF|24
Magic vs Bird|GSW|Sleepy Floyd|PG|23
Magic vs Bird|HOU|Allen Leavell|PG|26
Magic vs Bird|HOU|Caldwell Jones|C|33
Magic vs Bird|HOU|Craig Ehlo|SG|22
Magic vs Bird|HOU|Elvin Hayes|PF|38
Magic vs Bird|HOU|James Bailey|PF|26
Magic vs Bird|HOU|Lewis Lloyd|SG|24
Magic vs Bird|HOU|Major Jones|PF|30
Magic vs Bird|HOU|Phil Ford|PG|27
Magic vs Bird|HOU|Ralph Sampson|C|23
Magic vs Bird|HOU|Robert Reid|SF|28
Magic vs Bird|HOU|Rodney McCray|SF|22
Magic vs Bird|HOU|Terry Teagle|SG|23
Magic vs Bird|HOU|Wally Walker|SF|29
Magic vs Bird|IND|Brook Steppe|SG|24
Magic vs Bird|IND|Butch Carter|SG|25
Magic vs Bird|IND|Clark Kellogg|PF|22
Magic vs Bird|IND|George Johnson|SF|27
Magic vs Bird|IND|Granville Waiters|C|23
Magic vs Bird|IND|Herb Williams|C|25
Magic vs Bird|IND|Jerry Sichting|PG|27
Magic vs Bird|IND|Jim Thomas|SG|23
Magic vs Bird|IND|Kevin McKenna|SG|25
Magic vs Bird|IND|Leroy Combs|SF|23
Magic vs Bird|IND|Sidney Lowe|PG|24
Magic vs Bird|IND|Steve Stipanovich|C|23
Magic vs Bird|IND|Tracy Jackson|SG|24
Magic vs Bird|KCK|Billy Knight|SF|31
Magic vs Bird|KCK|Dane Suttle|SG|22
Magic vs Bird|KCK|Don Buse|PG|33
Magic vs Bird|KCK|Ed Nealy|PF|23
Magic vs Bird|KCK|Joe Meriweather|C|30
Magic vs Bird|KCK|Kevin Loder|SF|24
Magic vs Bird|KCK|Larry Drew|PG|25
Magic vs Bird|KCK|Larry Micheaux|PF|23
Magic vs Bird|KCK|LaSalle Thompson|C|22
Magic vs Bird|KCK|Mark Olberding|PF|27
Magic vs Bird|KCK|Mike Woodson|SG|25
Magic vs Bird|KCK|Steve Johnson|C|26
Magic vs Bird|LAL|Bob McAdoo|C|32
Magic vs Bird|LAL|Byron Scott|SG|22
Magic vs Bird|LAL|Calvin Garrett|SF|27
Magic vs Bird|LAL|Jamaal Wilkes|SF|30
Magic vs Bird|LAL|James Worthy|PF|22
Magic vs Bird|LAL|Kareem Abdul-Jabbar|C|36
Magic vs Bird|LAL|Kurt Rambis|PF|25
Magic vs Bird|LAL|Larry Spriggs|SF|24
Magic vs Bird|LAL|Magic Johnson|PG|24
Magic vs Bird|LAL|Michael Cooper|SG|27
Magic vs Bird|LAL|Mike McGee|SF|24
Magic vs Bird|LAL|Mitch Kupchak|PF|29
Magic vs Bird|LAL|Swen Nater|C|34
Magic vs Bird|MIL|Alton Lister|PF|25
Magic vs Bird|MIL|Bob Lanier|C|35
Magic vs Bird|MIL|Charlie Criss|PG|35
Magic vs Bird|MIL|Harvey Catchings|PF|32
Magic vs Bird|MIL|Junior Bridgeman|SF|30
Magic vs Bird|MIL|Kevin Grevey|SG|30
Magic vs Bird|MIL|Linton Townes|SF|24
Magic vs Bird|MIL|Marques Johnson|SF|27
Magic vs Bird|MIL|Mike Dunleavy|PG|29
Magic vs Bird|MIL|Paul Mokeski|C|27
Magic vs Bird|MIL|Paul Pressey|SG|25
Magic vs Bird|MIL|Randy Breuer|C|23
Magic vs Bird|MIL|Sidney Moncrief|SG|26
Magic vs Bird|MIL|Tiny Archibald|PG|35
Magic vs Bird|NJN|Albert King|SF|24
Magic vs Bird|NJN|Bill Willoughby|SF|26
Magic vs Bird|NJN|Bruce Kuczenski|PF|22
Magic vs Bird|NJN|Buck Williams|PF|23
Magic vs Bird|NJN|Darryl Dawkins|C|27
Magic vs Bird|NJN|Darwin Cook|PG|25
Magic vs Bird|NJN|Foots Walker|PG|32
Magic vs Bird|NJN|Kelvin Ransey|PG|25
Magic vs Bird|NJN|Mark Jones|PG|22
Magic vs Bird|NJN|Micheal Ray|PG|28
Magic vs Bird|NJN|Mike Gminski|C|24
Magic vs Bird|NJN|Mike O'Koren|SF|25
Magic vs Bird|NJN|Otis Birdsong|SG|28
Magic vs Bird|NJN|Reggie Johnson|PF|26
Magic vs Bird|NYK|Bernard King|SF|27
Magic vs Bird|NYK|Bill Cartwright|C|26
Magic vs Bird|NYK|Darrell Walker|PG|22
Magic vs Bird|NYK|Eric Fernsten|PF|30
Magic vs Bird|NYK|Ernie Grunfeld|SG|28
Magic vs Bird|NYK|Len Elmore|PF|31
Magic vs Bird|NYK|Louis Orr|SF|25
Magic vs Bird|NYK|Marvin Webster|C|31
Magic vs Bird|NYK|Ray Williams|SG|29
Magic vs Bird|NYK|Rory Sparrow|PG|25
Magic vs Bird|NYK|Rudy Macklin|SF|25
Magic vs Bird|NYK|Trent Tucker|SG|24
Magic vs Bird|NYK|Truck Robinson|PF|32
Magic vs Bird|PHI|Andrew Toney|SG|26
Magic vs Bird|PHI|Bobby Jones|PF|32
Magic vs Bird|PHI|Charles Jones|PF|26
Magic vs Bird|PHI|Clemon Johnson|C|27
Magic vs Bird|PHI|Clint Richardson|SG|27
Magic vs Bird|PHI|Franklin Edwards|PG|24
Magic vs Bird|PHI|Julius Erving|SF|33
Magic vs Bird|PHI|Leo Rautins|SF|23
Magic vs Bird|PHI|Marc Iavaroni|PF|27
Magic vs Bird|PHI|Maurice Cheeks|PG|27
Magic vs Bird|PHI|Moses Malone|C|28
Magic vs Bird|PHI|Sedale Threatt|PG|22
Magic vs Bird|PHO|Alvan Adams|C|29
Magic vs Bird|PHO|Alvin Scott|SF|28
Magic vs Bird|PHO|Charles Pittman|PF|25
Magic vs Bird|PHO|James Edwards|C|28
Magic vs Bird|PHO|Johnny High|PG|26
Magic vs Bird|PHO|Kyle Macy|PG|26
Magic vs Bird|PHO|Larry Nance|PF|24
Magic vs Bird|PHO|Maurice Lucas|PF|31
Magic vs Bird|PHO|Mike Sanders|SF|23
Magic vs Bird|PHO|Paul Westphal|SG|33
Magic vs Bird|PHO|Rick Robey|C|28
Magic vs Bird|PHO|Rod Foster|PG|23
Magic vs Bird|PHO|Rory White|SF|24
Magic vs Bird|PHO|Walter Davis|SG|29
Magic vs Bird|POR|Audie Norris|C|23
Magic vs Bird|POR|Calvin Natt|SF|27
Magic vs Bird|POR|Clyde Drexler|SG|21
Magic vs Bird|POR|Darnell Valentine|PG|24
Magic vs Bird|POR|Eddie Jordan|PG|29
Magic vs Bird|POR|Fat Lever|PG|23
Magic vs Bird|POR|Jeff Lamp|SF|24
Magic vs Bird|POR|Jim Paxson|SG|26
Magic vs Bird|POR|Kenny Carr|PF|28
Magic vs Bird|POR|Mychal Thompson|C|29
Magic vs Bird|POR|Pete Verhoeven|PF|24
Magic vs Bird|POR|Tom Piotrowski|C|23
Magic vs Bird|POR|Wayne Cooper|C|27
Magic vs Bird|SAS|Artis Gilmore|C|34
Magic vs Bird|SAS|Bob Miller|PF|27
Magic vs Bird|SAS|Brant Weidner|PF|23
Magic vs Bird|SAS|Darrell Lockhart|C|23
Magic vs Bird|SAS|Dave Batton|C|27
Magic vs Bird|SAS|Edgar Jones|PF|27
Magic vs Bird|SAS|Fred Roberts|PF|23
Magic vs Bird|SAS|Gene Banks|PF|24
Magic vs Bird|SAS|George Gervin|SG|31
Magic vs Bird|SAS|John Lucas|PG|30
Magic vs Bird|SAS|John Paxson|PG|23
Magic vs Bird|SAS|Johnny Moore|PG|25
Magic vs Bird|SAS|Keith Edmonson|SG|23
Magic vs Bird|SAS|Kevin Williams|SG|22
Magic vs Bird|SAS|Mark McNamara|C|24
Magic vs Bird|SAS|Mike Mitchell|SF|28
Magic vs Bird|SAS|Roger Phegley|SG|27
Magic vs Bird|SAS|Steve Lingenfelter|PF|25
Magic vs Bird|SDC|Bill Walton|C|31
Magic vs Bird|SDC|Billy McKinney|PG|28
Magic vs Bird|SDC|Craig Hodges|SG|23
Magic vs Bird|SDC|Derek Smith|SG|22
Magic vs Bird|SDC|Greg Kelser|SF|26
Magic vs Bird|SDC|Hank McDowell|PF|24
Magic vs Bird|SDC|Hutch Jones|SF|24
Magic vs Bird|SDC|James Donaldson|C|26
Magic vs Bird|SDC|Jerome Whitehead|C|27
Magic vs Bird|SDC|Michael Brooks|SF|25
Magic vs Bird|SDC|Norm Nixon|PG|28
Magic vs Bird|SDC|Ricky Pierce|SG|24
Magic vs Bird|SDC|Terry Cummings|PF|22
Magic vs Bird|SEA|Al Wood|SG|25
Magic vs Bird|SEA|Charles Bradley|SG|24
Magic vs Bird|SEA|Clay Johnson|SG|27
Magic vs Bird|SEA|Danny Vranes|SF|25
Magic vs Bird|SEA|David Thompson|SG|29
Magic vs Bird|SEA|Fred Brown|SG|35
Magic vs Bird|SEA|Gus Williams|PG|30
Magic vs Bird|SEA|Jack Sikma|C|28
Magic vs Bird|SEA|Jon Sundvold|PG|22
Magic vs Bird|SEA|Reggie King|SF|26
Magic vs Bird|SEA|Scooter McCray|PF|23
Magic vs Bird|SEA|Steve Hawes|PF|33
Magic vs Bird|SEA|Steve Hayes|C|28
Magic vs Bird|SEA|Tom Chambers|PF|24
Magic vs Bird|UTA|Adrian Dantley|SF|27
Magic vs Bird|UTA|Bob Hansen|SG|23
Magic vs Bird|UTA|Darrell Griffith|SG|25
Magic vs Bird|UTA|J.J. Anderson|SF|23
Magic vs Bird|UTA|Jeff Wilkins|C|28
Magic vs Bird|UTA|Jerry Eaves|PG|24
Magic vs Bird|UTA|John Drew|SF|29
Magic vs Bird|UTA|Mark Eaton|C|27
Magic vs Bird|UTA|Rich Kelley|C|30
Magic vs Bird|UTA|Rickey Green|PG|29
Magic vs Bird|UTA|Thurl Bailey|PF|22
Magic vs Bird|UTA|Tom Boswell|PF|30
Magic vs Bird|WSB|Bryan Warrick|PG|24
Magic vs Bird|WSB|Charles Davis|SF|25
Magic vs Bird|WSB|Darren Daye|SF|23
Magic vs Bird|WSB|DeWayne Scales|PF|25
Magic vs Bird|WSB|Frank Johnson|PG|25
Magic vs Bird|WSB|Greg Ballard|SF|29
Magic vs Bird|WSB|Jeff Malone|SG|22
Magic vs Bird|WSB|Jeff Ruland|C|25
Magic vs Bird|WSB|Joe Kopicki|PF|23
Magic vs Bird|WSB|Michael Wilson|PG|24
Magic vs Bird|WSB|Mike Gibson|PF|23
Magic vs Bird|WSB|Rick Mahorn|PF|25
Magic vs Bird|WSB|Ricky Sobers|SG|31
Magic vs Bird|WSB|Tom McMillen|C|31
Modern|ATL|Asa Newell|PF|19
Modern|ATL|Caleb Houstan|SF|22
Modern|ATL|Dyson Daniels|PG/SG|22
Modern|ATL|Jacob Toppin|PF|25
Modern|ATL|Jalen Johnson|SF/PF|23
Modern|ATL|Keaton Wallace|PG/SG|26
Modern|ATL|Kristaps Porzingis|C|29
Modern|ATL|Luke Kennard|SG|28
Modern|ATL|Mouhamed Gueye|C|22
Modern|ATL|N'Faly Dante|C|23
Modern|ATL|Nickeil Alexander-Walker|SG/SF|26
Modern|ATL|Nikola Djurisic|SG|21
Modern|ATL|Onyeka Okongwu|C|24
Modern|ATL|Trae Young|PG|26
Modern|ATL|Vit Krejci|PG|25
Modern|ATL|Zaccharie Risacher|SF|20
Modern|BKN|Ben Saraf|SG|19
Modern|BKN|Cam Thomas|PG/SG|23
Modern|BKN|Danny Wolf|C|21
Modern|BKN|Day'Ron Sharpe|C|23
Modern|BKN|Drake Powell|SG/SF|19
Modern|BKN|E.J. Liddell|PF|24
Modern|BKN|Egor Demin|SG/SF|19
Modern|BKN|Haywood Highsmith|SF|28
Modern|BKN|Jalen Wilson|SF/PF|24
Modern|BKN|Nic Claxton|C|26
Modern|BKN|Noah Clowney|SF/PF|20
Modern|BKN|Nolan Traore|PG/SG|19
Modern|BKN|Terance Mann|SG/SF|28
Modern|BKN|Tyrese Martin|SG/SF|26
Modern|BKN|Tyson Etienne|SG|25
Modern|BKN|Ziaire Williams|SF|23
Modern|BOS|Amari Williams|C|23
Modern|BOS|Anfernee Simons|PG/SG|26
Modern|BOS|Baylor Scheierman|SG|24
Modern|BOS|Chris Boucher|PF/C|32
Modern|BOS|Derrick White|SG|30
Modern|BOS|Hugo Gonzalez|SG/SF|19
Modern|BOS|Jaylen Brown|SG/SF|28
Modern|BOS|Jayson Tatum|SF/PF|27
Modern|BOS|Josh Minott|SG/SF|23
Modern|BOS|Luka Garza|C|26
Modern|BOS|Max Shulga|PG/SG|22
Modern|BOS|Neemias Queta|C|25
Modern|BOS|Payton Pritchard|PG|27
Modern|BOS|Sam Hauser|SF|27
Modern|BOS|Xavier Tillman|PF/C|26
Modern|CHA|Antonio Reeves|SG|24
Modern|CHA|Brandon Miller|SF/PF|22
Modern|CHA|Collin Sexton|PG/SG|26
Modern|CHA|Drew Peterson|SF/PF|25
Modern|CHA|Grant Williams|SF/PF|26
Modern|CHA|Josh Green|SG/SF|24
Modern|CHA|KJ Simpson|PG|22
Modern|CHA|Kon Knueppel|SG/SF|19
Modern|CHA|LaMelo Ball|PG|23
Modern|CHA|Liam McNeeley|SF|19
Modern|CHA|Mason Plumlee|C|35
Modern|CHA|Miles Bridges|SF/PF|27
Modern|CHA|Moussa Diabate|PF/C|23
Modern|CHA|Pat Connaughton|SG/SF|32
Modern|CHA|Ryan Kalkbrenner|C|23
Modern|CHA|Tidjane Salaun|SF/PF|19
Modern|CHA|Tre Mann|PG|24
Modern|CHI|Ayo Dosunmu|PG/SG|25
Modern|CHI|Coby White|PG/SG|25
Modern|CHI|Dalen Terry|SG/SF|22
Modern|CHI|Emanuel Miller|SF|25
Modern|CHI|Isaac Okoro|SG/SF|24
Modern|CHI|Jalen Smith|PF/C|25
Modern|CHI|Jevon Carter|PG|29
Modern|CHI|Josh Giddey|SG/SF|22
Modern|CHI|Julian Phillips|SF|21
Modern|CHI|Kevin Huerter|SG|26
Modern|CHI|Lachlan Olbrich|PF/C|21
Modern|CHI|Matas Buzelis|SF/PF|20
Modern|CHI|Nikola Vucevic|C|34
Modern|CHI|Noa Essengue|PF|18
Modern|CHI|Patrick Williams|PF|23
Modern|CHI|Tre Jones|PG|25
Modern|CHI|Trentyn Flowers|SG/SF|20
Modern|CHI|Zach Collins|PF/C|27
Modern|CLE|Darius Garland|PG|25
Modern|CLE|De'Andre Hunter|SF/PF|27
Modern|CLE|Dean Wade|PF|28
Modern|CLE|Donovan Mitchell|PG/SG|28
Modern|CLE|Evan Mobley|PF/C|24
Modern|CLE|Jarrett Allen|C|27
Modern|CLE|Jaylon Tyson|SF|22
Modern|CLE|Lonzo Ball|PG|27
Modern|CLE|Luke Travers|SG/SF|23
Modern|CLE|Max Strus|SG/SF|29
Modern|CLE|Nae'Qwan Tomlin|PF/C|24
Modern|CLE|Sam Merrill|SG|29
Modern|CLE|Thomas Bryant|C|27
Modern|CLE|Tyrese Proctor|PG/SG|21
Modern|DAL|Anthony Davis|PF/C|32
Modern|DAL|Brandon Williams|PG|25
Modern|DAL|Caleb Martin|SF/PF|29
Modern|DAL|Cooper Flagg|SF/PF|18
Modern|DAL|D'Angelo Russell|PG/SG|29
Modern|DAL|Daniel Gafford|C|26
Modern|DAL|Dante Exum|PG|29
Modern|DAL|Dwight Powell|C|33
Modern|DAL|Jaden Hardy|SG|22
Modern|DAL|Klay Thompson|SG/SF|35
Modern|DAL|Kyrie Irving|PG|33
Modern|DAL|Max Christie|SG|22
Modern|DAL|Miles Kelly|SG|22
Modern|DAL|Moussa Cisse|C|22
Modern|DAL|Naji Marshall|SF|27
Modern|DAL|P.J. Washington|PF/C|26
Modern|DAL|Ryan Nembhard|PG|22
Modern|DEN|Aaron Gordon|SF/PF|29
Modern|DEN|Cameron Johnson|PF|29
Modern|DEN|Christian Braun|SG/SF|24
Modern|DEN|Curtis Jones|SG|23
Modern|DEN|Hunter Tyson|SF|25
Modern|DEN|Jalen Pickett|PG|25
Modern|DEN|Jamal Murray|PG/SG|28
Modern|DEN|Jonas Valanciunas|C|33
Modern|DEN|Julian Strawther|SF|23
Modern|DEN|Nikola Jokic|C|30
Modern|DEN|Peyton Watson|SF|22
Modern|DEN|Spencer Jones|SF|24
Modern|DEN|Tamar Bates|SG|22
Modern|DEN|Zeke Nnaji|PF/C|24
Modern|DET|Ausar Thompson|SG/SF|22
Modern|DET|Bobi Klintman|PF|22
Modern|DET|Cade Cunningham|PG/SG|23
Modern|DET|Caris LeVert|SG/SF|30
Modern|DET|Chaz Lanier|SG|23
Modern|DET|Colby Jones|SG|23
Modern|DET|Daniss Jenkins|PG|23
Modern|DET|Duncan Robinson|SG/SF|31
Modern|DET|Isaiah Stewart|C|24
Modern|DET|Jaden Ivey|SG|23
Modern|DET|Jalen Duren|C|21
Modern|DET|Javonte Green|SG/SF|31
Modern|DET|Marcus Sasser|PG/SG|24
Modern|DET|Paul Reed|PF/C|26
Modern|DET|Tobias Harris|PF|32
Modern|DET|Tolu Smith|PF/C|27
Modern|GSW|Al Horford|C|39
Modern|GSW|Alex Toohey|SF|21
Modern|GSW|Brandin Podziemski|SG/SF|22
Modern|GSW|Buddy Hield|SG/SF|32
Modern|GSW|De'Anthony Melton|PG/SG|27
Modern|GSW|Draymond Green|PF|35
Modern|GSW|Gui Santos|SF|23
Modern|GSW|Jackson Rowe|SF|27
Modern|GSW|Jimmy Butler|SF/PF|35
Modern|GSW|Jonathan Kuminga|PF|22
Modern|GSW|Moses Moody|SG/SF|23
Modern|GSW|Pat Spencer|PG/SG|28
Modern|GSW|Quinten Post|C|25
Modern|GSW|Stephen Curry|PG|37
Modern|GSW|Trayce Jackson-Davis|PF|25
Modern|GSW|Will Richard|SG|22
Modern|HOU|Aaron Holiday|PG|28
Modern|HOU|Alperen Sengun|C|22
Modern|HOU|Amen Thompson|SG/SF|22
Modern|HOU|Clint Capela|C|31
Modern|HOU|Dorian Finney-Smith|SF/PF|32
Modern|HOU|Fred VanVleet|PG|31
Modern|HOU|Isaiah Crawford|SF|24
Modern|HOU|Jae'Sean Tate|SF/PF|29
Modern|HOU|JD Davison|PG|22
Modern|HOU|Jeff Green|SF/PF|38
Modern|HOU|Josh Okogie|SG|26
Modern|HOU|Kevin Durant|SF/PF|36
Modern|HOU|Kevon Harris|SG/SF|27
Modern|HOU|Reed Sheppard|SG|21
Modern|HOU|Steven Adams|C|31
Modern|HOU|Tari Eason|SF/PF|24
Modern|IND|Aaron Nesmith|SF|25
Modern|IND|Andrew Nembhard|PG/SG|25
Modern|IND|Ben Sheppard|PG/SG|23
Modern|IND|Bennedict Mathurin|SG/SF|23
Modern|IND|Isaiah Jackson|PF/C|23
Modern|IND|James Wiseman|C|24
Modern|IND|Jarace Walker|PF|21
Modern|IND|Jay Huff|C|26
Modern|IND|Johnny Furphy|SG/SF|20
Modern|IND|Kam Jones|SG/SF|23
Modern|IND|Obi Toppin|PF|27
Modern|IND|Pascal Siakam|PF/C|31
Modern|IND|Quenton Jackson|PG|26
Modern|IND|RayJ Dennis|PG|24
Modern|IND|T.J. McConnell|PG|33
Modern|IND|Taelon Peter|SG|23
Modern|IND|Tony Bradley|C|27
Modern|IND|Tyrese Haliburton|PG|25
Modern|LAC|Bogdan Bogdanovic|SG/SF|32
Modern|LAC|Bradley Beal|SG|31
Modern|LAC|Brook Lopez|C|37
Modern|LAC|Cam Christie|SG|19
Modern|LAC|Chris Paul|PG|40
Modern|LAC|Ivica Zubac|C|28
Modern|LAC|Jahmyl Telfort|SG/SF|24
Modern|LAC|James Harden|PG/SG|35
Modern|LAC|John Collins|PF|27
Modern|LAC|Jordan Miller|SG/SF|25
Modern|LAC|Kawhi Leonard|SG/SF|33
Modern|LAC|Kobe Brown|PF|25
Modern|LAC|Kris Dunn|PG|31
Modern|LAC|Nicolas Batum|PF|36
Modern|LAL|Adou Thiero|SG/SF|21
Modern|LAL|Austin Reaves|SG/SF|27
Modern|LAL|Bronny James|PG/SG|20
Modern|LAL|Chris Manon|PG/SG|23
Modern|LAL|Christian Koloko|C|24
Modern|LAL|Dalton Knecht|SG|24
Modern|LAL|Deandre Ayton|C|26
Modern|LAL|Gabe Vincent|PG/SG|29
Modern|LAL|Jake LaRavia|SG/SF|23
Modern|LAL|Jarred Vanderbilt|PF|26
Modern|LAL|Jaxson Hayes|C|25
Modern|LAL|LeBron James|SF/PF|40
Modern|LAL|Luka Doncic|PG/SG|26
Modern|LAL|Marcus Smart|PG/SG|31
Modern|LAL|Maxi Kleber|PF/C|33
Modern|LAL|Rui Hachimura|PF|27
Modern|MEM|Brandon Clarke|PF|28
Modern|MEM|Cam Spencer|SG|25
Modern|MEM|Cedric Coward|SG/SF|21
Modern|MEM|Ja Morant|PG|25
Modern|MEM|Javon Small|PG|22
Modern|MEM|Jaylen Wells|SF|21
Modern|MEM|Jock Landale|C|29
Modern|MEM|John Konchar|SG|29
Modern|MEM|Kentavious Caldwell-Pope|SG/SF|32
Modern|MEM|Olivier-Maxence Prosper|PF|22
Modern|MEM|Santi Aldama|PF/C|24
Modern|MEM|Ty Jerome|PG/SG|27
Modern|MEM|Zach Edey|C|23
Modern|MIA|Andrew Wiggins|SF/PF|30
Modern|MIA|Bam Adebayo|C|27
Modern|MIA|Davion Mitchell|PG|26
Modern|MIA|Dru Smith|SG|27
Modern|MIA|Jahmir Young|PG|24
Modern|MIA|Kasparas Jakucionis|PG|19
Modern|MIA|Kel'el Ware|PF|21
Modern|MIA|Keshad Johnson|SF|24
Modern|MIA|Myron Gardner|SG|24
Modern|MIA|Norman Powell|SG/SF|31
Modern|MIA|Terry Rozier|PG/SG|31
Modern|MIA|Tyler Herro|PG/SG|25
Modern|MIA|Vladislav Goldin|C|24
Modern|MIL|A.J. Green|SG|25
Modern|MIL|Alex Antetokounmpo|SF|23
Modern|MIL|Amir Coffey|SG/SF|28
Modern|MIL|Bobby Portis|PF/C|30
Modern|MIL|Cole Anthony|PG|25
Modern|MIL|Gary Harris|SG|30
Modern|MIL|Giannis Antetokounmpo|PF|30
Modern|MIL|Jericho Sims|C|26
Modern|MIL|Kyle Kuzma|PF|29
Modern|MIL|Mark Sears|PG|23
Modern|MIL|Myles Turner|C|29
Modern|MIL|Pete Nance|PF|25
Modern|MIL|Ryan Rollins|SG|22
Modern|MIL|Taurean Prince|SG/SF|30
Modern|MIL|Thanasis Antetokounmpo|SF/PF|32
Modern|MIN|Anthony Edwards|SG/SF|23
Modern|MIN|Bones Hyland|PG/SG|24
Modern|MIN|Donte DiVincenzo|SG|28
Modern|MIN|Enrique Freeman|SF/PF|24
Modern|MIN|Jaden McDaniels|SG/SF|24
Modern|MIN|Jaylen Clark|SG|23
Modern|MIN|Joan Beringer|C|18
Modern|MIN|Joe Ingles|SF/PF|37
Modern|MIN|Johnny Juzang|SG|24
Modern|MIN|Julius Randle|PF|30
Modern|MIN|Leonard Miller|SF/PF|21
Modern|MIN|Mike Conley|PG|37
Modern|MIN|Naz Reid|C|25
Modern|MIN|Rob Dillingham|PG|20
Modern|MIN|Rocco Zikarsky|C|18
Modern|MIN|Rudy Gobert|C|32
Modern|NOP|Bryce McGowens|SG|22
Modern|NOP|Dejounte Murray|PG/SG|28
Modern|NOP|Derik Queen|PF|20
Modern|NOP|Herbert Jones|SF/PF|26
Modern|NOP|Jeremiah Fears|PG|18
Modern|NOP|Jordan Hawkins|SG/SF|23
Modern|NOP|Jordan Poole|PG/SG|26
Modern|NOP|Jose Alvarado|PG|27
Modern|NOP|Karlo Matkovic|C|24
Modern|NOP|Kevon Looney|C|29
Modern|NOP|Micah Peavy|SG|23
Modern|NOP|Saddiq Bey|SF/PF|26
Modern|NOP|Trey Alexander|SG|22
Modern|NOP|Yves Missi|C|21
Modern|NOP|Zion Williamson|PF|24
Modern|NYK|Ariel Hukporti|C|23
Modern|NYK|Guerschon Yabusele|PF|29
Modern|NYK|Jalen Brunson|PG|28
Modern|NYK|Jordan Clarkson|SG|33
Modern|NYK|Josh Hart|SG/SF|30
Modern|NYK|Karl-Anthony Towns|C|29
Modern|NYK|Landry Shamet|SG|28
Modern|NYK|Mikal Bridges|SG/SF|28
Modern|NYK|Miles McBride|PG|24
Modern|NYK|Mitchell Robinson|C|27
Modern|NYK|Mohamed Diawara|PF/C|20
Modern|NYK|OG Anunoby|SG/SF|27
Modern|NYK|Pacome Dadiet|SG/SF|19
Modern|NYK|Tosan Evbuomwan|SF|24
Modern|NYK|Tyler Kolek|PG|24
Modern|OKC|Aaron Wiggins|SG/SF|26
Modern|OKC|Ajay Mitchell|PG|23
Modern|OKC|Alex Caruso|PG/SG|31
Modern|OKC|Branden Carlson|C|26
Modern|OKC|Brooks Barnhizer|SF|23
Modern|OKC|Cason Wallace|PG/SG|21
Modern|OKC|Chet Holmgren|C|22
Modern|OKC|Chris Youngblood|SG|23
Modern|OKC|Isaiah Hartenstein|C|27
Modern|OKC|Isaiah Joe|SG|25
Modern|OKC|Jalen Williams|SG/SF|24
Modern|OKC|Jaylin Williams|C|22
Modern|OKC|Kenrich Williams|SF/PF|30
Modern|OKC|Luguentz Dort|SG/SF|26
Modern|OKC|Nikola Topic|PG|19
Modern|OKC|Ousmane Dieng|SF/PF|22
Modern|OKC|Shai Gilgeous-Alexander|PG/SG|26
Modern|OKC|Thomas Sorber|PF/C|19
Modern|ORL|Anthony Black|SG/SF|21
Modern|ORL|Colin Castleton|C|25
Modern|ORL|Desmond Bane|SG/SF|27
Modern|ORL|Franz Wagner|SG/SF|23
Modern|ORL|Goga Bitadze|C|25
Modern|ORL|Jalen Suggs|PG/SG|24
Modern|ORL|Jamal Cain|SF|26
Modern|ORL|Jett Howard|SF|21
Modern|ORL|Jonathan Isaac|PF|27
Modern|ORL|Moritz Wagner|PF/C|28
Modern|ORL|Noah Penda|SF/PF|20
Modern|ORL|Orlando Robinson|PF/C|24
Modern|ORL|Paolo Banchero|PF|22
Modern|ORL|Tyus Jones|PG|29
Modern|PHI|Adem Bona|C|22
Modern|PHI|Andre Drummond|C|31
Modern|PHI|Dominick Barlow|SF/PF|22
Modern|PHI|Eric Gordon|SG/SF|36
Modern|PHI|Hunter Sallis|PG/SG|22
Modern|PHI|Jabari Walker|PF|22
Modern|PHI|Jared McCain|PG/SG|21
Modern|PHI|Joel Embiid|C|31
Modern|PHI|Johni Broome|C|23
Modern|PHI|Justin Edwards|SF|21
Modern|PHI|Kyle Lowry|PG|39
Modern|PHI|Paul George|SF/PF|35
Modern|PHI|Quentin Grimes|SG|25
Modern|PHI|Trendon Watford|PF/C|24
Modern|PHI|Tyrese Maxey|PG/SG|24
Modern|PHI|V.J. Edgecombe|SG|19
Modern|PHX|C.J. Huntley|SF/PF|23
Modern|PHX|Collin Gillespie|PG|25
Modern|PHX|Devin Booker|SG|28
Modern|PHX|Dillon Brooks|SF|29
Modern|PHX|Grayson Allen|SG/SF|29
Modern|PHX|Isaiah Livers|SF|26
Modern|PHX|Jalen Green|SG|23
Modern|PHX|Jordan Goodwin|PG/SG|26
Modern|PHX|Khaman Maluach|C|18
Modern|PHX|Koby Brea|SG/SF|22
Modern|PHX|Mark Williams|C|23
Modern|PHX|Nick Richards|C|27
Modern|PHX|Nigel Hayes-Davis|PF|30
Modern|PHX|Oso Ighodaro|PF|22
Modern|PHX|Rasheer Fleming|PF/C|20
Modern|PHX|Royce O'Neale|SF|32
Modern|PHX|Ryan Dunn|SG|22
Modern|POR|Blake Wesley|PG/SG|22
Modern|POR|Caleb Love|PG/SG|23
Modern|POR|Damian Lillard|PG|34
Modern|POR|Deni Avdija|SG/SF|24
Modern|POR|Donovan Clingan|C|21
Modern|POR|Duop Reath|C|28
Modern|POR|Hansen Yang|C|20
Modern|POR|Javonte Cooke|SG/SF|25
Modern|POR|Jerami Grant|SF/PF|31
Modern|POR|Jrue Holiday|PG/SG|35
Modern|POR|Kris Murray|SF/PF|24
Modern|POR|Matisse Thybulle|SG/SF|28
Modern|POR|Rayan Rupert|SG|21
Modern|POR|Scoot Henderson|PG|21
Modern|POR|Shaedon Sharpe|SG|22
Modern|POR|Sidy Cissoko|SF|21
Modern|POR|Toumani Camara|PF|25
Modern|SAC|Daeqwon Plowden|SG/SF|26
Modern|SAC|Dario Saric|PF/C|31
Modern|SAC|DeMar DeRozan|SF/PF|35
Modern|SAC|Dennis Schroder|PG/SG|31
Modern|SAC|Devin Carter|PG/SG|23
Modern|SAC|Domantas Sabonis|C|29
Modern|SAC|Doug McDermott|SF/PF|33
Modern|SAC|Drew Eubanks|C|28
Modern|SAC|Isaac Jones|C|24
Modern|SAC|Isaiah Stevens|PG|24
Modern|SAC|Keegan Murray|SF/PF|24
Modern|SAC|Keon Ellis|SG|25
Modern|SAC|Malik Monk|SG|27
Modern|SAC|Maxime Raynaud|C|22
Modern|SAC|Nique Clifford|SG|23
Modern|SAC|Russell Westbrook|PG|36
Modern|SAC|Zach LaVine|SG/SF|30
Modern|SAS|Bismack Biyombo|C|32
Modern|SAS|Carter Bryant|SF/PF|19
Modern|SAS|De'Aaron Fox|PG|27
Modern|SAS|Devin Vassell|SG/SF|24
Modern|SAS|Dylan Harper|SG|19
Modern|SAS|Harrison Barnes|SF/PF|33
Modern|SAS|Harrison Ingram|SG|22
Modern|SAS|Jeremy Sochan|PF|22
Modern|SAS|Jordan McLaughlin|PG|29
Modern|SAS|Julian Champagnie|SF|24
Modern|SAS|Keldon Johnson|SG/SF|25
Modern|SAS|Kelly Olynyk|PF/C|34
Modern|SAS|Luke Kornet|C|29
Modern|SAS|Stephon Castle|PG/SG|20
Modern|SAS|Victor Wembanyama|PF/C|21
Modern|TOR|A.J. Lawson|SG|24
Modern|TOR|Alijah Martin|PG/SG|23
Modern|TOR|Brandon Ingram|SG/SF|27
Modern|TOR|Chucky Hepburn|PG|22
Modern|TOR|Collin Murray-Boyles|PF|20
Modern|TOR|Garrett Temple|SG|39
Modern|TOR|Gradey Dick|SG/SF|21
Modern|TOR|Immanuel Quickley|PG/SG|26
Modern|TOR|Ja'Kobe Walter|SG/SF|20
Modern|TOR|Jakob Poeltl|C|29
Modern|TOR|Jamal Shead|PG|22
Modern|TOR|Jamison Battle|SF|24
Modern|TOR|Jonathan Mogbo|PF/C|23
Modern|TOR|Ochai Agbaji|SG|25
Modern|TOR|R.J. Barrett|SG/SF|24
Modern|TOR|Sandro Mamukelashvili|PF/C|26
Modern|TOR|Scottie Barnes|SF/PF|23
Modern|UTA|Ace Bailey|SF/PF|18
Modern|UTA|Brice Sensabaugh|SG/SF|21
Modern|UTA|Cody Williams|SG/SF|20
Modern|UTA|Elijah Harkless|PG/SG|25
Modern|UTA|Georges Niang|SF/PF|31
Modern|UTA|Isaiah Collier|PG|20
Modern|UTA|John Tonje|SG|24
Modern|UTA|Jusuf Nurkic|C|30
Modern|UTA|Kevin Love|PF|36
Modern|UTA|Keyonte George|SG|21
Modern|UTA|Kyle Anderson|PF|31
Modern|UTA|Kyle Filipowski|PF/C|21
Modern|UTA|Lauri Markkanen|SF/PF|28
Modern|UTA|Oscar Tshiebwe|PF/C|25
Modern|UTA|Sviatoslav Mykhailiuk|SG/SF|28
Modern|UTA|Taylor Hendricks|SF/PF|21
Modern|UTA|Walker Kessler|C|23
Modern|WAS|AJ Johnson|PG/SG|20
Modern|WAS|Alex Sarr|PF|20
Modern|WAS|Anthony Gill|PF|32
Modern|WAS|Bilal Coulibaly|SF|20
Modern|WAS|Bub Carrington|PG/SG|19
Modern|WAS|C.J. McCollum|PG/SG|33
Modern|WAS|Cam Whitmore|SF/PF|20
Modern|WAS|Corey Kispert|SF|26
Modern|WAS|Jamir Watkins|SF|23
Modern|WAS|Justin Champagnie|SF/PF|24
Modern|WAS|Khris Middleton|SF/PF|33
Modern|WAS|Kyshawn George|SG/SF|21
Modern|WAS|Malaki Branham|SG/SF|22
Modern|WAS|Sharife Cooper|PG|24
Modern|WAS|Tre Johnson|SG|19
Modern|WAS|Tristan Vukcevic|C|22
Modern|WAS|Will Riley|SG/SF|19
Steph|ATL|DeAndre' Bembry|SF|22
Steph|ATL|Dennis Schroder|PG|23
Steph|ATL|Dwight Howard|C|31
Steph|ATL|Edy Tavares|C|24
Steph|ATL|Gary Neal|SG|32
Steph|ATL|Kent Bazemore|SF|27
Steph|ATL|Kris Humphries|PF|31
Steph|ATL|Kyle Korver|SG|35
Steph|ATL|Lamar Patterson|SG|25
Steph|ATL|Malcolm Delaney|PG|27
Steph|ATL|Mike Muscala|C|25
Steph|ATL|Mike Scott|PF|28
Steph|ATL|Paul Millsap|PF|31
Steph|ATL|Ryan Kelly|PF|25
Steph|ATL|Taurean Waller-Prince|SF|22
Steph|ATL|Thabo Sefolosha|SF|32
Steph|ATL|Tim Hardaway|SG|24
Steph|BOS|Al Horford|C|30
Steph|BOS|Amir Johnson|PF|29
Steph|BOS|Avery Bradley|SG|26
Steph|BOS|Demetrius Jackson|PG|22
Steph|BOS|Gerald Green|SF|31
Steph|BOS|Isaiah Thomas|PG|27
Steph|BOS|Jae Crowder|SF|26
Steph|BOS|James Young|SG|21
Steph|BOS|Jaylen Brown|SF|20
Steph|BOS|Jonas Jerebko|PF|29
Steph|BOS|Jordan Mickey|PF|22
Steph|BOS|Kelly Olynyk|C|25
Steph|BOS|Marcus Smart|SG|22
Steph|BOS|Terry Rozier|PG|22
Steph|BOS|Tyler Zeller|C|27
Steph|BRK|Anthony Bennett|PF|23
Steph|BRK|Bojan Bogdanovic|SF|27
Steph|BRK|Brook Lopez|C|28
Steph|BRK|Caris LeVert|SF|22
Steph|BRK|Chris McCullough|PF|21
Steph|BRK|Greivis Vasquez|PG|30
Steph|BRK|Isaiah Whitehead|PG|21
Steph|BRK|Jeremy Lin|PG|28
Steph|BRK|Joe Harris|SG|25
Steph|BRK|Justin Hamilton|C|26
Steph|BRK|Luis Scola|PF|36
Steph|BRK|Randy Foye|SG|33
Steph|BRK|Rondae Hollis-Jefferson|SF|22
Steph|BRK|Sean Kilpatrick|SG|27
Steph|BRK|Spencer Dinwiddie|PG|23
Steph|BRK|Trevor Booker|PF|29
Steph|BRK|Yogi Ferrell|PG|23
Steph|CHI|Bobby Portis|PF|21
Steph|CHI|Cristiano Felicio|C|24
Steph|CHI|Denzel Valentine|SG|23
Steph|CHI|Doug McDermott|SF|25
Steph|CHI|Dwyane Wade|SG|35
Steph|CHI|Isaiah Canaan|SG|25
Steph|CHI|Jerian Grant|PG|24
Steph|CHI|Jimmy Butler|SF|27
Steph|CHI|Michael Carter-Williams|PG|25
Steph|CHI|Nikola Mirotic|PF|25
Steph|CHI|Paul Zipser|SF|22
Steph|CHI|R.J. Hunter|SG|23
Steph|CHI|Rajon Rondo|PG|30
Steph|CHI|Robin Lopez|C|28
Steph|CHI|Taj Gibson|PF|31
Steph|CHO|Aaron Harrison|SG|22
Steph|CHO|Brian Roberts|PG|31
Steph|CHO|Christian Wood|PF|21
Steph|CHO|Cody Zeller|PF|24
Steph|CHO|Frank Kaminsky|C|23
Steph|CHO|Jeremy Lamb|SG|24
Steph|CHO|Kemba Walker|PG|26
Steph|CHO|Marco Belinelli|SG|30
Steph|CHO|Marvin Williams|PF|30
Steph|CHO|Michael Kidd-Gilchrist|SF|23
Steph|CHO|Mike Tobey|C|22
Steph|CHO|Nicolas Batum|SG|28
Steph|CHO|Ramon Sessions|PG|30
Steph|CHO|Roy Hibbert|C|30
Steph|CHO|Spencer Hawes|PF|28
Steph|CHO|Treveon Graham|SG|23
Steph|CLE|Channing Frye|C|33
Steph|CLE|Chris Andersen|C|38
Steph|CLE|Dahntay Jones|SF|36
Steph|CLE|DeAndre Liggins|SG|28
Steph|CLE|Iman Shumpert|SG|26
Steph|CLE|J.R. Smith|SG|31
Steph|CLE|James Jones|SF|36
Steph|CLE|Jordan McRae|SG|25
Steph|CLE|Kay Felder|PG|21
Steph|CLE|Kevin Love|PF|28
Steph|CLE|Kyrie Irving|PG|24
Steph|CLE|Larry Sanders|C|28
Steph|CLE|LeBron James|SF|32
Steph|CLE|Mike Dunleavy|SF|36
Steph|CLE|Richard Jefferson|SF|36
Steph|CLE|Tristan Thompson|C|25
Steph|DAL|A.J. Hammons|C|24
Steph|DAL|Andrew Bogut|C|32
Steph|DAL|Ben Bentil|PF|21
Steph|DAL|Deron Williams|PG|32
Steph|DAL|Devin Harris|PG|33
Steph|DAL|Dirk Nowitzki|PF|38
Steph|DAL|Dorian Finney-Smith|PF|23
Steph|DAL|Dwight Powell|C|25
Steph|DAL|Harrison Barnes|PF|24
Steph|DAL|J.J. Barea|PG|32
Steph|DAL|Jarrod Uthoff|PF|23
Steph|DAL|Jonathan Gibson|PG|29
Steph|DAL|Justin Anderson|SF|23
Steph|DAL|Manny Harris|SG|27
Steph|DAL|Nicolas Brussino|SF|23
Steph|DAL|Pierre Jackson|PG|25
Steph|DAL|Quincy Acy|PF|26
Steph|DAL|Quinn Cook|PG|23
Steph|DAL|Salah Mejri|C|30
Steph|DAL|Seth Curry|PG|26
Steph|DAL|Wesley Matthews|SG|30
Steph|DEN|Alonzo Gee|SF|29
Steph|DEN|Danilo Gallinari|SF|28
Steph|DEN|Darrell Arthur|PF|28
Steph|DEN|Emmanuel Mudiay|PG|20
Steph|DEN|Gary Harris|SG|22
Steph|DEN|Jamal Murray|SG|19
Steph|DEN|Jameer Nelson|PG|34
Steph|DEN|Jarnell Stokes|C|23
Steph|DEN|Johnny O'Bryant|PF|23
Steph|DEN|Juan Hernangomez|PF|21
Steph|DEN|Jusuf Nurkic|C|22
Steph|DEN|Kenneth Faried|PF|27
Steph|DEN|Malik Beasley|SG|20
Steph|DEN|Mike Miller|SF|36
Steph|DEN|Nikola Jokic|C|21
Steph|DEN|Will Barton|SG|26
Steph|DEN|Wilson Chandler|SF|29
Steph|DET|Andre Drummond|C|23
Steph|DET|Aron Baynes|C|30
Steph|DET|Beno Udrih|PG|34
Steph|DET|Boban Marjanovic|C|28
Steph|DET|Darrun Hilliard|SG|23
Steph|DET|Henry Ellenson|PF|20
Steph|DET|Ish Smith|PG|28
Steph|DET|Jon Leuer|PF|27
Steph|DET|Kentavious Caldwell-Pope|SG|23
Steph|DET|Marcus Morris|SF|27
Steph|DET|Michael Gbinije|SG|24
Steph|DET|Reggie Bullock|SF|25
Steph|DET|Reggie Jackson|PG|26
Steph|DET|Stanley Johnson|SF|20
Steph|DET|Tobias Harris|PF|24
Steph|GSW|Anderson Varejao|C|34
Steph|GSW|Andre Iguodala|SF|33
Steph|GSW|Briante Weber|PG|24
Steph|GSW|Damian Jones|C|21
Steph|GSW|David West|C|36
Steph|GSW|Draymond Green|PF|26
Steph|GSW|Ian Clark|SG|25
Steph|GSW|James Michael|PF|24
Steph|GSW|JaVale McGee|C|29
Steph|GSW|Kevin Durant|SF|28
Steph|GSW|Kevon Looney|C|20
Steph|GSW|Klay Thompson|SG|26
Steph|GSW|Patrick McCaw|SG|21
Steph|GSW|Shaun Livingston|PG|31
Steph|GSW|Stephen Curry|PG|28
Steph|GSW|Zaza Pachulia|C|32
Steph|HOU|Bobby Brown|PG|32
Steph|HOU|Chinanu Onuaku|C|20
Steph|HOU|Clint Capela|C|22
Steph|HOU|Corey Brewer|SF|30
Steph|HOU|Eric Gordon|SG|28
Steph|HOU|Isaiah Taylor|PG|22
Steph|HOU|James Harden|PG|27
Steph|HOU|K.J. McDaniels|SF|23
Steph|HOU|Kyle Wiltjer|PF|24
Steph|HOU|Montrezl Harrell|C|23
Steph|HOU|Nene Hilario|C|34
Steph|HOU|Patrick Beverley|SG|28
Steph|HOU|Ryan Anderson|PF|28
Steph|HOU|Sam Dekker|SF|22
Steph|HOU|Trevor Ariza|SF|31
Steph|HOU|Tyler Ennis|PG|22
Steph|IND|Aaron Brooks|PG|32
Steph|IND|Al Jefferson|C|32
Steph|IND|C.J. Miles|SF|29
Steph|IND|Georges Niang|PF|23
Steph|IND|Glenn Robinson|SF|23
Steph|IND|Jeff Teague|PG|28
Steph|IND|Joe Young|PG|24
Steph|IND|Kevin Seraphin|PF|27
Steph|IND|Lavoy Allen|PF|27
Steph|IND|Monta Ellis|SG|31
Steph|IND|Myles Turner|C|20
Steph|IND|Paul George|SF|26
Steph|IND|Rakeem Christmas|PF|25
Steph|IND|Rodney Stuckey|PG|30
Steph|IND|Thaddeus Young|PF|28
Steph|LAC|Alan Anderson|SF|34
Steph|LAC|Austin Rivers|SG|24
Steph|LAC|Blake Griffin|PF|27
Steph|LAC|Brandon Bass|PF|31
Steph|LAC|Brice Johnson|PF|22
Steph|LAC|Chris Paul|PG|31
Steph|LAC|DeAndre Jordan|C|28
Steph|LAC|Diamond Stone|C|19
Steph|LAC|J.J. Redick|SG|32
Steph|LAC|Jamal Crawford|SG|36
Steph|LAC|Luc Mbah|SF|30
Steph|LAC|Marreese Speights|C|29
Steph|LAC|Paul Pierce|SF|39
Steph|LAC|Raymond Felton|PG|32
Steph|LAC|Wesley Johnson|SF|29
Steph|LAL|Brandon Ingram|SF|19
Steph|LAL|D'Angelo Russell|PG|20
Steph|LAL|David Nwaba|SG|24
Steph|LAL|Ivica Zubac|C|19
Steph|LAL|Jordan Clarkson|SG|24
Steph|LAL|Jose Calderon|PG|35
Steph|LAL|Julius Randle|PF|22
Steph|LAL|Larry Nance|PF|24
Steph|LAL|Lou Williams|SG|30
Steph|LAL|Luol Deng|SF|31
Steph|LAL|Marcelo Huertas|PG|33
Steph|LAL|Metta World|SF|37
Steph|LAL|Nick Young|SG|31
Steph|LAL|Tarik Black|C|25
Steph|LAL|Thomas Robinson|PF|25
Steph|LAL|Timofey Mozgov|C|30
Steph|MEM|Andrew Harrison|PG|22
Steph|MEM|Brandan Wright|PF|29
Steph|MEM|Chandler Parsons|SF|28
Steph|MEM|Deyonta Davis|C|20
Steph|MEM|James Ennis|SF|26
Steph|MEM|JaMychal Green|PF|26
Steph|MEM|Jarell Martin|PF|22
Steph|MEM|Marc Gasol|C|32
Steph|MEM|Mike Conley|PG|29
Steph|MEM|Toney Douglas|PG|30
Steph|MEM|Tony Allen|SG|35
Steph|MEM|Troy Daniels|SG|25
Steph|MEM|Troy Williams|SF|22
Steph|MEM|Vince Carter|SF|40
Steph|MEM|Wade Baldwin|PG|20
Steph|MEM|Zach Randolph|PF|35
Steph|MIA|Derrick Williams|PF|25
Steph|MIA|Dion Waiters|SG|25
Steph|MIA|Goran Dragic|PG|30
Steph|MIA|Hassan Whiteside|C|27
Steph|MIA|James Johnson|PF|29
Steph|MIA|Josh McRoberts|PF|29
Steph|MIA|Josh Richardson|SG|23
Steph|MIA|Justise Winslow|SF|20
Steph|MIA|Luke Babbitt|SF|27
Steph|MIA|Okaro White|PF|24
Steph|MIA|Rodney McGruder|SG|25
Steph|MIA|Tyler Johnson|PG|24
Steph|MIA|Udonis Haslem|C|36
Steph|MIA|Wayne Ellington|SG|29
Steph|MIA|Willie Reed|C|26
Steph|MIL|Axel Toupane|SF|24
Steph|MIL|Gary Payton|PG|24
Steph|MIL|Giannis Antetokounmpo|SF|22
Steph|MIL|Greg Monroe|C|26
Steph|MIL|Jabari Parker|PF|21
Steph|MIL|Jason Terry|SG|39
Steph|MIL|John Henson|C|26
Steph|MIL|Khris Middleton|SF|25
Steph|MIL|Malcolm Brogdon|SG|24
Steph|MIL|Matthew Dellavedova|PG|26
Steph|MIL|Michael Beasley|PF|28
Steph|MIL|Miles Plumlee|C|28
Steph|MIL|Mirza Teletovic|PF|31
Steph|MIL|Rashad Vaughn|SG|20
Steph|MIL|Steve Novak|PF|33
Steph|MIL|Thon Maker|C|19
Steph|MIL|Tony Snell|SG|25
Steph|MIN|Adreian Payne|PF|25
Steph|MIN|Andrew Wiggins|SF|21
Steph|MIN|Brandon Rush|SG|31
Steph|MIN|Cole Aldrich|C|28
Steph|MIN|Gorgui Dieng|PF|27
Steph|MIN|John Lucas|PG|34
Steph|MIN|Jordan Hill|C|29
Steph|MIN|Karl-Anthony Towns|C|21
Steph|MIN|Kris Dunn|PG|22
Steph|MIN|Nemanja Bjelica|PF|28
Steph|MIN|Ricky Rubio|PG|26
Steph|MIN|Shabazz Muhammad|SF|24
Steph|MIN|Tyus Jones|PG|20
Steph|MIN|Zach LaVine|SG|21
Steph|NOP|Alexis Ajinca|C|28
Steph|NOP|Anthony Brown|SF|24
Steph|NOP|Anthony Davis|C|23
Steph|NOP|Archie Goodwin|SG|22
Steph|NOP|Buddy Hield|SG|23
Steph|NOP|Cheick Diallo|PF|20
Steph|NOP|Dante Cunningham|SF|29
Steph|NOP|Donatas Motiejunas|PF|26
Steph|NOP|E'Twaun Moore|SG|27
Steph|NOP|Jarrett Jack|PG|33
Steph|NOP|Jordan Crawford|SG|28
Steph|NOP|Jrue Holiday|PG|26
Steph|NOP|Lance Stephenson|SG|26
Steph|NOP|Langston Galloway|PG|25
Steph|NOP|Omer Asik|C|30
Steph|NOP|Reggie Williams|SF|30
Steph|NOP|Solomon Hill|SF|25
Steph|NOP|Terrence Jones|PF|25
Steph|NOP|Tim Frazier|PG|26
Steph|NOP|Tyreke Evans|SF|27
Steph|NOP|Wayne Selden|SG|22
Steph|NYK|Brandon Jennings|PG|27
Steph|NYK|Carmelo Anthony|SF|32
Steph|NYK|Courtney Lee|SG|31
Steph|NYK|Derrick Rose|PG|28
Steph|NYK|Joakim Noah|C|31
Steph|NYK|Justin Holiday|SG|27
Steph|NYK|Kristaps Porzingis|PF|21
Steph|NYK|Kyle O'Quinn|C|26
Steph|NYK|Lance Thomas|PF|28
Steph|NYK|Marshall Plumlee|C|24
Steph|NYK|Maurice Ndour|PF|24
Steph|NYK|Mindaugas Kuzminskas|SF|27
Steph|NYK|Ron Baker|SG|23
Steph|NYK|Sasha Vujacic|SG|32
Steph|NYK|Willy Hernangomez|C|22
Steph|OKC|Alex Abrines|SG|23
Steph|OKC|Andre Roberson|SF|25
Steph|OKC|Anthony Morrow|SG|31
Steph|OKC|Cameron Payne|PG|22
Steph|OKC|Domantas Sabonis|PF|20
Steph|OKC|Enes Kanter|C|24
Steph|OKC|Ersan Ilyasova|PF|29
Steph|OKC|Joffrey Lauvergne|PF|25
Steph|OKC|Josh Huestis|PF|25
Steph|OKC|Kyle Singler|SF|28
Steph|OKC|Nick Collison|PF|36
Steph|OKC|Norris Cole|PG|28
Steph|OKC|Russell Westbrook|PG|28
Steph|OKC|Semaj Christon|PG|24
Steph|OKC|Steven Adams|C|23
Steph|OKC|Victor Oladipo|SG|24
Steph|ORL|Aaron Gordon|SF|21
Steph|ORL|Arinze Onuaku|C|29
Steph|ORL|Bismack Biyombo|C|24
Steph|ORL|C.J. Watson|PG|32
Steph|ORL|C.J. Wilcox|SG|26
Steph|ORL|D.J. Augustin|PG|29
Steph|ORL|Damjan Rudez|SF|30
Steph|ORL|Elfrid Payton|PG|22
Steph|ORL|Evan Fournier|SG|24
Steph|ORL|Jeff Green|PF|30
Steph|ORL|Jodie Meeks|SG|29
Steph|ORL|Marcus Georges-Hunt|SG|22
Steph|ORL|Mario Hezonja|SF|21
Steph|ORL|Nikola Vucevic|C|26
Steph|ORL|Patricio Garino|SG|23
Steph|ORL|Serge Ibaka|PF|27
Steph|ORL|Stephen Zimmerman|C|20
Steph|PHI|Alex Poythress|PF|23
Steph|PHI|Chasson Randle|PG|23
Steph|PHI|Dario Saric|PF|22
Steph|PHI|Gerald Henderson|SG|29
Steph|PHI|Hollis Thompson|SG|25
Steph|PHI|Jahlil Okafor|C|21
Steph|PHI|Jerami Grant|SF|22
Steph|PHI|Jerryd Bayless|PG|28
Steph|PHI|Joel Embiid|C|22
Steph|PHI|Justin Harper|PF|27
Steph|PHI|Nerlens Noel|C|22
Steph|PHI|Nik Stauskas|SG|23
Steph|PHI|Richaun Holmes|C|23
Steph|PHI|Robert Covington|SF|26
Steph|PHI|Sergio Rodriguez|PG|30
Steph|PHI|Shawn Long|C|24
Steph|PHI|T.J. McConnell|PG|24
Steph|PHI|Tiago Splitter|C|32
Steph|PHI|Timothe Luwawu-Cabarrot|SF|21
Steph|PHO|Alan Williams|C|24
Steph|PHO|Alex Len|C|23
Steph|PHO|Brandon Knight|SG|25
Steph|PHO|Derrick Jones|SF|19
Steph|PHO|Devin Booker|SG|20
Steph|PHO|Dragan Bender|PF|19
Steph|PHO|Elijah Millsap|SG|29
Steph|PHO|Eric Bledsoe|PG|27
Steph|PHO|Jared Dudley|PF|31
Steph|PHO|Jarell Eddie|SF|25
Steph|PHO|John Jenkins|SG|25
Steph|PHO|Leandro Barbosa|SG|34
Steph|PHO|Marquese Chriss|PF|19
Steph|PHO|P.J. Tucker|SF|31
Steph|PHO|Ronnie Price|PG|33
Steph|PHO|T.J. Warren|SF|23
Steph|PHO|Tyler Ulis|PG|21
Steph|PHO|Tyson Chandler|C|34
Steph|POR|Al-Farouq Aminu|SF|26
Steph|POR|Allen Crabbe|SG|24
Steph|POR|C.J. McCollum|SG|25
Steph|POR|Damian Lillard|PG|26
Steph|POR|Ed Davis|PF|27
Steph|POR|Evan Turner|SF|28
Steph|POR|Jake Layman|SF|22
Steph|POR|Mason Plumlee|C|26
Steph|POR|Maurice Harkless|SF|23
Steph|POR|Meyers Leonard|PF|24
Steph|POR|Noah Vonleh|PF|21
Steph|POR|Pat Connaughton|SG|24
Steph|POR|Shabazz Napier|PG|25
Steph|POR|Tim Quarterman|SG|22
Steph|SAC|Anthony Tolliver|PF|31
Steph|SAC|Arron Afflalo|SG|31
Steph|SAC|Ben McLemore|SG|23
Steph|SAC|Darren Collison|PG|29
Steph|SAC|DeMarcus Cousins|C|26
Steph|SAC|Garrett Temple|SG|30
Steph|SAC|Georgios Papagiannis|C|19
Steph|SAC|Jordan Farmar|PG|30
Steph|SAC|Kosta Koufos|C|27
Steph|SAC|Malachi Richardson|SG|21
Steph|SAC|Matt Barnes|SF|36
Steph|SAC|Omri Casspi|SF|28
Steph|SAC|Rudy Gay|SF|30
Steph|SAC|Skal Labissiere|PF|20
Steph|SAC|Ty Lawson|PG|29
Steph|SAC|Willie Cauley-Stein|C|23
Steph|SAS|Bryn Forbes|SG|23
Steph|SAS|Danny Green|SG|29
Steph|SAS|David Lee|PF|33
Steph|SAS|Davis Bertans|PF|24
Steph|SAS|Dejounte Murray|PG|20
Steph|SAS|Dewayne Dedmon|C|27
Steph|SAS|Joel Anthony|C|34
Steph|SAS|Jonathon Simmons|SG|27
Steph|SAS|Kawhi Leonard|SF|25
Steph|SAS|Kyle Anderson|SG|23
Steph|SAS|LaMarcus Aldridge|PF|31
Steph|SAS|Manu Ginobili|SG|39
Steph|SAS|Nicolas Laprovittola|PG|27
Steph|SAS|Patty Mills|PG|28
Steph|SAS|Pau Gasol|C|36
Steph|SAS|Tony Parker|PG|34
Steph|TOR|Bruno Caboclo|SF|21
Steph|TOR|Cory Joseph|SG|25
Steph|TOR|Delon Wright|PG|24
Steph|TOR|DeMar DeRozan|SG|27
Steph|TOR|DeMarre Carroll|SF|30
Steph|TOR|Fred VanVleet|PG|22
Steph|TOR|Jakob Poeltl|C|21
Steph|TOR|Jared Sullinger|PF|24
Steph|TOR|Jonas Valanciunas|C|24
Steph|TOR|Kyle Lowry|PG|30
Steph|TOR|Lucas Nogueira|C|24
Steph|TOR|Norman Powell|SG|23
Steph|TOR|Pascal Siakam|PF|22
Steph|TOR|Patrick Patterson|PF|27
Steph|TOR|Terrence Ross|SF|25
Steph|UTA|Alec Burks|SG|25
Steph|UTA|Boris Diaw|PF|34
Steph|UTA|Dante Exum|PG|21
Steph|UTA|Derrick Favors|PF|25
Steph|UTA|George Hill|PG|30
Steph|UTA|Gordon Hayward|SF|26
Steph|UTA|Jeff Withey|C|26
Steph|UTA|Joe Ingles|SF|29
Steph|UTA|Joe Johnson|SF|35
Steph|UTA|Joel Bolomboy|PF|23
Steph|UTA|Raul Neto|PG|24
Steph|UTA|Rodney Hood|SG|24
Steph|UTA|Rudy Gobert|C|24
Steph|UTA|Shelvin Mack|PG|26
Steph|UTA|Trey Lyles|PF|21
Steph|WAS|Andrew Nicholson|PF|27
Steph|WAS|Bradley Beal|SG|23
Steph|WAS|Daniel Ochefu|C|23
Steph|WAS|Danuel House|SG|23
Steph|WAS|Ian Mahinmi|C|30
Steph|WAS|Jason Smith|C|30
Steph|WAS|John Wall|PG|26
Steph|WAS|Kelly Oubre|SF|21
Steph|WAS|Marcin Gortat|C|32
Steph|WAS|Marcus Thornton|SG|29
Steph|WAS|Markieff Morris|PF|27
Steph|WAS|Otto Porter|SF|23
Steph|WAS|Sheldon McClellan|SG|24
Steph|WAS|Tomas Satoransky|SG|25
Steph|WAS|Trey Burke|PG|24
`.trim();

export const ERA_ROSTERS:EraRosterPlayer[]=RAW_ROSTERS.split('\n').map((row,index)=>{
  const [era,team,name,position,age]=row.split('|');
  return {id:`era-roster-${index}`,era:era as MyNBAEra,team,name,position,age:Number(age)||undefined};
});
export function teamsForEra(era:MyNBAEra):string[]{return [...new Set(ERA_ROSTERS.filter(player=>player.era===era).map(player=>player.team))].sort()}
export function rosterForTeam(era:MyNBAEra,team:string):EraRosterPlayer[]{return ERA_ROSTERS.filter(player=>player.era===era&&player.team===team)}
