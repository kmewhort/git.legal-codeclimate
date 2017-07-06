require 'spec_helper'

describe 'Codeclimate QA' do
  before { skip unless ENV['INCLUDE_MANUAL_VERIFICATION_TESTS'] }

  let(:tmp_download_dir) { Dir.mktmpdir }

  describe 'Popular repos' do
    repos = {
      # top ten Github ruby repos, by stars, based on the following query (with non-ruby repos then discarded):
      # https://github.com/search?l=Ruby&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      ruby: [
        'rails/rails',
        'jekyll/jekyll',
        'discourse/discourse',
        'gitlabhq/gitlabhq',
        'plataformatec/devise',
        'fastlane/fastlane',
        'huginn/huginn',
        'mitchellh/vagrant',
        'Thibaut/devdocs',
        'jondot/awesome-react-native'
      ],

      # js/npm - https://github.com/search?l=JavaScript&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      js: [
        'freeCodeCamp/freeCodeCamp',
        'twbs/bootstrap',
        'facebook/react',
        'd3/d3',
        'vuejs/vue'
      ],

      # python - https://github.com/search?l=Python&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      # --but redacted to only ones with a checked-in requirements.txt
      python: [
        'requests/requests',
        'ansible/ansible:devel',
        'scrapy/scrapy'
      ],

      # php - https://github.com/search?l=PHP&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      php: [
        'laravel/laravel',
        'symfony/symfony',
        'bcit-ci/CodeIgniter',
        'domnikl/DesignPatternsPHP',
        'fzaninotto/Faker'
      ]
    }

    repos.each do |type, repos|
      describe type do
        repos.each do |repo_name_and_branch|
          describe repo_name_and_branch do
            before do
              if repo_name_and_branch.include? ':'
                repo_name, branch = repo_name_and_branch.split ':'
              else
                repo_name = repo_name_and_branch
                branch = 'master'
              end

              git_url = "git@github.com:#{repo_name}"
              pull_cmd = "cd #{tmp_download_dir} && git init && git pull --depth=1 #{git_url} #{branch}"
              system(pull_cmd) or raise "Unable to pull remote repository ('#{pull_cmd}' failed)"

              # docker can't connect to /var/folders/ on OSX, so use the project tmpdir; however, for git, need to be
              # outside project
              orig_tmp_dir = ENV['TMPDIR']
              ENV['TMPDIR'] = "#{File.dirname(__FILE__)}/../tmp"
              @tmp_code_dir = Dir.mktmpdir
              ENV['TMPDIR'] = orig_tmp_dir
              `mv #{tmp_download_dir}/* #{@tmp_code_dir}/`

              IO.write "#{@tmp_code_dir}/.codeclimate.yml", <<~YML
              ---
              engines:
                git-legal:
                  enabled: true
              YML
            end

            it "executes successfully" do
              result = `cd #{@tmp_code_dir} && codeclimate analyze --dev -e git-legal`

              puts "------ Result for #{repo_name_and_branch} ------"
              puts result
              puts "-------------------------------------"

              expect(result).to include 'Analysis complete!'
            end
          end
        end
      end
    end
  end
end
