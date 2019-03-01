#!/bin/bash

#set -x
cd /home/ajorians/Temp

rm index.html
wget http://devblog.techsmith.com/feed/

getxml() { # $1 = xml file, $2 = xpath expression
    echo "cat $2" | xmllint --shell $1 |\
    sed -n 's/[^\"]*\"\([^\"]*\)\"[^\"]*/\1/gp'
}

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

filename=$(find index.html)

newerTime=0

lasttimestamp="";
lastpostfile=$(find lastpost.txt)

govfilename=$(date +%Y-%m-%d).dat

value=5

lasttitle1=$(cat /home/ajorians/Temp/lasttitle1);
lasttitle2=$(cat /home/ajorians/Temp/lasttitle2);
lasttitle3=$(cat /home/ajorians/Temp/lasttitle3);
lasttitle4=$(cat /home/ajorians/Temp/lasttitle4);
lasttitle5=$(cat /home/ajorians/Temp/lasttitle5);

currentpost=0;

if [ -n "$lastpostfile" ]; then
   lasttimestamp=$(cat $lastpostfile)
   echo "Last timestamp: $lasttimestamp"
fi

if [ -n "$filename" ]; then
	echo $filename
	fullpath="/home/ajorians/Temp/$filename"
	echo $fullpath

        title="";
        link="";
        pubDate="";
        while read_dom; do
           #echo "Entry: $ENTITY"
           if [[ $ENTITY == "title" ]] ; then
              title=$CONTENT
           elif [[ $ENTITY == "link" ]] ; then
              link=$CONTENT
           elif [[ $ENTITY == "pubDate" ]] ; then
              pubDate=$CONTENT
           fi

           if [ -n "$title" ] && [ -n "$link" ] && [ -n "$pubDate" ]; then

#=========================================================================

              if [ "$title" != "$lasttitle1" ] && [ "$title" != "$lasttitle2" ] && [ "$title" != "$lasttitle3" ] && [ "$title" != "$lasttitle4" ] && [ "$title" != "$lasttitle5" ] ; then

                 currentpost=$(expr $currentpost + 1);

                 if [ $currentpost == 1 ] ; then
                    lasttitle5=$lasttitle4;
                    lasttitle4=$lasttitle3;
                    lasttitle3=$lasttitle2;
                    lasttitle2=$lasttitle1;
                    lasttitle1=$title;
                 elif [ $currentpost == 2 ] ; then
                    lasttitle5=$lasttitle4;
                    lasttitle4=$lasttitle3;
                    lasttitle3=$lasttitle2;
                    lasttitle2=$title;
                 elif [ $currentpost == 3 ] ; then
                    lasttitle5=$lasttitle4;
                    lasttitle4=$lasttitle3;
                    lasttitle3=$title;
                 elif [ $currentpost == 4 ] ; then
                    lasttitle5=$lasttitle4;
                    lasttitle4=$title;
                 elif [ $currentpost == 5 ] ; then
                    lasttitle5=$title;
                 fi

                 echo $lasttitle1 > /home/ajorians/Temp/lasttitle1
                 echo $lasttitle2 > /home/ajorians/Temp/lasttitle2
                 echo $lasttitle3 > /home/ajorians/Temp/lasttitle3
                 echo $lasttitle4 > /home/ajorians/Temp/lasttitle4
                 echo $lasttitle5 > /home/ajorians/Temp/lasttitle5

              else
                 echo "Duplicate title as an existing post"
                 break
              fi

#=========================================================================

              if [ "$pubDate" != "$lasttimestamp" ]; then
                 if [ $newerTime == 0 ]; then
                    echo $pubDate > lastpost.txt;
                    newerTime=1
                 fi
              else
                 echo "No more newer posts"
                 break
              fi

#=========================================================================

              foundfilename=$(find $govfilename)
              if [ -n "$foundfilename" ]; then
                 echo "Has an existing value"
                 value=$(cat $govfilename)
                 value=$(($value-1))

                if [ $value -lt 1 ]; then
                   echo "Stopping writting; too many posts :)"
                   exit 1
                fi

              else
                 echo "File does not exist using default"
              fi

              echo $value > $govfilename

#=========================================================================

              echo "New post"
              echo "Title: $title Link: $link pubDate: $pubDate"

              message="New DevBlog post: [$title]($link)"
              echo "Message: $message"
              /home/ajorians/Documents/Git/DevBlogBot/Build/SimpleFlowdockConsole/SimpleFlowdockConsole --org techsmith --flow development --user a.orians@techsmith.com --password <Withheld> --say "$message"
              #/home/ajorians/Documents/Git/DevBlogBot/Build/SimpleFlowdockConsole/SimpleFlowdockConsole --org aj-org --flow main --user ajorians@gmail.com --password <Withheld> --say "$message"
              
              title="";
              link="";
              pubDate="";
           fi

        done < index.html
fi

#set +x

