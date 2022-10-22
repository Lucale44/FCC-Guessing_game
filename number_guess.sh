#!/bin/bash
#Program that prompts a user to guess a random number

#PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

HOME() {
NUM=$(( RANDOM % 1000 + 1 ))
X=0
echo "Enter your username: "
read NAME


CHECK_NAME=$($PSQL "SELECT username FROM users WHERE username = '$NAME'")
if [[ -z $CHECK_NAME ]]
then
  NEW_USER=$($PSQL "INSERT INTO users(username, played, best) VALUES('$NAME', 0, 9999)")
  echo "Welcome, "$NAME"! It looks like this is your first time here."
else
  GET_USER=$($PSQL "SELECT username, played, best FROM users WHERE username = '$NAME'")
  echo "$GET_USER" | while read EXNAME BAR PLAYED BAR BEST
    do
      echo "Welcome back, "$EXNAME"! You have played "$PLAYED" games, and your best game took "$BEST" guesses."
    done
  echo "Guess the secret number between 1 and 1000:"
fi

  START() {    
  while read GUESS
  do
  X=$(( $X + 1 ))
  
    if [[ "$GUESS" =~ [0-9] ]]
    then
      TEST
    else
      echo "That is not an integer, guess again:"
      START
    fi
  done
  }

  TEST() {
    if [[ "$NUM" == "$GUESS" ]]
    then
      echo "You guessed it in "$X" tries. The secret number was "$NUM". Nice job!"
      GET_PLAYED
    elif [[ "$NUM" -lt "$GUESS" ]]
    then
      TOO_HIGH
    else
      TOO_LOW
    fi
  }

  TOO_HIGH() {
    echo "It's lower than that, guess again:"
  START
  }

  TOO_LOW() {
    echo "It's higher than that, guess again:"
  START
  }

  GET_PLAYED() {
    PLAYED=$($PSQL "SELECT played FROM users WHERE username = '$NAME'")
    NEW_PLAYED=$(( $PLAYED + 1 ))
    GET_BEST
  }

  GET_BEST() {
    BEST=$($PSQL "SELECT best FROM users WHERE username = '$NAME'")
    if [[ $X -le $BEST ]]
    then
      NEW_BEST=$X
    else
      NEW_BEST=$BEST
    fi
    FINAL
  }

  FINAL() {
    UPDATE=$($PSQL "UPDATE users SET username = '$NAME', played = $NEW_PLAYED, best = $NEW_BEST WHERE username = '$NAME'")
    exit 0
  }
START
}
HOME
