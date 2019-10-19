library(tidyverse)
library(lubridate)

Customers <- tribble(
  ~PersonID, ~Name, ~Street, ~City, ~State,
  1, 'Derek Sonderegger',  '231 River Run', 'Flagstaff', 'AZ',
  2, 'Aubrey Sonderegger', '231 River Run', 'Flagstaff', 'AZ',
  3, 'Robert Buscaglia', '754 Forest Heights', 'Flagstaff', 'AZ',
  4, 'Roy St Laurent', '845 Elk View', 'Flagstaff', 'AZ')

Retailers <- tribble(
  ~RetailID, ~Name, ~Street, ~City, ~State,
  1, 'Kickstand Kafe', '719 N Humphreys St', 'Flagstaff', 'AZ',
  2, 'MartAnnes', '112 E Route 66', 'Flagstaff', 'AZ',
  3, 'REI', '323 S Windsor Ln', 'Flagstaff', 'AZ' )

Cards <- tribble(
  ~CardID, ~PersonID, ~Issue_DateTime, ~Exp_DateTime,
  '9876768717278723',  1,  '2019-9-20 0:00:00', '2022-9-20 0:00:00',
  '9876765798212987',  2,  '2019-9-20 0:00:00', '2022-9-20 0:00:00',
  '9876765498122734',  3,  '2019-9-28 0:00:00', '2022-9-28 0:00:00',
  '9876768965231926',  4,  '2019-9-30 0:00:00', '2022-9-30 0:00:00' ) 

Transactions <- tribble(
  ~CardID, ~RetailID, ~DateTime, ~Amount,
  '9876768717278723', 1, '2019-10-1 8:31:23',    5.68,
  '9876765498122734', 2, '2019-10-1 12:45:45',  25.67,
  '9876768717278723', 1, '2019-10-2 8:26:31',    5.68,
  '9876768717278723', 1, '2019-10-2 8:30:09',    9.23,
  '9876765798212987', 3, '2019-10-5 18:58:57',  68.54,
  '9876765498122734', 2, '2019-10-5 12:39:26',  31.84,
  '9876768965231926', 2, '2019-10-10 19:02:20', 42.83) 

Cards <- Cards %>% 
  mutate( Issue_DateTime = lubridate::ymd_hms(Issue_DateTime),
          Exp_DateTime   = lubridate::ymd_hms(Exp_DateTime) )
Transactions <- Transactions %>% 
  mutate( DateTime = lubridate::ymd_hms(DateTime))


# Derek's Statement
customer = 'Derek Sonderegger'
Customers %>%
  filter(Name == customer) %>%
  left_join(Cards) %>% left_join(Transactions) %>% 
  left_join( Retailers %>% select(RetailID, Name), by='RetailID') %>%
  select(DateTime, Amount, Name.y) %>%
  rename(Retailer = Name.y)


# Deactivate Aubrey's Credit Card
Cards <- Cards %>%
  mutate(Exp_DateTime = if_else(CardID=='9876765798212987', ymd_hms('2019-10-15 16:28:21'), Exp_DateTime))
  
# Issue a New Card
Cards <- Cards %>%
  add_row(CardID = '9876765798212988', 
          PersonID=2, 
          Issue_DateTime=ymd_hms('2019-10-15 16:28:45'),
          Exp_DateTime = ymd_hms('2022-10-15 0:00:00'))


# Generate a Transaction, checking to see if the card is valid
now <- ymd_hms('2019-10-16 14:30:21')
card <- '9876765798212988'
retailid = 1
amount = 4.98
  
Active <- Cards %>% 
  filter(CardID == card) %>% 
  filter(Issue_DateTime < now, now < Exp_DateTime) %>% 
  nrow() == 1

if( Active ){
  Transactions <- Transactions %>% 
    add_row(CardID = card, RetailID=retailid, DateTime=now, Amount=amount)
}else{
  warning('Invalid Card')
}


# Generate a New Transaction, 
now <- ymd_hms('2019-10-17 14:30:21')   # Time stamp after deactivation!
card <- '9876765798212987'              # This is the deactivated card
retailid = 1
amount = 4.98

Active <- Cards %>% 
  filter(CardID == card) %>% 
  filter(Issue_DateTime < now, now < Exp_DateTime) %>% 
  nrow() == 1

if( Active ){
  Transactions <- Transactions %>% 
    add_row(CardID = card, RetailID=retailid, DateTime=now, Amount=amount)
}else{
  warning('Invalid Card')
}


write_csv(Cards, 'data-raw/CreditCard_Cards.csv')
write_csv(Customers, 'data-raw/CreditCard_Customers.csv')
write_csv(Retailers, 'data-raw/CreditCard_Retailers.csv')
write_csv(Transactions, 'data-raw/CreditCard_Transactions.csv')

