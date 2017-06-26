require 'spec_helper'

describe 'Codeclimate QA' do
  let(:tmp_download_dir) { Dir.mktmpdir }

  describe 'Popular repos' do
    repos = [
      # top ten Github ruby repos, by stars, based on the following query (with non-ruby repos then discarded):
      # https://github.com/search?l=Ruby&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      'rails/rails',
      'jekyll/jekyll',
      'discourse/discourse',
      'gitlabhq/gitlabhq',
      'plataformatec/devise',
      'fastlane/fastlane',
      'huginn/huginn',
      'mitchellh/vagrant',
      'Thibaut/devdocs',
      'jondot/awesome-react-native',

      # js/npm - https://github.com/search?l=JavaScript&o=desc&q=stars:>1&ref=searchresults&s=stars&type=Repositories&utf8=✓
      'freeCodeCamp/freeCodeCamp',
      'twbs/bootstrap',
      'facebook/react',
      'd3/d3',
      'vuejs/vue'
    ]

    repos.each do |repo_name|
      describe repo_name do
        before do
          git_url = "git@github.com:#{repo_name}"
          pull_cmd = "cd #{tmp_download_dir} && git init && git pull --depth=1 #{git_url} master"
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

          puts "------ Result for #{repo_name} ------"
          puts result
          puts "-------------------------------------"

          expect(result).to include 'Analysis complete!'
        end
      end
    end
  end
end
