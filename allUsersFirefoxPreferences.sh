#!/usr/bin/env bash
function findCFGFile
{
    fxPath="/Applications/Firefox.app/Contents/Resources/defaults/pref/*.js"
    regex="filename\", \"(.*)\");"
    filename=0
    for f in $fxPath
    do
        if [[ `cat $f` =~ $regex ]] 
        then
            filename="/Applications/Firefox.app/Contents/Resources/${BASH_REMATCH[1]}"
        fi   
    done
    echo $filename
}
function getCFGFile
{
    cfgFile=$(findCFGFile)
    if [ $cfgFile = 0 ] #cck, or other provisioning is not in user
    then
        cfgFile="/Applications/Firefox.app/Contents/Resources/mozilla.cfg"
        newDefaultsFile="/Applications/Firefox.app/Contents/Resources/defaults/pref/autoconfig.js"
        echo "pref(\"general.config.filename\", \"mozilla.cfg\");" >> $newDefaultsFile
        echo "pref(\"general.config.obscure_value\", 0);" >> $newDefaultsFile
    fi
    if [ ! -f $cfgFile ]
    then
        echo " " >> $cfgFile
    fi
    echo $cfgFile
}

function setLockFirefoxPreference
{
    cfgFile=$(getCFGFile)
    echo "setting locks in ${cfgFile}"
    sed -i '' "/^lock[P|p]ref(\"${1}\".*$/d" "${cfgFile}"
    if [ $3 = 1 ] 
     then
     echo "lockPref(\"$1\", \"$2\");" >> $cfgFile
    fi
}


settingKeys[0]="network.negotiate-auth.delegation-uris"
settingValues[0]="bucksiu.org" 
settingLocked[0]=1
settingKeys[1]="network.negotiate-auth.trusted-uris"
settingValues[1]="bucksiu.org"
settingLocked[1]=1

echo "*************************************************************"
echo "***** Updating Preferences in all users FireFox Profiles ****"
echo "*************************************************************"
echo "************************ New Values *************************"
index=0
for setting in "${settingKeys[@]}"
        do
            value=${settingValues[$index]}
            if [ ${settingLocked[$index]} = 1 ]
            then
                setLockFirefoxPreference $setting $value 1
                echo "${setting} = ${value} locked" 
            else
                setLockFirefoxPreference $setting $value 0
                echo "${setting} = ${value} unlocked"
            fi
            
            ((index++))
        done
echo "*************************************************************"

for user in /Users/*/; do

 echo "Modifying User profile " $user
 
 for fxProf in ${user}Library/Application\ Support/Firefox/Profiles/*; do
    prefFile="${fxProf}/prefs.js"
    if [ -f "${prefFile}" ] 
    then
        index=0
        for setting in "${settingKeys[@]}"
        do
            value=${settingValues[$index]}
            sed -i '' "s/^user_pref(\"${setting}\".*$//g" "${prefFile}"
            echo "user_pref(\"${setting}\", \"${value}\");" >> "${prefFile}"
            ((index++))
        done
    fi
 done
done
echo "*******************************************************"
echo "************************ Done *************************"
echo "*******************************************************"