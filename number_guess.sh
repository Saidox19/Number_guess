#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo  "Enter your username:"

read USERNAME

USER_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME'")

#If not available
if [[ -z $USER_ID ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME_REUSLT=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM guesses WHERE username_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM guesses WHERE username_id=$USER_ID")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
fi

# Ask player to choose a number between 1 and 1000
echo -e "Guess the secret number between 1 and 1000:"
read GUESS

#Generate a random number
SECRET_NUM=$(( $RANDOM % 1000 + 1 ))
ATTEMPT=1

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    ATTEMPT=$(( $ATTEMPT+1 ))
    continue
  fi

  if [[ $GUESS -gt $SECRET_NUM ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    ATTEMPT=$(( $ATTEMPT+1 ))
  elif [[ $GUESS -lt $SECRET_NUM ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
    ATTEMPT=$(( $ATTEMPT+1 ))
   else
    echo "You guessed it in $ATTEMPT tries. The secret number was $SECRET_NUM. Nice job!"
    break
  fi
done

if [[ -z $GAMES_PLAYED ]]
then
  GAMES_PLAYED=$(( $GAMES_PLAYED+1 ))
  USER_ID=$($PSQL "SELECT username_id FROM usernames WHERE username='$USERNAME'")
  INSERT_INTO_GUESS=$($PSQL "INSERT INTO guesses(username_id, games_played, best_game) VALUES($USER_ID, $GAMES_PLAYED, $ATTEMPT)")
else
  GAMES_PLAYED=$(( $GAMES_PLAYED+1 ))
  UPDATE_GAME_PLAYED=$($PSQL "UPDATE guesses SET games_played=$GAMES_PLAYED WHERE username_id=$USER_ID")
fi

if [[ $ATTEMPT -lt $BEST_GAME ]]
then
  UPDATE_BEST_PLAY=$($PSQL "UPDATE guesses SET best_game=$ATTEMPT WHERE username_id=$USER_ID")
fi



