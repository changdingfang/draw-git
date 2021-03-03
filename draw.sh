#!/bin/bash
# =======================================================================
#  FileName:     draw.sh
#  Author:       dingfang
#  CreateDate:   2021-03-01 19:31:27
#  ModifyAuthor: dingfang
#  ModifyDate:   2021-03-03 08:03:22
# =======================================================================

source ./draw_conf.sh

########################################################################
########################################################################
# 空字符串表示以当前时间为基准，否则以填写时间的年为基准(必须填写xxxx年一月一号)
begin_year="2020-01-01"
# begin_year=""

# draw 配置
conf=(${i_love_cpp[@]})

# commit因子，commit(次数)=conf(数字)*factor
factor=1
# url
uri="git@github.com:changdingfang"
# remote 仓库
REPO="draw-git-2020"
# remote 分支
BRANCH="main"
########################################################################
########################################################################

scriptdir=`pwd`/$0
rootdir=`dirname ${scriptdir}`

ONE_WEEK=7
week_num=53
week52=364

if [[ -n "${begin_year}" ]]; then
    begin_week=`date -d ${begin_year} +%w`
    end_week=`date -d "${begin_year} + 1 year - 1 day" +%w`
else
    end_week=`date +%w`
    begin_year=`date -d "$((${week52}+${end_week})) days ago" +%Y-%m-%d`
    begin_week=0
fi

function init()
{
    cd ${rootdir}
    if [[ -d ${REPO} ]]; then
        rm -rf ${REPO}
    fi
    git init ${REPO}
    cd ${REPO}
    touch README.md
    git add README.md
    touch draw
    git add draw
}


function push()
{
    cd ${rootdir}/${REPO}
    git branch -M ${BRANCH} 
    git remote add origin ${uri}/${REPO}.git
    git pull origin ${BRANCH}
    git push -u origin ${BRANCH}
}


function draw()
{
    init

    cd ${rootdir}/${REPO}
    let conf_len=${#conf[@]}-7+${end_week}-${begin_week}
    days=0
    while [[ ${days} -le ${conf_len} ]]
    do
        let cal_days=${days}+${begin_week}
        let idx=(${cal_days}%${ONE_WEEK})*${week_num}+${cal_days}/${ONE_WEEK}

        d=${conf[${idx}]}
        if [[ ${d} -le 0 ]]; then
            let days+=1
            continue
        fi

        new_time=`date -d "$(date +"${begin_year}") + ${days} day" +"%Y-%m-%dT10:00:00"`

        n=0
        let d*=${factor}
        while [[ ${n} -lt ${d} ]]
        do
            GIT_AUTHOR_DATE=${new_time} GIT_COMMITTER_DATE=${new_time} git commit --allow-empty -m "draw" > /dev/null
            let n+=1
        done

        let days+=1
    done

    push
}

draw
