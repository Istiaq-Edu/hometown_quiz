import os

# Mixed list of fun facts (Bangladesh + Global)
fun_facts = [
    # --- BANGLADESH FACTS ---
    {"category": "Bangladesh", "text": "Bangladesh has the longest unbroken sea beach in the world, Cox's Bazar, stretching 120 km."},
    {"category": "Bangladesh", "text": "The Royal Bengal Tiger is our national animal and primarily lives in the Sundarbans, the largest mangrove forest on Earth."},
    {"category": "Bangladesh", "text": "Bangladesh has six seasons (Grishma, Barsha, Sharat, Hemanta, Sheet, Basanta) instead of the usual four."},
    {"category": "Bangladesh", "text": "The National Parliament House (Jatiya Sangsad Bhaban) is one of the largest legislative complexes in the world, designed by Louis I. Kahn."},
    {"category": "Bangladesh", "text": "Hilsa (Ilish) is the national fish of Bangladesh and accounts for about 12% of the country's total fish production."},
    {"category": "Bangladesh", "text": "Kabadib is the national sport of Bangladesh, though Cricket is the most popular."},
    {"category": "Bangladesh", "text": "The Magpie Robin (Doel) is the national bird of Bangladesh."},
    {"category": "Bangladesh", "text": "Jackfruit (Kathal) is the national fruit of Bangladesh."},
    {"category": "Bangladesh", "text": "Bangladesh is known as the 'Land of Rivers' with over 700 rivers flowing through it."},
    {"category": "Bangladesh", "text": "The Sundarbans is a UNESCO World Heritage Site and home to the last remaining population of mangrove tigers."},
    {"category": "Bangladesh", "text": "Muslin, a legendary lightweight cotton fabric, originated in Dhaka and was valuable worldwide before the industry declined."},
    {"category": "Bangladesh", "text": "Bangladesh is the 8th most populous country in the world."},
    {"category": "Bangladesh", "text": "Mahasthangarh in Bogra is the oldest known city in Bangladesh, dating back to at least the 3rd century BC."},
    {"category": "Bangladesh", "text": "The Shapla (White Water Lily) is the national flower of Bangladesh."},
    {"category": "Bangladesh", "text": "Bangladesh has the world's largest river delta, formed by the Ganges, Brahmaputra, and Meghna rivers."},
    {"category": "Bangladesh", "text": "Nakshi Kantha is a centuries-old tradition of making embroidered quilts from old saris."},
    {"category": "Bangladesh", "text": "Pohela Boishakh, the Bengali New Year, involves the colorful 'Mangal Shobhajatra' parade, recognized by UNESCO."},
    {"category": "Bangladesh", "text": "Rickshaws in Dhaka are famous for their colorful art and are recognized as Intangible Cultural Heritage by UNESCO."},
    {"category": "Bangladesh", "text": "Sylhet is known as the 'Land of Two Leaves and a Bud' due to its vast tea gardens."},
    {"category": "Bangladesh", "text": "Saint Martin's Island is the only coral island in Bangladesh."},
    {"category": "Bangladesh", "text": "Bagerhat is known as the 'City of Mosques' and hosts the historic Sixty Dome Mosque."},
    {"category": "Bangladesh", "text": "The Jamuna Bridge (Bangabandhu Bridge) is one of the longest bridges in South Asia."},
    {"category": "Bangladesh", "text": "Bangladesh is a top exporter of ready-made garments (RMG) worldwide."},
    {"category": "Bangladesh", "text": "The Doyel Chatwar in Dhaka features a giant statue of the national bird, the Magpie Robin."},
    {"category": "Bangladesh", "text": "Language Movement Day (February 21st) is celebrated globally as International Mother Language Day."},

    # --- GLOBAL FACTS ---
    {"category": "Global", "text": "Honey never spoils. Archaeologists have found pots of honey in ancient Egyptian tombs that are over 3,000 years old and still edible."},
    {"category": "Global", "text": "Bananas are botanically classified as berries, while strawberries are not."},
    {"category": "Global", "text": "Octopuses have three hearts and blue blood."},
    {"category": "Global", "text": "A day on Venus is longer than a year on Venus. It rotates very slowly."},
    {"category": "Global", "text": "The Eiffel Tower can be 15 cm taller during the summer due to thermal expansion of the iron."},
    {"category": "Global", "text": "Wombat poop is cube-shaped, which stops it from rolling away."},
    {"category": "Global", "text": "The shortest war in history was between Britain and Zanzibar on August 27, 1896. Zanzibar surrendered after 38 minutes."},
    {"category": "Global", "text": "Avocados were named after the Aztec word for 'testicle' because of their shape."},
    {"category": "Global", "text": "A group of flamingos is called a 'flamboyance'."},
    {"category": "Global", "text": "Bangkok's full ceremonial name is the longest city name in the world, with 168 letters."},
    {"category": "Global", "text": "Human teeth are the only part of the body that cannot heal themselves."},
    {"category": "Global", "text": "It is physically impossible for pigs to look up into the sky."},
    {"category": "Global", "text": "A cloud can weigh more than a million pounds."},
    {"category": "Global", "text": "The Great Wall of China is not visible from space with the naked eye, contrary to popular myth."},
    {"category": "Global", "text": "Cows have best friends and get stressed when they are distinguishable."},
    {"category": "Global", "text": "Cleopatra lived closer in time to the Moon landing than to the construction of the Great Pyramid of Giza."},
    {"category": "Global", "text": "There are more stars in the universe than grains of sand on all the Earth's beaches."},
    {"category": "Global", "text": "Sea otters hold hands when they sleep to keep from drifting apart."},
    {"category": "Global", "text": "The unicorn is the national animal of Scotland."},
    {"category": "Global", "text": "Humans share about 60% of their DNA with bananas."},
    {"category": "Global", "text": "A bolt of lightning contains enough energy to toast 100,000 slices of bread."},
    {"category": "Global", "text": "The inventor of the Pringles can is now buried in one."},
    {"category": "Global", "text": "Water makes up about 71% of the Earth's surface, but vast majority of it is salt water."},
    {"category": "Global", "text": "Sharks have existed for longer than trees."},
    {"category": "Global", "text": "There is a species of jellyfish (Turritopsis dohrnii) that is biologically immortal."}
]

# Generate SQL
sql_statements = []
for fact in fun_facts:
    # Escape single quotes for SQL
    text = fact['text'].replace("'", "''")
    category = fact['category']
    sql = f"INSERT INTO fun_facts (fact_text, category) VALUES ('{text}', '{category}');"
    sql_statements.append(sql)

# Write to file
with open('migration_fun_facts.sql', 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_statements))

print(f"Generated {len(sql_statements)} SQL statements in migration_fun_facts.sql")
