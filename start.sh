#!/usr/bin/env bash
# RestockR Launcher
# Entry point for the RestockR Development Kit

set -euo pipefail

# Source all dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/envsetup.sh"
source "${SCRIPT_DIR}/install.sh"
source "${SCRIPT_DIR}/emulators.sh"

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup_start() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]] && [[ ${exit_code} -ne 130 ]]; then
    error "Launcher interrupted (exit code: ${exit_code})"
  fi
  log_plain "[INFO] start.sh exiting"
}

# Register cleanup trap (only if running as main script, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  trap cleanup_start EXIT INT TERM
fi

# ============================================================================
# FLUTTER EXECUTION FUNCTIONS
# ============================================================================

run_flutter_run() {
  debug "Executing flutter run $*"
  run_flutter_command "Launching ${APP_NAME}" flutter run "$@"
}

update_app_icons() {
  local icon_source="${SCRIPT_DIR}/Images/R_WhiteBG.png"

  if [[ ! -f "${icon_source}" ]]; then
    debug "App icon source not found at ${icon_source}; skipping refresh"
    return 0
  fi

  if ! command -v sips >/dev/null 2>&1; then
    warn "sips utility not available; skipping app icon refresh"
    return 0
  fi

  local ios_dir="${SCRIPT_DIR}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
  if [[ -d "${ios_dir}" ]]; then
    local ios_specs=(
      "Icon-App-20x20@1x.png:20"
      "Icon-App-20x20@2x.png:40"
      "Icon-App-20x20@3x.png:60"
      "Icon-App-29x29@1x.png:29"
      "Icon-App-29x29@2x.png:58"
      "Icon-App-29x29@3x.png:87"
      "Icon-App-40x40@1x.png:40"
      "Icon-App-40x40@2x.png:80"
      "Icon-App-40x40@3x.png:120"
      "Icon-App-60x60@2x.png:120"
      "Icon-App-60x60@3x.png:180"
      "Icon-App-76x76@1x.png:76"
      "Icon-App-76x76@2x.png:152"
      "Icon-App-83.5x83.5@2x.png:167"
      "Icon-App-1024x1024@1x.png:1024"
    )

    for spec in "${ios_specs[@]}"; do
      local name="${spec%%:*}"
      local size="${spec##*:}"
      local target="${ios_dir}/${name}"

      if [[ ! -f "${target}" || "${icon_source}" -nt "${target}" ]]; then
        if ! sips -s format png -z "${size}" "${size}" "${icon_source}" --out "${target}" >/dev/null 2>&1; then
          warn "Failed to update iOS icon ${name}"
        else
          debug "Updated iOS icon ${name}"
        fi
      fi
    done
  else
    debug "iOS app icon directory missing; skipping iOS icon refresh"
  fi

  local android_base="${SCRIPT_DIR}/android/app/src/main/res"
  if [[ -d "${android_base}" ]]; then
    local android_specs=(
      "mipmap-mdpi/ic_launcher.png:48"
      "mipmap-hdpi/ic_launcher.png:72"
      "mipmap-xhdpi/ic_launcher.png:96"
      "mipmap-xxhdpi/ic_launcher.png:144"
      "mipmap-xxxhdpi/ic_launcher.png:192"
    )

    for spec in "${android_specs[@]}"; do
      local rel="${spec%%:*}"
      local size="${spec##*:}"
      local target="${android_base}/${rel}"
      local dir
      dir="$(dirname "${target}")"

      if [[ ! -d "${dir}" ]]; then
        continue
      fi

      if [[ ! -f "${target}" || "${icon_source}" -nt "${target}" ]]; then
        if ! sips -s format png -z "${size}" "${size}" "${icon_source}" --out "${target}" >/dev/null 2>&1; then
          warn "Failed to update Android icon ${rel}"
        else
          debug "Updated Android icon ${rel}"
        fi
      fi
    done
  else
    debug "Android resource directory missing; skipping Android icon refresh"
  fi
}

# ============================================================================
# GUIDED QUICK LAUNCH
# ============================================================================

guided_quick_launch() {
  # Use enhanced menu header if available
  if type draw_menu_header >/dev/null 2>&1; then
    printf "\n"
    draw_menu_header "Quick Launch" "${BRIGHT_CYAN:-${CYAN:-${BLUE}}}"
  else
    printf "\n${GREEN}${BOLD}════════════════════════════════════════${RESET}\n"
    printf "${GREEN}${BOLD}   Quick Launch${RESET}\n"
    printf "${GREEN}${BOLD}════════════════════════════════════════${RESET}\n\n"
  fi

  info "Checking for connected devices..."

  # Check if any device is already running
  local device_id
  device_id="$(get_device_id_by_platform "" 2>/dev/null || true)"

  if [[ -n "${device_id}" ]]; then
    ok "Found ready device: ${device_id}"
    printf "\n${BOLD}Ready to launch!${RESET}\n"
    read -r -p "Launch RestockR now? [Y/n] " resp || true
    resp="${resp,,}"
    if [[ -z "${resp}" || "${resp}" == "y" || "${resp}" == "yes" ]]; then
      run_flutter_run -d "${device_id}"
      return 0
    fi
    return 0
  fi

  # No device ready - guide user through setup
  warn "No devices are currently running"
  printf "\n${BOLD}Let's start a device:${RESET}\n\n"

  local platform_choice=""

  # Determine available platforms
  local has_ios=false has_android=false
  if [[ "$(uname -s)" == "Darwin" ]] && command -v xcodebuild >/dev/null 2>&1; then
    has_ios=true
  fi
  if [[ -d "/Applications/Android Studio.app" ]] || [[ -n "${ANDROID_HOME:-}" ]]; then
    has_android=true
  fi

  # Offer platform choices
  if $has_ios && $has_android; then
    printf "  ${GREEN}[1]${RESET} iOS Simulator (recommended for Mac)\n"
    printf "  ${GREEN}[2]${RESET} Android Emulator\n"
    printf "  ${BLUE}[3]${RESET} Chrome (Web)\n"
    printf "  ${DIM}[4]${RESET} Cancel\n\n"
    read -r -p "Select platform: " platform_choice || true
  elif $has_ios; then
    printf "  ${GREEN}[1]${RESET} iOS Simulator\n"
    printf "  ${BLUE}[2]${RESET} Chrome (Web)\n"
    printf "  ${DIM}[3]${RESET} Cancel\n\n"
    read -r -p "Select platform: " platform_choice || true
  elif $has_android; then
    printf "  ${GREEN}[1]${RESET} Android Emulator\n"
    printf "  ${BLUE}[2]${RESET} Chrome (Web)\n"
    printf "  ${DIM}[3]${RESET} Cancel\n\n"
    read -r -p "Select platform: " platform_choice || true
  else
    printf "  ${BLUE}[1]${RESET} Chrome (Web)\n"
    printf "  ${DIM}[2]${RESET} Cancel\n\n"
    read -r -p "Select platform: " platform_choice || true
  fi

  # Launch based on choice
  case "${platform_choice}" in
    1)
      if $has_ios && $has_android; then
        # iOS chosen
        guided_ios_launch
      elif $has_ios; then
        # iOS (only option)
        guided_ios_launch
      elif $has_android; then
        # Android (only option)
        guided_android_launch
      else
        # Chrome (only option)
        info "Launching in Chrome..."
        run_flutter_run -d chrome
      fi
      ;;
    2)
      if $has_ios && $has_android; then
        # Android chosen
        guided_android_launch
      elif $has_ios; then
        # Chrome
        info "Launching in Chrome..."
        run_flutter_run -d chrome
      elif $has_android; then
        # Chrome
        info "Launching in Chrome..."
        run_flutter_run -d chrome
      else
        # Cancel
        info "Launch cancelled"
        return 1
      fi
      ;;
    3)
      if $has_ios && $has_android; then
        # Chrome chosen
        info "Launching in Chrome..."
        run_flutter_run -d chrome
      else
        # Cancel
        info "Launch cancelled"
        return 1
      fi
      ;;
    *)
      info "Launch cancelled"
      return 1
      ;;
  esac
}

guided_ios_launch() {
  timer_start "ios_launch_total"

  # Show header with Pokéball
  clear
  print_header
  printf "\n"

  info "Starting iOS Simulator launch sequence..."

  # Run comprehensive diagnostic check
  timer_start "diagnostic_check"
  printf "\n${BOLD}${CYAN}Pre-flight Diagnostics:${RESET}\n"

  local checks_passed=true
  local checks_output=""

  # Check 1: Xcode toolchain
  if [[ "${IOS_TOOLS_AVAILABLE}" != true ]]; then
    if ensure_ios_toolchain_status >/dev/null 2>&1; then
      checks_output+="  ${GREEN}✓${RESET} Xcode toolchain available\n"
    else
      checks_output+="  ${RED}✗${RESET} Xcode toolchain missing\n"
      checks_passed=false
    fi
  else
    checks_output+="  ${GREEN}✓${RESET} Xcode toolchain available\n"
  fi

  # Check 2: CocoaPods
  refresh_cocoapods_status >/dev/null 2>&1
  if [[ "${COCOAPODS_AVAILABLE}" == true ]]; then
    local pod_ver
    pod_ver="$(pod --version 2>/dev/null || echo "unknown")"
    checks_output+="  ${GREEN}✓${RESET} CocoaPods ${pod_ver} installed\n"
  else
    checks_output+="  ${RED}✗${RESET} CocoaPods not installed\n"
    checks_passed=false
  fi

  # Check 3: iOS Runtime availability
  if command -v xcrun >/dev/null 2>&1; then
    local runtime_check
    runtime_check=$(xcrun simctl list runtimes 2>/dev/null | grep "iOS" | wc -l | tr -d ' ' || echo "0")
    if [[ "${runtime_check}" -gt 0 ]]; then
      checks_output+="  ${GREEN}✓${RESET} iOS runtime available (${runtime_check} runtimes found)\n"
    else
      checks_output+="  ${RED}✗${RESET} No iOS runtimes installed\n"
      checks_passed=false
    fi
  else
    checks_output+="  ${YELLOW}⚠${RESET} Cannot check iOS runtimes (xcrun unavailable)\n"
  fi

  # Display all checks at once
  printf "%b" "${checks_output}"
  timer_end "diagnostic_check" "Diagnostic check"

  # If critical checks failed, offer to fix them
  if [[ "${checks_passed}" != true ]]; then
    printf "\n${YELLOW}${BOLD}Some requirements are missing.${RESET}\n"
    printf "Let me help you fix these issues.\n\n"

    # Fix iOS toolchain if needed
    if [[ "${IOS_TOOLS_AVAILABLE}" != true ]]; then
      timer_start "toolchain_check"
      if ! ensure_ios_toolchain_status; then
        error "iOS toolchain not available"
        suggest_simulator_not_found
        return 1
      fi
      timer_end "toolchain_check" "iOS toolchain setup"
    fi

    # Fix CocoaPods if needed
    if [[ "${COCOAPODS_AVAILABLE}" != true ]]; then
      timer_start "cocoapods_check"
      warn "CocoaPods is required for iOS development"
      printf "\n${BOLD}Install CocoaPods now?${RESET} [Y/n] "
      read -r -p "" resp || true
      resp="${resp,,}"
      if [[ -z "${resp}" || "${resp}" == "y" || "${resp}" == "yes" ]]; then
        if ! ensure_cocoapods; then
          error "CocoaPods installation failed"
          suggest_cocoapods_failed 1
          return 1
        fi
      else
        warn "Cannot launch iOS without CocoaPods"
        return 1
      fi
      timer_end "cocoapods_check" "CocoaPods installation"
    fi

    printf "\n${GREEN}${BOLD}✓ All requirements resolved!${RESET}\n\n"
  else
    printf "${GREEN}${BOLD}✓ All checks passed!${RESET}\n\n"
  fi

  # Prepare iOS project
  timer_start "ios_project_prep"
  if ! prepare_ios_project; then
    warn "iOS project preparation incomplete"
  fi
  timer_end "ios_project_prep" "iOS project preparation"

  # Ensure simulator exists and boot it
  info "Checking for iOS simulators..."
  if ! ensure_ios_simulator; then
    error "Failed to prepare iOS simulator"
    return 1
  fi

  # Open Simulator app
  timer_start "open_simulator_app"
  open_simulator_app || true
  timer_end "open_simulator_app" "Opening Simulator.app"

  # Wait for device to be ready with loading animation
  timer_start "wait_for_device"
  if type spinner >/dev/null 2>&1; then
    spinner "Waiting for device to appear in Flutter..." 60 &
    local spinner_pid=$!
    local device_id
    if ! device_id="$(wait_for_device "ios" 60 2 2>/dev/null)"; then
      kill "${spinner_pid}" 2>/dev/null || true
      wait "${spinner_pid}" 2>/dev/null || true
      printf "\r\033[K"  # Clear spinner line
      timer_end "wait_for_device" "Device detection (failed)"
      error "Simulator did not appear in Flutter devices"
      return 1
    fi
    kill "${spinner_pid}" 2>/dev/null || true
    wait "${spinner_pid}" 2>/dev/null || true
    printf "\r\033[K"  # Clear spinner line
    timer_end "wait_for_device" "Device detection"
    ok "Simulator ready: ${device_id}"
  else
    info "Waiting for simulator to appear in Flutter (this may take 30-60 seconds)..."
    local device_id
    if ! device_id="$(wait_for_device "ios" 60 2)"; then
      timer_end "wait_for_device" "Device detection (failed)"
      error "Simulator did not appear in Flutter devices"
      return 1
    fi
    timer_end "wait_for_device" "Device detection"
    ok "Simulator ready: ${device_id}"
  fi

  # Validate device ID
  if ! device_id="$(validate_device_id "${device_id}")"; then
    error "Invalid device ID detected"
    return 1
  fi

  # Launch the app
  timer_end "ios_launch_total" "Total iOS launch preparation"
  printf "\n${GREEN}${BOLD}🚀 Launching RestockR...${RESET}\n\n"
  run_flutter_run -d "${device_id}"
}

guided_android_launch() {
  info "Starting Android Emulator..."

  # Create emulator if needed
  create_android_emulator || true

  # Get list of available emulators
  local android_list=""
  local android_json
  android_json="$(flutter emulators --machine 2>/dev/null || echo "")"

  if command -v python3 >/dev/null 2>&1; then
    android_list="$(RESTOCKR_JSON="${android_json}" python3 - <<'PY'
import json, os
payload = os.environ.get("RESTOCKR_JSON", "").strip()
try:
    data = json.loads(payload) if payload else []
except Exception:
    data = []
android_emus = [emu for emu in data if emu.get("platform") == "android"]
if not android_emus:
    raise SystemExit
for emu in android_emus:
    print(f"{emu.get('id')}")
PY
2>/dev/null)"
  else
    android_list="$(flutter emulators 2>/dev/null | grep -i 'android' | awk '{print $1}' || true)"
  fi

  if [[ -z "${android_list}" ]]; then
    error "No Android emulators available"
    printf "\n${BOLD}Create an emulator in Android Studio first${RESET}\n"
    printf "Tools ▸ Device Manager ▸ Create Device\n\n"
    read -r -p "Open Android Studio now? [y/N] " resp || true
    resp="${resp,,}"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      open -a "Android Studio" 2>/dev/null || true
    fi
    return 1
  fi

  # Get first available emulator
  local emu_id
  emu_id="$(echo "${android_list}" | head -n1)"

  info "Launching emulator: ${emu_id}"
  flutter emulators --launch "${emu_id}" >/dev/null 2>&1 || true

  # Wait for device to be ready with loading animation
  if type spinner >/dev/null 2>&1; then
    spinner "Waiting for emulator to boot..." 120 &
    local spinner_pid=$!
    local device_id
    if ! device_id="$(wait_for_device "android" 120 3 2>/dev/null)"; then
      kill "${spinner_pid}" 2>/dev/null || true
      wait "${spinner_pid}" 2>/dev/null || true
      printf "\r\033[K"  # Clear spinner line
      error "Emulator did not boot in time"
      return 1
    fi
    kill "${spinner_pid}" 2>/dev/null || true
    wait "${spinner_pid}" 2>/dev/null || true
    printf "\r\033[K"  # Clear spinner line
    ok "Emulator ready: ${device_id}"
  else
    info "Waiting for emulator to boot (this may take 1-2 minutes)..."
    local device_id
    if ! device_id="$(wait_for_device "android" 120 3)"; then
      error "Emulator did not boot in time"
      return 1
    fi
    ok "Emulator ready: ${device_id}"
  fi

  # Validate device ID
  if ! device_id="$(validate_device_id "${device_id}")"; then
    error "Invalid device ID detected"
    return 1
  fi

  # Launch the app
  printf "\n${GREEN}${BOLD}🚀 Launching RestockR...${RESET}\n\n"
  run_flutter_run -d "${device_id}"
}

# ============================================================================
# MENU FUNCTIONS
# ============================================================================

show_developer_menu() {
  printf "\n${BOLD}Developer Tools:${RESET}\n"
  printf "  ${GREEN}[1]${RESET} Quick Launch (recommended)\n"
  printf "  ${GREEN}[2]${RESET} Launch on specific device\n"
  printf "  ${BLUE}[3]${RESET} Manage Emulators/Devices\n"
  printf "  ${BLUE}[4]${RESET} Show Flutter devices\n"
  printf "  ${BLUE}[5]${RESET} Run flutter doctor\n"
  printf "  ${YELLOW}[6]${RESET} Run flutter test\n"
  printf "  ${YELLOW}[7]${RESET} Run flutter analyze\n"
  printf "  ${DIM}[8]${RESET} Back to main menu\n\n"
}

developer_menu() {
  # Use enhanced menu header if available
  if type draw_menu_header >/dev/null 2>&1; then
    printf "\n"
    draw_menu_header "${APP_NAME} Developer Menu" "${GREEN}"
    if type status_message >/dev/null 2>&1; then
      status_message "info" "Use Quick Launch [1] for the easiest experience!"
      printf "\n"
    else
      printf "${BOLD}${GREEN}💡 Tip:${RESET} ${DIM}Use Quick Launch [1] for the easiest experience!${RESET}\n\n"
    fi
  else
    printf "\n${GREEN}${BOLD}════════════════════════════════════════${RESET}\n"
    printf "${GREEN}${BOLD}   ${APP_NAME} Developer Menu${RESET}\n"
    printf "${GREEN}${BOLD}════════════════════════════════════════${RESET}\n\n"
    printf "${BOLD}${GREEN}💡 Tip:${RESET} ${DIM}Use Quick Launch [1] for the easiest experience!${RESET}\n\n"
  fi

  while true; do
    show_developer_menu
    read -r -p "Select an option: " choice || true

    case "${choice}" in
      1)
        guided_quick_launch
        ;;
      2)
        run_flutter_run
        ;;
      3)
        launch_emulator_menu
        ;;
      4)
        run_flutter_devices
        ;;
      5)
        run_flutter_doctor
        ;;
      6)
        run_flutter_test
        ;;
      7)
        run_flutter_analyze
        ;;
      8|"")
        return 0
        ;;
      *)
        warn "Unknown option: ${choice}"
        ;;
    esac
  done
}

show_main_menu() {
  local has_install="$1"

  printf "\n${BOLD}RestockR Dev Kit Menu:${RESET}\n"

  if [[ "${has_install}" == "true" ]]; then
    printf "  ${GREEN}[1]${RESET} Launch Developer Menu\n"
    printf "  ${GREEN}[2]${RESET} Emulator Launcher\n"
    printf "  ${BLUE}[3]${RESET} Install/Update Dependencies\n"
    printf "  ${BLUE}[4]${RESET} Check Environment Status\n"
    printf "  ${YELLOW}[5]${RESET} Re-install RestockR Dev Kit\n"
    printf "  ${RED}[6]${RESET} Uninstall RestockR Dev Kit\n"
    printf "  ${DIM}[7]${RESET} Exit\n\n"
  else
    printf "  ${GREEN}[1]${RESET} Install RestockR Dev Kit\n"
    printf "  ${BLUE}[2]${RESET} Check Environment Status\n"
    printf "  ${DIM}[3]${RESET} Exit\n\n"
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  cd "${PROJECT_ROOT}"
  print_header
  info "RestockR Dev Kit Launcher"
  info "Session log: ${LOG_FILE}"

  local has_install auto_launch_done=false

  # Initial status check
  if check_install_status; then
    has_install="true"
    ok "Valid installation detected"
  else
    has_install="false"
    warn "RestockR Dev Kit is not yet installed"
  fi

  update_app_icons

  # Go straight to developer menu if installed
  if [[ "${has_install}" == "true" ]]; then
    # Ensure iOS toolchain status is known
    ensure_ios_toolchain_status || true

    # Show developer menu
    developer_menu
  fi

  # Main menu loop
  while true; do
    # Refresh installation status
    if check_install_status; then
      has_install="true"
    else
      has_install="false"
    fi

    show_main_menu "${has_install}"
    read -r -p "Select an option: " choice || true

    if [[ "${has_install}" == "true" ]]; then
      # Menu for installed systems
      case "${choice}" in
        1)
          developer_menu
          ;;
        2)
          launch_emulator_menu
          ;;
        3)
          info "Updating dependencies..."
          run_pub_get
          if [[ "$(uname -s)" == "Darwin" ]] && [[ "${IOS_TOOLS_AVAILABLE}" == true ]]; then
            prepare_ios_project || warn "iOS project preparation incomplete"
          fi
          ok "Dependencies updated"
          ;;
        4)
          info "Checking environment status..."
          diagnose_dependencies
          ;;
        5)
          warn "This will reinstall the Dev Kit and reset the workspace"
          read -r -p "Continue? [y/N] " resp || true
          resp="${resp,,}"
          if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
            "${SCRIPT_DIR}/install.sh" --force --yes
            ok "Re-installation complete"
          else
            info "Re-installation cancelled"
          fi
          ;;
        6)
          "${SCRIPT_DIR}/uninstall.sh"
          # Refresh status after uninstall
          if ! check_install_status; then
            has_install="false"
          fi
          ;;
        7|"")
          printf "\n${DIM}Thanks for using ${APP_NAME}! Run ./start.sh anytime.${RESET}\n"
          break
          ;;
        *)
          warn "Unknown option: ${choice}"
          ;;
      esac
    else
      # Menu for non-installed systems
      case "${choice}" in
        1)
          "${SCRIPT_DIR}/install.sh"

          # After installation, check if it succeeded
          if check_install_status; then
            has_install="true"
            ok "Installation complete!"

            # Auto-launch after fresh install
            info "Launching development environment..."
            ensure_ios_toolchain_status || true
            if auto_launch_default_environment; then
              auto_launch_done=true
            fi

            # Show developer menu
            developer_menu
          else
            warn "Installation may not have completed successfully"
          fi
          ;;
        2)
          info "Checking environment status..."
          diagnose_dependencies
          ;;
        3|"")
          printf "\n${DIM}Run ./start.sh when ready to install.${RESET}\n"
          break
          ;;
        *)
          warn "Unknown option: ${choice}"
          ;;
      esac
    fi
  done
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
