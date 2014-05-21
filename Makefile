VERSION = $(shell grep 'VERSION=' deploy.sh | sed 's/VERSION=//' | sed s/\"//g)
DATE = $(shell date)

push: tag
	echo "git push origin --tags ${VERSION} master"

tag:
	git tag -a ${VERSION} -m "${DATE}"
