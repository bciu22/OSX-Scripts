#!/usr/bin/env bash

settingKeys[0]="network.negotiate-auth.delegation-uris"
settingValues[0]="bucksiu.org" 
settingKeys[1]="network.negotiate-auth.trusted-uris"
settingValues[1]="bucksiu.org"

echo "*************************************************************"
echo "***** Updating Preferences in all users FireFox Profiles ****"
echo "*************************************************************"
echo "************************ New Values *************************"
index=0
for setting in "${settingKeys[@]}"
        do
            value=${settingValues[$index]}
            echo "${setting} = ${value}"
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