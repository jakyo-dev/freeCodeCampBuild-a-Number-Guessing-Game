#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# ($PSQL "delete from users where username like 'user_%'") > /dev/null


MAIN() {
  echo "Enter your username:"
  read USERNAME

  # check if username exists
  USER_EXISTS=$($PSQL "select games_played,best_game from users where username='$USERNAME'")

  if [[ -z $USER_EXISTS ]] ; then
    # welcome and create new user
    CREATE_USER_RESULT=$($PSQL "insert into users(username) values('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GUESS_NUMBER $USERNAME 0
  else
    IFS="|" read USER_GAMES_PLAYED USER_BEST_GAME <<< $USER_EXISTS
    echo "Welcome back, $USERNAME! You have played $USER_GAMES_PLAYED games, and your best game took $USER_BEST_GAME guesses."
    GUESS_NUMBER $USERNAME $USER_GAMES_PLAYED
  fi

  # USER_GAMES_PLAYED=$($PSQL "select games_played from users where username='$USERNAME'")
  # USER_BEST_GAME=$($PSQL "select best_game from users where username='$USERNAME'")

  # if [[ ! -z $USER_EXISTS ]] ; then
  #   echo "Welcome back, $USERNAME! You have played $USER_GAMES_PLAYED games, and your best game took $USER_BEST_GAME guesses."
  # fi

  # GUESS_NUMBER $USERNAME $USER_GAMES_PLAYED
}

GUESS_NUMBER() {
  USERNAME=$1
  USER_GAMES_PLAYED=$2

  RANDOM_NUMBER=$((1 + $RANDOM % 1000))

  NUMBER_OF_TRIES=1

  echo "Guess the secret number between 1 and 1000:"
  read USER_RANDOM_NUMBER_INPUT

  while [[ ! $USER_RANDOM_NUMBER_INPUT = $RANDOM_NUMBER ]]
  do
    ((NUMBER_OF_TRIES++))

    if [[ ! $USER_RANDOM_NUMBER_INPUT =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    fi

    if [[ $USER_RANDOM_NUMBER_INPUT -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    fi

    if [[ $USER_RANDOM_NUMBER_INPUT -gt $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    fi

    read USER_RANDOM_NUMBER_INPUT

    if [[ $USER_RANDOM_NUMBER_INPUT -eq $RANDOM_NUMBER ]]
    then
      ($PSQL "update users set games_played = games_played + 1, best_game = LEAST(best_game,$NUMBER_OF_TRIES) where username='$USERNAME'") > /dev/null
      echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      break
    fi 
  done

  
}

MAIN
