#!/bin/sh

project_dir=${1:-.}
remote=${2:-origin}

get_es_version() {
    cd $project_dir && git show $1:buildSrc/version.properties | grep '^elasticsearch' | sed 's/elasticsearch[[:blank:]]*=[[:blank:]]*//g'
}

# fetch the latest versions
(cd $project_dir && git fetch $remote)

# next major
next_major_branch=${remote}/master
next_major_version=`get_es_version $next_major_branch`

# next minor
next_minor_branch=${remote}/$((`echo $next_major_version | cut -f1 -d.`-1)).x
next_minor_version=`get_es_version $next_minor_branch`

# next bugfix
next_bugfix_branch=${remote}/`echo $next_minor_version | cut -f1 -d.`.$((`echo $next_minor_version | cut -f2 -d.`-1))
next_bugfix_version=`get_es_version $next_bugfix_branch`

echo "current versions on branches:     $next_major_branch @ $next_major_version, $next_minor_branch @ $next_minor_version, $next_bugfix_branch @ $next_bugfix_version"
echo "tags major new feature:           $next_major_version"
echo "tags for new feature enhancement: $next_major_version $next_minor_version"
echo "    --> also needs merge back into $next_minor_branch"
echo "tags for bugfixes:                $next_major_version $next_minor_version $next_bugfix_version"
echo "    --> also needs merge back into $next_minor_branch, $next_bugfix_branch"
