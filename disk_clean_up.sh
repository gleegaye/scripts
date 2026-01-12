#!/bin/bash
################################################################################
# Disk Cleanup and Analysis Script
# Description: Analyzes disk usage and provides cleanup options
# Author: CSR-Checker Team
# Date: 2026-01-12
################################################################################

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
THRESHOLD_WARNING=70  # Warn if disk usage > 70%
THRESHOLD_CRITICAL=85 # Critical if disk usage > 85%
LOG_FILE="/var/log/disk_cleanup_$(date +%Y%m%d_%H%M%S).log"

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

confirm_action() {
    local message="$1"
    echo -ne "${YELLOW}$message (y/N): ${NC}"
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

human_readable_size() {
    numfmt --to=iec-i --suffix=B "$1" 2>/dev/null || echo "$1 bytes"
}

################################################################################
# Disk Analysis Functions
################################################################################

analyze_disk_usage() {
    print_header "Disk Usage Analysis"

    echo ""
    echo "Current Disk Usage:"
    echo "-------------------"
    df -h / /var /tmp /home 2>/dev/null | grep -v "Filesystem" || df -h /

    echo ""
    echo "Detailed Breakdown:"
    echo "-------------------"

    # Get root partition usage
    ROOT_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    ROOT_AVAILABLE=$(df -h / | tail -1 | awk '{print $4}')

    echo "Root (/) Usage: ${ROOT_USAGE}% (${ROOT_AVAILABLE} available)"

    if [ "$ROOT_USAGE" -ge "$THRESHOLD_CRITICAL" ]; then
        print_error "CRITICAL: Disk usage is above ${THRESHOLD_CRITICAL}%!"
        return 2
    elif [ "$ROOT_USAGE" -ge "$THRESHOLD_WARNING" ]; then
        print_warning "WARNING: Disk usage is above ${THRESHOLD_WARNING}%"
        return 1
    else
        print_success "Disk usage is healthy (below ${THRESHOLD_WARNING}%)"
        return 0
    fi
}

analyze_large_directories() {
    print_header "Top 10 Largest Directories"

    echo ""
    echo "Analyzing... (this may take a moment)"
    echo ""

    # Find largest directories
    du -h --max-depth=2 / 2>/dev/null | sort -rh | head -10 || \
    du -h -d 2 / 2>/dev/null | sort -rh | head -10

    echo ""
}

analyze_large_files() {
    print_header "Top 20 Largest Files"

    echo ""
    echo "Searching for large files... (this may take a moment)"
    echo ""

    # Find files larger than 100MB
    find / -type f -size +100M -exec du -h {} \; 2>/dev/null | sort -rh | head -20 || {
        echo "No files larger than 100MB found"
    }

    echo ""
}

analyze_docker_usage() {
    print_header "Docker Disk Usage"

    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed or not accessible"
        return 1
    fi

    echo ""
    docker system df || {
        print_error "Unable to get Docker disk usage"
        return 1
    }

    echo ""
    echo "Docker Volume Details:"
    docker volume ls -q | while read -r vol; do
        size=$(docker volume inspect "$vol" 2>/dev/null | grep -i mountpoint | cut -d'"' -f4 | xargs du -sh 2>/dev/null | cut -f1)
        echo "  $vol: $size"
    done

    echo ""
}

analyze_logs() {
    print_header "Log File Analysis"

    echo ""
    echo "Large log files (>50MB):"
    echo "------------------------"

    # Common log directories
    LOG_DIRS=(
        "/var/log"
        "/home/WX92SL007QDOC1AP-U/docker4sg/csr-checker"
        "/app/logs"
        "/var/log/gunicorn"
    )

    for dir in "${LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -name "*.log" -size +50M -exec du -h {} \; 2>/dev/null | sort -rh
        fi
    done

    echo ""
    echo "Total log size per directory:"
    echo "-----------------------------"
    for dir in "${LOG_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo "  $dir: $size"
        fi
    done

    echo ""
}

analyze_temp_files() {
    print_header "Temporary Files Analysis"

    echo ""
    echo "Temporary directories usage:"
    echo "----------------------------"

    TEMP_DIRS=(
        "/tmp"
        "/var/tmp"
        "/home/WX92SL007QDOC1AP-U/tmp"
        "/home/WX92SL007QDOC1AP-U/.cache"
    )

    for dir in "${TEMP_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "  $dir: $size ($count files)"
        fi
    done

    echo ""
}

################################################################################
# Cleanup Functions
################################################################################

cleanup_docker() {
    print_header "Docker Cleanup"

    if ! command -v docker &> /dev/null; then
        print_warning "Docker is not installed"
        return 1
    fi

    echo ""
    echo "This will clean up:"
    echo "  - Stopped containers"
    echo "  - Unused networks"
    echo "  - Dangling images"
    echo "  - Build cache"
    echo ""

    if confirm_action "Proceed with Docker cleanup?"; then
        log_action "Starting Docker cleanup"

        echo ""
        print_info "Removing stopped containers..."
        docker container prune -f

        print_info "Removing unused networks..."
        docker network prune -f

        print_info "Removing dangling images..."
        docker image prune -f

        print_info "Removing build cache..."
        docker builder prune -f

        echo ""
        if confirm_action "Also remove unused images (not just dangling)?"; then
            print_info "Removing unused images..."
            docker image prune -a -f
        fi

        if confirm_action "Also remove unused volumes (CAUTION: may delete data)?"; then
            print_warning "This will remove ALL unused volumes!"
            if confirm_action "Are you REALLY sure?"; then
                print_info "Removing unused volumes..."
                docker volume prune -f
            fi
        fi

        echo ""
        print_success "Docker cleanup completed"
        log_action "Docker cleanup completed"

        echo ""
        echo "Space reclaimed:"
        docker system df
    else
        print_info "Docker cleanup cancelled"
    fi
}

cleanup_logs() {
    print_header "Log Cleanup"

    echo ""
    echo "This will:"
    echo "  - Truncate logs larger than 100MB"
    echo "  - Remove logs older than 30 days"
    echo "  - Compress old logs"
    echo ""

    if confirm_action "Proceed with log cleanup?"; then
        log_action "Starting log cleanup"

        # Truncate large logs
        print_info "Truncating large log files (>100MB)..."
        find /var/log -type f -name "*.log" -size +100M 2>/dev/null | while read -r logfile; do
            size_before=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile")
            echo "  Truncating: $logfile ($(human_readable_size "$size_before"))"
            : > "$logfile"
        done

        # Remove old logs
        print_info "Removing logs older than 30 days..."
        find /var/log -type f -name "*.log.*" -mtime +30 -delete 2>/dev/null || true

        # Compress old logs
        print_info "Compressing uncompressed old logs..."
        find /var/log -type f -name "*.log.*" ! -name "*.gz" -mtime +7 2>/dev/null | while read -r logfile; do
            if [ -f "$logfile" ]; then
                echo "  Compressing: $logfile"
                gzip "$logfile" 2>/dev/null || true
            fi
        done

        # Clean specific app logs
        if [ -d "/home/WX92SL007QDOC1AP-U/docker4sg/csr-checker" ]; then
            print_info "Cleaning CSR-Checker logs..."
            find /home/WX92SL007QDOC1AP-U/docker4sg/csr-checker -name "*.log" -mtime +7 -exec gzip {} \; 2>/dev/null || true
            find /home/WX92SL007QDOC1AP-U/docker4sg/csr-checker -name "*.log.gz" -mtime +30 -delete 2>/dev/null || true
        fi

        print_success "Log cleanup completed"
        log_action "Log cleanup completed"
    else
        print_info "Log cleanup cancelled"
    fi
}

cleanup_temp_files() {
    print_header "Temporary Files Cleanup"

    echo ""
    echo "This will remove:"
    echo "  - Files in /tmp older than 7 days"
    echo "  - Python cache files (__pycache__, *.pyc)"
    echo "  - npm/pip cache"
    echo ""

    if confirm_action "Proceed with temp cleanup?"; then
        log_action "Starting temporary files cleanup"

        # Clean /tmp
        print_info "Cleaning /tmp (files older than 7 days)..."
        find /tmp -type f -mtime +7 -delete 2>/dev/null || true
        find /tmp -type d -empty -delete 2>/dev/null || true

        # Clean Python cache
        print_info "Cleaning Python cache files..."
        find /home/WX92SL007QDOC1AP-U -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
        find /home/WX92SL007QDOC1AP-U -type f -name "*.pyc" -delete 2>/dev/null || true
        find /home/WX92SL007QDOC1AP-U -type f -name "*.pyo" -delete 2>/dev/null || true

        # Clean pip cache
        if command -v pip &> /dev/null; then
            print_info "Cleaning pip cache..."
            pip cache purge 2>/dev/null || true
        fi

        # Clean user cache
        if [ -d "/home/WX92SL007QDOC1AP-U/.cache" ]; then
            print_info "Cleaning user cache..."
            size_before=$(du -sh /home/WX92SL007QDOC1AP-U/.cache 2>/dev/null | cut -f1)
            find /home/WX92SL007QDOC1AP-U/.cache -type f -mtime +30 -delete 2>/dev/null || true
            size_after=$(du -sh /home/WX92SL007QDOC1AP-U/.cache 2>/dev/null | cut -f1)
            echo "  Cache: $size_before → $size_after"
        fi

        print_success "Temporary files cleanup completed"
        log_action "Temporary files cleanup completed"
    else
        print_info "Temp cleanup cancelled"
    fi
}

cleanup_package_cache() {
    print_header "Package Cache Cleanup"

    echo ""
    echo "This will clean package manager caches:"
    echo "  - APT cache (Debian/Ubuntu)"
    echo "  - YUM/DNF cache (RedHat/CentOS)"
    echo ""

    if confirm_action "Proceed with package cache cleanup?"; then
        log_action "Starting package cache cleanup"

        # APT cleanup
        if command -v apt-get &> /dev/null; then
            print_info "Cleaning APT cache..."
            sudo apt-get clean 2>/dev/null || apt-get clean 2>/dev/null || true
            sudo apt-get autoclean 2>/dev/null || apt-get autoclean 2>/dev/null || true
            sudo apt-get autoremove -y 2>/dev/null || apt-get autoremove -y 2>/dev/null || true
        fi

        # YUM/DNF cleanup
        if command -v yum &> /dev/null; then
            print_info "Cleaning YUM cache..."
            sudo yum clean all 2>/dev/null || yum clean all 2>/dev/null || true
        elif command -v dnf &> /dev/null; then
            print_info "Cleaning DNF cache..."
            sudo dnf clean all 2>/dev/null || dnf clean all 2>/dev/null || true
        fi

        print_success "Package cache cleanup completed"
        log_action "Package cache cleanup completed"
    else
        print_info "Package cache cleanup cancelled"
    fi
}

cleanup_old_kernels() {
    print_header "Old Kernels Cleanup"

    if ! command -v dpkg &> /dev/null; then
        print_warning "This feature is only available on Debian/Ubuntu systems"
        return 1
    fi

    current_kernel=$(uname -r)
    echo ""
    echo "Current kernel: $current_kernel"
    echo ""
    echo "Installed kernels:"
    dpkg -l 'linux-image-*' | grep '^ii' | awk '{print $2}' || true
    echo ""

    if confirm_action "Remove old kernels (keep current + 1)?"; then
        log_action "Starting old kernels cleanup"

        print_info "Removing old kernels..."
        sudo apt-get autoremove --purge -y 2>/dev/null || {
            print_warning "Unable to remove old kernels (may need sudo)"
        }

        print_success "Old kernels cleanup completed"
        log_action "Old kernels cleanup completed"
    else
        print_info "Kernel cleanup cancelled"
    fi
}

cleanup_database() {
    print_header "Database Cleanup (PostgreSQL)"

    echo ""
    echo "This will:"
    echo "  - VACUUM PostgreSQL databases"
    echo "  - Clean old validation requests (>365 days)"
    echo ""

    if confirm_action "Proceed with database cleanup?"; then
        log_action "Starting database cleanup"

        # Check if we're in docker environment
        if [ -f "/.dockerenv" ]; then
            print_info "Running in Docker container"
            DB_HOST="${DB_HOST:-db}"
        else
            DB_HOST="${DB_HOST:-localhost}"
        fi

        # VACUUM database
        print_info "Running VACUUM on database..."
        docker exec -it $(docker ps -qf "name=postgres") psql -U postgres -c "VACUUM FULL;" 2>/dev/null || {
            print_warning "Unable to VACUUM database (check if PostgreSQL is running)"
        }

        # Clean old records
        print_info "Cleaning old validation requests..."
        docker exec -it $(docker ps -qf "name=django") python manage.py shell <<EOF 2>/dev/null || true
from datetime import timedelta
from django.utils import timezone
from PKI.models import CSRValidationRequest

cutoff_date = timezone.now() - timedelta(days=365)
deleted_count = CSRValidationRequest.objects.filter(created_at__lt=cutoff_date).delete()
print(f"Deleted {deleted_count[0]} old validation requests")
EOF

        print_success "Database cleanup completed"
        log_action "Database cleanup completed"
    else
        print_info "Database cleanup cancelled"
    fi
}

################################################################################
# Main Menu
################################################################################

show_menu() {
    clear
    print_header "Disk Cleanup and Analysis Tool"

    echo ""
    echo "Analysis Options:"
    echo "  1) Full disk analysis"
    echo "  2) Show large directories"
    echo "  3) Show large files"
    echo "  4) Analyze Docker usage"
    echo "  5) Analyze log files"
    echo "  6) Analyze temp files"
    echo ""
    echo "Cleanup Options:"
    echo "  7) Clean Docker (containers, images, cache)"
    echo "  8) Clean logs"
    echo "  9) Clean temp files"
    echo " 10) Clean package cache"
    echo " 11) Clean old kernels (Debian/Ubuntu)"
    echo " 12) Clean database"
    echo ""
    echo " 99) Run FULL cleanup (all options)"
    echo ""
    echo "  0) Exit"
    echo ""
}

run_full_cleanup() {
    print_header "FULL CLEANUP MODE"

    echo ""
    print_warning "This will run ALL cleanup operations!"
    print_warning "Some operations may require sudo privileges"
    echo ""

    if confirm_action "Are you sure you want to proceed?"; then
        log_action "Starting FULL cleanup"

        cleanup_docker
        cleanup_logs
        cleanup_temp_files
        cleanup_package_cache
        cleanup_database

        echo ""
        print_header "Cleanup Summary"
        analyze_disk_usage

        print_success "Full cleanup completed!"
        log_action "Full cleanup completed"
    else
        print_info "Full cleanup cancelled"
    fi
}

main() {
    # Check if running as root for some operations
    if [ "$EUID" -ne 0 ]; then
        print_warning "Some cleanup operations may require root/sudo privileges"
        echo ""
    fi

    while true; do
        show_menu

        echo -ne "${BLUE}Enter your choice: ${NC}"
        read -r choice

        case $choice in
            1) analyze_disk_usage; echo ""; read -p "Press Enter to continue..."; ;;
            2) analyze_large_directories; echo ""; read -p "Press Enter to continue..."; ;;
            3) analyze_large_files; echo ""; read -p "Press Enter to continue..."; ;;
            4) analyze_docker_usage; echo ""; read -p "Press Enter to continue..."; ;;
            5) analyze_logs; echo ""; read -p "Press Enter to continue..."; ;;
            6) analyze_temp_files; echo ""; read -p "Press Enter to continue..."; ;;
            7) cleanup_docker; echo ""; read -p "Press Enter to continue..."; ;;
            8) cleanup_logs; echo ""; read -p "Press Enter to continue..."; ;;
            9) cleanup_temp_files; echo ""; read -p "Press Enter to continue..."; ;;
            10) cleanup_package_cache; echo ""; read -p "Press Enter to continue..."; ;;
            11) cleanup_old_kernels; echo ""; read -p "Press Enter to continue..."; ;;
            12) cleanup_database; echo ""; read -p "Press Enter to continue..."; ;;
            99) run_full_cleanup; echo ""; read -p "Press Enter to continue..."; ;;
            0)
                echo ""
                print_success "Goodbye!"
                log_action "Script ended"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                sleep 1
                ;;
        esac
    done
}

################################################################################
# Entry Point
################################################################################

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG_FILE")"

# Log script start
log_action "Disk cleanup script started"

# Run main function
main
