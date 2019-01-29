#!/bin/sh
set -e

## change the base dir
BASEDIR="/tmp/emqx-rel/deps"

## put the project names here
declare -a projects=("emqx_plugin_template")

SED_REPLACE="sed -i "
case $(sed --help 2>&1) in
    *GNU*) SED_REPLACE="sed -i ";;
    *) SED_REPLACE="sed -i ''";;
esac

msg() {
    echo "\n========================================\n"
    echo $1
    echo "\n========================================\n"
}

if [ -z `hub version` ]; then
    msg "error: cannot found "hub", plz install it first, maybe using 'brew install hub'"
    exit 1
fi

for d in "${projects[@]}"
do
    pdir="$BASEDIR/$d"
    msg "enentering dir $pdir"
    cd "$pdir"

    ## fetch full remote branches
    git remote set-branches origin '*'
    git fetch -v

    git checkout -- .

    ## change the copyright and the deps versions
    msg "change the copyright and the deps versions..."
    git checkout testing
    find . -type f \( -name "*.erl" -o -name "*.hrl" \) -exec $SED_REPLACE -i -e 's/2013-2018/2013-2019/g' {} \;
    find . -type f \( -name "*.erl" -o -name "*.hrl" \) -exec $SED_REPLACE -i -e 's/2018/2013-2019/g' {} \;
    git commit -a -m "Update Copyright" && msg "Update Copyright..."

    $SED_REPLACE -i -e 's/ emqx30/ testing/g' Makefile
    git commit -a -m "Update deps version" && msg "Update deps version to testing..."

    $SED_REPLACE -i -e 's/PROJECT_VERSION = 3.0/PROJECT_VERSION = 3.1/g' Makefile
    git commit -a -m "Update release version to 3.1" && msg "Update release version to 3.1..."
    git push

    ## open pr from branch testing to develop
    msg "open pr from branch testing to develop..."
    git checkout develop && git checkout testing
    pr=`hub pull-request -b develop -m "Update Copyright"`
    open $pr
    read -n 1 -s -r -p "Press any key to confirm merge..."

    ## merge the above pr on develop and update deps versions
    msg "merge the above pr on develop and update deps versions..."
    git checkout develop
    git merge --no-ff testing -m "Merge branch 'testing' into develop"

    $SED_REPLACE -i -e 's/ testing/ develop/g' Makefile
    git commit -a -m "Update deps version" && msg "Update deps version to develop..."
    git push origin develop

    ## open pr from branch develop to release-3.1
    msg "open pr from branch develop to release-3.1 ..."
    git checkout release-3.1 && git checkout develop
    pr=`hub pull-request -b release-3.1 -m "Update Copyright"`
    open $pr
    read -n 1 -s -r -p "Press any key to confirm merge..."

    git checkout release-3.1
    git merge --no-ff develop -m "Merge branch 'develop' into release-3.1"
    $SED_REPLACE -i -e 's/ develop/ release-3.1/g' Makefile
    git commit -a -m "Update deps version" && msg "Update deps version to release-3.1..."
    git push origin release-3.1

done
