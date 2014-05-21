VERSION = $(shell grep 'VERSION=' deploy.sh | sed 's/VERSION=//' | sed s/\"//g)
DATE = $(shell date)

push: tag
	git push origin --tags master

tag:
	git tag -a ${VERSION} -m "${DATE}"
