image:
	docker build -t codeclimate/codeclimate-git.legal .

test: image
	docker run --rm codeclimate/codeclimate-git.legal sh -c 'cd /usr/src/app && bundle exec rspec'

run: image
	docker run codeclimate/codeclimate-git.legal

run_on_self: image
	codeclimate analyze --dev
