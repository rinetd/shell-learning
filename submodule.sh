#!/bin/bash
set -e


## 
submodules=("
git@github.com:zero-os/0-initramfs.git # install-redis
git@github.com:funnysailor/scripts.git # deply-script
git@github.com:StuHorsman/cdh-preinstall.git
git@github.com:likelion/openstack.git
")

remove_submodules=("

")
default_dir=submodules

function parse() {
  url=${1%.git*}    # git@domain:username/filename
  ## 通过解析用户名和文件名
  # git@domain:username/filename.git/dirname@branchname
  if [[ "$1" =~ ^git@ ]]; then
      _uf=${url#*:}     # 从左到右截取到第一个":" username/filename
      user=${_uf%%/*}   # 贪婪模式 从右到左截取到最左端的 "/" username
      file=${_uf##*/}
    elif [[ "$1" =~ ^http ]]; then
      # http://domain/username/filename.git/dirname@branchname
      _uf=${url#*:}
      user=$(basename $(dirname $url))
      file=$(basename $url)
    else
      url="."
    fi
  ## 2. 解析@分支名和子目录名
  # [[ "$branch" == *.git ]] && branch=master
  _bd=${1##*.git} 
  [[ "$_bd" =~ "@" ]] && branch=${_bd#*@} || branch=master
  subdir=${_bd%%@*}
  subdir=${subdir##*/}
  if [[ -n "$subdir" ]]; then
      dir=$subdir/$user/$file
    else
      dir=$default_dir/$user
  fi
  
  
  if [[ "$url" != "." ]];then
    echo " "
    # echo $1
    echo url: $url
    # echo _uf: $_uf
    echo user: $user
    echo file: $file

    # echo _bd:  $_bd
    # echo subdir: $subdir
    echo dir: $dir
    echo branch: $branch
  fi
}


### 1. 移除不需要的 submodules
for url_ext in $remove_submodules; do
  parse $url_ext
  [ -d  ./$dir ] && (echo $dir && git submodule deinit -f $dir && \
                           git rm --cached $dir && \
                           git config -f .gitmodules --remove-section submodule.$dir && \
                           rm -rf $dir .git/modules/$dir )

done

############################# 3. submodules [submodules/user] #######################################

# echo " "
# url=$(dirname $1)
# tmp=$(basename $(dirname $url))        #git@github.com:paulirish
# tmp=${1#*:}    
# user=${tmp%%/*}  ## 从右到左截取到最左端的 "/" , 贪婪模式
# tmp2=${1#*/}
# file=${tmp2%%.git*}
# # file=$(basename $1 .git)             # maupassant-hexo
# branch=$(basename $1)

### 2. 添加新的 submodules
for u in $submodules; do
  parse $u
  [ "$url" == "." ] || [ -d ./$dir ] || git submodule add --force -b $branch $url $dir
done

echo ""
echo "[submodule] update"
# git submodule foreach git pull