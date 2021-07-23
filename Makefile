msg=Updated blog

blog:
	hugo -t beautifulhugo --minify

server:
	hugo -D server

deploy: blog
	git add .
	git commit -m "$(msg)"
	git push
