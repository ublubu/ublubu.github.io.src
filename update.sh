cd ../ublubu.github.io
mv google*.html ..
rm *.html
rm *.pdf
rm -rf css
rm -rf posts

cp -a ../ublubu.github.io.src/_site/* .
mv ../google*.html .
