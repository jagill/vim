#!/bin/sh
# Usage: ./make_file_taglist.sh
# Makes a file $projectHome/.filenametags that has the filenames for the project in $projectHome in a tag format
# Should upgrade ctags to understand objC: git clone git://git.aeruder.net/ctags-objc.git

if [ -z "$projectHome" ] ; then
    echo Not in a project.
    exit 0
fi

if [ `which exuberant-ctags` ] ; then
    CTAG_CMD=`which exuberant-ctags`
else
    CTAG_CMD=`which ctags`
fi
echo $CTAG_CMD

TAG_FILE=$projectHome/.tags
FILE_NAME_FILE=$projectHome/.filenametags
CSCOPE_FILES_FILE=$projectHome/.cscope.files
CSCOPE_OUT_FILE=$projectHome/.cscope.out

#Strangely, pushd and popd aren't working in ubuntu
HERE=`pwd`
cd $projectHome
$CTAG_CMD -f $TAG_FILE --langmap=java:+.vm --recurse
sed -i .bak '\:build/:d' $TAG_FILE
rm $TAG_FILE.bak
echo "Made tag file"
sed -E '/(^!)|(F$)/!d' $TAG_FILE > $FILE_NAME_FILE
echo "Made filename tag file."
ack -f > $CSCOPE_FILES_FILE
echo "Made cscope file file"
if [ `which cscope` ] ; then
    cscope -b -i $CSCOPE_FILES_FILE -f $CSCOPE_OUT_FILE 
    #echo "Made cscope database"
fi
cd $HERE
