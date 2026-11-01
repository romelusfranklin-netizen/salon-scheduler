#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Main menu function
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Prompt for service_id
  read SERVICE_ID_SELECTED

  # Check if service exists
  SERVICE_EXIST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_EXIST ]]
  then
    # If service doesn't exist, show menu again
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # Get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # If customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    # Get appointment time
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # Output confirmation message
    print_service_name=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
    print_customer_name=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
    print_service_time=$(echo $SERVICE_TIME | sed -r 's/^ *| *$//g')

    echo -e "\nI have put you down for a $print_service_name at $print_service_time, $print_customer_name."
  fi
}

MAIN_MENU