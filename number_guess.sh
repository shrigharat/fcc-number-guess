#!/bin/bash

# USERS TABLE SCHEMA
# USER user_id SERIAL PRIMARY KEY,username VARCHAR(22) NOT NULL, games_played INTEGER, best_game INTEGER

# PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

# echo "Enter your username:"
# read USERNAME_INPUT

# # check if username exists
# CURRENT_USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME_INPUT'")
# if [[ -z $CURRENT_USER ]]
# then
#   # if doesnt exist
#   # create user
#   INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME_INPUT', 0, 2147483647)")
#   if [[ $INSERT_USER_RESULT = "INSERT 0 1" ]]
#   then
#     CURRENT_USER=$($PSQL "SELECT * FROM users WHERE username='$USERNAME_INPUT'")
#     # show new user message
#     IFS='|'
#     read -ra VALUES <<< "$CURRENT_USER"
#     echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
#   fi
# else
#   # if exists show details input message
#   IFS='|'
#   read -ra VALUES <<< "$CURRENT_USER"
#   echo "Welcome back, ${VALUES[1]}! You have played ${VALUES[2]} games, and your best game took ${VALUES[3]} guesses."
# fi

# # maintain count of tries
# NUMBER_OF_GUESSES=0

# # generate random number
# RANDOM_NUMBER=$((1 + RANDOM % 1000))
# echo "Number to guess: $RANDOM_NUMBER"

# # infinite loop to get user input, until he guesses the correct number
# while [[ $USER_GUESS -ne $RANDOM_NUMBER ]]; do
#   # show guess number message   
#   echo "Guess the secret number between 1 and 1000:"
#   # read user input for the guess
#   read USER_GUESS
#   # if guess is correct show message 
#   if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
#   then
#     echo "That is not an integer, guess again:"
#     ((NUMBER_OF_GUESSES++))
#   elif  [ $USER_GUESS -lt $RANDOM_NUMBER ]
#   then
#     # if guess is lower show message
#     echo "It's higher than that, guess again:"
#     ((NUMBER_OF_GUESSES++))
#   elif [ $USER_GUESS -gt $RANDOM_NUMBER ]
#   then
#     # if guess is higher show message
#     echo "It's lower than that, guess again:"
#     ((NUMBER_OF_GUESSES++))
#   fi
# done

# # echo "Number of tries: $NUMBER_OF_GUESSES"

# # check if this is the best game for this user
# BEST_GAME=$((VALUES[3]))
# GAMES_PLAYED=$((VALUES[2]))
# ((GAMES_PLAYED++))
# USER_ID=$((VALUES[0]))

# if [ $BEST_GAME -gt $NUMBER_OF_GUESSES ]
# then
#   BEST_GAME=$NUMBER_OF_GUESSES
# fi

# # echo "BEST_GAME: $BEST_GAME, GAMES_PLAYED: $GAMES_PLAYED"
# # enter updated games_played and best_game
# echo "$PSQL UPDATE users SET games_played = $GAMES_PLAYED,best_game = $BEST_GAME WHERE username='$USERNAME_INPUT'"
# UPDATE_USER=$($PSQL "update users set games_played=$GAMES_PLAYED,best_game=$BEST_GAME WHERE username='$USERNAME_INPUT'")
# echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

PSQL="psql --username=freecodecamp --dbname=game -t --no-align -c"

MENU() {
    if [[ $1 ]]; then
        echo -e "$1\n"
    fi
    echo "Enter your username:"
    read USERNAME
}

GUESS() {
    if [[ $1 ]]; then
        echo -e "$1"
    else
        echo -e "Guess the secret number between 1 and 1000:"
    fi
    read NUMBER
}

MENU

while [[ -z $USERNAME ]]; do
    MENU "The username filed is required."
done

# --- Find user by name ----
USER=$($PSQL "SELECT username,games_played,best_game FROM users WHERE username='$USERNAME'")
if [[ -z $USER ]]; then
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    IFS='|' read -r -a USER_ARRAY <<<"$USER"
    for ((i = 0; i <= ${#USER_ARRAY[@]} - 1; i++)); do
        USER_ARRAY[$i]=$(echo ${USER_ARRAY[$i]} | sed -e 's/^+ | +$//')
    done
    echo "Welcome back, ${USER_ARRAY[0]}! You have played ${USER_ARRAY[1]} games, and your best game took ${USER_ARRAY[2]} guesses."
fi

# ---- RANDOM NUMBER && NUMBER OF GUESSES
GUESS_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=1

GUESS

while [[ $NUMBER -ne $GUESS_NUMBER ]]; do
    if ! [[ $NUMBER =~ ^[0-9]+$ ]]; then
        GUESS "That is not an integer, guess again:"
    elif [[ $NUMBER -lt $GUESS_NUMBER ]]; then
        GUESS "It's higher than that, guess again:"
    elif [[ $NUMBER -gt $GUESS_NUMBER ]]; then
        GUESS "It's lower than that, guess again:"
    fi
    ((GUESS_COUNT++))
done

if [[ -z "${USER_ARRAY}" ]]; then
    UPDATE_USER=$($PSQL "UPDATE users SET games_played=1,best_game=$GUESS_COUNT WHERE username='$USERNAME'")
else
    GAMES_PLAYED=$((${USER_ARRAY[1]} + 1))
    if [[ $GUESS_COUNT -lt ${USER_ARRAY[2]} ]]; then
        UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED,best_game=$GUESS_COUNT WHERE username='$USERNAME'")
    else
        UPDATE_USER=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
    fi
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $GUESS_NUMBER. Nice job!"
