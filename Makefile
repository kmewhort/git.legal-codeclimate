image:
	docker build -t codeclimate/codeclimate-git.legal .

run: image
	docker run codeclimate/codeclimate-git.legal

run_on_self: image
	codeclimate analyze --dev

run_on_self_html: image
	codeclimate analyze --dev -f html > tmp/run_on_self.html && open tmp/run_on_self.html

production_db:
	bundle exec rake git_legal:refresh_db[rubygems_license_db,git_legal_production,production_rubygems]
	bundle exec rake git_legal:refresh_db[npm_license_db,git_legal_production,production_npm]

