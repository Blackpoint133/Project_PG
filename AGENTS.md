# Repository Instructions

- The project uses Godot 4.7.2 Standard and GDScript.
- All work must remain inside this repository.
- Work on one focused task at a time.
- Make minimal, targeted changes.
- Never modify production services or unrelated files.
- Never use destructive commands.
- Never store secrets, credentials, private keys, environment files, or Godot binaries.
- Do not commit generated `.godot` or `.import` directories.
- Do not run `git add`, `git commit`, `git push`, or remote commands unless the user explicitly asks.
- Code, resource names, node names, and code comments must be in English.
- All tracked repository content must be written in English.
- This includes documentation, reports, filenames, directory names, code comments, configuration comments, UI text, branch names, and commit messages.
- Direct conversational responses to the user may be written in Russian.
- Every development task must still have its own report directory: `DEV/reports/{NNN}_{task_name}/`.
- Every report stored in the repository must be written in English.
- Reports must contain: objective; completed changes; exact changed file list; checks actually performed; pending manual checks; known risks or limitations; recommended next step.
- Never claim a test or visual verification that was not actually performed.
- Preserve the future modular player architecture: body, legs, arms, weapon, and jetpack must be separate systems.
- The immediate target is a roughly one-minute playable vertical-slice demo.

## Git policy

- Codex may inspect Git status, history, branches, diffs, and the configured remote.
- Codex may fetch from the existing `origin`.
- Codex may use fast-forward-only pull when synchronization is required.
- After completing and validating an approved task, Codex may stage task-related files, create an English commit, and push the current branch to the existing `origin`.
- Before committing, inspect the diff and confirm that only task-related files are included.
- Commit messages must be concise and written in English.
- Never commit secrets, credentials, environment files, executables, Godot cache files, or unrelated changes.
- Never change credentials or print authentication data.
- Never change remote URLs, force-push, reset shared history, rebase shared history, delete branches or tags, modify GitHub settings, or merge pull requests without explicit user authorization.
- Direct user communication may be Russian, but all tracked repository contents must remain English.
