#!/usr/bin/env bash
# RestockR Log Management Utility
# View, search, export, and manage RestockR logs

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# ============================================================================
# LOG MANAGEMENT COMMANDS
# ============================================================================

show_log_stats() {
  info "RestockR Log Statistics"

  local total_logs compressed_logs uncompressed_logs total_size

  total_logs=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | wc -l | tr -d ' ')
  compressed_logs=$(find "${LOG_DIR}" -type f -name "session_*.log.gz" 2>/dev/null | wc -l | tr -d ' ')
  uncompressed_logs=$(find "${LOG_DIR}" -type f -name "session_*.log" 2>/dev/null | wc -l | tr -d ' ')

  if command -v du >/dev/null 2>&1; then
    total_size=$(du -sh "${LOG_DIR}" 2>/dev/null | awk '{print $1}')
  else
    total_size="unknown"
  fi

  printf "\n"
  printf "${BOLD}Log Directory:${RESET} %s\n" "${LOG_DIR}"
  printf "${BOLD}Total Logs:${RESET} %d\n" "${total_logs}"
  printf "  • Uncompressed: %d\n" "${uncompressed_logs}"
  printf "  • Compressed: %d\n" "${compressed_logs}"
  printf "${BOLD}Disk Usage:${RESET} %s\n" "${total_size}"
  printf "\n"

  if (( total_logs > 0 )); then
    printf "${BOLD}Recent Logs:${RESET}\n"
    find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) -print0 2>/dev/null | \
      xargs -0 ls -lht | head -n 5 | awk '{print "  " $9 " (" $5 ")"}'
    printf "\n"
  fi
}

list_logs() {
  local pattern="${1:-}"

  info "Available Logs"
  printf "\n"

  local log_files
  if [[ -n "${pattern}" ]]; then
    log_files=$(find "${LOG_DIR}" -type f \( -name "*${pattern}*.log" -o -name "*${pattern}*.log.gz" \) 2>/dev/null | sort -r)
  else
    log_files=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | sort -r)
  fi

  if [[ -z "${log_files}" ]]; then
    warn "No logs found${pattern:+ matching pattern: ${pattern}}"
    return 1
  fi

  local count=0
  while IFS= read -r log_file; do
    ((count++))
    local filename size
    filename="$(basename "${log_file}")"
    if command -v stat >/dev/null 2>&1; then
      if stat -f "%z" "${log_file}" >/dev/null 2>&1; then
        size=$(stat -f "%z" "${log_file}" 2>/dev/null)
      else
        size=$(stat -c "%s" "${log_file}" 2>/dev/null)
      fi
      # Convert to human readable
      if (( size > 1048576 )); then
        size="$((size / 1048576))M"
      elif (( size > 1024 )); then
        size="$((size / 1024))K"
      else
        size="${size}B"
      fi
    else
      size="?"
    fi
    printf "  [%2d] %s (%s)\n" "${count}" "${filename}" "${size}"
  done <<< "${log_files}"

  printf "\n"
  ok "Found ${count} log file(s)"
}

compress_logs_manually() {
  if ! command -v gzip >/dev/null 2>&1; then
    error "gzip not available on this system"
    return 1
  fi

  local uncompressed
  uncompressed=$(find "${LOG_DIR}" -type f -name "session_*.log" 2>/dev/null)

  if [[ -z "${uncompressed}" ]]; then
    info "No uncompressed logs to compress"
    return 0
  fi

  local count=0
  while IFS= read -r log_file; do
    if gzip -f "${log_file}" 2>/dev/null; then
      ((count++))
      debug "Compressed: $(basename "${log_file}")"
    else
      warn "Failed to compress: $(basename "${log_file}")"
    fi
  done <<< "${uncompressed}"

  if (( count > 0 )); then
    ok "Compressed ${count} log file(s)"
  else
    warn "No logs were compressed"
  fi
}

clean_old_logs() {
  local days="${1:-30}"

  warn "Cleaning logs older than ${days} days"
  printf "This will permanently delete old log files.\n"
  read -r -p "Continue? [y/N] " resp || true
  resp="${resp,,}"

  if [[ "${resp}" != "y" && "${resp}" != "yes" ]]; then
    info "Cancelled"
    return 0
  fi

  local count=0
  if command -v find >/dev/null 2>&1; then
    while IFS= read -r log_file; do
      if [[ -n "${log_file}" ]]; then
        rm -f "${log_file}" 2>/dev/null && ((count++))
      fi
    done < <(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) -mtime "+${days}" 2>/dev/null)
  fi

  if (( count > 0 )); then
    ok "Deleted ${count} old log file(s)"
  else
    info "No logs older than ${days} days found"
  fi
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================

show_menu() {
  printf "\n${BOLD}RestockR Log Management${RESET}\n\n"
  printf "  ${GREEN}[1]${RESET} Show log statistics\n"
  printf "  ${GREEN}[2]${RESET} List all logs\n"
  printf "  ${GREEN}[3]${RESET} View latest log\n"
  printf "  ${GREEN}[4]${RESET} View specific log\n"
  printf "  ${GREEN}[5]${RESET} Search logs\n"
  printf "  ${GREEN}[6]${RESET} Export logs\n"
  printf "  ${BLUE}[7]${RESET} Compress uncompressed logs\n"
  printf "  ${YELLOW}[8]${RESET} Clean old logs\n"
  printf "  ${DIM}[9]${RESET} Exit\n\n"
}

interactive_menu() {
  while true; do
    show_menu
    read -r -p "Select an option: " choice || true

    case "${choice}" in
      1)
        show_log_stats
        read -r -p "Press Enter to continue..." || true
        ;;
      2)
        list_logs
        read -r -p "Press Enter to continue..." || true
        ;;
      3)
        view_log "latest"
        ;;
      4)
        printf "Enter log identifier (filename or pattern): "
        read -r identifier || true
        if [[ -n "${identifier}" ]]; then
          view_log "${identifier}"
        fi
        ;;
      5)
        printf "Enter search term: "
        read -r term || true
        if [[ -n "${term}" ]]; then
          search_logs "${term}"
          read -r -p "Press Enter to continue..." || true
        fi
        ;;
      6)
        printf "Enter pattern (leave blank for all logs): "
        read -r pattern || true
        printf "Enter output filename (default: restockr_logs_export.txt): "
        read -r output || true
        output="${output:-restockr_logs_export.txt}"
        export_logs "${pattern}" "${output}"
        read -r -p "Press Enter to continue..." || true
        ;;
      7)
        compress_logs_manually
        read -r -p "Press Enter to continue..." || true
        ;;
      8)
        printf "Enter days (delete logs older than this many days): "
        read -r days || true
        days="${days:-30}"
        clean_old_logs "${days}"
        read -r -p "Press Enter to continue..." || true
        ;;
      9|"")
        printf "\n${DIM}Exiting log management${RESET}\n"
        break
        ;;
      *)
        warn "Unknown option: ${choice}"
        ;;
    esac
  done
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  local command="${1:-menu}"
  shift || true

  case "${command}" in
    stats|status)
      show_log_stats
      ;;
    list|ls)
      list_logs "$@"
      ;;
    view|cat)
      view_log "${1:-latest}"
      ;;
    search|grep)
      if [[ $# -eq 0 ]]; then
        error "Search term required"
        printf "Usage: $0 search <term>\n"
        exit 1
      fi
      search_logs "$1"
      ;;
    export)
      export_logs "${1:-}" "${2:-restockr_logs_export.txt}"
      ;;
    compress)
      compress_logs_manually
      ;;
    clean)
      clean_old_logs "${1:-30}"
      ;;
    menu|--menu)
      interactive_menu
      ;;
    --help|-h|help)
      printf "\n${BOLD}RestockR Log Management Utility${RESET}\n\n"
      printf "Usage: $0 [command] [options]\n\n"
      printf "${BOLD}Commands:${RESET}\n"
      printf "  stats         Show log statistics\n"
      printf "  list [pat]    List logs (optionally filter by pattern)\n"
      printf "  view [id]     View log (default: latest)\n"
      printf "  search <term> Search logs for term\n"
      printf "  export [pat]  Export logs to file\n"
      printf "  compress      Compress uncompressed logs\n"
      printf "  clean [days]  Delete logs older than N days (default: 30)\n"
      printf "  menu          Show interactive menu (default)\n"
      printf "  help          Show this help\n\n"
      printf "${BOLD}Examples:${RESET}\n"
      printf "  $0 stats                    # Show log statistics\n"
      printf "  $0 list 20251012            # List logs from Oct 12, 2025\n"
      printf "  $0 view latest              # View most recent log\n"
      printf "  $0 search \"ERROR\"           # Find all errors\n"
      printf "  $0 export                   # Export all logs\n"
      printf "  $0 compress                 # Compress old logs\n"
      printf "  $0 clean 7                  # Delete logs > 7 days old\n\n"
      ;;
    *)
      error "Unknown command: ${command}"
      printf "Run '$0 help' for usage information\n"
      exit 1
      ;;
  esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  print_header
  info "RestockR Log Management"
  info "Log directory: ${LOG_DIR}"
  printf "\n"

  main "$@"
fi
