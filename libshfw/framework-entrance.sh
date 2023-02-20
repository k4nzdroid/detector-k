#!/bin/sh 

set -e

# 定位框架根目录
LIBSHFW_ROOT=$(dirname $(realpath $(find ./ -type f -name '*.flag' -print -quit)))
export LIBSHFW_ROOT

# 加载框架的全部模块
for i in $(find $LIBSHFW_ROOT -type f -name '*.lib.sh')
do
    . $i
done