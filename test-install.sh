#!/bin/bash
# Tests for install.sh
# Usage: bash test-install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install.sh"
TEST_DIR="/tmp/claude-install-tests"
PASSED=0
FAILED=0

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

setup() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
}

pass() {
    echo -e "  ${GREEN}PASS${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "  ${RED}FAIL${NC} $1: $2"
    FAILED=$((FAILED + 1))
}

assert_file_exists() {
    if [ -f "$1" ]; then
        pass "$2"
    else
        fail "$2" "file not found: $1"
    fi
}

assert_file_not_empty() {
    if [ -s "$1" ]; then
        pass "$2"
    else
        fail "$2" "file is empty: $1"
    fi
}

assert_contains() {
    if echo "$1" | grep -q "$2"; then
        pass "$3"
    else
        fail "$3" "expected to contain '$2'"
    fi
}

assert_not_contains() {
    if echo "$1" | grep -q "$2"; then
        fail "$3" "should not contain '$2'"
    else
        pass "$3"
    fi
}

# ============================================================
echo -e "\n${YELLOW}1. Non-interactive mode uses defaults${NC}"
# ============================================================
setup
HOME="$TEST_DIR/home" mkdir -p "$TEST_DIR/home"
OUTPUT=$(HOME="$TEST_DIR/home" bash "$INSTALL_SCRIPT" < /dev/null 2>&1) || true

assert_contains "$OUTPUT" "Non-interactive mode" "shows non-interactive warning"
assert_contains "$OUTPUT" "Mode: " "echoes selected mode"
assert_contains "$OUTPUT" "project" "defaults to project mode"

# ============================================================
echo -e "\n${YELLOW}2. Project install creates correct structure${NC}"
# ============================================================
setup
mkdir -p "$TEST_DIR/project" && cd "$TEST_DIR/project"
HOME="$TEST_DIR/home" bash "$INSTALL_SCRIPT" < /dev/null 2>&1 > /dev/null

assert_file_exists "$TEST_DIR/project/CLAUDE.md" "CLAUDE.md created"
assert_file_exists "$TEST_DIR/project/.claude/security.md" "security.md created"
assert_file_exists "$TEST_DIR/project/.claude/testing.md" "testing.md created"
assert_file_exists "$TEST_DIR/project/.claude/api-design.md" "api-design.md created"
assert_file_exists "$TEST_DIR/project/.claude/structure.md" "structure.md created"
assert_file_exists "$TEST_DIR/project/.claude/database.md" "database.md created"
assert_file_exists "$TEST_DIR/project/.claude/standards.md" "standards.md created"
assert_file_exists "$TEST_DIR/project/.claude/project-init.md" "project-init.md created"
assert_file_exists "$TEST_DIR/project/.claude/security-review.md" "security-review.md created"
assert_file_exists "$TEST_DIR/project/.claude/skills/commit/SKILL.md" "commit skill created"
assert_file_exists "$TEST_DIR/project/.claude/skills/merge/SKILL.md" "merge skill created"
assert_file_exists "$TEST_DIR/project/.claude/skills/issue/SKILL.md" "issue skill created"
assert_file_exists "$TEST_DIR/project/.claude/skills/review/SKILL.md" "review skill created"

assert_file_not_empty "$TEST_DIR/project/CLAUDE.md" "CLAUDE.md is not empty"
assert_file_not_empty "$TEST_DIR/project/.claude/security.md" "security.md is not empty"

# ============================================================
echo -e "\n${YELLOW}3. Project install updates .gitignore${NC}"
# ============================================================
setup
mkdir -p "$TEST_DIR/project" && cd "$TEST_DIR/project"
echo "node_modules/" > .gitignore
HOME="$TEST_DIR/home" bash "$INSTALL_SCRIPT" < /dev/null 2>&1 > /dev/null

GITIGNORE=$(cat "$TEST_DIR/project/.gitignore")
assert_contains "$GITIGNORE" ".claude/settings.local.json" ".gitignore updated with settings.local.json"
assert_contains "$GITIGNORE" "node_modules" ".gitignore preserves existing entries"

# ============================================================
echo -e "\n${YELLOW}4. Project install skips .gitignore if already has entry${NC}"
# ============================================================
setup
mkdir -p "$TEST_DIR/project" && cd "$TEST_DIR/project"
echo ".claude/settings.local.json" > .gitignore
HOME="$TEST_DIR/home" bash "$INSTALL_SCRIPT" < /dev/null 2>&1 > /dev/null

LINE_COUNT=$(grep -c "settings.local.json" "$TEST_DIR/project/.gitignore")
if [ "$LINE_COUNT" -eq 1 ]; then
    pass ".gitignore not duplicated"
else
    fail ".gitignore not duplicated" "found $LINE_COUNT occurrences"
fi

# ============================================================
echo -e "\n${YELLOW}5. Project install skips .gitignore if none exists${NC}"
# ============================================================
setup
mkdir -p "$TEST_DIR/project" && cd "$TEST_DIR/project"
HOME="$TEST_DIR/home" bash "$INSTALL_SCRIPT" < /dev/null 2>&1 > /dev/null

if [ ! -f "$TEST_DIR/project/.gitignore" ]; then
    pass "no .gitignore created when none existed"
else
    fail "no .gitignore created when none existed" ".gitignore was created"
fi

# ============================================================
echo -e "\n${YELLOW}6. Global install creates correct structure${NC}"
# ============================================================
setup
mkdir -p "$TEST_DIR/home/.claude"
cd "$TEST_DIR"
# Use CLAUDE_INSTALL_RESPONSES: "g" for mode, "n" for attribution
HOME="$TEST_DIR/home" CLAUDE_INSTALL_RESPONSES="g,n" bash "$INSTALL_SCRIPT" < /dev/null 2>&1 > /dev/null || true

assert_file_exists "$TEST_DIR/home/.claude/CLAUDE.md" "global CLAUDE.md created"
assert_file_exists "$TEST_DIR/home/.claude/.claude/security.md" "global security.md in .claude/.claude/"
assert_file_exists "$TEST_DIR/home/.claude/skills/commit/SKILL.md" "global commit skill in skills/"
assert_file_exists "$TEST_DIR/home/.claude/skills/review/SKILL.md" "global review skill in skills/"

# ============================================================
echo -e "\n${YELLOW}7. jq deep merge preserves existing keys${NC}"
# ============================================================
setup
INPUT='{"env":{"FOO":"bar"},"attribution":{"commit":"old","pr":"old","issue":"custom"}}'
RESULT=$(echo "$INPUT" | jq '.attribution.commit = "" | .attribution.pr = ""')

assert_contains "$RESULT" '"issue": "custom"' "deep merge preserves extra attribution keys"
assert_contains "$RESULT" '"commit": ""' "deep merge sets commit to empty"
assert_contains "$RESULT" '"pr": ""' "deep merge sets pr to empty"
assert_contains "$RESULT" '"FOO": "bar"' "deep merge preserves unrelated keys"

# ============================================================
echo -e "\n${YELLOW}8. Attribution success message only on actual success${NC}"
# ============================================================
setup
# Read the install script and check that "Attribution disabled" is inside success branches
SCRIPT_CONTENT=$(cat "$INSTALL_SCRIPT")

# Count occurrences of the success message
SUCCESS_COUNT=$(grep -c "Attribution disabled" "$INSTALL_SCRIPT")
# Count occurrences inside if blocks (after mv or printf)
INSIDE_COUNT=$(grep -B2 "Attribution disabled" "$INSTALL_SCRIPT" | grep -c -E "(mv |printf )")

if [ "$SUCCESS_COUNT" -eq 2 ] && [ "$INSIDE_COUNT" -eq 2 ]; then
    pass "success message only after actual file writes"
else
    fail "success message only after actual file writes" "found $SUCCESS_COUNT messages, $INSIDE_COUNT after writes"
fi

# ============================================================
echo -e "\n${YELLOW}9. No false success when jq missing${NC}"
# ============================================================
setup
# Check that the jq-not-found branch does NOT have "Attribution disabled"
JQ_MISSING_BLOCK=$(sed -n '/jq not found/,/fi/p' "$INSTALL_SCRIPT")
assert_not_contains "$JQ_MISSING_BLOCK" "Attribution disabled" "no false success in jq-missing path"

# ============================================================
echo -e "\n${YELLOW}10. Script uses RED for fatal errors${NC}"
# ============================================================
FATAL_LINE=$(grep "Neither curl nor wget" "$INSTALL_SCRIPT")
assert_contains "$FATAL_LINE" 'RED' "fatal error uses RED color"

# ============================================================
echo -e "\n${YELLOW}11. wget has error handling${NC}"
# ============================================================
WGET_LINE=$(grep "wget -q" "$INSTALL_SCRIPT")
assert_contains "$WGET_LINE" "exit 1" "wget has exit on failure"

# ============================================================
echo -e "\n${YELLOW}12. Attribution defaults to non-destructive${NC}"
# ============================================================
ATTR_LINE=$(grep "Disable commit/PR attribution" "$INSTALL_SCRIPT")
assert_contains "$ATTR_LINE" '"n"' "attribution defaults to n"

# ============================================================
echo -e "\n${YELLOW}13. README accuracy${NC}"
# ============================================================
README="$SCRIPT_DIR/README.md"
README_CONTENT=$(cat "$README")

assert_not_contains "$README_CONTENT" "3 parallel" "no stale '3 parallel reviewers' reference"
assert_not_contains "$README_CONTENT" "BEST_PRACTICES_OFFICIAL" "no reference to non-existent file"
assert_not_contains "$README_CONTENT" "http://bit.ly" "no HTTP bit.ly URLs (should be HTTPS)"
assert_contains "$README_CONTENT" "https://bit.ly" "bit.ly URLs use HTTPS"
assert_contains "$README_CONTENT" "2 parallel" "correct '2 parallel reviewers' count"

# ============================================================
echo -e "\n${YELLOW}14. Overwrite warning for existing global files${NC}"
# ============================================================
WARN_CHECK=$(grep -c "Existing files.*will be overwritten" "$INSTALL_SCRIPT")
if [ "$WARN_CHECK" -ge 1 ]; then
    pass "overwrite warning exists in global install path"
else
    fail "overwrite warning exists in global install path" "warning not found"
fi

# ============================================================
echo -e "\n${YELLOW}15. Syntax check${NC}"
# ============================================================
if bash -n "$INSTALL_SCRIPT" 2>&1; then
    pass "install.sh passes bash -n syntax check"
else
    fail "install.sh passes bash -n syntax check" "syntax error"
fi

# ============================================================
# Summary
# ============================================================
TOTAL=$((PASSED + FAILED))
echo -e "\n================================"
if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}All $TOTAL tests passed${NC}"
else
    echo -e "${RED}$FAILED/$TOTAL tests failed${NC}"
fi
echo -e "================================\n"

cd "$SCRIPT_DIR"
if [ "$FAILED" -eq 0 ]; then
    rm -rf "$TEST_DIR"
else
    echo -e "${YELLOW}Test artifacts preserved at: $TEST_DIR${NC}"
fi
exit "$FAILED"
