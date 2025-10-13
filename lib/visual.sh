#!/usr/bin/env bash
# RestockR Visual Library
# Enhanced TUI components, ASCII art, animations, and decorators

# Prevent multiple sourcing
if [[ -n "${RESTOCKR_VISUAL_LOADED:-}" ]]; then
  return 0
fi
RESTOCKR_VISUAL_LOADED=true

# ============================================================================
# POKÉMON-THEMED COLOR PALETTE
# ============================================================================

if [[ -t 1 ]]; then
  # Text formatting
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  RESET="$(tput sgr0)"

  # Primary Theme Colors (Pokémon-inspired)
  POKE_YELLOW="$(tput setaf 11 2>/dev/null || tput setaf 3)"     # Pikachu / Electric Energy
  POKE_BLUE="$(tput setaf 14 2>/dev/null || tput setaf 6)"       # Squirtle / Water Energy
  POKE_GREEN="$(tput setaf 10 2>/dev/null || tput setaf 2)"      # Bulbasaur / Grass Energy
  POKE_RED="$(tput setaf 9 2>/dev/null || tput setaf 1)"         # Charmander / Fire Energy
  POKE_ORANGE="$(tput setaf 3)"                                   # Rapidash / Warning
  POKE_MAGENTA="$(tput setaf 13 2>/dev/null || tput setaf 5)"    # Mewtwo / Psychic
  POKE_GRAY="$(tput setaf 8 2>/dev/null || tput setaf 0)"        # Pokéball Shadow
  POKE_WHITE="$(tput setaf 15 2>/dev/null || tput setaf 7)"      # Pokécenter Interior

  # Legacy compatibility - map to Pokémon theme
  RED="${POKE_RED}"
  GREEN="${POKE_GREEN}"
  BLUE="${POKE_BLUE}"
  YELLOW="${POKE_YELLOW}"
  CYAN="${POKE_BLUE}"
  MAGENTA="${POKE_MAGENTA}"
  WHITE="${POKE_WHITE}"
  BLACK="$(tput setaf 0)"

  # Bright variants mapped to theme
  BRIGHT_RED="${POKE_RED}"
  BRIGHT_GREEN="${POKE_GREEN}"
  BRIGHT_YELLOW="${POKE_YELLOW}"
  BRIGHT_BLUE="${POKE_BLUE}"
  BRIGHT_MAGENTA="${POKE_MAGENTA}"
  BRIGHT_CYAN="${POKE_BLUE}"

  # Background colors
  BG_RED="$(tput setab 1)"
  BG_GREEN="$(tput setab 2)"
  BG_YELLOW="$(tput setab 3)"
  BG_BLUE="$(tput setab 4)"
  BG_MAGENTA="$(tput setab 5)"
  BG_CYAN="$(tput setab 6)"
  BG_BLACK="$(tput setab 0)"
  BG_GRAY="$(tput setab 8 2>/dev/null || tput setab 0)"

  # Special formatting
  UNDERLINE="$(tput smul)"
  NO_UNDERLINE="$(tput rmul)"
  REVERSE="$(tput rev)"
  BLINK="$(tput blink 2>/dev/null || echo '')"
else
  # No TTY - disable all colors and formatting
  BOLD=""
  DIM=""
  RESET=""
  POKE_YELLOW=""
  POKE_BLUE=""
  POKE_GREEN=""
  POKE_RED=""
  POKE_ORANGE=""
  POKE_MAGENTA=""
  POKE_GRAY=""
  POKE_WHITE=""
  RED=""
  GREEN=""
  BLUE=""
  YELLOW=""
  CYAN=""
  MAGENTA=""
  WHITE=""
  BLACK=""
  BRIGHT_RED=""
  BRIGHT_GREEN=""
  BRIGHT_YELLOW=""
  BRIGHT_BLUE=""
  BRIGHT_MAGENTA=""
  BRIGHT_CYAN=""
  BG_RED=""
  BG_GREEN=""
  BG_YELLOW=""
  BG_BLUE=""
  BG_MAGENTA=""
  BG_CYAN=""
  BG_BLACK=""
  BG_GRAY=""
  UNDERLINE=""
  NO_UNDERLINE=""
  REVERSE=""
  BLINK=""
fi

# ============================================================================
# DYNAMIC ASCII ART RENDERER
# ============================================================================

# Pokémon-style Pokeball - Extra Large (for terminals 100+ cols)
POKEBALL_XL='
                           .+##################+.
                      .####+++++++++++++++++++++++####.
                  .#######+++++++++++++++++++++++++++++#######.
                ###.        -+++++++++++++++++++++++++++++++++++###
              ##.             +++++++++++++++++++++++++++++++++++++##
            ##                 +++++++++++++++++++++++++++++++++++++++##
          .#.                  +++++++++++++++++++++++++++++++++++++++++#.
         .#+                  +++++++++++++++++++++++++++++++++++++++++++#.
        ##++                 ++++++++++++++++++++++++++++++++++++++++++++++##
       ##+++               .+++++++++++++++++++++++++++++++++++++++++++++++++##
      ##++++-           .++++++++++++++++++################++++++++++++++++++++##
     -#++++++#+-....--+++++++++++++++++#######################+++++++++++++++++#-
     #+++++++++++++++++++++++++++++++#########.        .########++++++++++++++++#+
    ##+++++++++++++++++++++++++##############.  -     .-  .#####++++++++++++++++++#
    #++++++++++++++++++++################.    .        .    ########++++++++++++++#
    #++++++++++++##########################   .         .     ###########+++++++++++#.
   -#++##################################-             -       ##################++++#-
   -#####################################   -        #   .    ###################+++#-
   -######################              ######                 #######################-
    ##########.-.                         .##################+          -###########.
    ###++--------                              ###############-                   .###
    #++------------                                                                 .#
     #------------.                                                                  #
     -+-------------                                                                ++
      #+-------------                                                              .#
       #+--------------.                                                          .#
        ++---------------.                                                       ++
         .#----------------.                                                   -#.
           #+----------------.                                             .--+#
             ##+------------------..                                 ..----++#
               ###--------------------------------------...........--------###
                 .####-----------------------------------------------####.
                     .#####---------------------------------------#####.
                          .#########++++++------++++++#########.
'

# Pokéball - Large (for terminals 75+ cols)
POKEBALL_LARGE='
                      .+###############+.
                  ###+++++++++++++++++++++###
              .#####++++++++++++++++++++++++++##.
            ##.      -+++++++++++++++++++++++++++##
          #.           ++++++++++++++++++++++++++++##
        #-             ++++++++++++++++++++++++++++++##
      .#.              ++++++++++++++++++++++++++++++++#.
     +#+              ++++++++++++++++++++++++++++++++++#+
    ##++             ++++++++++++++++++++++++++++++++++++##
   ##+++-         .++++++++++++++############+++++++++++++#+
  -#+++++#+-..--++++++++++++++#################++++++++++++#-
  #++++++++++++++++++++++++++######.      .######+++++++++++#
 ##+++++++++++++++++++###########. -     .- -####+++++++++++##
 #++++++++++++##################- .        . #######+++++++++#
 #++++++######################## .         .  ###########++++#.
-#+#############################-          - +################-
-################################  -      # .#################-
-################+           ######        ###################-
 #########-.                  .###############+      -########.
 ###+-------                     ###########-              ###
 #+----------                                               .#
  #----------.                                              #
  -+-----------                                            ++
   #+-----------                                          .#
    #+-----------.                                       .#
     ++------------.                                    ++
      .#-------------.                                -#.
        #+--------------.                         .--+#
          #+----------------..                .----+#
            ##-----------------------------------##
              .##-----------------------------##-
                 .###---------------------###.
                      .#####++--+++#####.
'

# Pokéball - Medium (for terminals 50+ cols)
POKEBALL_MEDIUM='
            .+############+.
        .###++++++++++++++++++###.
      .##++++++++++++++++++++++++##.
     ##  -+++++++++++++++++++++++++##
    #.    +++++++++++++++++++++++++++#
   #-      ++++++++++++++++++++++++++#
  .#       +++++++++++++++++++++++++++#.
  #+      +++++++++++++++++++++++++++++#+
 ##++    +++++++++++++++++++++++++++++++##
 #++++  ++++++++++++#####++++++++++++++++#
-#+++++++++++++++++#######+++++++++++++++#+
#+++++++++++++++++#####.####+++++++++++++++#
#+++++++++++++########. -  #####+++++++++++#
#+++++############### .      ####+++++++++++#
#++##################        -##############-
##################              #############-
########-               ######################-
 ####------               #######      ######.
 #+--------                                 +#
  #---------                                 #
  -+----------                              ++
   #-----------                            .#
    #+----------.                         .#
     ++-----------.                      ++
      .#------------.                  -#.
        #+-------------.            .--+#
          ##----------------....-----##
            .##-------------------##.
               .###-----------###.
                   .####+++####.
'

# Pokéball - Compact (for terminals 35+ cols)
POKEBALL_COMPACT='
       .+###########+.
    ###++++++++++++++###
  ##+++++++++++++++++++++##
 #++++++++####+++++++++++++#
#+++++++###  ####++++++++++#
#+++############+++++++++++#
#####+      ######++++######
###--         ####       ###
#+---                     +#
 #----                   -#
  ##---                -##
    ####-----------####
       ###########
'

# Pokéball - Minimal (for terminals 20+ cols)
POKEBALL_MINIMAL='
     .+#####+.
   ##+++++++++##
  #++++++++++++#
 #++####++++++++#
##++#  #+++++++##
#++######++#####
##        ######
#+--          +#
 #--        --#
  ##------##
    ######
'

# Pokéball - Icon (for very narrow terminals < 20 cols)
POKEBALL_ICON='
   .####.
  ##+++##
 #++###++#
##++# #++##
#++####++#
 ##++#++#
  ######
'

# ============================================================================
# GRADIENT TEXT EFFECTS
# ============================================================================

print_gradient_text() {
  local text="$1"
  local gradient_type="${2:-red_to_blue}"  # red_to_blue, blue_to_green, rainbow

  # Simple implementation: alternate colors per character (Pokémon theme)
  case "${gradient_type}" in
    red_to_blue)
      local colors=("${POKE_RED}" "${POKE_MAGENTA}" "${POKE_BLUE}")
      ;;
    blue_to_green)
      local colors=("${POKE_BLUE}" "${POKE_GREEN}" "${POKE_YELLOW}")
      ;;
    rainbow)
      local colors=("${POKE_RED}" "${POKE_ORANGE}" "${POKE_YELLOW}" "${POKE_GREEN}" "${POKE_BLUE}" "${POKE_MAGENTA}")
      ;;
    *)
      printf "%s" "${text}"
      return
      ;;
  esac

  local i=0
  local color_count=${#colors[@]}
  while IFS= read -r -n1 char; do
    if [[ -n "${char}" ]]; then
      printf "%b%s" "${colors[$((i % color_count))]}" "${char}"
      ((i++))
    else
      printf "\n"
    fi
  done <<< "${text}"
  printf "%b" "${RESET}"
}

# ============================================================================
# BOX DRAWING & DECORATORS
# ============================================================================

# Unicode box drawing characters
if [[ "${LANG:-}" =~ UTF-8 ]] || [[ "${LC_ALL:-}" =~ UTF-8 ]]; then
  BOX_H="═"          # Horizontal
  BOX_V="║"          # Vertical
  BOX_TL="╔"         # Top-left
  BOX_TR="╗"         # Top-right
  BOX_BL="╚"         # Bottom-left
  BOX_BR="╝"         # Bottom-right
  BOX_VR="╠"         # Vertical-right (left edge)
  BOX_VL="╣"         # Vertical-left (right edge)
  BOX_HU="╩"         # Horizontal-up (bottom edge)
  BOX_HD="╦"         # Horizontal-down (top edge)
  BOX_CROSS="╬"      # Cross

  # Light box drawing
  BOX_H_LIGHT="─"
  BOX_V_LIGHT="│"
  BOX_TL_LIGHT="┌"
  BOX_TR_LIGHT="┐"
  BOX_BL_LIGHT="└"
  BOX_BR_LIGHT="┘"

  # Special characters
  ARROW_RIGHT="→"
  ARROW_LEFT="←"
  ARROW_UP="↑"
  ARROW_DOWN="↓"
  CHECKMARK="✓"
  CROSSMARK="✗"
  BULLET="•"
  STAR="★"
  HEART="♥"
  DIAMOND="◆"
  CIRCLE="●"
  SQUARE="■"
else
  # ASCII fallbacks
  BOX_H="="
  BOX_V="|"
  BOX_TL="+"
  BOX_TR="+"
  BOX_BL="+"
  BOX_BR="+"
  BOX_VR="+"
  BOX_VL="+"
  BOX_HU="+"
  BOX_HD="+"
  BOX_CROSS="+"

  BOX_H_LIGHT="-"
  BOX_V_LIGHT="|"
  BOX_TL_LIGHT="+"
  BOX_TR_LIGHT="+"
  BOX_BL_LIGHT="+"
  BOX_BR_LIGHT="+"

  ARROW_RIGHT=">"
  ARROW_LEFT="<"
  ARROW_UP="^"
  ARROW_DOWN="v"
  CHECKMARK="+"
  CROSSMARK="x"
  BULLET="*"
  STAR="*"
  HEART="<3"
  DIAMOND="<>"
  CIRCLE="o"
  SQUARE="#"
fi

# Draw a fancy box around text
draw_fancy_box() {
  local text="$1"
  local color="${2:-${POKE_BLUE}}"
  local style="${3:-double}"  # double, single, bold

  update_term_cols

  # Select box style
  local h v tl tr bl br
  case "${style}" in
    single)
      h="${BOX_H_LIGHT}" v="${BOX_V_LIGHT}"
      tl="${BOX_TL_LIGHT}" tr="${BOX_TR_LIGHT}"
      bl="${BOX_BL_LIGHT}" br="${BOX_BR_LIGHT}"
      ;;
    bold)
      h="━" v="┃" tl="┏" tr="┓" bl="┗" br="┛"
      # Fallback if not available
      if [[ "${LANG:-}" != *UTF-8* ]]; then
        h="${BOX_H}" v="${BOX_V}"
        tl="${BOX_TL}" tr="${BOX_TR}"
        bl="${BOX_BL}" br="${BOX_BR}"
      fi
      ;;
    *)  # double
      h="${BOX_H}" v="${BOX_V}"
      tl="${BOX_TL}" tr="${BOX_TR}"
      bl="${BOX_BL}" br="${BOX_BR}"
      ;;
  esac

  # Calculate box width
  local text_len=${#text}
  local box_width=$((text_len + 4))  # +4 for padding and borders

  # Draw top border
  printf "%b%s" "${color}${BOLD}" "${tl}"
  printf "%${box_width}s" | tr ' ' "${h}"
  printf "%s%b\n" "${tr}" "${RESET}"

  # Draw text line
  printf "%b%s${color}${BOLD}  %s  %s%b\n" "${color}${BOLD}" "${v}" "${RESET}${text}${color}${BOLD}" "${v}" "${RESET}"

  # Draw bottom border
  printf "%b%s" "${color}${BOLD}" "${bl}"
  printf "%${box_width}s" | tr ' ' "${h}"
  printf "%s%b\n" "${br}" "${RESET}"
}

# Draw a title banner
draw_banner() {
  local title="$1"
  local subtitle="${2:-}"
  local color="${3:-${POKE_BLUE}}"

  update_term_cols

  local title_len=${#title}
  local subtitle_len=${#subtitle}
  local max_len=$title_len
  (( subtitle_len > max_len )) && max_len=$subtitle_len

  local banner_width=$((max_len + 8))
  (( banner_width > TERM_COLS )) && banner_width=$TERM_COLS

  # Top border
  printf "\n%b" "${color}${BOLD}"
  printf "${BOX_TL}"
  printf "%$((banner_width - 2))s" | tr ' ' "${BOX_H}"
  printf "${BOX_TR}\n"

  # Title line
  local title_pad=$(( (banner_width - title_len - 2) / 2 ))
  printf "${BOX_V}"
  printf "%${title_pad}s" ""
  printf "%b%s%b" "${WHITE}${BOLD}" "${title}" "${color}"
  printf "%$((banner_width - title_len - title_pad - 2))s" ""
  printf "${BOX_V}\n"

  # Subtitle if provided
  if [[ -n "${subtitle}" ]]; then
    printf "${BOX_VR}"
    printf "%$((banner_width - 2))s" | tr ' ' "${BOX_H}"
    printf "${BOX_VL}\n"

    local subtitle_pad=$(( (banner_width - subtitle_len - 2) / 2 ))
    printf "${BOX_V}"
    printf "%${subtitle_pad}s" ""
    printf "%b%s%b" "${DIM}" "${subtitle}" "${color}"
    printf "%$((banner_width - subtitle_len - subtitle_pad - 2))s" ""
    printf "${BOX_V}\n"
  fi

  # Bottom border
  printf "${BOX_BL}"
  printf "%$((banner_width - 2))s" | tr ' ' "${BOX_H}"
  printf "${BOX_BR}%b\n\n" "${RESET}"
}

# ============================================================================
# LOADING ANIMATIONS
# ============================================================================

# Spinner animation
spinner() {
  local message="$1"
  local duration="${2:-5}"  # seconds
  local pid="${3:-}"  # Optional: PID to monitor

  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
  # ASCII fallback
  if [[ "${LANG:-}" != *UTF-8* ]]; then
    frames=("|" "/" "-" "\\")
  fi

  local frame_count=${#frames[@]}
  local i=0
  local elapsed=0

  # Hide cursor
  tput civis 2>/dev/null || true

  while (( elapsed < duration )); do
    if [[ -n "${pid}" ]] && ! kill -0 "${pid}" 2>/dev/null; then
      break
    fi

    printf "\r%b%s%b %s" "${POKE_YELLOW}${BOLD}" "${frames[$i]}" "${RESET}" "${message}"
    sleep 0.1
    i=$(( (i + 1) % frame_count ))
    elapsed=$((elapsed + 1))
  done

  # Show cursor
  tput cnorm 2>/dev/null || true
  printf "\r%*s\r" "${TERM_COLS}" ""  # Clear line
}

# Progress bar
progress_bar() {
  local current="$1"
  local total="$2"
  local message="${3:-Progress}"
  local bar_width=40

  update_term_cols
  (( bar_width > TERM_COLS - 30 )) && bar_width=$((TERM_COLS - 30))

  local percent=$(( current * 100 / total ))
  local filled=$(( current * bar_width / total ))
  local empty=$(( bar_width - filled ))

  # Color based on progress (Pokémon theme)
  local bar_color="${POKE_RED}"
  (( percent >= 33 )) && bar_color="${POKE_ORANGE}"
  (( percent >= 66 )) && bar_color="${POKE_GREEN}"

  printf "\r%s: [%b" "${message}" "${bar_color}${BOLD}"
  printf "%${filled}s" | tr ' ' '█'
  printf "%b" "${DIM}"
  printf "%${empty}s" | tr ' ' '░'
  printf "%b] %3d%%" "${RESET}" "${percent}"
}

# Pulsing dots animation
pulsing_dots() {
  local message="$1"
  local duration="${2:-5}"

  local dots=("   " ".  " ".. " "...")
  local i=0
  local elapsed=0

  while (( elapsed < duration )); do
    printf "\r%b%s%s%b" "${POKE_BLUE}${BOLD}" "${message}" "${dots[$i]}" "${RESET}"
    sleep 0.3
    i=$(( (i + 1) % 4 ))
    elapsed=$((elapsed + 1))
  done

  printf "\r%*s\r" "${TERM_COLS}" ""  # Clear line
}

# ============================================================================
# ENHANCED HEADER WITH DYNAMIC ASCII ART
# ============================================================================

print_enhanced_header() {
  local show_pokeball="${1:-true}"
  update_term_cols

  printf "\n"

  # Title with Pokémon theme colors (if wide enough)
  if (( TERM_COLS >= 60 )); then
    draw_banner "⚡ RESTOCKR MOBILE ⚡" "Developer Release • by Q" "${POKE_YELLOW}"
  else
    # Simple centered title for narrow terminals
    center_line "${BOLD}${POKE_YELLOW}⚡ RESTOCKR MOBILE ⚡${RESET}"
    center_line "${POKE_GRAY}Developer Release${RESET}"
    printf "\n"
  fi

  if [[ "${show_pokeball}" != "true" ]]; then
    return
  fi

  # Select appropriate Pokéball based on terminal width
  local pokeball_art
  if (( TERM_COLS >= 100 )); then
    pokeball_art="${POKEBALL_XL}"
  elif (( TERM_COLS >= 75 )); then
    pokeball_art="${POKEBALL_LARGE}"
  elif (( TERM_COLS >= 50 )); then
    pokeball_art="${POKEBALL_MEDIUM}"
  elif (( TERM_COLS >= 35 )); then
    pokeball_art="${POKEBALL_COMPACT}"
  elif (( TERM_COLS >= 20 )); then
    pokeball_art="${POKEBALL_MINIMAL}"
  elif (( TERM_COLS >= 15 )); then
    pokeball_art="${POKEBALL_ICON}"
  else
    # Too narrow for any art
    center_line "${DIM}[ ${CIRCLE} POKÉBALL ]${RESET}"
    printf "\n"
    return
  fi

  # Center and color the Pokéball (red top, white bottom)
  # First, find the maximum line width to center consistently
  local max_width=0
  while IFS= read -r line; do
    local line_len=${#line}
    (( line_len > max_width )) && max_width=$line_len
  done <<< "${pokeball_art}"

  # Calculate left padding for centering
  local left_pad=$(( (TERM_COLS - max_width) / 2 ))
  (( left_pad < 0 )) && left_pad=0

  # Now print each line with consistent padding and coloring
  while IFS= read -r line; do
    if [[ "${line}" =~ ^[[:space:]]*$ ]]; then
      printf "\n"
      continue
    fi

    # Determine if line is in top (red) or bottom (white) half
    # Simple heuristic: lines with many + are top, lines with - are bottom
    local plus_count=$(echo "${line}" | tr -cd '+' | wc -c | tr -d ' ')
    local dash_count=$(echo "${line}" | tr -cd '-' | wc -c | tr -d ' ')

    # Print with consistent left padding
    printf "%*s" "${left_pad}" ""

    if (( plus_count > dash_count )); then
      # Top half - Pokéball red (Charmander fire energy)
      printf "%b%s%b\n" "${POKE_RED}${BOLD}" "${line}" "${RESET}"
    elif (( dash_count > 3 )); then
      # Bottom half - Pokéball shadow (dim)
      printf "%b%s%b\n" "${POKE_GRAY}" "${line}" "${RESET}"
    else
      # Middle section - white separator band
      printf "%b%s%b\n" "${POKE_WHITE}${BOLD}" "${line}" "${RESET}"
    fi
  done <<< "${pokeball_art}"

  printf "\n"
}

# ============================================================================
# STATUS INDICATORS
# ============================================================================

status_icon() {
  local status="$1"  # success, error, warning, info, working

  case "${status}" in
    success)
      printf "%b%s%b" "${POKE_GREEN}${BOLD}" "${CHECKMARK}" "${RESET}"
      ;;
    error)
      printf "%b%s%b" "${POKE_RED}${BOLD}" "${CROSSMARK}" "${RESET}"
      ;;
    warning)
      printf "%b!%b" "${POKE_ORANGE}${BOLD}" "${RESET}"
      ;;
    info)
      printf "%bi%b" "${POKE_BLUE}${BOLD}" "${RESET}"
      ;;
    working)
      printf "%b...%b" "${POKE_BLUE}" "${RESET}"
      ;;
    *)
      printf "%b%s%b" "${POKE_GRAY}" "${BULLET}" "${RESET}"
      ;;
  esac
}

# Enhanced status messages
status_message() {
  local status="$1"
  local message="$2"

  printf "  "
  status_icon "${status}"
  printf " %s\n" "${message}"
}

# ============================================================================
# DIVIDERS & SEPARATORS
# ============================================================================

draw_divider() {
  local char="${1:-${BOX_H}}"
  local color="${2:-${POKE_GRAY}}"

  update_term_cols
  printf "%b" "${color}"
  printf "%${TERM_COLS}s" | tr ' ' "${char}"
  printf "%b\n" "${RESET}"
}

draw_gradient_divider() {
  update_term_cols
  local colors=("${POKE_RED}" "${POKE_ORANGE}" "${POKE_YELLOW}" "${POKE_GREEN}" "${POKE_BLUE}" "${POKE_MAGENTA}")
  local color_count=${#colors[@]}

  for ((i=0; i<TERM_COLS; i++)); do
    printf "%b${BOX_H}" "${colors[$((i % color_count))]}"
  done
  printf "%b\n" "${RESET}"
}

# ============================================================================
# MENU HELPERS
# ============================================================================

draw_menu_header() {
  local title="$1"

  printf "\n"
  draw_divider "${BOX_H}" "${POKE_YELLOW}${BOLD}"
  center_line "${POKE_WHITE}${BOLD}${title}${RESET}"
  draw_divider "${BOX_H}" "${POKE_YELLOW}${BOLD}"
  printf "\n"
}

draw_menu_option() {
  local number="$1"
  local text="$2"
  local color="${3:-${POKE_BLUE}}"
  local icon="${4:-}"

  printf "  %b[%s]%b " "${color}${BOLD}" "${number}" "${RESET}"

  if [[ -n "${icon}" ]]; then
    printf "%s " "${icon}"
  fi

  printf "%s\n" "${text}"
}

draw_menu_footer() {
  printf "\n"
  draw_divider "${BOX_H_LIGHT}" "${POKE_GRAY}"
}

# Log initialization
[[ "${DEBUG_MODE:-false}" == "true" ]] && echo "[DEBUG] RestockR visual library loaded" >&2 || true
