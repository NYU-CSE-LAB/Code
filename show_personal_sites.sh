for dir in /home/SPRING2017/*/
do
    dir=${dir%*/}
    echo ${dir##*/}
    curl ${dir##*/}.code.engineering.nyu.edu
done
