from pathlib import Path

import json
current_dir = Path()

alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
#open file
people_all=[]
for letter in alphabet:
    with open(current_dir / "Dataset" / f'{letter}_people.json', encoding='utf-8') as file:
        people_all.append(json.load(file))
 
#create empty lists
republican_list = [] 
democrat_list = []

republican_universities={}
democrat_universities={}

multiple_unis = 0
one_uni = 0

for letter in people_all:
    for person in letter:
        if ('ontology/party_label' in person) and ('ontology/almaMater_label' in person):
            party = person['ontology/party_label']
            uni = person['ontology/almaMater_label']
            if isinstance(uni,list): 
                multiple_unis += 1
            elif isinstance(uni,str):
                one_uni += 1
            """
            if party == 'Republican Party (United States)': 
                republican_list.append(person)
                if uni in republican_universities:
                    republican_universities[uni] = republican_universities[uni] + 1
                else:
                    republican_universities[uni] = 1
            if party == 'Democratic Party (United States)': 
                democrat_list.append(person)
                if uni in democrat_universities:
                    democrat_universities[uni] = democrat_universities[uni] + 1
                else:
                    democrat_universities[uni] = 1       
            """     
            
print(one_uni)
print(multiple_unis)


print(f"Republicans: {len(republican_list)}")
print(f"Democrats: {len(democrat_list)}")
print(republican_universities)
print(republican_universities)


