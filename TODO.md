# CodeForge TODO plan

**Goal:** Build a modular, performant, cross-platform code editor/IDE that surpasses VSCode in speed, extensibility, and user experience.

---

## Status Legend
- [ ] Not started
- [~] In progress
- [x] Complete
- [blocked] Blocked
- [deferred] Deferred

---

## Current Progress (from codebase)
- [x] File Explorer (open, browse, refresh, show/hide hidden files)
- [x] Code Editor (syntax highlighting, minimap, markdown preview, context menu)
- [x] Tab Management (open/close tabs, basic tab bar)
- [x] Terminal Pane (integrated terminal per workspace)
- [x] Source Control (basic git status, stage, commit)
- [x] AI Pane (prompt, model selection, response display)
- [x] Command Palette (basic commands, theme toggling)
- [x] Status Bar (basic info)
- [x] Workspace Management (open/add workspace, recent workspaces)
- [x] Settings Service (load/save settings)
- [x] Theme Service (light/dark/ultra-dark, high contrast)
- [x] Resizable Layouts (sidebars, panels, editor splits)
- [x] Keyboard Shortcuts (core toggles, command palette, sidebar, panel)

---

## Core Features
- [~] **Editor**
  - [x] Syntax highlighting (Dart, Python, JS, Markdown, Plaintext)
  - [ ] IntelliSense (auto-complete, signature help, parameter hints)
  - [ ] Code navigation (go to definition, references, symbol search)
  - [ ] Refactoring (rename, extract, inline, etc.)
  - [ ] Code folding (indentation, region markers)
  - [ ] Multi-cursor/multi-selection
  - [ ] Column/box selection
  - [ ] Overtype mode
  - [ ] Compare files (diff view, compare with clipboard/saved)
  - [ ] Formatting (format document/selection, on save/type/paste)
  - [ ] Error/warning squiggles (linting, diagnostics)
  - [ ] Breadcrumbs (file/symbol path navigation)
  - [ ] Sticky Scroll (scope headers at top)
  - [ ] Indent guides
  - [ ] Word wrap, rulers
  - [ ] File encoding support

- [~] **File Explorer**
  - [x] Browse, open, refresh, show/hide hidden files
  - [ ] Create, delete, rename files/folders
  - [ ] Drag and drop (move/copy files/folders)
  - [ ] Multi-selection, context menu actions
  - [ ] Outline view (symbols tree)
  - [ ] Timeline view (local history, git history)

- [~] **Tab/Editor Management**
  - [x] Open/close tabs
  - [ ] Tab reordering, pinning, preview mode
  - [ ] Grid editor layout (vertical/horizontal splits, drag to float)
  - [ ] Floating windows (multi-monitor)
  - [ ] Wrapped tabs
  - [ ] Custom tab labels

- [~] **Panels & Views**
  - [x] Terminal pane
  - [x] Source control pane
  - [x] Output pane
  - [x] Problems panel
  - [ ] Extensions view (marketplace, install/manage)
  - [ ] Run/debug panel
  - [ ] Test panel
  - [ ] Custom views (contributed by extensions)

- [~] **Search**
  - [x] Find/replace in file
  - [ ] Find/replace in selection
  - [ ] Search across files (with glob, regex, include/exclude)
  - [ ] Search editor (results as editable document)
  - [ ] Search/replace history

- [~] **Source Control**
  - [x] Git status, stage, commit
  - [ ] Branch management (create, switch, merge, rebase)
  - [ ] Diff/merge UI
  - [ ] Stash, cherry-pick, revert
  - [ ] Inline blame, history, timeline
  - [ ] Support for other VCS (hg, svn, etc.)

- [~] **Terminal**
  - [x] Integrated terminal (per workspace)
  - [ ] Multiple terminals, split terminals
  - [ ] Terminal profiles (bash, zsh, PowerShell, etc.)
  - [ ] Shell integration (env, cwd, etc.)
  - [ ] Appearance customization

- [~] **Settings & Configuration**
  - [x] Settings service (load/save)
  - [ ] Settings UI (search, edit, per-user/workspace)
  - [ ] Settings sync (cloud, across devices)
  - [ ] Keybindings editor
  - [ ] Profiles (per-project, per-language)

- [~] **Command Palette**
  - [x] Basic commands
  - [ ] All commands (searchable, extensible)
  - [ ] Quick open (files, symbols, recent, etc.)
  - [ ] Command args, context-aware

- [~] **Workspaces**
  - [x] Open/add workspace
  - [x] Recent workspaces
  - [ ] Multi-root workspaces
  - [ ] Workspace trust/security
  - [ ] Workspace settings

- [~] **UI/UX**
  - [x] Resizable split views
  - [x] Light/dark/high contrast/ultra-dark themes
  - [ ] Custom themes (user, extensions)
  - [ ] Custom icons
  - [ ] Accessibility (screen reader, keyboard nav, font scaling)
  - [ ] Zen mode, centered editor
  - [ ] Notifications, Do Not Disturb

---

## Advanced Features
- [ ] **Extensions/Plugins**
  - [ ] Extension API (UI, commands, language, debug, etc.)
  - [ ] Extension marketplace (browse, install, update, remove)
  - [ ] Extension sandboxing/security
  - [ ] Extension settings, contributions

- [ ] **Debugging**
  - [ ] Debug adapters (DAP)
  - [ ] Breakpoints, watch, call stack, variables
  - [ ] Debug console
  - [ ] Launch/attach configs
  - [ ] Inline values, logpoints

- [ ] **Testing**
  - [ ] Test explorer
  - [ ] Run/debug tests
  - [ ] Test output, coverage

- [ ] **Remote Development**
  - [ ] SSH, containers, WSL, Codespaces
  - [ ] Port forwarding
  - [ ] Remote terminals, file sync

- [ ] **Collaboration**
  - [ ] Live share (pair programming)
  - [ ] Chat, comments, presence

- [ ] **Data Science/Notebooks**
  - [ ] Jupyter notebook support
  - [ ] Interactive cells, plots
  - [ ] Variable explorer

---

## Performance & Modularity
- [ ] **Performance**
  - [ ] Startup time profiling/optimization
  - [ ] Editor rendering benchmarks
  - [ ] Large file support
  - [ ] Low memory/CPU mode
  - [ ] Async IO everywhere
  - [ ] Lazy loading of features/views
  - [ ] Fast search/indexing

- [ ] **Modularity**
  - [ ] Plugin-based architecture (core vs. extensions)
  - [ ] Decoupled UI components
  - [ ] Hot reloadable modules
  - [ ] Headless/CLI mode

---

## AI/Next-Gen Features
- [x] AI Pane (prompt, model selection, response)
- [ ] AI code completion (inline, multi-line, context-aware)
- [ ] AI-powered refactoring
- [ ] AI-powered search/replace
- [ ] AI chat (contextual, code-aware)
- [ ] AI test generation
- [ ] AI code review
- [ ] AI-driven documentation
- [ ] AI-powered debugging
- [ ] AI-powered onboarding/tours
- [ ] AI plugin API (extensions can use AI)

---

## Moonshot/Stretch Goals
- [ ] WebAssembly plugin support
- [ ] Cloud sync for everything (settings, extensions, history)
- [ ] Mobile-first/Tablet UI
- [ ] VR/AR code editing
- [ ] Voice coding
- [ ] Customizable workbench (drag/drop UI, layouts)
- [ ] Built-in package manager (npm, pip, pub, etc.)
- [ ] Built-in container/dev environment management
- [ ] Built-in code search engine (like Sourcegraph)
- [ ] Built-in code review/PR UI
- [ ] Built-in project templates/scaffolding

---

## How to Use This File
- Update status markers as you make progress.
- Add notes, blockers, or links to issues as needed.
- Use this as a living document to drive development and prioritize work.

---

*Last updated: 2025-08-11*
