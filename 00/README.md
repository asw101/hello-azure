# README

## vs code keybindings

See: [keybindings.json](https://github.com/asw101/gist/blob/200200-code-keybindings/vs-code-keybindings/keybindings.json)

Docs for [Integrated Terminal](https://code.visualstudio.com/docs/editor/integrated-terminal) and [runSelectedText](https://code.visualstudio.com/docs/editor/integrated-terminal#_run-selected-text)

## azp

`azp` is a bash function (primarily for macOS) that will open a browser to the `Azure Portal` at the correct `Resource Group`, as defined in the `RESOURCE_GROUP` environment variable (when running `azp`), as a parameter `azp <resource_group>`, or piped in (e.g. `echo resource_group | azpi`).

<https://github.com/asw101/gist/blob/master/200100-azp/azp.sh>

## hub

hub, available via <https://github.com/github/hub>, is "a command line tool that wraps git in order to extend it with extra features and commands that make working with GitHub easier".

`hub browse` will open the current repository and branch in the web interface.

`hub clone` will clone a repository via git. However, if cloning a GitHub repository (e.g. `github/hub`), you need only run `hub clone github.com/hub` rather than a fully-qualified HTTPS or SSH clone command.

See also: `gh`, the GitHub CLI, available from <https://github.com/cli/cli>. Note: not all functionality available in `hub` is available in `gh`, today.