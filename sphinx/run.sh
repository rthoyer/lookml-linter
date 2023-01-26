

copy contents of this folder to parent folder

sphinx-apidoc -f -P -o tmp/source src
sphinx-apidoc -f -P -o tmp/source src/linter
sphinx-apidoc -f -P -o tmp/source src/linter/rules/
sphinx-apidoc -f -P -o tmp/source src/linter/rules/filerules
sphinx-apidoc -f -P -o tmp/source src/linter/rules/fieldrules
sphinx-apidoc -f -P -o tmp/source src/linter/rules/otherrules

make clean

make html

#mkdir docs

rm -rf docs

mv _build/html docs/

git add docs/

touch docs/.nojekyll

git add docs/.nojekyll

git commit

git push


#create build for pypi

python setup.py sdist bdist_wheel

python -m twine upload --repository-url https://upload.pypi.org/legacy/ dist/*