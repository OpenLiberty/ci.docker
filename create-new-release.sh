#!/bin/bash

echo "Hello from the create-new-release.sh script!"
echo $(date)

# Set variables to the positional parameters
OLD_VERSION=$1
NEW_VERSION=$2
BETA_VERSION=$3
BUILD_LABEL=$4

# See if NEW_VERSION and OLD_VERSION fit expected pattern.
if [[ $OLD_VERSION =~ 2[3-9]\.0\.0\.[0-9]+ && $NEW_VERSION =~ 2[3-9]\.0\.0\.[0-9]+ && $BETA_VERSION =~ 2[3-9]\.0\.0\.[0-9]+ ]];
then
   echo "$OLD_VERSION, $NEW_VERSION, and $BETA_VERSION matches expected version format."
else
   echo "Either $OLD_VERSION, $NEW_VERSION, or $BETA_VERSION does not fit expected version format."
   exit 1;
fi

# Get last digit of old version
OLD_SHORT_VERSION=${OLD_VERSION:7}

echo "OLD_VERSION = $OLD_VERSION"
echo "NEW_VERSION = $NEW_VERSION"
echo "BETA_VERSION = $BETA_VERSION"
echo "BUILD_LABEL = $BUILD_LABEL"
echo "OLD_SHORT_VERSION = $OLD_SHORT_VERSION"

echo "Copying latest files to $NEW_VERSION"
cp -r ./releases/latest ./releases/$NEW_VERSION
# Remove the beta subdir from the new release directory.
# There is probably a more efficient way to exclude during a copy.
rm -r ./releases/$NEW_VERSION/beta

# Perform the substitutions in both latest and $NEW_VERSION directories.
for file in $(find ./releases/latest ./releases/$NEW_VERSION -name Dockerfile.*); do
   echo "Processing $file";

   # Do these substitutions only in releases/latest/beta Docker files.
   if [[ "$file" == "./releases/latest/beta/"* ]];
   then
      sed -i'.bak' -e "s/$NEW_VERSION/$BETA_VERSION/" $file;
   fi

   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;
   sed -i'.bak' -e "s/ARG LIBERTY_BUILD_LABEL=.*/ARG LIBERTY_BUILD_LABEL=$BUILD_LABEL/g" $file;

   sed -i'.bak' -e "s/LIBERTY_SHA=.*/LIBERTY_SHA={replace_with_correct_sha}/" $file;
   
   sed -i'.bak' -e "s/FEATURES_SHA=.*/FEATURES_SHA={replace_with_correct_sha}/" $file;

   # Do these substitutions only in $NEW_VERSION, not latest.
   if [[ "$file" == "./releases/$NEW_VERSION/"* ]];
   then
      sed -i'.bak' -e "s/ARG PARENT_IMAGE=icr.io\/appcafe\/open-liberty:kernel-slim/ARG PARENT_IMAGE=icr.io\/appcafe\/open-liberty:$NEW_VERSION-kernel-slim/g" $file;
   fi

   # Clean up temp files
   rm $file.bak

done

# Update the .travis.yml file.
sed -i'.bak' -e "s/RELEASE=\.\.\/releases\/$OLD_VERSION/RELEASE=\.\.\/releases\/$NEW_VERSION/" ./.travis.yml;
rm ./.travis.yml.bak;

# Update the images.txt file
cp ./releases/$OLD_VERSION/images.txt ./releases/$NEW_VERSION/images.txt;
sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./releases/$NEW_VERSION/images.txt;
rm ./releases/$NEW_VERSION/images.txt.bak;

# If the old version is a still supported N-2 quarterly release, keep it.
if [[ $(( $OLD_SHORT_VERSION % 3 )) -eq 0 ]]
  then
      :
  else
      rm -rf ./releases/$OLD_VERSION
  fi

# Finally, comment out "releases/*/*/resources/*" in .gitignore so
# newly created $NEW_VERSION/full/resources and $NEW_VERSION/kernel/resources 
# directories can be committed and pushed.
sed -i'.bak' -e "s/releases\/\*\/\*\/resources\/\*/#releases\/\*\/\*\/resources\/\*/g" .gitignore
rm ./.gitignore.bak

echo "Done performing file updates.";
