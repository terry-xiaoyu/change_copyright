# change_copyright
Change the copyright of emqx projects

```shell
1. change first lines of the script file:
## change the base dir
BASEDIR="/tmp/emqx-rel/deps"

## put the project names here
declare -a projects=("emqx_plugin_template")

2. run !
./change_copyright.sh
```
