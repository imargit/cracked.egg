import json
alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
#open file
People=[]
for letter in alphabet:
    with open(f'Dataset\{letter}_people.json', encoding='utf-8') as file:
        People.append(json.load(file))
 
#create empty lists
republican_list = [] 
democrat_list = []

for letter in People:
    for item in letter:
        if 'ontology/party_label' in item:
            if item['ontology/party_label'] == 'Republican Party (United States)': 
                republican_list.append(item)

for letter in People:
    for item in letter:
        if 'ontology/party_label' in item:
            if item['ontology/party_label'] == 'Democratic Party (United States)': 
                democrat_list.append(item)
        
print(f"Republicans: {len(republican_list)}")
print(f"Democrats: {len(democrat_list)}")



