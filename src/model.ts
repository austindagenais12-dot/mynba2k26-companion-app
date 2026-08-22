export type Canon = '2K Confirmed' | 'User Confirmed' | 'Companion Canon' | 'Rumor';
export type Stage = 'High School' | 'Pre-NBA' | 'Awaiting Draft' | 'NBA';
export type SimDetail = 'Quick' | 'Normal' | 'Detailed';
export type ImmersionMode = 'Basketball Focused' | 'Immersive' | 'Full Life' | 'Chaos';
export type MyNBAEra = 'Magic vs Bird'|'Jordan'|'Kobe'|'LeBron'|'Steph'|'Modern';

export type Attribute = { name: string; category: string; rating: number; cap: number };
export type Badge = { name: string; category: string; level: 'Locked'|'Bronze'|'Silver'|'Gold'|'HOF'|'Legend'; progress: number };
export type Game = {
  id: string; date: string; opponent: string; result: 'W'|'L'; pts: number; reb: number; ast: number; stl: number; blk: number;
  tov: number; fgm: number; fga: number; tpm: number; tpa: number; ftm: number; fta: number; minutes: number; plusMinus: number;
  importance: 'Regular'|'Rivalry'|'Playoff'|'Elimination'|'Finals'; xp: number;
  scheduleGameId?: string;
  homeAway?: 'Home'|'Away';
};
export type Relationship = {
  id: string; name: string; role: string; team?: string; trust: number; respect: number; friendship: number; loyalty: number;
  rivalry: number; resentment: number; influence: number; closeness: number; status: string; memories: string[];
};
export type SocialPost = { id: string; date: string; author: string; handle: string; body: string; likes: number; reposts: number; replies: number; kind: string; canon: Canon; likedByUser?: boolean };
export type NewsItem = { id: string; date: string; outlet: string; headline: string; body: string; importance: string; canon: Canon };
export type EventChoice = { label: string; outcome: string; effects: Record<string, number> };
export type DynamicEvent = { id: string; date: string; title: string; body: string; category: string; importance: string; choices: EventChoice[]; resolved?: string };
export type Sponsor = { id: string; brand: string; category: string; status: 'Offer'|'Active'|'Declined'|'Expired'; years: number; value: number; bonus: number; obligations: string; interest: number; relationship: number; objective: string; progress: number; target: number };
export type Storyline = { id: string; title: string; arcType: string; status: 'Active'|'Resolved'; heat: number; summary: string; participants: string[]; started: string };
export type HistoryItem = { id: string; date: string; title: string; body: string; category: string; importance: string; canon: Canon };
export type NotificationItem = { id: string; date: string; icon: string; title: string; body: string; read: boolean };
export type FinanceItem = { id: string; date: string; kind: string; description: string; amount: number; balanceAfter: number };
export type Transaction = { id: string; date: string; type: string; player: string; fromTeam: string; toTeam: string; canon: Canon; details?: string };
export type WorldPlayer = { id: string; name: string; team: string; position: string; age: number; overall: number; potential: number; personality: string; reputation: string; history: string[] };
export type Prospect = {
  id: string; name: string; position: string; age: number; overall: number; potential: number; projection: string;
  personality: string; background: string; status: string; height?: string; weight?: number; school?: string;
  rank?: number; draftYear?: number; source?: 'Companion'|'2K Scan'|'Manual';
};
export type ScheduleGame = {
  id: string;
  era: MyNBAEra;
  date: string;
  awayTeam: string;
  homeTeam: string;
  source: 'NBA 2025-26'|'2K Schedule Scan'|'Manual';
  canon: 'League Baseline'|'2K Confirmed'|'User Confirmed';
};
export type PhoneContactRole = 'NBA Player'|'Coach'|'Scout'|'Agent'|'Family'|'Friend'|'Trainer'|'Executive'|'Media';
export type PhoneContact = {
  id: string;
  name: string;
  role: PhoneContactRole;
  team?: string;
  relationshipId?: string;
  favorite?: boolean;
  verified?: boolean;
};
export type PhoneMessage = {
  id: string;
  contactId: string;
  date: string;
  body: string;
  direction: 'Incoming'|'Outgoing';
  read: boolean;
  kind: 'Career'|'Check-in'|'Reply'|'System';
  relatedGameId?: string;
  relatedScheduleGameId?: string;
};
export type Milestone = { id: string; name: string; achieved: boolean; date?: string };
export type ScreenScanRecord = {
  id: string;
  date: string;
  target: 'Player Overview'|'Game Stats'|'Attributes'|'Badges'|'Transactions'|'Draft Class'|'Schedule';
  recognized: number;
  summary: string;
};

export type CareerState = {
  version: number;
  player: {
    name: string; position: string; age: number; height: string; weight: number; hometown: string; nationality: string; dominantHand: 'Right'|'Left'; highSchoolYear: string; stage: Stage; route: string;
    schoolOrClub: string; team: string; jersey: number; overall: number; potential: number; seasonYear: number; currentDate: string;
    phase: string; xp: number; money: number; careerEarnings: number; followers: number; marketability: number; morale: number;
    fatigue: number; legacy: number; agentName: string; agentTrust: number; draftProjection: string; draftDeclared: boolean;
    draftPick?: number; role: string; reputation: string[]; traits: string[];
  };
  settings: {
    immersionMode: ImmersionMode; simDetail: SimDetail; romanceEnabled: boolean; autosave: boolean; onboardingComplete: boolean;
    myNBAEra: MyNBAEra; myNBASeasonStart: number;
  };
  attributes: Attribute[];
  badges: Badge[];
  games: Game[];
  relationships: Relationship[];
  social: SocialPost[];
  news: NewsItem[];
  events: DynamicEvent[];
  sponsors: Sponsor[];
  storylines: Storyline[];
  history: HistoryItem[];
  notifications: NotificationItem[];
  finances: FinanceItem[];
  transactions: Transaction[];
  worldPlayers: WorldPlayer[];
  prospects: Prospect[];
  scheduleGames: ScheduleGame[];
  phoneContacts: PhoneContact[];
  phoneMessages: PhoneMessage[];
  milestones: Milestone[];
  screenScans: ScreenScanRecord[];
};
