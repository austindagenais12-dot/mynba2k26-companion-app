extends RefCounted
class_name CareerCatalog

const RANKS := ["Entry", "Experienced", "Senior", "Lead", "Executive"]

static var cached_jobs: Array = []
static var job_index: Dictionary = {}


static func all_jobs() -> Array:
	if cached_jobs.is_empty():
		build_catalog()
	return cached_jobs


static func count() -> int:
	return all_jobs().size()


static func sectors() -> Array:
	var names: Array = []
	for definition in sector_definitions():
		names.append(str(definition.get("sector", "Other")))
	return names


static func find_job(job_id: String) -> Dictionary:
	if cached_jobs.is_empty():
		build_catalog()
	if job_index.has(job_id):
		return cached_jobs[int(job_index[job_id])].duplicate(true)
	return {}


static func filter_jobs(query: String, sector: String = "All sectors", education_limit: int = -1) -> Array:
	var normalized := query.strip_edges().to_lower()
	var results: Array = []
	for job in all_jobs():
		if sector != "All sectors" and str(job.get("sector", "")) != sector:
			continue
		if education_limit >= 0 and int(job.get("education", 0)) > education_limit:
			continue
		if not normalized.is_empty():
			var haystack := "%s %s %s %s" % [job.get("title", ""), job.get("base_title", ""), job.get("sector", ""), job.get("workplace", "")]
			if normalized not in haystack.to_lower():
				continue
		results.append(job)
	return results


static func promote(job: Dictionary) -> Dictionary:
	var promoted := job.duplicate(true)
	var next_level := clampi(int(promoted.get("level", 1)) + 1, 1, RANKS.size())
	promoted["level"] = next_level
	promoted["rank"] = RANKS[next_level - 1]
	promoted["salary"] = int(round(float(promoted.get("salary", 0)) * (1.07 + float(next_level) * 0.015)))
	return promoted


static func education_label(level: int) -> String:
	match level:
		1:
			return "High School Diploma"
		2:
			return "College, Trade, or Bachelor's Credential"
		3:
			return "Master's or Professional Degree"
		4:
			return "Doctorate or Medical Degree"
		_:
			return "No Formal Credential"


static func education_short_label(level: int) -> String:
	match level:
		1: return "High school"
		2: return "Postsecondary"
		3: return "Graduate degree"
		4: return "Doctorate/medical"
		_: return "On-the-job training"


static func education_programs() -> Array:
	return [
		{"id": "college_diploma", "title": "College Diploma", "subtitle": "Practical two-year postsecondary training", "requires": 1, "target": 2, "years": 2, "annual_cost": 6500},
		{"id": "bachelors_degree", "title": "Bachelor's Degree", "subtitle": "A broad four-year university program", "requires": 1, "target": 2, "years": 4, "annual_cost": 9000},
		{"id": "masters_degree", "title": "Master's Degree", "subtitle": "Advanced graduate study and specialization", "requires": 2, "target": 3, "years": 2, "annual_cost": 12000},
		{"id": "professional_degree", "title": "Professional Degree", "subtitle": "Law, pharmacy, therapy, and other regulated paths", "requires": 2, "target": 3, "years": 3, "annual_cost": 15500},
		{"id": "doctorate", "title": "Doctorate", "subtitle": "Original research and the highest academic credential", "requires": 3, "target": 4, "years": 4, "annual_cost": 14000},
		{"id": "medical_degree", "title": "Medical Degree", "subtitle": "A demanding route into medicine and clinical practice", "requires": 2, "target": 4, "years": 6, "annual_cost": 22000}
	]


static func find_program(program_id: String) -> Dictionary:
	for program in education_programs():
		if str(program.get("id", "")) == program_id:
			return program.duplicate(true)
	return {}


static func build_catalog() -> void:
	cached_jobs.clear()
	job_index.clear()
	for definition in sector_definitions():
		var sector_name := str(definition.get("sector", "Other"))
		var stat := str(definition.get("stat", "discipline"))
		var contexts: Array = definition.get("contexts", [])
		var role_number := 0
		for group_data in definition.get("groups", []):
			var education := int(group_data.get("education", 0))
			var base_salary := int(group_data.get("salary", 30000))
			var minimum := int(group_data.get("minimum", 30))
			for role in group_data.get("roles", []):
				for context_number in range(contexts.size()):
					var workplace := str(contexts[context_number])
					var base_title := str(role)
					var id_value := slugify("%s_%s_%s" % [sector_name, base_title, workplace])
					var salary_variation := role_number * 850 + context_number * 375 + int(stable_number(id_value) % 2200)
					var salary := base_salary + salary_variation
					var min_age: int = int([16, 18, 18, 21, 24][clampi(education, 0, 4)])
					var job := {
						"id": id_value,
						"title": "%s — %s" % [base_title, workplace],
						"base_title": base_title,
						"workplace": workplace,
						"sector": sector_name,
						"salary": salary,
						"min_age": min_age,
						"education": education,
						"stat": stat,
						"minimum": clampi(minimum + role_number % 4, 20, 92),
						"level": 1,
						"rank": RANKS[0]
					}
					job_index[id_value] = cached_jobs.size()
					cached_jobs.append(job)
				role_number += 1


static func stable_number(text: String) -> int:
	var value := 7
	for index in range(text.length()):
		value = (value * 31 + text.unicode_at(index)) % 2147483000
	return value


static func slugify(text: String) -> String:
	var value := text.to_lower()
	var output := ""
	var previous_was_separator := false
	for index in range(value.length()):
		var code := value.unicode_at(index)
		var is_letter := (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
		if is_letter:
			output += value.substr(index, 1)
			previous_was_separator = false
		elif not previous_was_separator:
			output += "_"
			previous_was_separator = true
	return output.trim_suffix("_")


static func sector_definitions() -> Array:
	return [
		sector("Healthcare", "discipline", ["Public Hospital", "Community Clinic", "Private Practice", "Rehabilitation Centre", "Long-Term Care", "Remote Health Service", "University Medical Centre", "Specialist Clinic"], [
			group(0, 33000, 30, ["Patient Transporter", "Hospital Housekeeper", "Medical Courier", "Clinic Receptionist"]),
			group(1, 43000, 40, ["Medical Office Assistant", "Pharmacy Assistant", "Sterile Processing Technician", "Emergency Medical Responder"]),
			group(2, 65000, 56, ["Licensed Practical Nurse", "Paramedic", "Dental Hygienist", "Medical Laboratory Technologist"]),
			group(4, 112000, 76, ["Physician", "Dentist", "Pharmacist", "Physician Assistant"])
		]),
		sector("Mental Health & Social Services", "reputation", ["Community Agency", "Youth Centre", "Hospital Program", "Private Practice", "School Board", "Crisis Service", "Correctional Program", "Family Resource Centre"], [
			group(0, 32000, 32, ["Peer Support Worker", "Shelter Worker", "Outreach Assistant", "Residential Support Worker"]),
			group(1, 41000, 42, ["Addictions Support Worker", "Youth Worker", "Community Service Worker", "Disability Support Worker"]),
			group(2, 60000, 55, ["Social Worker", "Behavioural Therapist", "Case Manager", "Rehabilitation Counsellor"]),
			group(3, 85000, 70, ["Clinical Psychologist", "Psychotherapist", "Mental Health Program Director", "Marriage and Family Therapist"])
		]),
		sector("Education", "smarts", ["Public School", "Independent School", "College", "University", "Adult Learning Centre", "Online Academy", "Special Education Program", "Community Education Office"], [
			group(0, 30000, 30, ["School Custodian", "Lunchroom Supervisor", "Crossing Guard", "Classroom Helper"]),
			group(1, 40000, 42, ["Education Assistant", "Early Childhood Educator", "School Secretary", "Library Technician"]),
			group(2, 62000, 58, ["Elementary Teacher", "Secondary Teacher", "Academic Advisor", "Instructional Designer"]),
			group(3, 88000, 72, ["School Principal", "University Professor", "Curriculum Specialist", "Education Researcher"])
		]),
		sector("Science & Research", "smarts", ["University Laboratory", "Government Institute", "Biotechnology Company", "Field Research Station", "Museum Laboratory", "Clinical Research Centre", "Environmental Institute", "Private Research Firm"], [
			group(0, 35000, 38, ["Laboratory Attendant", "Field Survey Assistant", "Specimen Processor", "Research Participant Coordinator"]),
			group(1, 48000, 48, ["Laboratory Technician", "Research Assistant", "Quality Control Technician", "Field Sampling Technician"]),
			group(2, 72000, 64, ["Biologist", "Chemist", "Physicist", "Geologist"]),
			group(4, 105000, 78, ["Research Scientist", "Epidemiologist", "Principal Investigator", "Research Director"])
		]),
		sector("Engineering", "smarts", ["Consulting Firm", "Municipal Project", "Manufacturing Plant", "Technology Company", "Infrastructure Contractor", "Research Facility", "Mining Operation", "Energy Project"], [
			group(0, 39000, 38, ["Engineering Shop Assistant", "Survey Crew Helper", "Materials Runner", "Drafting Assistant"]),
			group(1, 55000, 50, ["Engineering Technologist", "CAD Technician", "Survey Technician", "Quality Assurance Technician"]),
			group(2, 82000, 66, ["Civil Engineer", "Mechanical Engineer", "Electrical Engineer", "Chemical Engineer"]),
			group(3, 111000, 78, ["Aerospace Engineer", "Biomedical Engineer", "Structural Engineer", "Engineering Project Director"])
		]),
		sector("Software & IT", "smarts", ["Software Studio", "Cloud Company", "Technology Consultancy", "Government IT Office", "Hospital IT Department", "Financial Technology Firm", "Game Studio", "Remote Product Team"], [
			group(0, 36000, 36, ["IT Support Trainee", "Computer Repair Assistant", "Data Entry Clerk", "Technology Retail Specialist"]),
			group(1, 52000, 48, ["Help Desk Analyst", "Network Technician", "Systems Support Specialist", "Quality Assurance Tester"]),
			group(2, 80000, 64, ["Software Developer", "Mobile App Developer", "Cloud Engineer", "DevOps Engineer"]),
			group(3, 115000, 78, ["Software Architect", "Engineering Manager", "Chief Technology Officer", "Technical Program Manager"])
		]),
		sector("Data & Artificial Intelligence", "smarts", ["Analytics Consultancy", "Research Laboratory", "Technology Company", "Healthcare Analytics Team", "Financial Institution", "Retail Intelligence Group", "Government Data Office", "AI Product Studio"], [
			group(0, 38000, 40, ["Data Labelling Specialist", "Survey Data Clerk", "Analytics Assistant", "Research Data Collector"]),
			group(1, 56000, 52, ["Business Intelligence Technician", "Database Technician", "Data Quality Analyst", "Reporting Analyst"]),
			group(2, 88000, 68, ["Data Analyst", "Data Engineer", "Machine Learning Engineer", "Business Intelligence Developer"]),
			group(3, 128000, 82, ["Data Scientist", "AI Researcher", "Machine Learning Architect", "Chief Data Officer"])
		]),
		sector("Cybersecurity", "discipline", ["Security Operations Centre", "Bank Security Team", "Government Cyber Unit", "Technology Company", "Defence Contractor", "Healthcare Network", "Cybersecurity Consultancy", "Cloud Security Provider"], [
			group(0, 38000, 40, ["Security Operations Trainee", "Access Control Clerk", "Hardware Inventory Assistant", "Compliance Assistant"]),
			group(1, 59000, 54, ["Security Operations Analyst", "Network Security Technician", "Identity Access Analyst", "Vulnerability Technician"]),
			group(2, 90000, 68, ["Cybersecurity Analyst", "Penetration Tester", "Digital Forensics Examiner", "Cloud Security Engineer"]),
			group(3, 132000, 82, ["Security Architect", "Incident Response Director", "Chief Information Security Officer", "Cyber Risk Consultant"])
		]),
		sector("Business & Management", "confidence", ["National Corporation", "Small Business", "Management Consultancy", "Nonprofit Organization", "Technology Startup", "Manufacturing Company", "Healthcare Organization", "International Enterprise"], [
			group(0, 33000, 34, ["Office Clerk", "Administrative Assistant", "Reception Coordinator", "Records Assistant"]),
			group(1, 48000, 48, ["Office Manager", "Operations Coordinator", "Human Resources Assistant", "Project Coordinator"]),
			group(2, 76000, 62, ["Operations Manager", "Human Resources Manager", "Business Analyst", "Project Manager"]),
			group(3, 118000, 78, ["Management Consultant", "Operations Director", "Chief Operating Officer", "Chief Executive Officer"])
		]),
		sector("Finance & Accounting", "smarts", ["Credit Union", "Chartered Bank", "Accounting Firm", "Investment Company", "Insurance Provider", "Government Finance Office", "Corporate Finance Team", "Wealth Management Firm"], [
			group(0, 34000, 36, ["Bank Teller", "Billing Clerk", "Payroll Assistant", "Accounts Payable Clerk"]),
			group(1, 50000, 48, ["Bookkeeper", "Loan Officer", "Insurance Underwriter", "Tax Preparation Specialist"]),
			group(2, 78000, 64, ["Accountant", "Financial Analyst", "Auditor", "Investment Analyst"]),
			group(3, 124000, 80, ["Actuary", "Portfolio Manager", "Finance Director", "Chief Financial Officer"])
		]),
		sector("Law & Legal Services", "smarts", ["Community Legal Clinic", "Corporate Law Firm", "Government Legal Office", "Courthouse", "Public Defender Office", "Human Rights Organization", "Insurance Legal Team", "Independent Practice"], [
			group(0, 35000, 36, ["Court Clerk", "Legal Receptionist", "File Clerk", "Process Server"]),
			group(1, 52000, 50, ["Paralegal", "Legal Assistant", "Court Reporter", "Law Office Administrator"]),
			group(3, 96000, 72, ["Lawyer", "Mediator", "Crown Prosecutor", "Legal Counsel"]),
			group(4, 142000, 84, ["Judge", "Senior Crown Counsel", "Law Professor", "Chief Legal Officer"])
		]),
		sector("Government & Public Administration", "reputation", ["Municipal Hall", "Provincial Ministry", "Federal Department", "Indigenous Government", "Regulatory Agency", "Public Service Commission", "International Mission", "Regional District"], [
			group(0, 35000, 36, ["Public Service Clerk", "Permit Counter Assistant", "Election Worker", "Records Clerk"]),
			group(1, 50000, 48, ["Program Administrator", "Bylaw Officer", "Immigration Officer", "Government Communications Assistant"]),
			group(2, 76000, 62, ["Policy Analyst", "Urban Planner", "Economic Development Officer", "Public Affairs Advisor"]),
			group(3, 112000, 78, ["City Manager", "Diplomat", "Deputy Minister", "Public Policy Director"])
		]),
		sector("Skilled Trades", "discipline", ["Union Contractor", "Residential Service Company", "Commercial Job Site", "Industrial Plant", "Municipal Works Department", "Remote Resource Camp", "Independent Shop", "Maintenance Company"], [
			group(0, 35000, 36, ["General Labourer", "Shop Helper", "Material Handler", "Maintenance Helper"]),
			group(1, 49000, 48, ["Apprentice Electrician", "Apprentice Plumber", "Apprentice Carpenter", "Apprentice Welder"]),
			group(2, 72000, 62, ["Electrician", "Plumber", "Carpenter", "Welder"]),
			group(2, 88000, 72, ["Industrial Millwright", "Heavy-Duty Mechanic", "Elevator Technician", "Instrumentation Technician"])
		]),
		sector("Construction & Architecture", "discipline", ["Residential Builder", "Commercial Contractor", "Architecture Studio", "Civil Construction Firm", "Municipal Development Office", "Restoration Company", "High-Rise Project", "Green Building Firm"], [
			group(0, 37000, 38, ["Construction Labourer", "Demolition Worker", "Concrete Helper", "Roofing Helper"]),
			group(1, 53000, 50, ["Construction Estimator", "Building Inspector", "Architectural Technologist", "Site Safety Coordinator"]),
			group(2, 80000, 64, ["Construction Manager", "Quantity Surveyor", "Landscape Architect", "Interior Designer"]),
			group(3, 112000, 78, ["Architect", "Urban Design Director", "Senior Project Executive", "Building Science Consultant"])
		]),
		sector("Manufacturing & Industrial", "discipline", ["Food Processing Plant", "Automotive Factory", "Electronics Manufacturer", "Pharmaceutical Plant", "Metal Fabrication Shop", "Packaging Facility", "Aerospace Factory", "Industrial Equipment Company"], [
			group(0, 36000, 36, ["Assembly Worker", "Production Packer", "Machine Helper", "Warehouse Material Handler"]),
			group(1, 51000, 48, ["Machine Operator", "CNC Operator", "Quality Control Inspector", "Production Scheduler"]),
			group(2, 73000, 62, ["Industrial Designer", "Process Technologist", "Supply Chain Analyst", "Plant Maintenance Planner"]),
			group(3, 105000, 76, ["Plant Manager", "Manufacturing Engineer", "Quality Director", "Industrial Operations Director"])
		]),
		sector("Transportation & Logistics", "discipline", ["Courier Company", "Transit Authority", "Freight Carrier", "Distribution Centre", "Railway Company", "Moving Company", "Municipal Fleet", "International Logistics Firm"], [
			group(0, 35000, 34, ["Delivery Driver", "Warehouse Associate", "Mover", "Bicycle Courier"]),
			group(1, 52000, 48, ["Commercial Truck Driver", "Bus Driver", "Train Conductor", "Forklift Operator"]),
			group(2, 72000, 60, ["Logistics Coordinator", "Fleet Manager", "Transportation Planner", "Customs Broker"]),
			group(3, 104000, 75, ["Supply Chain Manager", "Rail Operations Manager", "Distribution Director", "Global Logistics Director"])
		]),
		sector("Aviation & Aerospace", "discipline", ["Regional Airline", "International Airline", "Airport Authority", "Flight School", "Aircraft Manufacturer", "Air Ambulance Service", "Cargo Airline", "Space Technology Company"], [
			group(0, 37000, 38, ["Baggage Handler", "Ramp Agent", "Aircraft Cleaner", "Airport Customer Service Agent"]),
			group(1, 57000, 52, ["Flight Dispatcher", "Aircraft Maintenance Technician", "Air Traffic Services Assistant", "Cabin Crew Member"]),
			group(2, 92000, 68, ["Commercial Pilot", "Air Traffic Controller", "Avionics Technologist", "Aerospace Systems Analyst"]),
			group(3, 138000, 82, ["Airline Captain", "Aerospace Program Manager", "Flight Test Engineer", "Airport Operations Director"])
		]),
		sector("Agriculture & Forestry", "discipline", ["Family Farm", "Organic Farm", "Greenhouse Operation", "Forestry Company", "Agricultural Cooperative", "Vineyard", "Government Agriculture Office", "Food Production Company"], [
			group(0, 32000, 32, ["Farm Worker", "Greenhouse Labourer", "Fruit Picker", "Forestry Labourer"]),
			group(1, 47000, 46, ["Agricultural Equipment Operator", "Nursery Technician", "Irrigation Technician", "Logging Equipment Operator"]),
			group(2, 69000, 60, ["Agronomist", "Forester", "Agricultural Technologist", "Farm Manager"]),
			group(3, 98000, 74, ["Agricultural Scientist", "Forestry Operations Director", "Food Systems Consultant", "Agribusiness Director"])
		]),
		sector("Environment & Conservation", "reputation", ["National Park", "Environmental Consultancy", "Wildlife Foundation", "Municipal Sustainability Office", "Conservation Authority", "Coastal Research Station", "Recycling Organization", "Climate Policy Institute"], [
			group(0, 33000, 34, ["Park Attendant", "Trail Crew Worker", "Recycling Sorter", "Wildlife Rehabilitation Assistant"]),
			group(1, 50000, 48, ["Conservation Technician", "Water Quality Technician", "Environmental Field Technician", "Park Ranger"]),
			group(2, 74000, 62, ["Environmental Scientist", "Wildlife Biologist", "Sustainability Coordinator", "Conservation Officer"]),
			group(3, 106000, 76, ["Climate Policy Advisor", "Environmental Impact Director", "Conservation Program Director", "Ecological Research Lead"])
		]),
		sector("Energy & Utilities", "discipline", ["Hydroelectric Station", "Solar Energy Company", "Wind Farm", "Electric Utility", "Natural Gas Company", "Municipal Water Utility", "Nuclear Facility", "Energy Consulting Firm"], [
			group(0, 39000, 38, ["Utility Labourer", "Meter Reader", "Plant Helper", "Line Crew Assistant"]),
			group(1, 59000, 52, ["Powerline Technician", "Water Treatment Operator", "Power Plant Operator", "Solar Installation Technician"]),
			group(2, 85000, 66, ["Energy Analyst", "Electrical Grid Engineer", "Renewable Energy Specialist", "Utility Operations Manager"]),
			group(3, 124000, 80, ["Nuclear Engineer", "Energy Trading Manager", "Grid Modernization Director", "Chief Sustainability Officer"])
		]),
		sector("Media & Journalism", "confidence", ["Local Newspaper", "National Broadcaster", "Digital Newsroom", "Public Radio Station", "Magazine Publisher", "Independent Media Studio", "Sports Network", "Community News Service"], [
			group(0, 32000, 34, ["Newsroom Assistant", "Production Runner", "Archive Assistant", "Community Correspondent"]),
			group(1, 47000, 48, ["Copy Editor", "Photojournalist", "Broadcast Technician", "Social Media Producer"]),
			group(2, 67000, 62, ["Reporter", "Investigative Journalist", "News Producer", "Documentary Researcher"]),
			group(3, 98000, 76, ["Managing Editor", "News Anchor", "Executive Producer", "Editorial Director"])
		]),
		sector("Arts & Design", "confidence", ["Design Agency", "Independent Studio", "Museum", "Publishing House", "Technology Company", "Advertising Firm", "Public Arts Organization", "Retail Brand"], [
			group(0, 31000, 34, ["Gallery Attendant", "Art Studio Assistant", "Print Shop Assistant", "Framing Technician"]),
			group(1, 47000, 48, ["Graphic Designer", "Illustrator", "Production Artist", "Exhibit Technician"]),
			group(2, 68000, 62, ["User Experience Designer", "Industrial Designer", "Fashion Designer", "Art Director"]),
			group(3, 98000, 76, ["Creative Director", "Design Strategist", "Museum Curator", "Chief Design Officer"])
		]),
		sector("Film & Television", "confidence", ["Film Production", "Television Studio", "Streaming Company", "Documentary Unit", "Animation Studio", "Commercial Production House", "Post-Production Studio", "Independent Production"], [
			group(0, 32000, 34, ["Production Assistant", "Set Runner", "Background Performer", "Craft Services Assistant"]),
			group(1, 50000, 50, ["Camera Operator", "Lighting Technician", "Sound Recordist", "Assistant Editor"]),
			group(2, 76000, 64, ["Film Editor", "Cinematographer", "Screenwriter", "Animation Director"]),
			group(3, 118000, 80, ["Film Director", "Showrunner", "Visual Effects Supervisor", "Executive Producer"])
		]),
		sector("Music & Performing Arts", "confidence", ["Recording Studio", "Theatre Company", "Orchestra", "Touring Production", "Music School", "Festival Organization", "Independent Label", "Live Entertainment Venue"], [
			group(0, 30000, 34, ["Stagehand", "Venue Usher", "Instrument Technician Assistant", "Rehearsal Assistant"]),
			group(1, 46000, 48, ["Audio Technician", "Dance Instructor", "Music Teacher", "Theatre Technician"]),
			group(2, 67000, 62, ["Professional Musician", "Actor", "Choreographer", "Composer"]),
			group(3, 102000, 78, ["Music Producer", "Orchestra Conductor", "Theatre Director", "Touring Creative Director"])
		]),
		sector("Sports & Fitness", "health", ["Community Recreation Centre", "Professional Team", "Private Gym", "University Athletics", "Youth Sports Academy", "Sports Medicine Clinic", "Outdoor Adventure Company", "National Sport Organization"], [
			group(0, 30000, 40, ["Recreation Attendant", "Equipment Room Assistant", "Youth Sports Referee", "Fitness Floor Attendant"]),
			group(1, 45000, 55, ["Personal Trainer", "Group Fitness Instructor", "Lifeguard", "Sports Equipment Technician"]),
			group(2, 69000, 66, ["Athletic Therapist", "Strength and Conditioning Coach", "Sports Analyst", "Recreation Program Manager"]),
			group(3, 108000, 80, ["Professional Coach", "Sports Psychologist", "Athletic Director", "General Manager of Sport Operations"])
		]),
		sector("Hospitality & Tourism", "confidence", ["Downtown Hotel", "Mountain Resort", "Cruise Company", "Conference Centre", "Tour Operator", "Casino Resort", "Luxury Lodge", "Destination Marketing Office"], [
			group(0, 30000, 32, ["Hotel Housekeeper", "Bell Attendant", "Front Desk Clerk", "Tourism Information Clerk"]),
			group(1, 43000, 46, ["Concierge", "Event Coordinator", "Tour Guide", "Guest Services Supervisor"]),
			group(2, 65000, 60, ["Hotel Manager", "Conference Planner", "Travel Consultant", "Revenue Manager"]),
			group(3, 96000, 74, ["Resort Director", "Tourism Development Manager", "Director of Guest Experience", "Hospitality Operations Director"])
		]),
		sector("Food & Culinary", "discipline", ["Neighbourhood Restaurant", "Luxury Hotel", "Hospital Kitchen", "Catering Company", "Bakery", "Food Truck Company", "College Dining Service", "Fine Dining Restaurant"], [
			group(0, 29000, 30, ["Dishwasher", "Kitchen Helper", "Counter Attendant", "Food Delivery Driver"]),
			group(1, 41000, 46, ["Line Cook", "Baker", "Barista", "Butcher"]),
			group(2, 61000, 60, ["Sous Chef", "Pastry Chef", "Restaurant Manager", "Catering Manager"]),
			group(3, 93000, 74, ["Executive Chef", "Food Product Developer", "Culinary Director", "Restaurant Group Director"])
		]),
		sector("Retail & Sales", "confidence", ["Independent Store", "Department Store", "Electronics Retailer", "Automotive Dealership", "Business-to-Business Supplier", "Online Marketplace", "Luxury Boutique", "Wholesale Company"], [
			group(0, 29000, 30, ["Retail Sales Associate", "Cashier", "Stock Clerk", "Merchandise Picker"]),
			group(1, 44000, 46, ["Department Supervisor", "Visual Merchandiser", "Customer Success Representative", "Inside Sales Representative"]),
			group(2, 67000, 60, ["Store Manager", "Account Executive", "Sales Operations Analyst", "Territory Sales Manager"]),
			group(3, 108000, 76, ["Regional Sales Director", "National Account Director", "Vice President of Sales", "Chief Revenue Officer"])
		]),
		sector("Marketing & Communications", "confidence", ["Advertising Agency", "Technology Company", "Nonprofit Organization", "Consumer Brand", "Government Communications Office", "Sports Organization", "Public Relations Firm", "Independent Consultancy"], [
			group(0, 33000, 34, ["Marketing Assistant", "Communications Clerk", "Promotions Representative", "Content Assistant"]),
			group(1, 50000, 48, ["Social Media Coordinator", "Public Relations Coordinator", "Email Marketing Specialist", "Events Marketing Coordinator"]),
			group(2, 74000, 62, ["Marketing Manager", "Brand Strategist", "Communications Advisor", "Market Research Analyst"]),
			group(3, 112000, 78, ["Creative Strategy Director", "Public Relations Director", "Vice President of Marketing", "Chief Marketing Officer"])
		]),
		sector("Real Estate & Property", "confidence", ["Residential Brokerage", "Commercial Brokerage", "Property Management Company", "Municipal Housing Agency", "Construction Developer", "Appraisal Firm", "Retirement Community", "Real Estate Investment Company"], [
			group(0, 33000, 34, ["Leasing Assistant", "Property Maintenance Worker", "Real Estate Office Clerk", "Show Home Attendant"]),
			group(1, 52000, 50, ["Real Estate Agent", "Property Administrator", "Home Inspector", "Mortgage Broker"]),
			group(2, 76000, 62, ["Property Manager", "Real Estate Appraiser", "Commercial Leasing Manager", "Development Analyst"]),
			group(3, 118000, 78, ["Real Estate Developer", "Asset Management Director", "Brokerage Managing Director", "Real Estate Investment Director"])
		]),
		sector("Beauty & Personal Care", "confidence", ["Neighbourhood Salon", "Luxury Spa", "Independent Studio", "Film and Television Set", "Resort Spa", "Medical Aesthetics Clinic", "Fashion Company", "Mobile Service Business"], [
			group(0, 29000, 32, ["Salon Receptionist", "Spa Attendant", "Shampoo Assistant", "Beauty Retail Associate"]),
			group(1, 43000, 48, ["Hairstylist", "Barber", "Esthetician", "Nail Technician"]),
			group(2, 62000, 60, ["Makeup Artist", "Massage Therapist", "Medical Aesthetics Technician", "Salon Manager"]),
			group(3, 90000, 74, ["Creative Makeup Director", "Spa Director", "Beauty Brand Educator", "Personal Care Business Owner"])
		]),
		sector("Childcare & Family Services", "reputation", ["Licensed Daycare", "Family Resource Centre", "Public School Program", "Private Household", "Youth Camp", "Hospital Family Program", "Community Centre", "Child Development Clinic"], [
			group(0, 30000, 34, ["Childcare Assistant", "Camp Counsellor", "Playground Supervisor", "Family Program Helper"]),
			group(1, 43000, 48, ["Early Childhood Educator", "Nanny", "Youth Program Leader", "Childcare Centre Supervisor"]),
			group(2, 65000, 62, ["Child Life Specialist", "Family Support Coordinator", "Child Development Consultant", "Adoption Case Worker"]),
			group(3, 92000, 76, ["Childcare Centre Director", "Family Services Director", "Child Development Program Director", "Youth Policy Advisor"])
		]),
		sector("Emergency Services", "health", ["Municipal Fire Department", "Regional Ambulance Service", "Police Service", "Search and Rescue Team", "Emergency Communications Centre", "Airport Emergency Unit", "Wildfire Service", "Industrial Emergency Team"], [
			group(0, 36000, 44, ["Emergency Services Cadet", "Fire Hall Attendant", "Rescue Equipment Assistant", "Community Safety Assistant"]),
			group(1, 56000, 60, ["Emergency Dispatcher", "Emergency Medical Responder", "Auxiliary Firefighter", "Bylaw Enforcement Officer"]),
			group(2, 78000, 72, ["Firefighter", "Paramedic", "Police Officer", "Search and Rescue Technician"]),
			group(3, 112000, 84, ["Fire Chief", "Paramedic Superintendent", "Police Inspector", "Emergency Management Director"])
		]),
		sector("Military & Defence", "discipline", ["Canadian Army", "Royal Canadian Navy", "Royal Canadian Air Force", "Military Intelligence Unit", "Defence Research Centre", "Military Logistics Command", "Cyber Defence Unit", "Peace Support Mission"], [
			group(0, 42000, 48, ["Infantry Soldier", "Supply Technician", "Vehicle Crew Member", "Combat Engineer Trainee"]),
			group(1, 57000, 60, ["Medical Technician", "Signals Technician", "Weapons Technician", "Military Police Member"]),
			group(2, 82000, 72, ["Commissioned Officer", "Intelligence Officer", "Military Engineer", "Naval Warfare Officer"]),
			group(3, 126000, 84, ["Senior Command Officer", "Defence Scientist", "Base Commander", "Strategic Operations Director"])
		]),
		sector("Maritime & Fisheries", "discipline", ["Commercial Fishing Vessel", "Coast Guard Station", "Cargo Shipping Company", "Marine Research Institute", "Port Authority", "Ferry Service", "Aquaculture Farm", "Shipbuilding Yard"], [
			group(0, 35000, 38, ["Deckhand", "Fish Processor", "Dock Worker", "Marine Yard Helper"]),
			group(1, 52000, 52, ["Marine Engine Technician", "Fisheries Observer", "Aquaculture Technician", "Ferry Deck Officer"]),
			group(2, 78000, 66, ["Ship Captain", "Marine Biologist", "Naval Architect", "Port Operations Manager"]),
			group(3, 112000, 80, ["Harbour Master", "Fleet Operations Director", "Marine Research Director", "Shipyard General Manager"])
		]),
		sector("Automotive & Mobility", "discipline", ["Independent Garage", "Automotive Dealership", "Fleet Maintenance Shop", "Motorsport Team", "Electric Vehicle Company", "Collision Repair Centre", "Transit Maintenance Depot", "Vehicle Engineering Firm"], [
			group(0, 33000, 36, ["Lube Technician", "Tire Installer", "Automotive Detailer", "Parts Delivery Driver"]),
			group(1, 52000, 50, ["Automotive Service Technician", "Collision Repair Technician", "Parts Specialist", "Service Advisor"]),
			group(2, 75000, 64, ["Automotive Diagnostic Technician", "Fleet Maintenance Manager", "Vehicle Systems Technologist", "Motorsport Technician"]),
			group(3, 108000, 78, ["Automotive Engineer", "Electric Vehicle Program Manager", "Motorsport Technical Director", "Dealer Operations Director"])
		]),
		sector("Animal Care & Veterinary", "reputation", ["Veterinary Hospital", "Animal Shelter", "Wildlife Rehabilitation Centre", "Farm Animal Practice", "Pet Grooming Business", "Zoo", "Animal Research Facility", "Mobile Veterinary Service"], [
			group(0, 30000, 34, ["Kennel Attendant", "Animal Shelter Assistant", "Pet Sitter", "Stable Hand"]),
			group(1, 44000, 48, ["Veterinary Assistant", "Pet Groomer", "Animal Control Officer", "Zookeeper Assistant"]),
			group(2, 65000, 62, ["Veterinary Technologist", "Animal Behaviourist", "Wildlife Rehabilitator", "Animal Shelter Manager"]),
			group(4, 112000, 78, ["Veterinarian", "Veterinary Surgeon", "Zoo Veterinarian", "Veterinary Medical Director"])
		]),
		sector("Funeral & Memorial Services", "reputation", ["Family Funeral Home", "Cemetery", "Crematorium", "Municipal Coroner Service", "Hospital Bereavement Office", "Memorial Planning Company", "Religious Funeral Service", "Independent Mortuary"], [
			group(0, 33000, 38, ["Funeral Home Attendant", "Cemetery Groundskeeper", "Memorial Service Assistant", "Transport Attendant"]),
			group(1, 50000, 52, ["Crematorium Operator", "Funeral Services Administrator", "Embalming Assistant", "Bereavement Coordinator"]),
			group(2, 72000, 66, ["Funeral Director", "Embalmer", "Cemetery Manager", "Grief Support Coordinator"]),
			group(3, 98000, 78, ["Chief Coroner", "Funeral Home General Manager", "Memorial Services Director", "Forensic Pathology Administrator"])
		]),
		sector("Religion & Spiritual Care", "reputation", ["Local Congregation", "Hospital Chaplaincy", "University Campus", "Military Chaplaincy", "Community Outreach Mission", "Interfaith Centre", "Retreat Centre", "Religious Education Office"], [
			group(0, 30000, 34, ["Congregation Administrator", "Worship Service Assistant", "Community Outreach Worker", "Religious Education Helper"]),
			group(1, 43000, 48, ["Youth Ministry Coordinator", "Pastoral Care Assistant", "Religious Education Coordinator", "Music Ministry Leader"]),
			group(2, 62000, 62, ["Pastor", "Priest", "Rabbi", "Imam"]),
			group(3, 90000, 76, ["Hospital Chaplain", "Theologian", "Regional Faith Leader", "Interfaith Program Director"])
		]),
		sector("Entrepreneurship & Gig Economy", "confidence", ["Home-Based Business", "Online Marketplace", "Local Service Area", "Shared Studio", "Freelance Platform", "Mobile Business", "Subscription Company", "Independent Consultancy"], [
			group(0, 30000, 36, ["Delivery Courier", "Pet Care Provider", "Home Cleaner", "Handyperson"]),
			group(1, 47000, 50, ["Freelance Photographer", "Online Reseller", "Virtual Assistant", "Independent Tutor"]),
			group(2, 72000, 64, ["Freelance Developer", "Independent Consultant", "Content Creator", "Small Business Owner"]),
			group(3, 115000, 80, ["Startup Founder", "Agency Owner", "Franchise Owner", "Venture Studio Director"])
		])
	]


static func sector(name_value: String, stat: String, contexts: Array, groups: Array) -> Dictionary:
	return {"sector": name_value, "stat": stat, "contexts": contexts, "groups": groups}


static func group(education: int, salary: int, minimum: int, roles: Array) -> Dictionary:
	return {"education": education, "salary": salary, "minimum": minimum, "roles": roles}
