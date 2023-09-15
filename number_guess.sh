#!/bin/bash

#Random number guessing game
PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"
# Generate a random number between 1 and 1000
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

# Asking player for username
echo -e "\n~~~~~~~~  Welcome to a number guessing game!  ~~~~~~~~"
echo "Enter your username:"
read USER_NAME

# Checking if player in database
GET_USER_INFO=$($PSQL "SELECT name, games_played, best_game FROM players WHERE name = '$USER_NAME'")
if [[ -z $GET_USER_INFO ]]
then
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  ADD_USER_INFO=$($PSQL "INSERT INTO players(name, games_played, best_game) VALUES('$USER_NAME', 0, 0)")
else 
  echo $GET_USER_INFO | while read NAME BAR GAMES_PLAYED BAR BEST_GAME
  do
    echo -e "\nWelcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
  done
fi

# Ask player for a number between 1 and 1000
echo "Guess the secret number between 1 and 1000:"
N=0

GUESS() {
  read NUMBER
# check if NUMBER is integer
if [[ ! $NUMBER =~ ^[0-9]+$ ]]
then
  echo "That is not an integer, guess again:"
  GUESS
else
# check if NUMBER is equal to RANDOM
  if [[ $NUMBER -eq $RANDOM_NUMBER ]]
  then
    N=$(( N+1 ))
    echo "You guessed it in $N tries. The secret number was $RANDOM_NUMBER. Nice job!"
  # check if NUMBER is higher
  elif [[ $NUMBER -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    N=$(( N+1 ))
    GUESS
  # check if NUMBER is lower
  elif [[ $NUMBER -gt $RANDOM_NUMBER ]] 
  then
    echo "It's lower than that, guess again:"
    N=$(( N+1 ))
    GUESS
  fi
fi
}
GUESS

# insert data from last game in database
echo $GET_USER_INFO | while read NAME BAR GAMES_PLAYED BAR BEST_GAME
do
  NEW_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  INSERT_GAME_PLAYED=$($PSQL "UPDATE players SET games_played = $NEW_GAMES_PLAYED WHERE name = '$USER_NAME'")
  if [[ $BEST_GAME -eq 0 ]]
  then
    INSERT_BEST_GAME=$($PSQL "UPDATE players SET best_game = $N WHERE name = '$USER_NAME'")
  else
    if [[ $N -lt $BEST_GAME ]]
    then 
      INSERT_BEST_GAME=$($PSQL "UPDATE players SET best_game = $N WHERE name = '$USER_NAME'")
    fi
  fi
done





