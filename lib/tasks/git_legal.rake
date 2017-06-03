namespace :git_legal do
  desc "Refresh source files coming from Git.legal"
  task :refresh_source => [:environment] do
    require 'fileutils'

    GIT_LEGAL_MAIN_PROJECT_ROOT = Rails.root.join('..','git.legal','app').to_s
    GIT_LEGAL_CC_ROOT = Rails.root.join('lib','git.legal').to_s

    Dir["#{GIT_LEGAL_CC_ROOT}/**/*"].each do |file|
      next unless File.file? file

      relative_path = file.to_s.gsub GIT_LEGAL_CC_ROOT, ''
      main_project_path = "#{GIT_LEGAL_MAIN_PROJECT_ROOT}#{relative_path}"

      puts "Copying #{main_project_path}..."
      FileUtils.cp main_project_path, file
    end
  end

  task :refresh_db, [:from_db, :to_db] => [:environment] do |task, args|
    require 'yaml_db'

    source_db = args[:from_db] or raise 'Please specify the source and target databases'
    target_db = args[:to_db] or raise 'Please specify the source and target databases'

    # this task runs for a long time...and somehow seems to get SIGHUP even with nohup?! ...so ignore.
    Signal.trap('HUP') do
      # no-op
    end

    # for copying from a cached copy to the new db
    def restore_objects(objs, source_db, target_db)
      return if objs.blank?

      db_load_helper = YamlDb::SerializationHelper::Load
      db_dump_helper = YamlDb::SerializationHelper::Dump

      objs = objs.to_a
      model = objs.first.class

      # flip to new db
      ActiveRecord::Base.establish_connection target_db

      # delete any existing objects
      objs.first.class.delete_all

      table_name = objs.first.class.table_name
      columns = db_dump_helper.table_column_names(table_name)

      data = {}
      data['columns'] = columns
      data['records'] = objs.map do |old_object|
        columns.map {|column| old_object['column']}
      end

      db_load_helper.load_table(table_name, data)

      # flip back to the old db
      ActiveRecord::Base.establish_connection source_db
    end

    ActiveRecord::Base.establish_connection source_db

    projects = Project.where(system: true)
    restore_objects projects, source_db, target_db

    restore_objects Policy.where(project_id: projects.pluck(:id)), source_db, target_db

    branches = Branch.where(project_id: projects.pluck(:id))
    restore_objects branches, source_db, target_db

    created_license_type_ids = {}
    libraries = Library.where(branch_id: branches.pluck(:id))

    i = 0
    total = libraries.count
    libraries.find_in_batches(batch_size: 10000) do |libs|
      puts "Loading library #{i*10000} of #{total}"; STDOUT.flush
      i+=1

      restore_objects libs, source_db, target_db

      puts '...Querying licenses'; STDOUT.flush
      lib_ids = libs.map(&:id)
      licenses = License.where(library_id: lib_ids)

      # only pull license types tied to the licenses we pull in (and not already created)
      puts '...Loading license types'; STDOUT.flush
      license_type_ids = licenses.pluck(:license_type_id)
      uncreated_license_type_ids = license_type_ids.select {|ltid| !created_license_type_ids.has_key? ltid}
      LicenseType.skip_callback :save, :before, :generate_searchable_identifiers
      restore_objects LicenseType.where(id: uncreated_license_type_ids), source_db, target_db
      restore_objects Obligation.where(license_type_id: license_type_ids), source_db, target_db
      restore_objects CopyleftClause.where(license_type_id: license_type_ids), source_db, target_db
      uncreated_license_type_ids.each {|ltid| created_license_type_ids[ltid] = true}

      puts '...Loading licenses'; STDOUT.flush
      restore_objects licenses, source_db, target_db
    end
  end
end
