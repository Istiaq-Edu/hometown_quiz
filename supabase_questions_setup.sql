-- ============================================
-- STEP 1: Create the questions table
-- ============================================

CREATE TABLE IF NOT EXISTS questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  city TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('Places & History', 'Culture & Traditions', 'Everyday Bangladesh')),
  type TEXT NOT NULL CHECK (type IN ('mcq', 'true_false')),
  question_text TEXT NOT NULL,
  options JSONB, -- NULL for true/false, array for MCQ
  correct_answer TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_questions_city_category ON questions(city, category);

-- Enable Row Level Security
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- Allow everyone to read questions (they're public)
CREATE POLICY "Anyone can read questions"
  ON questions FOR SELECT
  TO public
  USING (true);

-- Only authenticated users can insert (for admin purposes)
CREATE POLICY "Authenticated users can insert questions"
  ON questions FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- ============================================
-- STEP 2: Insert Dhaka Questions
-- ============================================

-- PLACES & HISTORY (22 questions)
INSERT INTO questions (city, category, type, question_text, options, correct_answer) VALUES
('Dhaka', 'Places & History', 'mcq', 'Dhaka, the capital of Bangladesh, is located on the banks of which river?', 
  '["A) Padma", "B) Meghna", "C) Buriganga", "D) Jamuna"]', 'C) Buriganga'),

('Dhaka', 'Places & History', 'true_false', 'Ahsan Manzil, also known as the "Pink Palace," was the residential palace of the Nawabs of Dhaka.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'What is the name of the famous unfinished Mughal fort in Dhaka?', 
  '["A) Lalbagh Fort", "B) Hajiganj Fort", "C) Sonakanda Fort", "D) Idrakpur Fort"]', 'A) Lalbagh Fort'),

('Dhaka', 'Places & History', 'mcq', 'Dhaka University, one of Bangladesh''s oldest universities, was established in which year?', 
  '["A) 1905", "B) 1921", "C) 1947", "D) 1971"]', 'B) 1921'),

('Dhaka', 'Places & History', 'mcq', 'Which of these is the national mosque of Bangladesh, located in Dhaka?', 
  '["A) Star Mosque", "B) Shahi Mosque", "C) Sixty Dome Mosque", "D) Baitul Mukarram"]', 'D) Baitul Mukarram'),

('Dhaka', 'Places & History', 'true_false', 'Dhaka is located in the Khulna Division of Bangladesh.', 
  NULL, 'False'),

('Dhaka', 'Places & History', 'mcq', 'Who made Dhaka the capital of Mughal Bengal in 1610 and named it Jahangirnagar?', 
  '["A) Shaista Khan", "B) Islam Khan I", "C) Murshid Quli Khan", "D) Mir Jumla II"]', 'B) Islam Khan I'),

('Dhaka', 'Places & History', 'true_false', 'The Curzon Hall at Dhaka University was originally intended to be a new governor''s palace but was later made part of the university.', 
  NULL, 'False'),

('Dhaka', 'Places & History', 'mcq', 'The Language Movement of 1952, a key event in Bangladesh''s history, was centered in which city?', 
  '["A) Chittagong", "B) Comilla", "C) Kolkata", "D) Dhaka"]', 'D) Dhaka'),

('Dhaka', 'Places & History', 'true_false', 'The High Court Building in Dhaka is a notable example of European-Neoclassical architecture combined with Mughal motifs.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'true_false', 'Sadarghat, located on the Buriganga river, is one of the largest and busiest river ports in the world.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'The "Aparajeyo Bangla" statue at Dhaka University commemorates the...', 
  '["A) Language Movement of 1952", "B) Liberation War of 1971", "C) 1969 Mass Uprising", "D) Anti-British Movement"]', 'B) Liberation War of 1971'),

('Dhaka', 'Places & History', 'mcq', 'What is the approximate total area of Dhaka District (not the entire metropolitan area)?', 
  '["A) ~850 sq km", "B) ~1,460 sq km", "C) ~2,100 sq km", "D) ~3,200 sq km"]', 'B) ~1,460 sq km'),

('Dhaka', 'Places & History', 'true_false', 'The architectural style of the Star Mosque (Tara Masjid) in Dhaka was originally Mughal, but it was significantly altered with Japanese and English porcelain tiles in the early 20th century.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'The historic "Dhaka Race Course" (now Suhrawardy Udyan) was the site of Sheikh Mujibur Rahman''s famous 7th March Speech and the surrender of the Pakistani army. In which year did the surrender take place?', 
  '["A) 1969", "B) 1970", "C) 1971", "D) 1972"]', 'C) 1971'),

('Dhaka', 'Places & History', 'true_false', 'The name "Dhaka" is popularly believed to be derived from the "Dhak" tree, which was once common in the area.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'Who was the Armenian merchant after whom the historic Armanitola area in old Dhaka is named?', 
  '["A) Nicholas Pogose", "B) Arathoon Michael", "C) Johannes Aviet", "D) The name is not from a person, but from \"Armenian Quarter.\""]', 'D) The name is not from a person, but from "Armenian Quarter."'),

('Dhaka', 'Places & History', 'true_false', 'The main terminal of Hazrat Shahjalal International Airport was designed by the famous French architect Paul Andreu.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'The "Dhakeshwari" Temple, from which Dhaka is also theorized to have gotten its name, is dedicated to which Hindu deity?', 
  '["A) Shiva", "B) Vishnu", "C) A form of Durga (Adi Shakti)", "D) Ganesha"]', 'C) A form of Durga (Adi Shakti)'),

('Dhaka', 'Places & History', 'mcq', 'Which Mughal Subahdar is credited with constructing the Bara Katra, a grand caravanserai in Old Dhaka?', 
  '["A) Shaista Khan", "B) Islam Khan I", "C) Mir Jumla II", "D) Prince Azam Shah"]', 'A) Shaista Khan'),

('Dhaka', 'Places & History', 'true_false', 'The Armenian Church of the Holy Resurrection in Dhaka is one of the oldest churches in Bangladesh, dating back to the 18th century.', 
  NULL, 'True'),

('Dhaka', 'Places & History', 'mcq', 'The area known as "Shahbagh" in Dhaka was historically famous for what type of garden or orchard?', 
  '["A) Mango orchards", "B) Rose gardens", "C) Spice plantations", "D) Tea gardens"]', 'B) Rose gardens');

-- CULTURE & TRADITIONS (12 questions)
INSERT INTO questions (city, category, type, question_text, options, correct_answer) VALUES
('Dhaka', 'Culture & Traditions', 'true_false', 'The "Jamdani" sari, a UNESCO Intangible Cultural Heritage, is a famous product originating from the Dhaka region.', 
  NULL, 'True'),

('Dhaka', 'Culture & Traditions', 'mcq', 'The "Pohela Boishakh" (Bengali New Year) celebration at Ramna Batamul in Dhaka is organized by which cultural institution?', 
  '["A) Bangla Academy", "B) Chhayanaut", "C) Shilpakala Academy", "D) Nazrul Institute"]', 'B) Chhayanaut'),

('Dhaka', 'Culture & Traditions', 'mcq', 'Which of these famous delicacies is Dhaka particularly known for?', 
  '["A) Shatkora Beef", "B) Chui Jhal", "C) Kacchi Biryani", "D) Mezban"]', 'C) Kacchi Biryani'),

('Dhaka', 'Culture & Traditions', 'mcq', 'What is the traditional folk theatre form that is often seen in rural areas surrounding Dhaka, featuring masked performances and mythical stories?', 
  '["A) Jatra", "B) Pala Gaan", "C) Lalon Giti", "D) Kirtan"]', 'A) Jatra'),

('Dhaka', 'Culture & Traditions', 'true_false', 'The annual Dhaka Lit Fest is an international literary festival that brings together writers and thinkers from around the world.', 
  NULL, 'True'),

('Dhaka', 'Culture & Traditions', 'mcq', 'Which musical instrument is central to traditional Bengali folk music, often played by street musicians in Dhaka, and has a distinctive gourde body?', 
  '["A) Tabla", "B) Sitar", "C) Dotara", "D) Ektara"]', 'D) Ektara'),

('Dhaka', 'Culture & Traditions', 'true_false', 'Eid-ul-Fitr and Eid-ul-Adha are the two largest religious festivals celebrated with great fervor in Dhaka.', 
  NULL, 'True'),

('Dhaka', 'Culture & Traditions', 'mcq', 'What is the traditional art of painting rickshaw vans in Dhaka called, known for its vibrant colors and intricate designs?', 
  '["A) Alpona", "B) Nakshi Kantha", "C) Rickshaw Art", "D) Pot Shilpa"]', 'C) Rickshaw Art'),

('Dhaka', 'Culture & Traditions', 'true_false', 'Pitha Utsab, a festival dedicated to traditional Bengali cakes and pastries, is a popular cultural event in Dhaka during winter.', 
  NULL, 'True'),

('Dhaka', 'Culture & Traditions', 'mcq', 'The Bangla Academy in Dhaka plays a significant role in promoting which aspect of Bengali culture?', 
  '["A) Traditional dance", "B) Bengali language and literature", "C) Folk music", "D) Culinary arts"]', 'B) Bengali language and literature'),

('Dhaka', 'Culture & Traditions', 'mcq', 'What is the significance of the Central Shaheed Minar (Martyr Monument) in Dhaka?', 
  '["A) It commemorates the Liberation War of 1971.", "B) It commemorates the heroes of the Language Movement of 1952.", "C) It is a monument to the first capital of Bengal.", "D) It celebrates Bengali New Year."]', 'B) It commemorates the heroes of the Language Movement of 1952.'),

('Dhaka', 'Culture & Traditions', 'true_false', 'Traditional Bengali wedding ceremonies in Dhaka often involve elaborate rituals and vibrant processions.', 
  NULL, 'True');

-- EVERYDAY BANGLADESH (15 questions)
INSERT INTO questions (city, category, type, question_text, options, correct_answer) VALUES
('Dhaka', 'Everyday Bangladesh', 'mcq', 'What is the common name for the three-wheeled passenger carts that are a famous symbol of Dhaka?', 
  '["A) Tanga", "B) Tomtom", "C) Rickshaw", "D) Auto"]', 'C) Rickshaw'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'What major international cricket stadium is located in the Mirpur area of Dhaka?', 
  '["A) Eden Gardens", "B) Sher-e-Bangla National Cricket Stadium", "C) M. A. Aziz Stadium", "D) National Stadium, Karachi"]', 'B) Sher-e-Bangla National Cricket Stadium'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'New Market is a well-known...', 
  '["A) Historical fort", "B) Shopping complex", "C) River port", "D) Public park"]', 'B) Shopping complex'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'The Dhaka Metro Rail, a major infrastructure project, began its first phase of commercial operations in which year?', 
  '["A) 2019", "B) 2021", "C) 2022", "D) 2024"]', 'C) 2022'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'How many upazilas (sub-districts) are there within Dhaka District (as of 2025)?', 
  '["A) 5", "B) 10", "C) 15", "D) 20"]', 'A) 5'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'According to 2024-2025 estimates, Dhaka consistently ranks as one of the world''s...', 
  '["A) Most livable cities", "B) Most densely populated cities", "C) Safest cities", "D) Cleanest cities"]', 'B) Most densely populated cities'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'The literacy rate in Dhaka District, according to the 2022 census, was the highest in Bangladesh, at approximately...', 
  '["A) 65.2%", "B) 72.8%", "C) 78.1%", "D) 85.4%"]', 'C) 78.1%'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'Which of these is NOT one of the 5 upazilas of Dhaka District?', 
  '["A) Dhamrai", "B) Savar", "C) Keraniganj", "D) Tejgaon"]', 'D) Tejgaon'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'What is the primary public transportation system, besides rickshaws and buses, that has recently seen significant expansion in Dhaka?', 
  '["A) Tram", "B) Ferry Service", "C) Metro Rail", "D) Cable Car"]', 'C) Metro Rail'),

('Dhaka', 'Everyday Bangladesh', 'true_false', 'Traffic congestion is a significant daily challenge for residents and commuters in Dhaka.', 
  NULL, 'True'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'Which of these is a popular destination for families and young people in Dhaka looking for recreation and green space?', 
  '["A) Ramna Park", "B) Gulshan Lake Park", "C) Lalbagh Garden", "D) All of the above"]', 'D) All of the above'),

('Dhaka', 'Everyday Bangladesh', 'true_false', 'Dhaka is the financial and commercial hub of Bangladesh.', 
  NULL, 'True'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'What type of market is "Karwan Bazar" famously known for in Dhaka?', 
  '["A) Electronics market", "B) Wholesale raw produce market", "C) Textile market", "D) Book market"]', 'B) Wholesale raw produce market'),

('Dhaka', 'Everyday Bangladesh', 'true_false', 'Despite being a bustling metropolis, many residents in Dhaka still rely on traditional markets for their daily groceries.', 
  NULL, 'True'),

('Dhaka', 'Everyday Bangladesh', 'mcq', 'Which authority is responsible for urban planning and development in the greater Dhaka area?', 
  '["A) Dhaka City Corporation North", "B) Dhaka City Corporation South", "C) Rajdhani Unnayan Kartripakkha (RAJUK)", "D) Ministry of Public Works"]', 'C) Rajdhani Unnayan Kartripakkha (RAJUK)');

-- ============================================
-- DONE! All 49 Dhaka questions inserted
-- ============================================
