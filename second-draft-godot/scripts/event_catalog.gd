extends RefCounted
class_name EventCatalog


static func milestone_for_age(age: int, state: Dictionary) -> Dictionary:
	match age:
		5:
			return _event(
				"first_school_day", "The First Bell",
				"The classroom smells like crayons and new books. Your teacher asks everyone to introduce themselves.",
				[
					_choice("Tell a funny story", "The whole class laughs. You feel like you belong.", {"happiness": 7, "confidence": 6, "friends": 5}),
					_choice("Say your name quietly", "You make it through, then find a friendly face at recess.", {"smarts": 2, "confidence": -1, "friends": 2}),
					_choice("Ask the teacher a question", "Your curiosity makes a strong first impression.", {"smarts": 6, "discipline": 4})
				]
			)
		12:
			return _event(
				"middle_school", "A Bigger World",
				"You start secondary school. There are new hallways, new expectations, and hundreds of possible versions of you.",
				[
					_choice("Join a sports club", "Practice gives you energy and a new circle of friends.", {"health": 7, "confidence": 5, "friends": 5}),
					_choice("Join the tech club", "You discover how satisfying it is to build something that works.", {"smarts": 8, "discipline": 4}),
					_choice("Keep a low profile", "You observe everything before deciding where you fit.", {"smarts": 3, "happiness": -2})
				]
			)
		16:
			return _event(
				"drivers_test", "The Road Test",
				"A driving examiner waits in the passenger seat with a clipboard and an unreadable expression.",
				[
					_choice("Drive carefully", "You pass with only one note about checking your mirrors.", {"discipline": 5, "confidence": 5, "set_flag": {"drivers_license": true}}),
					_choice("Try to impress them", "A sharp turn earns an instant failure. At least nobody was hurt.", {"confidence": -6, "happiness": -4}),
					_choice("Take more lessons first", "You postpone the test and become a calmer driver.", {"money": -280, "discipline": 7})
				]
			)
		18:
			return _event(
				"after_graduation", "The Next Chapter",
				"High school is over. Everyone keeps asking what you are going to do with the rest of your life.",
				[
					_choice("Attend university", "You enroll in a four-year degree and take on tuition costs.", {"education_path": "university", "money": -5000, "smarts": 7}),
					_choice("Learn a skilled trade", "You begin paid training as an apprentice.", {"education_path": "trade", "set_job": "apprentice_electrician", "discipline": 7}),
					_choice("Start working now", "You enter the workforce and begin building experience.", {"education_path": "work", "set_job": "retail_associate", "money": 700, "confidence": 3}),
					_choice("Take a gap year", "You choose time and uncertainty over rushing into the wrong path.", {"education_path": "gap", "happiness": 8, "money": -1200})
				]
			)
		30:
			return _event(
				"thirty_reflection", "Thirty",
				"A round number makes you look back at the promises you once made to yourself.",
				[
					_choice("Set an ambitious goal", "You write it down and build a plan around it.", {"discipline": 8, "confidence": 5}),
					_choice("Celebrate what you have", "Gratitude makes the present feel larger.", {"happiness": 10, "family": 4, "friends": 4}),
					_choice("Change direction", "You decide that starting again is allowed.", {"happiness": 4, "confidence": 7, "money": -900})
				]
			)
		65:
			return _event(
				"retirement_choice", "A Different Pace",
				"You are eligible to retire. The thought feels equal parts freeing and strange.",
				[
					_choice("Retire", "You close the work chapter and make room for slower mornings.", {"retire": true, "happiness": 10, "health": 3}),
					_choice("Keep working", "Purpose matters more to you than the calendar.", {"discipline": 6, "happiness": -2, "reputation": 5}),
					_choice("Work part-time", "You choose a balance of purpose and freedom.", {"part_time": true, "happiness": 6, "health": 2})
				]
	return {}


static func events() -> Array:
	return [
		{
			"id": "playground_dare", "title": "The Tall Slide", "body": "A group of kids dares you to go down the tallest slide backward.",
			"min_age": 5, "max_age": 10, "weight": 5,
			"choices": [
				_choice("Do it", "You land in the sand laughing, with only a bruised elbow.", {"confidence": 6, "health": -3, "friends": 4}),
				_choice("Suggest a race instead", "The race becomes the best game of recess.", {"health": 3, "smarts": 2, "friends": 5}),
				_choice("Walk away", "The dare fades, but you wonder what would have happened.", {"discipline": 3, "happiness": -2})
			]
		},
		{
			"id": "science_fair", "title": "Science Fair", "body": "Your class announces a science fair. You have three weeks to make something memorable.",
			"min_age": 7, "max_age": 17, "weight": 5,
			"choices": [
				_choice("Build a water filter", "Your working prototype wins a blue ribbon.", {"smarts": 9, "discipline": 6, "reputation": 3}),
				_choice("Make a volcano overnight", "It erupts all over the judging table, which is at least memorable.", {"happiness": 4, "smarts": 2}),
				_choice("Skip it", "You spend the week gaming and accept the missing grade.", {"happiness": 3, "smarts": -4, "discipline": -5})
			]
		},
		{
			"id": "lost_dog", "title": "A Dog in the Rain", "body": "You spot a soaked dog wandering alone with a faded collar.",
			"min_age": 6, "max_age": 90, "weight": 4,
			"choices": [
				_choice("Find the owner", "After an hour of knocking on doors, a relieved family answers.", {"happiness": 8, "reputation": 6, "discipline": 3}),
				_choice("Bring it home", "The owner is found later, but the dog becomes your friend for a day.", {"happiness": 7, "family": 2}),
				_choice("Call animal services", "Professionals take over and scan the collar.", {"discipline": 4, "reputation": 2})
			]
		},
		{
			"id": "family_trip", "title": "Long Way Around", "body": "Your family plans a road trip through the mountains, but everyone disagrees about the route.",
			"min_age": 4, "max_age": 17, "weight": 4,
			"choices": [
				_choice("Choose the scenic road", "The trip takes longer, but the lake views are unforgettable.", {"happiness": 9, "family": 6}),
				_choice("Navigate the fastest route", "You arrive early and earn the title of family navigator.", {"smarts": 4, "family": 3}),
				_choice("Put on headphones", "The argument becomes background noise.", {"happiness": 1, "family": -4})
			]
		},
		{
			"id": "school_bully", "title": "The Hallway", "body": "A bigger student keeps knocking books from a classmate's hands.",
			"min_age": 8, "max_age": 17, "weight": 5,
			"choices": [
				_choice("Stand beside the classmate", "The bully backs down when they realize someone is watching.", {"confidence": 8, "reputation": 5, "friends": 6}),
				_choice("Tell a teacher", "The school intervenes quietly and the harassment stops.", {"discipline": 5, "reputation": 2}),
				_choice("Ignore it", "You avoid trouble, but the moment follows you home.", {"happiness": -6, "reputation": -3})
			]
		},
		{
			"id": "snow_day", "title": "Snow Day", "body": "School closes after an overnight storm blankets the streets.",
			"min_age": 5, "max_age": 17, "weight": 5,
			"choices": [
				_choice("Build a snow fort", "By sunset, your crew has built a frozen castle.", {"health": 4, "happiness": 8, "friends": 4}),
				_choice("Catch up on homework", "You finish everything before lunch and feel unusually prepared.", {"smarts": 5, "discipline": 7}),
				_choice("Sleep all day", "You wake up at dinner, refreshed and slightly confused.", {"health": 2, "happiness": 4, "discipline": -2})
			]
		},
		{
			"id": "school_team", "title": "Final Roster", "body": "Tryouts are crowded. One final spot remains on the school team.",
			"min_age": 10, "max_age": 18, "weight": 4,
			"choices": [
				_choice("Give everything", "Your effort earns the final spot.", {"health": 7, "discipline": 6, "confidence": 7}),
				_choice("Play it safe", "You perform well, but another player takes the spot.", {"health": 3, "confidence": -3}),
				_choice("Cheer for a friend", "You do not make the team, but your friendship grows.", {"friends": 7, "happiness": 3})
			]
		},
		{
			"id": "exam_week", "title": "Exam Week", "body": "Four exams land in the same week. Your notes are incomplete and sleep is tempting.",
			"min_age": 13, "max_age": 25, "weight": 6,
			"choices": [
				_choice("Follow a study plan", "Steady preparation pays off with strong grades.", {"smarts": 8, "discipline": 8, "happiness": -2}),
				_choice("Cram overnight", "You scrape through and forget half of it by morning.", {"smarts": 3, "health": -5, "discipline": -2}),
				_choice("Trust your instincts", "Your instincts are less educated than you hoped.", {"smarts": -3, "happiness": -4})
			]
		},
		{
			"id": "house_party", "title": "The Party", "body": "A classmate invites you to a crowded party while their parents are away.",
			"min_age": 15, "max_age": 20, "weight": 5,
			"choices": [
				_choice("Go and leave early", "You have fun and make it home before the chaos.", {"happiness": 7, "friends": 5, "discipline": 2}),
				_choice("Stay all night", "The stories are legendary; the next morning is not.", {"happiness": 8, "health": -7, "discipline": -5, "reputation": -2}),
				_choice("Stay home", "You enjoy a quiet night and avoid the neighborhood drama.", {"health": 2, "discipline": 4, "friends": -2})
			]
		},
		{
			"id": "first_crush", "title": "A Note in Your Locker", "body": "Someone leaves a handwritten note asking if you want to get coffee after school.",
			"min_age": 14, "max_age": 21, "weight": 4, "requires_single": true,
			"choices": [
				_choice("Say yes", "Coffee turns into a long walk and the start of something new.", {"set_partner": true, "happiness": 10, "confidence": 5}),
				_choice("Suggest being friends", "They appreciate your honesty and stay in your circle.", {"friends": 5, "reputation": 3}),
				_choice("Pretend you never saw it", "The note disappears, but the awkwardness remains.", {"confidence": -4, "happiness": -3})
			]
		},
		{
			"id": "viral_post", "title": "Unexpected Attention", "body": "A short video you posted begins spreading far beyond your friends.",
			"min_age": 14, "max_age": 55, "weight": 3,
			"choices": [
				_choice("Enjoy the moment", "You lean into the joke and gain a small following.", {"confidence": 5, "reputation": 7, "happiness": 6}),
				_choice("Delete it", "The attention fades before it becomes overwhelming.", {"discipline": 4, "happiness": 2}),
				_choice("Turn it into a brand", "A local sponsor pays for a follow-up post.", {"money": 600, "reputation": 5, "discipline": -2})
			]
		},
		{
			"id": "volunteer_day", "title": "Community Day", "body": "A neighborhood group needs volunteers to restore a lakeside trail.",
			"min_age": 13, "max_age": 90, "weight": 5,
			"choices": [
				_choice("Work the full day", "You end the day muddy, tired, and proud of the finished trail.", {"health": 4, "happiness": 6, "reputation": 7}),
				_choice("Bring supplies", "Your donation keeps the whole crew fed and hydrated.", {"money": -120, "reputation": 5}),
				_choice("Share the fundraiser", "Your post brings in new volunteers.", {"reputation": 3, "friends": 2})
			]
		},
		{
			"id": "found_wallet", "title": "The Wallet", "body": "A wallet lies beneath a bus stop bench. It contains identification and several hundred dollars.",
			"min_age": 12, "max_age": 90, "weight": 5,
			"choices": [
				_choice("Return everything", "The owner is stunned and insists you accept a small reward.", {"money": 80, "reputation": 8, "happiness": 4}),
				_choice("Keep the cash", "You mail back the wallet, but the decision weighs on you.", {"money": 420, "reputation": -8, "happiness": -3}),
				_choice("Hand it to transit staff", "It goes into the lost-and-found system.", {"discipline": 4, "reputation": 3})
			]
		},
		{
			"id": "roommate_offer", "title": "A Place Downtown", "body": "A friend offers you a room in a lively downtown apartment.",
			"min_age": 18, "max_age": 32, "weight": 4,
			"choices": [
				_choice("Move in", "The rent stretches your budget, but independence feels incredible.", {"money": -1800, "happiness": 8, "friends": 5, "set_flag": {"moved_out": true}}),
				_choice("Negotiate the rent", "You take the smaller room for a manageable price.", {"money": -900, "smarts": 3, "confidence": 4, "set_flag": {"moved_out": true}}),
				_choice("Stay where you are", "You keep saving and promise to revisit the idea later.", {"money": 500, "family": 2})
			]
		},
		{
			"id": "job_interview", "title": "The Interview", "body": "An interviewer asks you to describe a failure and what it taught you.",
			"min_age": 18, "max_age": 70, "weight": 5,
			"choices": [
				_choice("Answer honestly", "Your self-awareness makes a strong impression.", {"confidence": 5, "reputation": 4, "money": 300}),
				_choice("Tell a polished story", "The answer sounds perfect, perhaps too perfect.", {"confidence": 3, "smarts": 3}),
				_choice("Make a joke", "The joke lands, and the room finally relaxes.", {"happiness": 4, "confidence": 6})
			]
		},
		{
			"id": "workplace_credit", "title": "Who Gets the Credit?", "body": "A coworker presents your idea to management as if it were their own.",
			"min_age": 18, "max_age": 70, "weight": 5, "requires_job": true,
			"choices": [
				_choice("Speak to the manager", "You calmly show your notes and receive proper credit.", {"confidence": 7, "reputation": 5, "job_progress": 8}),
				_choice("Confront the coworker", "They apologize, but the working relationship stays tense.", {"confidence": 5, "happiness": -3, "reputation": -1}),
				_choice("Let it go", "The project succeeds, though your resentment quietly grows.", {"happiness": -7, "discipline": 2})
			]
		},
		{
			"id": "overtime_request", "title": "One More Weekend", "body": "Your manager asks you to rescue a project by working through the weekend.",
			"min_age": 18, "max_age": 69, "weight": 5, "requires_job": true,
			"choices": [
				_choice("Take the overtime", "The launch succeeds and the extra pay helps.", {"money": 900, "health": -4, "job_progress": 9, "discipline": 4}),
				_choice("Offer a smaller commitment", "You solve the hardest part without losing the whole weekend.", {"money": 350, "job_progress": 5, "happiness": 2}),
				_choice("Decline", "You protect your time, though your manager is disappointed.", {"health": 3, "happiness": 5, "job_progress": -4})
			]
		},
		{
			"id": "professional_course", "title": "Night Class", "body": "A respected certification course opens nearby, but it will consume evenings for months.",
			"min_age": 19, "max_age": 60, "weight": 4,
			"choices": [
				_choice("Enroll", "You finish the course with a stronger resume and new skills.", {"money": -1400, "smarts": 7, "discipline": 7, "job_progress": 6}),
				_choice("Ask work to pay", "Your employer covers half and expects you to share what you learn.", {"money": -700, "smarts": 6, "job_progress": 8}),
				_choice("Pass this time", "Your evenings remain yours.", {"happiness": 3})
			]
		},
		{
			"id": "side_project", "title": "A Small Idea", "body": "A simple side-project idea keeps returning whenever you try to sleep.",
			"min_age": 18, "max_age": 65, "weight": 5,
			"choices": [
				_choice("Build a prototype", "A few strangers pay for the first version.", {"money": 1100, "smarts": 6, "discipline": 5, "health": -2}),
				_choice("Write a business plan", "The numbers reveal both a path and several risks.", {"smarts": 7, "confidence": 3}),
				_choice("Let it remain an idea", "You finally get a full night's sleep.", {"health": 3, "happiness": 2})
			]
		},
		{
			"id": "unexpected_bill", "title": "The Expensive Noise", "body": "A grinding noise turns into an urgent repair bill.",
			"min_age": 18, "max_age": 90, "weight": 5,
			"choices": [
				_choice("Pay for a proper repair", "The problem is fixed and comes with a warranty.", {"money": -1200, "discipline": 3}),
				_choice("Find a cheaper fix", "It works for now, though you do not trust the new rattle.", {"money": -450, "smarts": 2, "happiness": -2}),
				_choice("Ignore it", "The repair becomes much more expensive by winter.", {"money": -2100, "happiness": -6})
			]
		},
		{
			"id": "market_dip", "title": "Red Numbers", "body": "Markets fall sharply and every headline predicts something different.",
			"min_age": 20, "max_age": 75, "weight": 3, "requires_balance": 2500,
			"choices": [
				_choice("Stay invested", "Patience protects you from selling at the worst moment.", {"money": 350, "discipline": 6, "smarts": 3}),
				_choice("Sell everything", "You lock in a loss but regain a sense of control.", {"money": -900, "happiness": 2, "confidence": -2}),
				_choice("Buy more", "The recovery rewards your nerve.", {"money": 1400, "confidence": 6, "health": -2})
			]
		},
		{
			"id": "friend_emergency", "title": "2:13 A.M.", "body": "A close friend calls late at night and says they need somewhere safe to stay.",
			"min_age": 18, "max_age": 80, "weight": 4,
			"choices": [
				_choice("Go get them", "You show up without questions. They never forget it.", {"friends": 10, "health": -2, "reputation": 4}),
				_choice("Pay for a hotel", "You help from a distance and make sure they are safe.", {"money": -240, "friends": 7}),
				_choice("Say you cannot help", "The friendship cools after that night.", {"friends": -10, "happiness": -4})
			]
		},
		{
			"id": "blind_date", "title": "Table for Two", "body": "A friend insists they know someone you absolutely have to meet.",
			"min_age": 18, "max_age": 60, "weight": 4, "requires_single": true,
			"choices": [
				_choice("Go with an open mind", "Conversation flows, and neither of you notices the restaurant closing.", {"set_partner": true, "happiness": 10, "confidence": 4}),
				_choice("Treat it as practice", "There is no spark, but you leave more confident.", {"confidence": 6, "friends": 2}),
				_choice("Cancel", "Your friend is disappointed but eventually drops the subject.", {"friends": -3, "happiness": 1})
			]
		},
		{
			"id": "partner_argument", "title": "The Unfinished Argument", "body": "A small disagreement with your partner grows into a much larger one about feeling unheard.",
			"min_age": 18, "max_age": 85, "weight": 5, "requires_partner": true,
			"choices": [
				_choice("Listen without defending", "The argument softens into an honest conversation.", {"partner": 9, "smarts": 3, "confidence": 2}),
				_choice("Take a walk first", "Space helps both of you return calmer.", {"partner": 5, "health": 2}),
				_choice("Try to win", "You prove your point and damage the thing that mattered more.", {"partner": -12, "happiness": -8, "reputation": -2})
			]
		},
		{
			"id": "anniversary", "title": "A Date Worth Remembering", "body": "Your anniversary is approaching and your partner has been dropping subtle hints.",
			"min_age": 20, "max_age": 85, "weight": 3, "requires_partner": true,
			"choices": [
				_choice("Plan a surprise trip", "Every detail lands perfectly, including the one that goes hilariously wrong.", {"money": -1400, "partner": 12, "happiness": 9}),
				_choice("Cook a favorite meal", "The evening feels thoughtful, warm, and entirely yours.", {"money": -90, "partner": 9, "happiness": 6}),
				_choice("Forget", "The date passes in a silence louder than any argument.", {"partner": -15, "happiness": -7})
			]
		},
		{
			"id": "start_family", "title": "Room for One More", "body": "Your partner asks whether the two of you should build a family together.",
			"min_age": 24, "max_age": 44, "weight": 3, "requires_partner": true, "max_children": 2,
			"choices": [
				_choice("Yes", "Months later, your world expands in one tiny, noisy instant.", {"new_child": true, "partner": 8, "happiness": 12, "money": -3500}),
				_choice("Not yet", "You agree to revisit the conversation after building more stability.", {"partner": 2, "discipline": 4}),
				_choice("No", "The honesty hurts, but it prevents a promise you cannot keep.", {"partner": -8, "confidence": 3})
			]
		},
		{
			"id": "health_check", "title": "The Checkup", "body": "A routine checkup shows your blood pressure has been climbing.",
			"min_age": 28, "max_age": 90, "weight": 5,
			"choices": [
				_choice("Change your routine", "Daily walks and better meals make a measurable difference.", {"health": 10, "discipline": 7, "happiness": 2}),
				_choice("Take medication", "The prescription helps, though it adds a monthly cost.", {"health": 7, "money": -420}),
				_choice("Ignore the warning", "The number keeps climbing, and so does your worry.", {"health": -10, "happiness": -6})
			]
		},
		{
			"id": "burnout", "title": "Running on Empty", "body": "You reread the same email three times and still cannot remember what it said.",
			"min_age": 22, "max_age": 65, "weight": 5, "requires_job": true,
			"choices": [
				_choice("Take a real vacation", "A week away restores more than you expected.", {"money": -900, "health": 9, "happiness": 10, "job_progress": -2}),
				_choice("Set boundaries", "You stop answering messages after dinner.", {"health": 6, "discipline": 5, "job_progress": 2}),
				_choice("Push through", "The work gets done, but your body keeps the score.", {"money": 500, "health": -12, "happiness": -9, "job_progress": 6})
			]
		},
		{
			"id": "promotion_offer", "title": "The Corner Office", "body": "You are offered a promotion with better pay, more pressure, and a team depending on you.",
			"min_age": 24, "max_age": 65, "weight": 4, "requires_job": true,
			"choices": [
				_choice("Accept", "The title is new; the expectations are immediate.", {"promotion": true, "confidence": 7, "reputation": 5, "health": -3}),
				_choice("Negotiate first", "You secure a stronger salary and clear priorities.", {"promotion": true, "money": 1200, "smarts": 4, "confidence": 6}),
				_choice("Decline", "You keep your balance and earn respect for knowing what you want.", {"health": 4, "happiness": 5, "reputation": 2})
			]
		},
		{
			"id": "layoff", "title": "The Meeting Invite", "body": "A surprise company-wide meeting confirms months of rumors: your role is being eliminated.",
			"min_age": 20, "max_age": 64, "weight": 2, "requires_job": true,
			"choices": [
				_choice("Ask for references", "You leave with a severance cheque and several warm introductions.", {"lose_job": true, "money": 3500, "reputation": 4, "confidence": -2}),
				_choice("Take time to recover", "Rest steadies you before the next search begins.", {"lose_job": true, "health": 5, "happiness": 2, "money": -600}),
				_choice("Start freelancing", "The first months are uneven, but your independence grows.", {"set_job": "freelancer", "money": 800, "confidence": 6, "discipline": 5})
			]
		},
		{
			"id": "home_opportunity", "title": "A Small House", "body": "A modest home comes onto the market below the usual neighborhood price.",
			"min_age": 25, "max_age": 70, "weight": 3, "requires_balance": 18000, "missing_asset": "starter_home",
			"choices": [
				_choice("Make an offer", "Your offer is accepted. The keys feel heavier than expected.", {"money": -18000, "add_asset": "starter_home", "happiness": 10, "reputation": 3}),
				_choice("Inspect it first", "The inspection uncovers costly foundation work. You walk away wiser.", {"money": -450, "smarts": 7, "discipline": 4}),
				_choice("Keep renting", "You preserve flexibility and keep building your savings.", {"money": 350, "discipline": 3})
			]
		},
		{
			"id": "storm_damage", "title": "After the Storm", "body": "A violent storm tears through the neighborhood and damages several homes.",
			"min_age": 20, "max_age": 90, "weight": 3,
			"choices": [
				_choice("Help the neighbors", "The cleanup takes days, but nobody faces it alone.", {"health": -3, "reputation": 9, "happiness": 5}),
				_choice("Donate to relief", "Your contribution buys materials for emergency repairs.", {"money": -600, "reputation": 6}),
				_choice("Focus on your own place", "You protect what is yours and avoid further damage.", {"money": -250, "discipline": 4})
			]
		},
		{
			"id": "old_friend", "title": "An Old Name", "body": "A message arrives from someone you once considered your closest friend.",
			"min_age": 30, "max_age": 80, "weight": 4,
			"choices": [
				_choice("Meet for coffee", "The years disappear faster than either of you expected.", {"friends": 9, "happiness": 8}),
				_choice("Write a thoughtful reply", "You reconnect slowly and without pressure.", {"friends": 5, "happiness": 4}),
				_choice("Leave it unread", "The message sinks beneath newer notifications.", {"friends": -4, "happiness": -2})
			]
		},
		{
			"id": "care_for_parent", "title": "Roles Reversed", "body": "A parent needs more help with appointments, errands, and everyday tasks.",
			"min_age": 38, "max_age": 68, "weight": 4,
			"choices": [
				_choice("Make time every week", "The schedule is difficult, but the conversations become precious.", {"family": 12, "health": -3, "happiness": 4}),
				_choice("Hire some support", "Professional help keeps them safe and gives everyone breathing room.", {"money": -1800, "family": 7, "discipline": 5}),
				_choice("Ask others to handle it", "The practical problem is solved, but distance grows.", {"family": -8, "happiness": -3})
			]
		},
		{
			"id": "career_change", "title": "The Sunday Feeling", "body": "Every Sunday night now arrives with the same heavy feeling about work.",
			"min_age": 30, "max_age": 58, "weight": 4, "requires_job": true,
			"choices": [
				_choice("Retrain for something new", "The transition costs money and restores your curiosity.", {"money": -3000, "smarts": 8, "happiness": 9, "lose_job": true}),
				_choice("Improve the current role", "A candid conversation changes your responsibilities for the better.", {"confidence": 5, "job_progress": 7, "happiness": 4}),
				_choice("Stay for the security", "The pay continues, as does the Sunday feeling.", {"money": 1000, "happiness": -8, "discipline": 3})
			]
		},
		{
			"id": "community_election", "title": "Your Name on a Ballot", "body": "Neighbors ask you to run for a seat on the community board.",
			"min_age": 35, "max_age": 75, "weight": 3,
			"choices": [
				_choice("Run a positive campaign", "You win narrowly and begin with broad support.", {"money": -700, "reputation": 12, "confidence": 8}),
				_choice("Help another candidate", "Your organizing work improves the campaign and the friendship.", {"friends": 6, "reputation": 7}),
				_choice("Decline", "You protect your private life and volunteer occasionally instead.", {"health": 2, "reputation": 2})
			]
		},
		{
			"id": "inheritance", "title": "A Letter from the Estate", "body": "A distant relative leaves you a small inheritance and an old handwritten recipe book.",
			"min_age": 35, "max_age": 80, "weight": 2,
			"choices": [
				_choice("Save the money", "You place it into long-term savings and keep the book safe.", {"money": 8500, "discipline": 6, "family": 3}),
				_choice("Take the family on a trip", "The inheritance becomes a collection of shared memories.", {"money": 3500, "family": 10, "happiness": 9}),
				_choice("Donate part of it", "A local program expands because of your contribution.", {"money": 5500, "reputation": 9, "happiness": 5})
			]
		},
		{
			"id": "midlife_hobby", "title": "Beginner Again", "body": "You discover a local class teaching something you have always wanted to learn.",
			"min_age": 40, "max_age": 72, "weight": 5,
			"choices": [
				_choice("Sign up", "Being terrible at something new turns out to be wonderfully freeing.", {"money": -380, "happiness": 10, "smarts": 4, "friends": 3}),
				_choice("Learn online", "You make slow, private progress from the comfort of home.", {"smarts": 5, "discipline": 4}),
				_choice("Maybe next year", "The class fills, and the brochure stays on your desk.", {"happiness": -2})
			]
		},
		{
			"id": "health_scare", "title": "A Sudden Pain", "body": "A sharp pain stops you in the middle of an ordinary afternoon.",
			"min_age": 50, "max_age": 95, "weight": 4,
			"choices": [
				_choice("Go to emergency", "Early treatment prevents a serious complication.", {"money": -650, "health": 3, "discipline": 6}),
				_choice("Call your doctor", "You are seen quickly and given a recovery plan.", {"money": -220, "health": -2, "discipline": 3}),
				_choice("Wait it out", "The delay makes recovery longer and harder.", {"health": -16, "happiness": -8})
			]
		},
		{
			"id": "reunion", "title": "Names from Long Ago", "body": "An invitation arrives for a school reunion in your hometown.",
			"min_age": 45, "max_age": 75, "weight": 3,
			"choices": [
				_choice("Attend", "Old stories improve with age, and so do some friendships.", {"money": -300, "happiness": 8, "friends": 8}),
				_choice("Send a video message", "Your message is warmly received from afar.", {"friends": 4, "reputation": 2}),
				_choice("Skip it", "You spend the evening with the life you chose instead.", {"family": 3, "happiness": 2})
			]
		},
		{
			"id": "mentor_someone", "title": "Pass It On", "body": "A younger person asks whether you would mentor them through a difficult career decision.",
			"min_age": 45, "max_age": 85, "weight": 4,
			"choices": [
				_choice("Meet every month", "Their progress reminds you how much you have learned.", {"reputation": 9, "happiness": 6, "smarts": 3}),
				_choice("Make an introduction", "The right connection opens a door for them.", {"reputation": 6, "friends": 3}),
				_choice("Decline honestly", "You point them toward someone with more time.", {"discipline": 2})
			]
		},
		{
			"id": "write_memoir", "title": "The Blank Page", "body": "Someone suggests that your stories should be written down before details begin to fade.",
			"min_age": 60, "max_age": 100, "weight": 4,
			"choices": [
				_choice("Write every morning", "A year later, your family holds the finished book.", {"discipline": 9, "family": 10, "happiness": 7, "reputation": 4}),
				_choice("Record audio stories", "Your voice becomes part of the family archive.", {"family": 8, "happiness": 5}),
				_choice("Keep stories private", "Some memories remain yours alone.", {"happiness": 2})
			]
		},
		{
			"id": "quiet_morning", "title": "A Quiet Morning", "body": "You wake before everyone else and watch sunlight move slowly across the room.",
			"min_age": 55, "max_age": 110, "weight": 5,
			"choices": [
				_choice("Take a long walk", "The cool air and steady pace leave you clear-headed.", {"health": 5, "happiness": 5}),
				_choice("Call someone you love", "A small conversation becomes the best part of both your days.", {"family": 5, "friends": 3, "happiness": 6}),
				_choice("Sit with the silence", "For once, nothing needs to happen next.", {"health": 2, "happiness": 7, "discipline": 3})
			]
		}
	]


static func jobs() -> Array:
	return [
		{"id": "retail_associate", "title": "Retail Associate", "salary": 29000, "min_age": 16, "education": 0, "stat": "confidence", "minimum": 25},
		{"id": "grocery_clerk", "title": "Grocery Clerk", "salary": 31000, "min_age": 16, "education": 0, "stat": "discipline", "minimum": 25},
		{"id": "apprentice_electrician", "title": "Apprentice Electrician", "salary": 47000, "min_age": 18, "education": 0, "stat": "discipline", "minimum": 45},
		{"id": "office_coordinator", "title": "Office Coordinator", "salary": 41000, "min_age": 18, "education": 1, "stat": "smarts", "minimum": 40},
		{"id": "personal_trainer", "title": "Personal Trainer", "salary": 44000, "min_age": 18, "education": 1, "stat": "health", "minimum": 65},
		{"id": "freelancer", "title": "Independent Freelancer", "salary": 52000, "min_age": 18, "education": 0, "stat": "discipline", "minimum": 55},
		{"id": "web_developer", "title": "Web Developer", "salary": 76000, "min_age": 20, "education": 2, "stat": "smarts", "minimum": 62},
		{"id": "teacher", "title": "Teacher", "salary": 64000, "min_age": 22, "education": 2, "stat": "reputation", "minimum": 50},
		{"id": "registered_nurse", "title": "Registered Nurse", "salary": 79000, "min_age": 22, "education": 2, "stat": "discipline", "minimum": 65},
		{"id": "accountant", "title": "Accountant", "salary": 72000, "min_age": 22, "education": 2, "stat": "smarts", "minimum": 62},
		{"id": "civil_engineer", "title": "Civil Engineer", "salary": 96000, "min_age": 22, "education": 2, "stat": "smarts", "minimum": 72},
		{"id": "product_manager", "title": "Product Manager", "salary": 104000, "min_age": 24, "education": 2, "stat": "confidence", "minimum": 68},
		{"id": "lawyer", "title": "Lawyer", "salary": 118000, "min_age": 25, "education": 3, "stat": "smarts", "minimum": 78},
		{"id": "physician", "title": "Physician", "salary": 164000, "min_age": 28, "education": 3, "stat": "discipline", "minimum": 82}
	]


static func activities() -> Array:
	return [
		{"id": "exercise", "title": "Train at the Gym", "subtitle": "Build health and confidence", "min_age": 12, "cost": 30, "effects": {"health": 6, "confidence": 3, "happiness": 2}},
		{"id": "study", "title": "Study Something New", "subtitle": "Build smarts and discipline", "min_age": 6, "cost": 0, "effects": {"smarts": 6, "discipline": 3, "happiness": -1}},
		{"id": "meditate", "title": "Take a Quiet Hour", "subtitle": "Restore happiness and health", "min_age": 10, "cost": 0, "effects": {"happiness": 6, "health": 2, "discipline": 2}},
		{"id": "socialize", "title": "Spend Time with Friends", "subtitle": "Strengthen your social circle", "min_age": 5, "cost": 70, "effects": {"happiness": 6, "friends": 7, "confidence": 2}},
		{"id": "doctor", "title": "Visit the Doctor", "subtitle": "Get a proper health check", "min_age": 0, "cost": 180, "effects": {"health": 9, "happiness": 1}},
		{"id": "volunteer", "title": "Volunteer Locally", "subtitle": "Help others and build reputation", "min_age": 13, "cost": 0, "effects": {"reputation": 7, "happiness": 4, "health": 1}},
		{"id": "side_hustle", "title": "Do a Side Hustle", "subtitle": "Trade energy for extra cash", "min_age": 16, "cost": 0, "effects": {"money": 650, "health": -3, "discipline": 3}},
		{"id": "family_day", "title": "Plan a Family Day", "subtitle": "Make time for the people at home", "min_age": 4, "cost": 90, "effects": {"family": 8, "happiness": 5}},
		{"id": "style_refresh", "title": "Refresh Your Style", "subtitle": "A new look and a little confidence", "min_age": 14, "cost": 240, "effects": {"confidence": 6, "happiness": 3, "reputation": 1}}
	]


static func assets() -> Array:
	return [
		{"id": "used_car", "title": "Reliable Used Car", "price": 8500, "yearly_cost": 1600, "min_age": 16, "subtitle": "Independence on four wheels"},
		{"id": "new_car", "title": "New Electric Car", "price": 42000, "yearly_cost": 2100, "min_age": 18, "subtitle": "Quiet, quick, and expensive"},
		{"id": "starter_home", "title": "Starter Home", "price": 65000, "yearly_cost": 7800, "min_age": 21, "subtitle": "Down payment and annual mortgage costs"},
		{"id": "lake_cabin", "title": "Lakeside Cabin", "price": 95000, "yearly_cost": 4600, "min_age": 25, "subtitle": "A peaceful place beyond the city"},
		{"id": "small_business", "title": "Small Local Business", "price": 120000, "yearly_cost": -18000, "min_age": 24, "subtitle": "Risk, responsibility, and annual profit"}
	]


static func find_job(job_id: String) -> Dictionary:
	for job in jobs():
		if str(job.get("id", "")) == job_id:
			return job.duplicate(true)
	return {}


static func find_asset(asset_id: String) -> Dictionary:
	for asset in assets():
		if str(asset.get("id", "")) == asset_id:
			return asset.duplicate(true)
	return {}


static func _event(id_value: String, title: String, body: String, choices: Array) -> Dictionary:
	return {"id": id_value, "title": title, "body": body, "choices": choices}


static func _choice(text: String, result: String, effects: Dictionary) -> Dictionary:
	return {"text": text, "result": result, "effects": effects}

