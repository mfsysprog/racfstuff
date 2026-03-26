#!/bin/bash
#
# lu - Wrapper function for the TSO LISTUSER (LU) RACF command
# Usage: lu <userid> [options]
#
# Execute RACF LISTUSER command via tsocmd on z/OS Unix System Services
#

lu() {
    local userid=""
    local options=""
    local show_help=0

    # Display usage information
    _lu_usage() {
        cat <<EOF
Usage: lu <userid> [options]

Wrapper for the TSO LISTUSER (LU) RACF command.

Arguments:
    userid              The RACF user ID to list (required)

Segment Options:
    --all, -a           Display all available segments
    --omvs              Display OMVS segment (UID, GID, home, shell)
    --tso               Display TSO segment
    --cics              Display CICS segment
    --dfp               Display DFP segment
    --language          Display LANGUAGE segment
    --workattr          Display WORKATTR segment
    --dce               Display DCE segment
    --ovm               Display OVM segment
    --lnotes            Display LNOTES (Lotus Notes) segment
    --nds               Display NDS segment
    --kerb              Display KERB (Kerberos) segment
    --proxy             Display PROXY segment
    --eim               Display EIM segment
    --csdata            Display CSDATA (installation-defined data) segment
    --mfa               Display MFA (multi-factor authentication) segment
    --operparm          Display OPERPARM segment
    --netview           Display NETVIEW segment

Other Options:
    --noracf            Display only name and installation data

General Options:
    -h, --help          Display this help message

Examples:
    lu IBMUSER                  # Basic user listing
    lu IBMUSER --omvs           # Show OMVS segment
    lu IBMUSER --all            # Show all segments
    lu IBMUSER --omvs --tso     # Show OMVS and TSO segments
    lu IBMUSER --noracf         # Show only name and install data

EOF
    }

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help=1
                shift
                ;;
            -a|--all)
                # RACF doesn't have an ALL keyword - expand to all segments
                options="${options} CICS DCE DFP EIM KERB LANGUAGE LNOTES NDS NETVIEW OMVS OPERPARM OVM PROXY TSO WORKATTR CSDATA MFA"
                shift
                ;;
            --omvs)
                options="${options} OMVS"
                shift
                ;;
            --tso)
                options="${options} TSO"
                shift
                ;;
            --cics)
                options="${options} CICS"
                shift
                ;;
            --dfp)
                options="${options} DFP"
                shift
                ;;
            --language)
                options="${options} LANGUAGE"
                shift
                ;;
            --workattr)
                options="${options} WORKATTR"
                shift
                ;;
            --dce)
                options="${options} DCE"
                shift
                ;;
            --ovm)
                options="${options} OVM"
                shift
                ;;
            --lnotes)
                options="${options} LNOTES"
                shift
                ;;
            --nds)
                options="${options} NDS"
                shift
                ;;
            --kerb)
                options="${options} KERB"
                shift
                ;;
            --proxy)
                options="${options} PROXY"
                shift
                ;;
            --eim)
                options="${options} EIM"
                shift
                ;;
            --csdata)
                options="${options} CSDATA"
                shift
                ;;
            --mfa)
                options="${options} MFA"
                shift
                ;;
            --operparm)
                options="${options} OPERPARM"
                shift
                ;;
            --netview)
                options="${options} NETVIEW"
                shift
                ;;
            --noracf)
                options="${options} NORACF"
                shift
                ;;
            -*)
                echo "Error: Unknown option: $1" >&2
                echo "Use 'lu --help' for usage information." >&2
                return 1
                ;;
            *)
                if [[ -z "$userid" ]]; then
                    userid="$1"
                else
                    echo "Error: Multiple userids specified: $userid and $1" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done

    # Show help if requested
    if [[ $show_help -eq 1 ]]; then
        _lu_usage
        return 0
    fi

    # Validate userid
    if [[ -z "$userid" ]]; then
        echo "Error: userid is required" >&2
        echo "Use 'lu --help' for usage information." >&2
        return 1
    fi

    # Convert userid to uppercase (RACF requirement)
    userid=$(echo "$userid" | tr '[:lower:]' '[:upper:]')

    # Build and execute the command
    local cmd="LU ${userid}${options}"
    
    # Execute via tsocmd (suppress command echo)
    tsocmd "${cmd}" 2>/dev/null
    return $?
}

# If script is sourced, the function is available
# If script is executed directly, run the function with arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    lu "$@"
fi
