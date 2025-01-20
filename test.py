import json

#open file
with open('A_people.json', encoding='utf- 8') as file:
    People = json.load(file) 
 
#create empty list
republican_list = [] 

#measurements for seattle
for item in People:
    if 'ontology/party_label' in item:
        if item['ontology/party_label'] == 'Democratic Party (United States)': 
            republican_list.append(item)
        
print(len(republican_list))



