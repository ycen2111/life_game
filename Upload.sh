git add ./ 
echo "Enter a commit: "
read name
git commit -m "$name" && git push origin master

if [ $? -ne 0 ]; then
read -n 1
exit
fi

echo "Done"
echo "Have a nice day :)"
sleep 1