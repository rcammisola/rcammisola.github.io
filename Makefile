msg="Updated blog"

blog:
	hugo -t beautifulhugo

server: blog
	hugo -D server

deploy: blog
	git add .
	git commit -m "$(msg)"
	git push
