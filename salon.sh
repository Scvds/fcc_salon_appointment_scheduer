#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo "$1"
  fi

  echo "$($PSQL "SELECT * FROM services")" | sed 's/ |/)/'
  read SERVICE_ID_SELECTED
  SERVICE_SELECTED=$(echo $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") | sed -E 's/^ *| *$//g')

  # if not service
  if [[ -z $SERVICE_SELECTED ]]
  then
    # return to start main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  
  # if it is a valid service
  else
    # get phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$( echo $($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'") | sed -E 's/^ *| *$//g')

    # if customer not in record
    if [[ -z $CUSTOMER_NAME ]]
    then
      # get name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # add new customer
      ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # get time of appointment
    echo -e "\nWhat time would you like your $SERVICE_SELECTED, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # add appointment to db
    ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    
    # print appointment that has been made
    echo -e "\nI have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

MAIN_MENU
