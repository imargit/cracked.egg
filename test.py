import json
alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
#open file
people_all=[]
for letter in alphabet:
    with open(f'Dataset\{letter}_people.json', encoding='utf-8') as file:
        people_all.append(json.load(file))
 
#create empty lists
republican_list = [] 
democrat_list = []

for letter in people_all:
    for person in letter:
        if 'ontology/party_label' in person:
            if person['ontology/party_label'] == 'Republican Party (United States)': 
                republican_list.append(person)
            if person['ontology/party_label'] == 'Democratic Party (United States)': 
                democrat_list.append(person)
        
print(f"Republicans: {len(republican_list)}")
print(f"Democrats: {len(democrat_list)}")



