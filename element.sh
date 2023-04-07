#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

#if no argument is given
if [[ ! $1 ]]
then
  echo "Please provide an element as an argument."
#argument is given
else

  #if input is a number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    #check if there is a matching atomic_number
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$1")
    #if no atomic number
    if [[ -z $ATOMIC_NUMBER ]]
    then
      echo "I could not find that element in the database."
      exit
    #else element exists
    else
      #assign element symbol & element name
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
      ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$ATOMIC_NUMBER")
    fi

  #else if input is a letter/string, 1 - 2 chars
  elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
  then
    #check if there is a matching symbol
    SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$1'")
    #if no symbol
    if [[ -z $SYMBOL ]]
    then
      echo "I could not find that element in the database."
      exit
    #else element exists
    else
      #assign element atomic number & element name
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$SYMBOL'")
      ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE symbol='$SYMBOL'")
    fi

  #else input is a string
  else
    #check if there is a matching name
    ELEMENT_NAME=$($PSQL "SELECT name FROM elements WHERE name='$1'")
    #if no element name
    if [[ -z $ELEMENT_NAME ]]
    then
      echo "I could not find that element in the database."
      exit
    #else element exists
    else
      #assign element atomic number & element symbol
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$ELEMENT_NAME'")
      SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$ELEMENT_NAME'")
    fi
  fi

  #get type, atomic_mass, melting_point, boiling_point
  TYPE=$($PSQL "SELECT type FROM properties FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER")
  ATOMIC_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")
  BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$ATOMIC_NUMBER")

  #print element info
  echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
