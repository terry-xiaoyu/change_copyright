# change_copyright
Change the copyright of emqx projects

### System Requirement
Mac OSX

### Usage
- change first lines of the script file:
```shell
## change the base dir
BASEDIR="/tmp/emqx-rel/deps"

## put the project names here
declare -a projects=("emqx_plugin_template")
```

- run !
```shell
./change_copyright.sh
```

The script stops every time it opens a new PR, and the PR will be opened in your browser for reviewing.
After reviewing the PR, back to the script and press `enter` to confirm the merge.
