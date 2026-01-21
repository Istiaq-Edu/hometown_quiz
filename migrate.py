import os
import re
import json

files = [
    'chittagong.md', 'sylhet.md', 'rajshahi.md', 'khulna.md',
    'barisal.md', 'rangpur.md', 'mymensingh.md', 'comilla.md',
    'gazipur.md', 'narayanganj.md', 'coxs_bazar.md', 'bogra.md', 'jessore.md',
    'dinajpur.md', 'tangail.md', 'kushtia.md', 'rangamati.md', 'brahmanbaria.md',
    'pabna.md', 'faridpur.md', 'jamalpur.md', 'netrokona.md', 'habiganj.md',
    'moulvibazar.md', 'sunamganj.md', 'bandarban.md', 'khagrachari.md', 'kishoreganj.md',
    'sherpur.md', 'munshiganj.md', 'manikganj.md', 'madaripur.md', 'gopalganj.md',
    'shariatpur.md', 'rajbari.md', 'magura.md', 'jhenaidah.md', 'chuadanga.md',
    'meherpur.md', 'narail.md', 'satkhira.md', 'bagerhat.md', 'pirojpur.md',
    'narsingdi.md', 'sirajganj.md', 'noakhali.md', 'feni.md', 'lakshmipur.md',
    'chandpur.md', 'jhalokati.md', 'patuakhali.md', 'barguna.md', 'panchagarh.md',
    'thakurgaon.md', 'nilphamari.md', 'lalmonirhat.md', 'kurigram.md', 'gaibandha.md',
    'joypurhat.md', 'naogaon.md', 'natore.md', 'chapainawabganj.md'
]

base_path = r'd:\Flutter App\hometown_quiz\lib\questions'
output_file = 'migration.sql'

sql_statements = []

for filename in files:
    city = filename.replace('.md', '').capitalize()
    filepath = os.path.join(base_path, filename)
    
    if not os.path.exists(filepath):
        print(f"File not found: {filepath}")
        continue
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    # Split by category
    categories = re.split(r'Category: ', content)[1:]
    
    for cat_section in categories:
        lines = cat_section.split('\n')
        category_name = lines[0].split('(')[0].strip()
        
        # Split by questions
        # Questions start with [MCQ] or [TRUE/FALSE]
        # We can use regex to find all questions
        
        question_blocks = re.split(r'\n(?=\[(?:MCQ|TRUE/FALSE)\])', cat_section)
        # Skip the first block as it is the category description
        
        for block in question_blocks[1:]:
            block = block.strip()
            if not block: continue
            
            q_type = 'MCQ' if '[MCQ]' in block else 'TRUE_FALSE'
            
            # Extract question text
            # Remove [MCQ] or [TRUE/FALSE]
            block_content = re.sub(r'^\[(?:MCQ|TRUE/FALSE)\]\s*', '', block).strip()
            
            lines = block_content.split('\n')
            question_text = lines[0].strip()
            
            options = {}
            correct_answer = ''
            
            if q_type == 'MCQ':
                q_type_db = 'mcq'
                # Parse options
                for line in lines[1:]:
                    line = line.strip()
                    if line.startswith('A)'): options['A'] = line[3:].strip()
                    elif line.startswith('B)'): options['B'] = line[3:].strip()
                    elif line.startswith('C)'): options['C'] = line[3:].strip()
                    elif line.startswith('D)'): options['D'] = line[3:].strip()
                    elif line.startswith('CORRECT ANSWER:'):
                        correct_answer = line.split(':')[1].strip()
            else:
                q_type_db = 'true_false'
                # True/False
                options = {'True': 'True', 'False': 'False'}
                for line in lines[1:]:
                    if line.startswith('CORRECT ANSWER:'):
                        correct_answer = line.split(':')[1].strip()
            
            # Escape single quotes for SQL
            city_sql = city.replace("'", "''")
            category_sql = category_name.replace("'", "''").replace('Places and History', 'Places & History').replace('Culture and Traditions', 'Culture & Traditions')
            q_text_sql = question_text.replace("'", "''")
            correct_sql = correct_answer.replace("'", "''")
            options_json = json.dumps(options).replace("'", "''")
            
            sql = f"INSERT INTO questions (city, category, type, question_text, options, correct_answer) VALUES ('{city_sql}', '{category_sql}', '{q_type_db}', '{q_text_sql}', '{options_json}', '{correct_sql}');"
            sql_statements.append(sql)

with open(output_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(sql_statements))

print(f"Generated {len(sql_statements)} SQL statements.")
