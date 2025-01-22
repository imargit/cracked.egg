from geopy.geocoders import Nominatim
import json
from pathlib import Path

current_dir = Path()

unique_universities=[]
with open(current_dir / 'Data' / 'unique_universities.json', encoding='utf-8') as file:
    unique_universities = json.load(file)

address_error_message = "NOT FOUND"
US_STATE_ABBREVIATIONS = {
    'Alabama': 'AL', 'Alaska': 'AK', 'Arizona': 'AZ', 'Arkansas': 'AR',
    'California': 'CA', 'Colorado': 'CO', 'Connecticut': 'CT', 'Delaware': 'DE',
    'Florida': 'FL', 'Georgia': 'GA', 'Hawaii': 'HI', 'Idaho': 'ID',
    'Illinois': 'IL', 'Indiana': 'IN', 'Iowa': 'IA', 'Kansas': 'KS',
    'Kentucky': 'KY', 'Louisiana': 'LA', 'Maine': 'ME', 'Maryland': 'MD',
    'Massachusetts': 'MA', 'Michigan': 'MI', 'Minnesota': 'MN', 'Mississippi': 'MS',
    'Missouri': 'MO', 'Montana': 'MT', 'Nebraska': 'NE', 'Nevada': 'NV',
    'New Hampshire': 'NH', 'New Jersey': 'NJ', 'New Mexico': 'NM', 'New York': 'NY',
    'North Carolina': 'NC', 'North Dakota': 'ND', 'Ohio': 'OH', 'Oklahoma': 'OK',
    'Oregon': 'OR', 'Pennsylvania': 'PA', 'Rhode Island': 'RI', 'South Carolina': 'SC',
    'South Dakota': 'SD', 'Tennessee': 'TN', 'Texas': 'TX', 'Utah': 'UT',
    'Vermont': 'VT', 'Virginia': 'VA', 'Washington': 'WA', 'West Virginia': 'WV',
    'Wisconsin': 'WI', 'Wyoming': 'WY'
}

geolocator = Nominatim(user_agent="university_locator")

def get_state(university_name):
    global geolocator
    try:
        location = geolocator.geocode(university_name)
        state_name = location.address.split(', ')[-3]
        return(US_STATE_ABBREVIATIONS[state_name])
    except:
        return(address_error_message)

university_addresses = {}
for uni in unique_universities:
    university_addresses[uni] = get_state(uni)

with open(current_dir / 'Data' / 'university_addresses.json', 'w', encoding='utf-8') as file:
    json.dump(university_addresses, file, indent=4)