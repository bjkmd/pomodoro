#!/usr/bin/env bash

SLEEP_DURATION=${SLEEP_DURATION:=1}  # default to 1 second, use to speed up tests

progress-bar() {
  local duration
  local columns
  local space_available
  local fit_to_screen  
  local space_reserved

  space_reserved=6   # reserved width for the percentage value
  duration=${1}
  columns=$(tput cols)
  space_available=$(( columns-space_reserved ))

  if (( duration < space_available )); then 
  	fit_to_screen=1; 
  else 
    fit_to_screen=$(( duration / space_available )); 
    fit_to_screen=$((fit_to_screen+1)); 
  fi

  already_done() { for ((done=0; done<(elapsed / fit_to_screen) ; done=done+1 )); do printf "▇"; done }
  remaining() { for (( remain=(elapsed/fit_to_screen) ; remain<(duration/fit_to_screen) ; remain=remain+1 )); do printf " "; done }
  percentage() { printf "| %s%%" $(( ((elapsed)*100)/(duration)*100/100 )); }
  clean_line() { printf "\r"; }

  for (( elapsed=1; elapsed<=duration; elapsed=elapsed+1 )); do
      columns=$(tput cols)
      space_available=$(( columns-space_reserved ))
      already_done; remaining; percentage
      sleep "$SLEEP_DURATION"
      clean_line
  done
  clean_line
}

# Usage: > tomat 25 'Task name'

MINUTES=${1}
# MINUTES=1
echo "Название задачи:"
# TASK_NAME=${2}
read TASK_NAME

START_TIMESTAMP=`date +"%Y-%m-%d %T"`
FILE=`date +"%Y_%m_%d_done.txt"`
checkbox="[v]"

start=$SECONDS

function cleanup {
  end=$SECONDS
  duration=$((( end - start )/60))
  END_TIME=`date +"%T"`
  if ((duration < MINUTES))
    then
      say "Жаль!"
      checkbox="[ ]"
  fi

  # Логируем в журнал сделанную задачу
  echo "${START_TIMESTAMP} ${END_TIME}| ${checkbox} ${TASK_NAME} | ${duration} мин." >> $FILE #done.txt

}
trap cleanup EXIT

# Выключаем уведомления MacOS
# osascript -e "tell application \"System Events\" to keystroke \"D\" using {command down, shift down, option down, control down}"
# Очищаем терминал перед запуском прогрессбара
reset

# Мак умеет разговаривать
say "Задача: ${TASK_NAME}."
say "Начали!"
echo "${TASK_NAME} ${MINUTES} мин."
# Функция обеспечивает паузу и показ прогресс-бара в терминале
progress-bar $((MINUTES*60))
# osascript -e "set Volume output muted false"
say "Вы молодец, так держать!"