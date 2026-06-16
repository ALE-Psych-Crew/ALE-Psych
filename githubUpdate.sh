echo 'Add all changes to git'

git add .

read -p 'Enter commit name: ' commitMessage

echo 'Running git commit with the provided name...'

git commit -m "$commitMessage"

echo "Pushing to the 'main' branch..."

git push origin main

echo 'Finished!'

read -p 'Press Enter to continue...'