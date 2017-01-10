# Flight-Ranking-Algorithm

Problem Statement:

A company ABC is a flight aggregator, aggregating a lot of flights from different providers when a user searches in real-time. At times our backend engine generates more than 200 flight combinations for a particular sector(say BOM-DEL) and journey date. 

For better user experience we would like to remove some flights from the combination which have very less probability of getting booked before we present the search results to a user. 

What is a non-bookable flight? 

Say you want to travel from Bangalore to Jammu, now there can be many combinations of flights which can take you from Bangalore to Jammu. Let’s have a look at few possible combinations. 

A. Bangalore -> Jammu                
duration: 4 hrs, fare: Rs 14000

B. Bangalore -> Delhi -> Jammu         
duration: 6hrs, fare: Rs 10000

C. Bangalore -> Chennai -> Jammu        
duration: 8.5 hrs,fare: Rs 15000

D. Bangalore -> Kolkata -> Delhi -> Jammu      
duration: 18 hrs, fare: Rs 20000

E. Bangalore -> Dubai -> Jammu          
duration: 10 hrs, fare: Rs 24000

F. Bangalore -> New York -> Jammu
duration: 45 hrs, fare: Rs 70000

Now if you look at these options, option(a) might be the good choice with least travel time and a low fare as compared to others. 
Option(b) might be the best choice if you are looking for a cheaper choice. And when travel date is so close we might not have any seats left in option(a) and option(b) then a user may go for option(c). Really desperate times there can be chances where a user opts for option(d). 

So,  non-bookable flights are those flights from the combination where the total fare is too high, long durations,  too many stopovers. 

Keep in mind that the non-bookable flights depend on availability, means if the options are less (sold out scenarios) some flights which were filtered out earlier as non-bookable suddenly becomes bookable. In simpler terms, you have to filter out the worst flights in a given list of flights.

Notes : 

We are looking for an algorithm/model which can perform well in real time. Flight team generates the above mentioned combination of flights and passes it to data team to remove non-bookable flights and only bookable flights are served to the user. All of this typical happens in under 8ms in our current setup.  So the algorithm/model that you would like to implement should be fast enough(say ~ 1ms) to weed out non-bookable flights.
Flight fares are dynamic, flight fares change a lot depending on the number of seats remaining, days to journey etc. So training of the model is too frequent since we have more data after a seat is booked and the old model is stale now. Try to look for models which take lesser resources(compute/memory/time) for training. 
You are free to use any technique, we are looking for a simple elegant solution.

Data Dictionary:

This is flight booking data which is consisting transactions as record. 

Each record has the following features:

Category :- Denoting if it’s domestic or international booking. Category is domestic if flight is taking-off and landing-to any of Indian city.

Sector :- A sector is term used for showing two connected airports. Like you are travelling from Delhi to Bangalore then del-blr(airport iata code) is sector. Roundtrip sectors are denoted with -r suffix(blr-del-r).

Transactionid :- It is unique id for a transaction.

Duration :- Duration of journey(in minutes).

Travel date :- Onward flight departure datetime.

Stopovers :-  Intermediate stops(layovers). Say if you are flying from Bangalore to Jammu via Delhi (i. e. Bangalore->Delhi and Delhi->Jammu) then Delhi is your stopover. In case of more than one stopover the field will contain stopovers in comma separated fashion. Special value NA denotes 0 stops(direct flight).

Days to journey :-Difference between the travel date and booking date. 

Roundtrip :- Passenger going from A to B and returning back to A from B.

Total fare :- Total fare of journey.

Flight Number :- Unique identification number for particular flight. 
