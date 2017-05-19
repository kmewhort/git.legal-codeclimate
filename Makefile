image:
	docker build -t kmewhort/git.legal-codeclimate .

test: image
	docker run --rm kmewhort/git.legal-codeclimate sh -c 'cd /usr/src/app && bundle exec rspec'

run: image
	docker run kmewhort/git.legal-codeclimate
