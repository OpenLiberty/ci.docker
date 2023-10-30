#!/bin/bash

echo "Hello from the update.sh script!"
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

# Perform the substitutions in both latest and $NEW_VERSION directories.
for file in $(find ./releases/latest ./releases/$NEW_VERSION -name Dockerfile.*); do
   echo "Processing $file";

   sed -i'.bak' -e "s/$NEW_VERSION/$BETA_VERSION/" releases/latest/beta/Dockerfile.ubuntu.openjdk8;
   sed -i'.bak' -e "s/$NEW_VERSION/$BETA_VERSION/" releases/latest/beta/Dockerfile.ubuntu.openjdk11;
   sed -i'.bak' -e "s/$NEW_VERSION/$BETA_VERSION/" releases/latest/beta/Dockerfile.ubi.openjdk17;
   sed -i'.bak' -e "s/$NEW_VERSION/$BETA_VERSION/" releases/latest/beta/Dockerfile.ubuntu.openjdk17;

   sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/" $file;
   sed -i'.bak' -e "s/ARG LIBERTY_BUILD_LABEL=.*/ARG LIBERTY_BUILD_LABEL=$BUILD_LABEL/g" $file;

   sed -i'.bak' -e "s/LIBERTY_SHA=.*/LIBERTY_SHA={replace_with_correct_sha}/" $file;

   # Clean up temp files
   rm $file.bak

done

# Update the .travis.yml file, which isn't used anymore so why do we keep it around? :(
sed -i'.bak' -e "s/RELEASE=\.\.\/releases\/$OLD_VERSION/RELEASE=\.\.\/releases\/$VERSION/" .travis.yml;

# Update the images.txt filecp ./releases/$OLD_VERSION/images.txt ./releases/$NEW_VERSION/images.txt;
sed -i'.bak' -e "s/$OLD_VERSION/$NEW_VERSION/g" ./releases/$NEW_VERSION/images.txt;
rm ./releases/$NEW_VERSION/images.txt.bak;

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
