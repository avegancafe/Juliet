# Sourced by juliet-bootstrap (bash) after your extension is loaded. Define
# extension-setup to run your own steps as the `extension` category, last.
# Run just this step with: juliet-bootstrap --enable=extension
#
# Helpers you can rely on (see Juliet's EXTENSIONS.md):
#   spin "Doing x..." cmd args   run cmd behind a spinner
#   substep "Doing x..."         open a step;  skip "why"  mark it skipped
#   notice / warn "msg"          print a note / warning
#   bootstrap_error "summary" "hint..."   record a failure (doesn't exit)
#   is-macos / is-fedora         OS checks
#   gum-confirm "question?"      yes/no prompt (respects -y / -n)
#   $EXTENSION_DIR               this extension's directory

extension-setup() {
  substep "Saying hello..."
  skip "nothing to do yet"
}
