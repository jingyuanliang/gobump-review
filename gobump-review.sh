#!/bin/bash

set -exuo pipefail

# shellcheck disable=SC2086
git add ${GOBUMP_REVIEW_FILES_ADD:-.}
# `git diff` returns 0 (success) if no differences.
# shellcheck disable=SC2015
git diff --quiet --exit-code --cached && exit 0 || true

git config user.name "${GOBUMP_REVIEW_NAME:-gobump-review}"
git config user.email "${GOBUMP_REVIEW_EMAIL:-gobump-review@example.com}"

if [[ -n "${GOBUMP_REVIEW_FILE_HASH:-}" ]]; then
  change_id="I$(git hash-object "${GOBUMP_REVIEW_FILE_HASH:-go.mod}")"
else
  change_id="I$(git diff --cached | grep '^+' | git hash-object --stdin)"
fi
git commit -m "
${GOBUMP_REVIEW_MESSAGE_SUBJECT:-}

$(cat "${GOBUMP_REVIEW_MESSAGE_BODY_FILE:-/dev/null}")

Change-Id: ${change_id}
"

push_options=()
for reviewer in ${GOBUMP_REVIEW_REVIEWERS:-}; do
  push_options+=(-o "r=${reviewer}")
done
if [[ -n "${GOBUMP_REVIEW_MESSAGE:-}" ]]; then
  push_options+=(-o "m=${GOBUMP_REVIEW_MESSAGE:-}")
fi
git push "${GOBUMP_REVIEW_REMOTE:-origin}" "HEAD:refs/for/${GOBUMP_REVIEW_BRANCH:-main}" "${push_options[@]}"
