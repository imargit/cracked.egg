import json
from pathlib import Path

#GET CURRENT DIRECTORY
current_dir = Path()

#DEFINE ALPHABET
alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

#IMPORT ALL DATA
people_all=[]
for letter in alphabet:
    with open(current_dir / "Data" / "Dataset" / f'{letter}_people.json', encoding='utf-8') as file:
        people_all.append(json.load(file))
        

#GENERATE A LIST OF UNIQUE UNIVERSITIES ACROSS ALL PEOPLE IN THE DATASET. TO BE USED LATER TO DETERMINE WHETHER AN ENTRY IN THE EDUCATION LABEL IS A UNIVERSITY (WHEN SOMEONE ONLY HAS EDUCATION LABEL BUT NOT ALMA MATER DEFINED)
"""
def generate_uni_list():
    uni_list = []
    for letter in people_all:
        for person in letter:
            if 'ontology/party_label' in person:
                if ('ontology/almaMater_label' in person) and (person['ontology/party_label'] == 'Republican Party (United States)' or person['ontology/party_label'] == 'Democratic Party (United States)'):
                    uni_data = person['ontology/almaMater_label']
                    personal_temp_list = []
                    if isinstance(uni_data,str): 
                        personal_temp_list = [uni_data]
                    elif isinstance(uni_data,list):
                        personal_temp_list = uni_data
                    for uni in personal_temp_list:
                        #ADD TO LIST IF NOT ALREADY IN LIST AND IT IS A UNIVERSITY, NOT A HIGH SCHOOL
                        if (uni not in uni_list) and ('high school' not in uni.lower()):
                            uni_list.append(uni)
    return uni_list
"""

#GET UNIQUE UNIVERSITY LIST
#ALREADY GENERATED, SO JUST LOAD THE FILE
unique_universities_list = []
with open(current_dir / 'Data' / 'unique_universities.json', encoding='utf-8') as file:
    unique_universities = json.load(file)


#CREATE EMPTY DICTIONARIES TO STORE FREQUENCIES
republican_universities={}
democrat_universities={}

#nr_of_democracts = 0
#nr_of_republicans = 0

#ADD UNIVERSITY TO ONE OF THE TWO DIRECTORIES (IF IT PASSES SOME TESTS)
def add_to_universities(party, uni_data, check_if_highschool, check_if_uni):
    #global nr_of_democracts
    #global nr_of_republicans

    #MAKE A LIST OF UNIVERSITIES REGARDLESS OF WHETHER THERE IS ONE OR MULTIPLE
    unilist = []
    if isinstance(uni_data,str): 
        unilist = [uni_data]
    elif isinstance(uni_data,list):
        unilist = uni_data
    
    #LOOP THROUGH UNIVERSITIES AND CREATE A NEW LIST OF THE ONES THAT SHOULD BE COUNTED
    unilist_filtered = []
    for uni in unilist:
        #FOR DATA FROM THE EDUCATION VARIABLE, CHECK IF IT IS A UNIVERSITY
        if check_if_uni:
            if uni not in unique_universities_list:
                #IF NOT A UNIVERSITY, SKIP IT AND DO NOT COUNT IT
                continue
        if check_if_highschool:
             if 'high school' in uni.lower():
                #ONLY CONSIDER IF IT IS A UNIVERSITY, NOT A HIGH SCHOOL
                continue
        unilist_filtered.append(uni)

    #STOP FUNCTION IF FILTERED LIST IS EMPTY
    if len(unilist_filtered) == 0:
        return

    #CALCULATE THE WEIGHTED VALUE THAT THE UNIVERSITY ATTENDANCE HAS
    uni_value = 1/len(unilist_filtered)

    #LOOP THROUGH THE UNIVERSITIES AND ADD THE RELEVANT VALUES TO THE DICTIONARIES
    for uni in unilist_filtered:
        if party == 'Republican Party (United States)': 
            #nr_of_republicans += uni_value
            if uni in republican_universities:
                republican_universities[uni] = republican_universities[uni] + uni_value
            else:
                republican_universities[uni] = uni_value
        elif party == 'Democratic Party (United States)': 
            #nr_of_democracts += uni_value
            if uni in democrat_universities:
                democrat_universities[uni] = democrat_universities[uni] + uni_value
            else:
                democrat_universities[uni] = uni_value


#nr_with_both = 0
#LOOP THROUGH ALL LETTERS
for letter in people_all:
    #WITHIN EACH LETTER, LOOP THROUGH ALL PEOPLE
    for person in letter:
        #THIS WAS USED TO CHECK THE POLITICIANS WHO HAVE AN EDUCATION BUT NOT AN ALMA MATER LABEL
        """
        if ('ontology/party_label' in person) and ('ontology/education_label' in person) and not ('ontology/almaMater_label' in person):
            print(str(person['ontology/education_label']))
            nr_with_both += 1
        """

        #IF THE PERSON IS A REPUBLICAN OR DEMOCRAT POLITICIAN AND HAS EITHER ALMA MATER OR EDUCATION DEFINED, CALL THE FUNCTION THAT ADDS THEIR INSTUTUTES TO THE DATA DICTIONARY
        if ('ontology/party_label' in person):
            if person['ontology/party_label'] == 'Republican Party (United States)' or person['ontology/party_label'] == 'Democratic Party (United States)':
                if ('ontology/almaMater_label' in person):
                    add_to_universities(
                        person['ontology/party_label'],
                        person['ontology/almaMater_label'],
                        True, #NEED TO CHECK IF HIGH SCHOOL, ONLY ADD IF NOT
                        False #NO NEED TO CHECK IF UNIVERSITY
                    )
                elif ('ontology/education_label' in person):
                    add_to_universities(
                         person['ontology/party_label'],
                         person['ontology/education_label'],
                         False, #NO NEED TO CHECK IF HIGH SCHOOL, SINCE LIST OF UNIQUE UNIS ALREDY EXCLUDES HIGH SCHOOLS
                         True #NEED TO CHECK IF UNIVERSITY, SINCE CONTAINS A LOT OF MISLEADING ENTRIES (E.G. BACHELOR OF ARTS)
                    )

#print(f'Nr of democracts: {nr_of_democracts}')
#print(f'Nr of republicans: {nr_of_republicans}')


#SAVE THE OBTAINED DATA AS A JSON FILE
with open(current_dir / 'Data' / 'republican.json', 'w', encoding='utf-8') as file:
    json.dump(republican_universities, file)
with open(current_dir / 'Data' / 'democrat.json', 'w', encoding='utf-8') as file:
    json.dump(democrat_universities, file)


#THIS WAS USED EARLIER TO SAVE THE LIST OF UNIQUE UNIVERSITIES
"""
with open(current_dir / 'Data' / 'unique_universities.json', 'w', encoding='utf-8') as file:
    json.dump(unique_universities_list, file, indent=4)
"""